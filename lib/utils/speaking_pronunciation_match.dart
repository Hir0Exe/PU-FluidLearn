import 'dart:math' as math;

/// Compara lo que entendió el STT con la frase objetivo (tolerante a acentos del motor).
class SpeakingPronunciationMatch {
  SpeakingPronunciationMatch._();

  static String normalize(String s) {
    var t = s.toLowerCase().trim();
    t = t.replaceAll(RegExp(r"[^\w\s']"), '');
    t = t.replaceAll(RegExp(r'\s+'), ' ');
    return t;
  }

  static bool _fuzzyToken(String heard, String target) {
    if (heard == target) return true;
    if (target.length <= 2) return heard == target;
    if (heard.length < 2) return false;
    final n = math.min(3, math.min(heard.length, target.length));
    if (heard.substring(0, n) == target.substring(0, n)) return true;
    if (heard.contains(target) || target.contains(heard)) return true;
    return false;
  }

  /// [minTokenRatio] fracción mínima de palabras del objetivo que deben aparecer reconocidas.
  static bool isCloseEnough(
    String rawHeard,
    String target, {
    double minTokenRatio = 0.68,
  }) {
    final h = normalize(rawHeard);
    final t = normalize(target);
    if (t.isEmpty) return false;
    if (h.isEmpty) return false;
    if (h == t) return true;
    final hw = h.split(' ').where((w) => w.isNotEmpty).toList();
    final tw = t.split(' ').where((w) => w.isNotEmpty).toList();
    if (tw.isEmpty) return true;
    var matched = 0;
    for (final w in tw) {
      if (w.length <= 2) {
        matched++;
        continue;
      }
      final ok = hw.any((x) => _fuzzyToken(x, w));
      if (ok) matched++;
    }
    return matched / tw.length >= minTokenRatio;
  }
}
