import 'package:flutter/material.dart';

import '../data/user_avatars.dart';
import '../models/user_model.dart';

/// Shows the user avatar: local PNG, legacy upload, or placeholder.
class UserAvatarView extends StatelessWidget {
  const UserAvatarView({
    super.key,
    this.profile,
    this.avatarIndex,
    this.profilePhotoUrl,
    this.size = 48,
    this.showBorder = false,
  });

  final UserModel? profile;
  final int? avatarIndex;
  final String? profilePhotoUrl;
  final double size;
  final bool showBorder;

  int? get _resolvedIndex {
    if (avatarIndex != null &&
        avatarIndex! >= 0 &&
        avatarIndex! < UserAvatars.count) {
      return avatarIndex;
    }
    final fromProfile = profile?.avatarIndex;
    if (fromProfile != null &&
        fromProfile >= 0 &&
        fromProfile < UserAvatars.count) {
      return fromProfile;
    }
    return null;
  }

  String? get _legacyPhotoUrl {
    final url = profilePhotoUrl ?? profile?.profilePhotoUrl;
    if (url == null || url.trim().isEmpty) return null;
    final trimmed = url.trim();
    if (trimmed.startsWith('http://') || trimmed.startsWith('https://')) {
      return trimmed;
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final index = _resolvedIndex;
    final legacyUrl = _legacyPhotoUrl;

    Widget face;
    if (index != null) {
      face = ClipOval(
        child: SizedBox(
          width: size,
          height: size,
          child: Image.asset(
            UserAvatars.assetPathForIndex(index),
            width: size,
            height: size,
            fit: BoxFit.cover,
            errorBuilder: (_, __, ___) => _placeholder(size),
          ),
        ),
      );
    } else if (legacyUrl != null) {
      face = ClipOval(
        child: Image.network(
          legacyUrl,
          width: size,
          height: size,
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) => _placeholder(size),
        ),
      );
    } else {
      face = _placeholder(size);
    }

    if (!showBorder) return face;

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: Colors.white, width: 2),
        boxShadow: const [
          BoxShadow(
            color: Color(0x22000000),
            blurRadius: 6,
            offset: Offset(0, 2),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: face,
    );
  }

  Widget _placeholder(double size) {
    return Container(
      width: size,
      height: size,
      decoration: const BoxDecoration(
        color: Color(0xFFDADDE3),
        shape: BoxShape.circle,
      ),
      child: Icon(
        Icons.person_outline_rounded,
        size: size * 0.45,
        color: const Color(0xFF697386),
      ),
    );
  }
}
