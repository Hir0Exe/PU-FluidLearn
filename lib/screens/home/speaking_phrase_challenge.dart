import 'dart:async' show Timer, unawaited;

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart' show kIsWeb, debugPrint;
import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:record/record.dart';
import 'package:speech_to_text/speech_to_text.dart';
import '../../utils/speaking_pronunciation_match.dart';

/// Flujo Speaking: frase modelo (TTS), grabación local y validación por reconocimiento de voz.
class SpeakingPhraseChallenge extends StatefulWidget {
  const SpeakingPhraseChallenge({
    super.key,
    required this.phrases,
    this.intro,
    required this.accentColor,
    required this.icon,
    required this.onAllPhrasesPassed,
  });

  final List<String> phrases;
  final String? intro;
  final Color accentColor;
  final IconData icon;
  final Future<void> Function() onAllPhrasesPassed;

  @override
  State<SpeakingPhraseChallenge> createState() =>
      _SpeakingPhraseChallengeState();
}

class _SpeakingPhraseChallengeState extends State<SpeakingPhraseChallenge> {
  final _speech = SpeechToText();
  final _recorder = AudioRecorder();
  final _player = AudioPlayer();
  FlutterTts? _tts;

  int _phraseIndex = 0;
  bool _speechReady = false;
  bool _recording = false;
  bool _validating = false;
  String? _recordPath;
  String _heard = '';
  String? _speechError;
  bool _finishing = false;

  String get _current => widget.phrases[_phraseIndex];
  bool get _canRecordFile => !kIsWeb;

  @override
  void initState() {
    super.initState();
    _initSpeech();
    _prepareTts();
  }

  Future<void> _prepareTts() async {
    try {
      final tts = FlutterTts();
      await tts.setLanguage('en-US');
      await tts.setSpeechRate(0.42);
      _tts = tts;
    } catch (e) {
      debugPrint('TTS: $e');
    }
  }

  Future<void> _initSpeech() async {
    final mic = await Permission.microphone.request();
    if (!mic.isGranted) {
      if (mounted) {
        setState(() {
          _speechError =
              'Microphone permission is required to evaluate pronunciation.';
        });
      }
      return;
    }
    final ok = await _speech.initialize(
      onError: (e) {
        if (mounted) {
          setState(() => _speechError = e.errorMsg);
        }
      },
      onStatus: (s) => debugPrint('speech status: $s'),
    );
    if (mounted) {
      setState(() {
        _speechReady = ok;
        if (!ok) {
          _speechError ??= 'Could not initialize speech recognition.';
        }
      });
    }
  }

  Future<void> _playModel() async {
    final tts = _tts;
    if (tts == null) return;
    try {
      await tts.stop();
      await tts.speak(_current);
    } catch (e) {
      debugPrint('TTS speak: $e');
    }
  }

  Future<void> _toggleRecord() async {
    if (!_canRecordFile) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'On web, recording is limited; use Validate Pronunciation with the microphone.',
          ),
        ),
      );
      return;
    }
    if (_recording) {
      final path = await _recorder.stop();
      if (mounted) {
        setState(() {
          _recording = false;
          _recordPath = path ?? _recordPath;
        });
      }
      return;
    }

    final allowed = await _recorder.hasPermission();
    if (!allowed) {
      await Permission.microphone.request();
      return;
    }

    if (_speech.isListening) {
      await _speech.stop();
    }

    final dir = await getTemporaryDirectory();
    final path =
        '${dir.path}/fluidlearn_speak_${DateTime.now().millisecondsSinceEpoch}.m4a';

    try {
      await _recorder.start(
        const RecordConfig(encoder: AudioEncoder.aacLc),
        path: path,
      );
      if (mounted) {
        setState(() {
          _recording = true;
          _recordPath = null;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Could not record: $e')));
      }
    }
  }

  Future<void> _playRecording() async {
    final p = _recordPath;
    if (p == null || p.isEmpty) return;
    try {
      await _player.stop();
      await _player.play(DeviceFileSource(p));
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Could not play recording: $e')));
      }
    }
  }

  Future<void> _runOnAllPassed() async {
    setState(() => _finishing = true);
    try {
      await widget.onAllPhrasesPassed();
    } finally {
      if (mounted) setState(() => _finishing = false);
    }
  }

  Future<void> _validatePronunciation() async {
    if (!_speechReady) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(_speechError ?? 'Speech recognition is not available.'),
        ),
      );
      return;
    }
    if (_recording) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Stop the recording before validating.'),
          backgroundColor: Color(0xFFC67D00),
        ),
      );
      return;
    }
    if (_validating) return;

    await _speech.stop();
    if (!mounted) return;
    setState(() {
      _validating = true;
      _heard = '';
    });

    var evaluated = false;
    Timer? watchdog;

    void finishEval(String words) {
      watchdog?.cancel();
      if (evaluated || !mounted) return;
      evaluated = true;
      unawaited(_speech.stop());
      setState(() {
        _validating = false;
        _heard = words;
      });

      if (words.trim().isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'No audio was captured. Speak near the microphone and try again.',
            ),
            backgroundColor: Color(0xFFC67D00),
          ),
        );
        return;
      }

      if (SpeakingPronunciationMatch.isCloseEnough(words, _current)) {
        if (_phraseIndex + 1 < widget.phrases.length) {
          setState(() {
            _phraseIndex++;
            _heard = '';
            _recordPath = null;
          });
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Very good! Keep going with the next phrase.'),
              backgroundColor: Color(0xFF2E7D4A),
            ),
          );
        } else {
          unawaited(_runOnAllPassed());
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'It didnt match up enough. I heard: "$words". '
              'Try again more clearly, similar to: $_current',
            ),
            backgroundColor: const Color(0xFFC67D00),
          ),
        );
      }
    }

    watchdog = Timer(const Duration(seconds: 32), () {
      if (!mounted || evaluated) return;
      evaluated = true;
      unawaited(_speech.stop());
      setState(() => _validating = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Time expired. Press Validate again and say the full phrase.',
          ),
          backgroundColor: Color(0xFFC67D00),
        ),
      );
    });

    try {
      await _speech.listen(
        onResult: (r) {
          if (!r.finalResult) {
            if (mounted) setState(() => _heard = r.recognizedWords);
            return;
          }
          finishEval(r.recognizedWords);
        },
        listenFor: const Duration(seconds: 28),
        pauseFor: const Duration(seconds: 4),
        localeId: 'en_US',
        listenOptions: SpeechListenOptions(
          listenMode: ListenMode.dictation,
          partialResults: true,
        ),
      );
    } catch (e) {
      if (mounted) {
        setState(() => _validating = false);
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error validating: $e')));
      }
    }
  }

  @override
  void dispose() {
    unawaited(_speech.stop());
    _tts?.stop();
    _player.dispose();
    unawaited(_recorder.dispose());
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        Row(
          children: [
            CircleAvatar(
              backgroundColor: widget.accentColor.withAlpha(40),
              child: Icon(widget.icon, color: widget.accentColor),
            ),
            const SizedBox(width: 12),
            const Expanded(
              child: Text(
                'Speaking: listen to the model, record your audio and validate with the microphone.',
                style: TextStyle(
                  fontSize: 14,
                  color: Color(0xFF5F6F86),
                  height: 1.35,
                ),
              ),
            ),
          ],
        ),
        if (widget.intro != null && widget.intro!.trim().isNotEmpty) ...[
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
              widget.intro!,
              style: const TextStyle(
                fontSize: 15,
                height: 1.45,
                color: Color(0xFF2B374E),
              ),
            ),
          ),
        ],
        const SizedBox(height: 20),
        Text(
          'Phrase ${_phraseIndex + 1} of ${widget.phrases.length}',
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w700,
            color: widget.accentColor,
          ),
        ),
        const SizedBox(height: 10),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
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
          child: Text(
            _current,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: Color(0xFF1D2A44),
              height: 1.35,
            ),
          ),
        ),
        const SizedBox(height: 18),
        Wrap(
          spacing: 10,
          runSpacing: 10,
          children: [
            FilledButton.tonalIcon(
              onPressed: _playModel,
              icon: const Icon(Icons.volume_up_rounded, size: 20),
              label: const Text('Listen to model'),
            ),
            if (_canRecordFile)
              FilledButton.icon(
                onPressed: _finishing ? null : _toggleRecord,
                style: FilledButton.styleFrom(
                  backgroundColor: _recording
                      ? const Color(0xFFC62828)
                      : const Color(0xFF111D33),
                ),
                icon: Icon(_recording ? Icons.stop_rounded : Icons.mic_rounded),
                label: Text(_recording ? 'Stop recording' : 'Record'),
              ),
            if (_canRecordFile && _recordPath != null && !_recording)
              OutlinedButton.icon(
                onPressed: _finishing ? null : _playRecording,
                icon: const Icon(Icons.play_arrow_rounded),
                label: const Text('My recording'),
              ),
            FilledButton.icon(
              onPressed: (_finishing || _validating || !_speechReady)
                  ? null
                  : _validatePronunciation,
              style: FilledButton.styleFrom(
                backgroundColor: const Color(0xFF2E7D4A),
              ),
              icon: _validating
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : const Icon(Icons.record_voice_over_rounded),
              label: Text(
                _validating ? 'Listening…' : 'Validate pronunciation',
              ),
            ),
          ],
        ),
        if (_heard.isNotEmpty) ...[
          const SizedBox(height: 16),
          Text(
            'Recognized: $_heard',
            style: const TextStyle(
              fontSize: 14,
              color: Color(0xFF5F6F86),
              fontStyle: FontStyle.italic,
            ),
          ),
        ],
        if (_speechError != null && !_speechReady) ...[
          const SizedBox(height: 12),
          Text(
            _speechError!,
            style: const TextStyle(color: Color(0xFFB71C1C), fontSize: 13),
          ),
        ],
        if (_finishing) ...[
          const SizedBox(height: 24),
          const Center(child: CircularProgressIndicator()),
        ],
      ],
    );
  }
}
