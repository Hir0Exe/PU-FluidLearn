import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'skill_activity_challenge_screen.dart';

class SkillActivitiesScreen extends StatefulWidget {
  const SkillActivitiesScreen({
    super.key,
    required this.uid,
    required this.skillKey,
    required this.title,
    required this.icon,
    required this.accentColor,
  });

  final String uid;
  final String skillKey;
  final String title;
  final IconData icon;
  final Color accentColor;

  @override
  State<SkillActivitiesScreen> createState() => _SkillActivitiesScreenState();
}

class _SkillActivitiesScreenState extends State<SkillActivitiesScreen> {
  final Set<String> _completedLocally = {};
  StreamSubscription<DocumentSnapshot<Map<String, dynamic>>>? _completedSub;

  @override
  void initState() {
    super.initState();
    _completedSub = FirebaseFirestore.instance
        .collection('users')
        .doc(widget.uid)
        .snapshots()
        .listen((snap) {
          final list = List<String>.from(
            snap.data()?['completedTaskIds'] ?? [],
          );
          if (!mounted) return;
          setState(() {
            _completedLocally
              ..clear()
              ..addAll(list);
          });
        });
  }

  @override
  void dispose() {
    _completedSub?.cancel();
    super.dispose();
  }

  List<_SkillTask> get _tasks {
    switch (widget.skillKey) {
      case 'listening':
        return const [
          _SkillTask(
            id: 'listening_short_audio',
            title: 'Short audio clip',
            subtitle: 'Audio + opción múltiple',
          ),
          _SkillTask(
            id: 'listening_dialogue',
            title: 'Dialogue comprehension',
            subtitle: 'Audio + opción múltiple',
          ),
          _SkillTask(
            id: 'listening_gap',
            title: 'Gap-fill listening',
            subtitle: 'Audio + opción múltiple',
          ),
          _SkillTask(
            id: 'listening_news_blurb',
            title: 'News blurb',
            subtitle: 'Audio + opción múltiple',
          ),
        ];
      case 'speaking':
        return const [
          _SkillTask(
            id: 'speaking_pronunciation',
            title: 'Pronunciation drill',
            subtitle: 'Grabar + validar pronunciación',
          ),
          _SkillTask(
            id: 'speaking_roleplay',
            title: 'Mini role-play',
            subtitle: 'Frases en voz alta (café)',
          ),
          _SkillTask(
            id: 'speaking_picture',
            title: 'Describe the image',
            subtitle: 'Describe la escena en voz alta',
          ),
          _SkillTask(
            id: 'speaking_small_talk',
            title: 'Small talk',
            subtitle: 'Conversación informal oral',
          ),
        ];
      case 'reading':
        return const [
          _SkillTask(
            id: 'reading_skim',
            title: 'Skim a short text',
            subtitle: 'Lectura + opción múltiple',
          ),
          _SkillTask(
            id: 'reading_detail',
            title: 'Detail questions',
            subtitle: 'Lectura + opción múltiple',
          ),
          _SkillTask(
            id: 'reading_vocab',
            title: 'Vocabulary in context',
            subtitle: 'Lectura + opción múltiple',
          ),
          _SkillTask(
            id: 'reading_hours_table',
            title: 'Hours & schedule',
            subtitle: 'Lectura + opción múltiple',
          ),
        ];
      case 'writing':
        return const [
          _SkillTask(
            id: 'writing_sentence',
            title: 'Formal correspondence',
            subtitle: 'Writing · Multiple choice',
          ),
          _SkillTask(
            id: 'writing_paragraph',
            title: 'Academic punctuation',
            subtitle: 'Writing · Multiple choice',
          ),
          _SkillTask(
            id: 'writing_edit',
            title: 'Passive voice',
            subtitle: 'Writing · Multiple choice',
          ),
          _SkillTask(
            id: 'writing_micro_email',
            title: 'Connectors & integrity',
            subtitle: 'Writing · Multiple choice',
          ),
        ];
      default:
        return const [];
    }
  }

  Future<void> _openChallenge(_SkillTask task) async {
    final ok = await Navigator.of(context).push<bool>(
      MaterialPageRoute<bool>(
        builder: (context) => SkillActivityChallengeScreen(
          uid: widget.uid,
          skillKey: widget.skillKey,
          taskId: task.id,
          taskTitle: task.title,
          icon: widget.icon,
          accentColor: widget.accentColor,
        ),
      ),
    );
    if (ok == true && mounted) {
      setState(() => _completedLocally.add(task.id));
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Great job — "${task.title}" is done!'),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F8FE),
      appBar: AppBar(
        title: Text(widget.title),
        backgroundColor: const Color(0xFFF4F8FE),
        foregroundColor: const Color(0xFF1D2A44),
        elevation: 0,
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _tasks.length,
        itemBuilder: (context, i) {
          final task = _tasks[i];
          final done = _completedLocally.contains(task.id);
          return Card(
            margin: const EdgeInsets.only(bottom: 12),
            child: ListTile(
              leading: CircleAvatar(
                backgroundColor: widget.accentColor.withAlpha(40),
                child: Icon(widget.icon, color: widget.accentColor, size: 22),
              ),
              title: Text(task.title),
              subtitle: Text(task.subtitle),
              trailing: done
                  ? const Icon(Icons.check_circle, color: Color(0xFF39CC9F))
                  : FilledButton(
                      onPressed: () => _openChallenge(task),
                      child: const Text('Start'),
                    ),
              onTap: done ? null : () => _openChallenge(task),
            ),
          );
        },
      ),
    );
  }
}

class _SkillTask {
  const _SkillTask({
    required this.id,
    required this.title,
    required this.subtitle,
  });

  final String id;
  final String title;
  final String subtitle;
}
