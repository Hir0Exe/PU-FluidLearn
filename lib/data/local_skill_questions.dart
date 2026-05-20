import 'dart:convert';

import 'package:flutter/services.dart';

import 'skill_activity_quizzes.dart';

/// Loads Reading / Writing quizzes from `assets/data/*.json`.
abstract final class LocalSkillQuestions {
  LocalSkillQuestions._();

  static const _readingAsset = 'assets/data/reading.json';
  static const _writingAsset = 'assets/data/writing.json';

  static bool _loaded = false;

  static Future<void> load() async {
    if (_loaded) return;

    final readingRaw = await rootBundle.loadString(_readingAsset);
    final writingRaw = await rootBundle.loadString(_writingAsset);

    final readingList = (jsonDecode(readingRaw) as List<dynamic>)
        .map((e) => _JsonQuestion.fromMap(e as Map<String, dynamic>))
        .toList();
    final writingList = (jsonDecode(writingRaw) as List<dynamic>)
        .map((e) => _JsonQuestion.fromMap(e as Map<String, dynamic>))
        .toList();

    final quizzes = <String, SkillQuiz>{};

    void put(String taskId, List<_JsonQuestion> items) {
      if (items.isEmpty) return;
      quizzes[taskId] = _buildQuiz(items);
    }

    if (readingList.isNotEmpty) put('reading_skim', [readingList[0]]);
    if (readingList.length > 1) put('reading_detail', [readingList[1]]);
    if (readingList.length > 2) put('reading_vocab', [readingList[2]]);
    if (readingList.length > 3) {
      put(
        'reading_hours_table',
        readingList.sublist(3, readingList.length.clamp(0, 5)),
      );
    }

    if (writingList.isNotEmpty) put('writing_sentence', [writingList[0]]);
    if (writingList.length > 1) put('writing_paragraph', [writingList[1]]);
    if (writingList.length > 2) put('writing_edit', [writingList[2]]);
    if (writingList.length > 3) {
      put(
        'writing_micro_email',
        writingList.sublist(3, writingList.length.clamp(0, 5)),
      );
    }

    registerAssetQuizzes(quizzes);
    _loaded = true;
  }
}

class _JsonQuestion {
  _JsonQuestion({
    required this.question,
    required this.options,
    required this.correctAnswer,
    this.text,
    this.level,
    this.topic,
    this.explanation,
  });

  final String? text;
  final String question;
  final List<String> options;
  final int correctAnswer;
  final String? level;
  final String? topic;
  final String? explanation;

  factory _JsonQuestion.fromMap(Map<String, dynamic> map) {
    return _JsonQuestion(
      text: map['text'] as String?,
      question: (map['question'] as String?)?.trim() ?? '',
      options: (map['options'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          const [],
      correctAnswer: (map['correctAnswer'] as num?)?.toInt() ?? 0,
      level: map['level'] as String?,
      topic: map['topic'] as String?,
      explanation: map['explanation'] as String?,
    );
  }
}

SkillQuiz _buildQuiz(List<_JsonQuestion> items) {
  final first = items.first;
  final introParts = <String>[];

  if (first.level != null && first.level!.isNotEmpty) {
    introParts.add('Level: ${first.level}');
  }
  if (first.topic != null && first.topic!.isNotEmpty) {
    introParts.add('Topic: ${first.topic}');
  }
  if (first.text != null && first.text!.trim().isNotEmpty) {
    introParts.add('Passage:\n\n${first.text!.trim()}');
  }
  if (items.length > 1) {
    introParts.add('${items.length} questions in this activity.');
  }

  final intro = introParts.isEmpty ? null : introParts.join('\n\n');

  return SkillQuiz(
    intro: intro,
    questions: items
        .map(
          (q) => SkillQuizQuestion(
            prompt: q.question,
            choices: q.options,
            correctIndex: q.correctAnswer.clamp(0, q.options.length - 1),
          ),
        )
        .toList(),
  );
}
