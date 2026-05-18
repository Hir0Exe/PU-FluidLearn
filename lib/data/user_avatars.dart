/// Avatares locales en `avatars/avatar_1.png` … `avatar_16.png`.
abstract final class UserAvatars {
  UserAvatars._();

  static const int count = 16;

  /// [index] es 0-based (0 = avatar_1.png).
  static String assetPathForIndex(int index) {
    assert(index >= 0 && index < count);
    return 'avatars/avatar_${index + 1}.png';
  }
}
