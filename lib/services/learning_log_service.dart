import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart' show debugPrint;

import '../data/skill_activity_quizzes.dart' show kAllSkillTaskIds;

/// Registro de racha, notificaciones y completado de actividades por habilidad.
///
/// Las notificaciones viven en **`users/{uid}.feedItems`** (array en el mismo documento)
/// para que basten reglas típicas sobre `users/{userId}` sin subcolección `feed`.
class LearningLogService {
  LearningLogService._();
  static final LearningLogService instance = LearningLogService._();

  final FirebaseFirestore _db = FirebaseFirestore.instance;

  static const Map<String, double> _defaultSkillProgress = {
    'listening': 0.0,
    'speaking': 0.0,
    'reading': 0.0,
    'writing': 0.0,
  };

  static const int _maxFeedItems = 40;

  String _dateKey(DateTime d) {
    return '${d.year.toString().padLeft(4, '0')}-'
        '${d.month.toString().padLeft(2, '0')}-'
        '${d.day.toString().padLeft(2, '0')}';
  }

  List<Map<String, dynamic>> _feedItemsFromData(dynamic raw) {
    if (raw is! List) return [];
    final out = <Map<String, dynamic>>[];
    for (final e in raw) {
      if (e is Map<String, dynamic>) {
        out.add(Map<String, dynamic>.from(e));
      } else if (e is Map) {
        out.add(Map<String, dynamic>.from(e));
      }
    }
    return out;
  }

  void _prependFeedItem(
    List<Map<String, dynamic>> items, {
    required String title,
    required String body,
    required String type,
  }) {
    final id =
        '${DateTime.now().millisecondsSinceEpoch}_${items.length}_${type.hashCode}';
    items.insert(0, {
      'id': id,
      'title': title,
      'body': body,
      'type': type,
      'createdAt': Timestamp.fromDate(DateTime.now()),
    });
    if (items.length > _maxFeedItems) {
      items.removeRange(_maxFeedItems, items.length);
    }
  }

  /// Días de racha y fracción visual (meta semanal de 7 días).
  Stream<({int days, double weekProgress})> watchStreak(String uid) {
    return _db.collection('users').doc(uid).snapshots().map((snap) {
      final data = snap.data() ?? const <String, dynamic>{};
      final days = (data['streakDays'] as num?)?.toInt() ?? 0;
      final weekProgress = (days / 7.0).clamp(0.0, 1.0);
      return (days: days, weekProgress: weekProgress);
    });
  }

  Stream<List<FeedItem>> watchFeed(String uid) {
    return _db.collection('users').doc(uid).snapshots().map((snap) {
      final raw = snap.data()?['feedItems'];
      final list = _feedItemsFromData(raw);
      return list.map(FeedItem.fromMap).toList();
    });
  }

  /// Añade un aviso tipo “profesor publicó material”.
  Future<void> addTeacherActivityNotice({
    required String uid,
    String title = 'New activity from your teacher',
    String body =
        'Your teacher posted new practice material. Check your skills.',
  }) async {
    final userRef = _db.collection('users').doc(uid);
    await _db.runTransaction((tx) async {
      final snap = await tx.get(userRef);
      final data = snap.data() ?? const <String, dynamic>{};
      final items = _feedItemsFromData(data['feedItems']);
      _prependFeedItem(items, title: title, body: body, type: 'teacher');
      tx.set(userRef, {'feedItems': items}, SetOptions(merge: true));
    });
  }

  /// Completa una actividad: progreso, racha, tarea y entrada en [feedItems] (mismo doc).
  Future<void> completeSkillActivity({
    required String uid,
    required String skillKey,
    required String taskId,
    required String taskTitle,
    double progressDelta = 0.12,
  }) async {
    final userRef = _db.collection('users').doc(uid);

    try {
      await _db.runTransaction((tx) async {
        final snap = await tx.get(userRef);
        final data = snap.data() ?? const <String, dynamic>{};

        final completed = List<String>.from(data['completedTaskIds'] ?? []);
        if (completed.contains(taskId)) {
          throw DuplicateTaskException();
        }

        final sp = Map<String, dynamic>.from(
          data['skillProgress'] ?? _defaultSkillProgress,
        );
        final cur = (sp[skillKey] as num?)?.toDouble() ?? 0.0;
        sp[skillKey] = (cur + progressDelta).clamp(0.0, 1.0);

        final today = _dateKey(DateTime.now());
        final yesterday = _dateKey(
          DateTime.now().subtract(const Duration(days: 1)),
        );
        final last = data['streakLastDate'] as String?;
        var streakDays = (data['streakDays'] as num?)?.toInt() ?? 0;

        if (last != today) {
          if (last == null || last.isEmpty) {
            streakDays = 1;
          } else if (last == yesterday) {
            streakDays += 1;
          } else {
            streakDays = 1;
          }
        }

        final feedItems = _feedItemsFromData(data['feedItems']);
        _prependFeedItem(
          feedItems,
          title: 'Activity completed',
          body: 'You completed: $taskTitle',
          type: 'activity',
        );

        tx.set(userRef, {
          'skillProgress': sp,
          'streakDays': streakDays,
          'streakLastDate': today,
          'completedTaskIds': FieldValue.arrayUnion([taskId]),
          'feedItems': feedItems,
        }, SetOptions(merge: true));
      });
    } on DuplicateTaskException {
      rethrow;
    } catch (e) {
      debugPrint('completeSkillActivity error: $e');
      rethrow;
    }
  }

  /// Pone a cero progreso por skill, tareas hechas, racha y [feedItems].
  /// Escribe con [SetOptions.merge], vacía [completedTaskIds] y verifica en el servidor.
  Future<void> resetLearningProgressForTesting(String uid) async {
    final userRef = _db.collection('users').doc(uid);
    final progressMap = <String, dynamic>{
      for (final e in _defaultSkillProgress.entries) e.key: e.value,
    };

    Future<void> pushZeros() async {
      await userRef.set({
        'skillProgress': progressMap,
        'completedTaskIds': <String>[],
        'streakDays': 0,
        'streakLastDate': FieldValue.delete(),
        'feedItems': <Map<String, dynamic>>[],
      }, SetOptions(merge: true));
    }

    await pushZeros();

    try {
      await userRef.update({
        'completedTaskIds': FieldValue.arrayRemove(kAllSkillTaskIds),
      });
    } catch (e) {
      debugPrint('reset arrayRemove: $e');
    }

    await pushZeros();

    try {
      await userRef.update({
        'skillProgress.listening': 0.0,
        'skillProgress.speaking': 0.0,
        'skillProgress.reading': 0.0,
        'skillProgress.writing': 0.0,
        'completedTaskIds': <String>[],
        'streakDays': 0,
      });
    } catch (e) {
      debugPrint('reset dotted update: $e');
    }

    final verify = await userRef.get(const GetOptions(source: Source.server));
    final data = verify.data();
    if (data != null) {
      final raw = data['skillProgress'];
      if (raw is Map) {
        for (final e in _defaultSkillProgress.entries) {
          final v = raw[e.key];
          final d = (v is num) ? v.toDouble() : 0.0;
          if (d > 0.0001) {
            throw FirebaseException(
              plugin: 'cloud_firestore',
              message:
                  'El servidor aún muestra progreso en ${e.key} (${(d * 100).round()}%). '
                  'Comprueba conexión y reglas de Firestore.',
              code: 'reset-verify-failed',
            );
          }
        }
      }
      final done = data['completedTaskIds'];
      if (done is List && done.isNotEmpty) {
        throw FirebaseException(
          plugin: 'cloud_firestore',
          message:
              'No se vaciaron las tareas completadas en el servidor. '
              'Vuelve a intentar o revisa reglas de Firestore.',
          code: 'reset-verify-tasks',
        );
      }
    }
  }
}

class DuplicateTaskException implements Exception {}

class FeedItem {
  FeedItem({
    required this.id,
    required this.title,
    required this.body,
    required this.type,
    required this.createdAt,
  });

  final String id;
  final String title;
  final String body;
  final String type;
  final DateTime? createdAt;

  factory FeedItem.fromMap(Map<String, dynamic> m) {
    final ts = m['createdAt'];
    DateTime? dt;
    if (ts is Timestamp) {
      dt = ts.toDate();
    }
    return FeedItem(
      id: (m['id'] ?? '') as String,
      title: (m['title'] ?? '') as String,
      body: (m['body'] ?? '') as String,
      type: (m['type'] ?? 'activity') as String,
      createdAt: dt,
    );
  }
}
