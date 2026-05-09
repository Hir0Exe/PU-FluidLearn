import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import '../../data/skill_activity_quizzes.dart';
import '../../services/learning_log_service.dart';
import 'speaking_phrase_challenge.dart';

/// Pantalla de reto: escuchar (TTS), MCQ y texto libre; envío al completar respuestas
/// (no se exige acertar todo para registrar la actividad).
class SkillActivityChallengeScreen extends StatefulWidget {
  const SkillActivityChallengeScreen({
    super.key,
    required this.uid,
    required this.skillKey,
    required this.taskId,
    required this.taskTitle,
    required this.icon,
    required this.accentColor,
  });

  final String uid;
  final String skillKey;
  final String taskId;
  final String taskTitle;
  final IconData icon;
  final Color accentColor;

  @override
  State<SkillActivityChallengeScreen> createState() =>
      _SkillActivityChallengeScreenState();
}

class _SkillActivityChallengeScreenState
    extends State<SkillActivityChallengeScreen> {
  final _log = LearningLogService.instance;
  late final SkillQuiz _quiz;
  List<int?> _mcqSelected = [];
  List<TextEditingController?> _textCtrls = [];

  FlutterTts? _tts;
  bool _ttsReady = false;
  bool _submitting = false;

  bool get _needsListen => (_quiz.listenAloudText?.trim().isNotEmpty ?? false);

  bool get _isSpeakingMode =>
      widget.skillKey == 'speaking' &&
      (_quiz.speakPhrases?.isNotEmpty ?? false);

  String get _skillHowItWorks {
    switch (widget.skillKey) {
      case 'listening':
        return 'Listening: escucha el audio (Escuchar) y responde solo con opción múltiple.';
      case 'reading':
        return 'Reading: lee el texto en pantalla y responde con opción múltiple.';
      case 'writing':
        return 'Writing: redacta en los recuadros; no hay audio en estas tareas.';
      case 'speaking':
        return 'Speaking: escucha el modelo, graba y valida tu pronunciación con el micrófono.';
      default:
        return _needsListen
            ? 'Escucha el audio (opcional) y responde todas las preguntas.'
            : 'Responde todas las preguntas antes de enviar.';
    }
  }

  @override
  void initState() {
    super.initState();
    final q = quizForTaskId(widget.taskId);
    final speakingMode =
        widget.skillKey == 'speaking' &&
        q != null &&
        (q.speakPhrases?.isNotEmpty ?? false);

    if (q == null || (!speakingMode && q.questions.isEmpty)) {
      _quiz = SkillQuiz(
        intro: 'Practice activity',
        questions: const [
          SkillQuizQuestion(
            prompt: 'Confirm you reviewed this skill topic.',
            choices: ['Not yet', 'Yes, I am ready to finish'],
            correctIndex: 1,
          ),
        ],
      );
    } else {
      _quiz = q;
    }

    if (_isSpeakingMode) {
      _mcqSelected = [];
      _textCtrls = [];
    } else {
      _mcqSelected = List<int?>.filled(_quiz.questions.length, null);
      _textCtrls = List.generate(_quiz.questions.length, (i) {
        return _quiz.questions[i].isOpenText ? TextEditingController() : null;
      });

      if (_needsListen) {
        WidgetsBinding.instance.addPostFrameCallback((_) => _prepareTts());
      }
    }
  }

  Future<void> _prepareTts() async {
    if (!_needsListen) return;
    try {
      final tts = FlutterTts();
      await tts.setLanguage('en-US');
      await tts.setSpeechRate(0.42);
      // Without this, `speak()` often completes immediately and `setCompletionHandler` never
      // fires on some Android engines — blocking submit forever.
      await tts.awaitSpeakCompletion(true);
      tts.setErrorHandler((_) => debugPrint('TTS error'));
      _tts = tts;
      if (mounted) setState(() => _ttsReady = true);
    } catch (e) {
      debugPrint('TTS init: $e');
      if (mounted) setState(() => _ttsReady = true);
    }
  }

  int _wordCount(String s) {
    final t = s.trim();
    if (t.isEmpty) return 0;
    return t.split(RegExp(r'\s+')).where((w) => w.isNotEmpty).length;
  }

  bool get _allAnswered {
    for (var i = 0; i < _quiz.questions.length; i++) {
      final q = _quiz.questions[i];
      if (q.isOpenText) {
        if (_wordCount(_textCtrls[i]!.text) < q.minWords) return false;
      } else {
        if (_mcqSelected[i] == null) return false;
      }
    }
    return true;
  }

  Future<void> _playListenAloud() async {
    final text = _quiz.listenAloudText?.trim();
    if (text == null || text.isEmpty) return;
    if (_tts == null) await _prepareTts();
    final tts = _tts;
    if (tts == null) return;
    try {
      await tts.stop();
      // Evita quedarse colgado si el motor no completa el Future (algunos Android/PC).
      await tts.speak(text).timeout(const Duration(minutes: 4));
    } on TimeoutException {
      debugPrint('TTS speak timed out');
    } catch (e) {
      debugPrint('TTS speak: $e');
    }
  }

  Future<void> _submit() async {
    if (!_allAnswered) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Responde todas las preguntas (y cumple el mínimo de palabras donde aplica).',
          ),
        ),
      );
      return;
    }

    await _completeActivityToFirestore();
  }

  Future<void> _completeActivityToFirestore() async {
    setState(() => _submitting = true);
    try {
      await _log.completeSkillActivity(
        uid: widget.uid,
        skillKey: widget.skillKey,
        taskId: widget.taskId,
        taskTitle: widget.taskTitle,
      );
      if (!mounted) return;
      Navigator.of(context).pop(true);
    } on DuplicateTaskException {
      if (!mounted) return;
      Navigator.of(context).pop(true);
    } on FirebaseException catch (e) {
      if (!mounted) return;
      setState(() => _submitting = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.message ?? e.code),
          backgroundColor: Colors.red,
        ),
      );
    } catch (e) {
      if (!mounted) return;
      setState(() => _submitting = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('$e'), backgroundColor: Colors.red),
      );
    }
  }

  @override
  void dispose() {
    _tts?.stop();
    for (final c in _textCtrls) {
      c?.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_isSpeakingMode) {
      return Scaffold(
        backgroundColor: const Color(0xFFF4F8FE),
        appBar: AppBar(
          title: Text(widget.taskTitle),
          backgroundColor: const Color(0xFFF4F8FE),
          foregroundColor: const Color(0xFF1D2A44),
          elevation: 0,
        ),
        body: Stack(
          children: [
            SpeakingPhraseChallenge(
              phrases: _quiz.speakPhrases!,
              intro: _quiz.intro,
              accentColor: widget.accentColor,
              icon: widget.icon,
              onAllPhrasesPassed: _completeActivityToFirestore,
            ),
            if (_submitting)
              Container(
                color: Colors.black26,
                child: const Center(child: CircularProgressIndicator()),
              ),
          ],
        ),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF4F8FE),
      appBar: AppBar(
        title: Text(widget.taskTitle),
        backgroundColor: const Color(0xFFF4F8FE),
        foregroundColor: const Color(0xFF1D2A44),
        elevation: 0,
      ),
      bottomNavigationBar: Material(
        color: const Color(0xFFF4F8FE),
        elevation: 12,
        shadowColor: Colors.black26,
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 10, 20, 12),
            child: SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: _submitting ? null : _submit,
                style: FilledButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  backgroundColor: const Color(0xFF111D33),
                  foregroundColor: Colors.white,
                  disabledBackgroundColor: const Color(0xFF111D33),
                  disabledForegroundColor: Color(0xFF9AA4B8),
                ),
                child: _submitting
                    ? const SizedBox(
                        height: 22,
                        width: 22,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Text('Enviar respuestas'),
              ),
            ),
          ),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
        children: [
          Row(
            children: [
              CircleAvatar(
                backgroundColor: widget.accentColor.withAlpha(40),
                child: Icon(widget.icon, color: widget.accentColor),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  _skillHowItWorks,
                  style: const TextStyle(
                    fontSize: 14,
                    color: Color(0xFF5F6F86),
                    height: 1.35,
                  ),
                ),
              ),
            ],
          ),
          if (_needsListen) ...[
            const SizedBox(height: 16),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFFE0E6EF)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      FilledButton.tonalIcon(
                        onPressed: _ttsReady ? _playListenAloud : null,
                        icon: const Icon(Icons.volume_up_rounded, size: 20),
                        label: Text(_ttsReady ? 'Escuchar' : 'Preparando…'),
                      ),
                      const SizedBox(width: 12),
                      const Expanded(
                        child: Text(
                          'Pulsa Escuchar para oír el texto (opcional). '
                          'Puedes enviar cuando todas las preguntas tengan respuesta.',
                          style: TextStyle(
                            fontSize: 13,
                            color: Color(0xFF5F6F86),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
          if (_quiz.intro != null && _quiz.intro!.trim().isNotEmpty) ...[
            const SizedBox(height: 16),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFFE0E6EF)),
              ),
              child: Text(
                _quiz.intro!,
                style: const TextStyle(
                  fontSize: 15,
                  height: 1.45,
                  color: Color(0xFF2B374E),
                ),
              ),
            ),
          ],
          const SizedBox(height: 20),
          for (var i = 0; i < _quiz.questions.length; i++) ...[
            if (_quiz.questions[i].isOpenText)
              _OpenTextBlock(
                index: i + 1,
                question: _quiz.questions[i],
                controller: _textCtrls[i]!,
                accent: widget.accentColor,
                wordCount: _wordCount,
                onChanged: () => setState(() {}),
              )
            else
              _QuestionBlock(
                index: i + 1,
                question: _quiz.questions[i],
                groupValue: _mcqSelected[i],
                accent: widget.accentColor,
                onChanged: (v) => setState(() => _mcqSelected[i] = v),
              ),
            const SizedBox(height: 16),
          ],
          const SizedBox(height: 80),
        ],
      ),
    );
  }
}

class _OpenTextBlock extends StatelessWidget {
  const _OpenTextBlock({
    required this.index,
    required this.question,
    required this.controller,
    required this.accent,
    required this.wordCount,
    required this.onChanged,
  });

  final int index;
  final SkillQuizQuestion question;
  final TextEditingController controller;
  final Color accent;
  final int Function(String) wordCount;
  final VoidCallback onChanged;

  @override
  Widget build(BuildContext context) {
    final n = wordCount(controller.text);
    final ok = n >= question.minWords;
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(13),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Pregunta $index — escribe',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: accent,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            question.prompt,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Color(0xFF1D2A44),
              height: 1.3,
            ),
          ),
          const SizedBox(height: 10),
          TextField(
            controller: controller,
            onChanged: (_) => onChanged(),
            minLines: 4,
            maxLines: 8,
            decoration: InputDecoration(
              hintText: 'Escribe aquí…',
              filled: true,
              fillColor: const Color(0xFFF8FAFD),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: const BorderSide(color: Color(0xFFE0E6EF)),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide(
                  color: ok ? const Color(0xFFB8D4C0) : const Color(0xFFE0E6EF),
                ),
              ),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '$n / ${question.minWords} palabras mín.',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: ok ? const Color(0xFF2E7D4A) : const Color(0xFF8A96A8),
            ),
          ),
        ],
      ),
    );
  }
}

class _QuestionBlock extends StatelessWidget {
  const _QuestionBlock({
    required this.index,
    required this.question,
    required this.groupValue,
    required this.accent,
    required this.onChanged,
  });

  final int index;
  final SkillQuizQuestion question;
  final int? groupValue;
  final Color accent;
  final ValueChanged<int?> onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(13),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Pregunta $index',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: accent,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            question.prompt,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Color(0xFF1D2A44),
              height: 1.3,
            ),
          ),
          const SizedBox(height: 10),
          ...List.generate(question.choices.length, (j) {
            final selected = groupValue == j;
            return Padding(
              padding: const EdgeInsets.only(bottom: 6),
              child: InkWell(
                onTap: () => onChanged(j),
                borderRadius: BorderRadius.circular(8),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 10,
                  ),
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: selected ? accent : const Color(0xFFE0E6EF),
                    ),
                    borderRadius: BorderRadius.circular(8),
                    color: selected ? accent.withAlpha(28) : null,
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(
                        selected
                            ? Icons.radio_button_checked
                            : Icons.radio_button_off,
                        color: accent,
                        size: 22,
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          question.choices[j],
                          style: const TextStyle(fontSize: 14, height: 1.35),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          }),
        ],
      ),
    );
  }
}
