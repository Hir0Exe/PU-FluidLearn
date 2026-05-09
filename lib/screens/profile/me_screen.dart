import 'package:flutter/material.dart';
import '../../app_state.dart';
import '../../services/auth_service.dart';
import '../../theme/fluidlearn_colors.dart';
import '../auth/complete_profile_screen.dart';
import '../home/simple_home_screen.dart';
import 'profile_option_screens.dart';
import 'reset_learning_progress_dialog.dart';

class MeScreen extends StatelessWidget {
  const MeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F8FE),
      body: SafeArea(
        child: Stack(
          children: [
            ListenableBuilder(
              listenable: authController,
              builder: (context, _) {
                final profile = authController.appUser;
                final fullName = profile?.fullName ?? 'Usuario';
                final email =
                    authController.currentUser?.email ?? 'correo@ejemplo.com';
                final photoUrl = profile?.profilePhotoUrl?.trim();
                final bioText = profile?.bio.trim() ?? '';
                final showBio = bioText.isNotEmpty;

                return SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(16, 20, 16, 120),
                  child: Column(
                    children: [
                      Container(
                        width: 102,
                        height: 102,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 2),
                          boxShadow: const [
                            BoxShadow(
                              color: Color(0x22000000),
                              blurRadius: 8,
                              offset: Offset(0, 4),
                            ),
                          ],
                        ),
                        clipBehavior: Clip.antiAlias,
                        child: CircleAvatar(
                          key: ValueKey<String>(photoUrl ?? ''),
                          radius: 51,
                          backgroundColor: const Color(0xFFDADDE3),
                          backgroundImage: photoUrl != null && photoUrl.isNotEmpty
                              ? NetworkImage(photoUrl)
                              : null,
                          child: photoUrl == null || photoUrl.isEmpty
                              ? const Icon(
                                  Icons.person_outline_rounded,
                                  color: Color(0xFF697386),
                                  size: 38,
                                )
                              : null,
                        ),
                      ),
                      const SizedBox(height: 14),
                      Text(
                        fullName,
                        style: const TextStyle(
                          fontSize: 30,
                          color: FluidLearnColors.brandBlue,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        email,
                        style: const TextStyle(
                          color: Color(0xFF97A3B5),
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        showBio
                            ? bioText
                            : 'Passionate about language learning',
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          color: Color(0xFF667389),
                          fontSize: 13,
                        ),
                      ),
                  const SizedBox(height: 12),
                  _ProfileActionChip(
                    icon: Icons.edit_rounded,
                    label: 'Edit Profile',
                    onTap: () async {
                      await Navigator.of(context).push<void>(
                        MaterialPageRoute<void>(
                          builder: (_) => const CompleteProfileScreen(),
                        ),
                      );
                      await authController.refreshProfile();
                    },
                  ),
                  const SizedBox(height: 18),
                  const _StatsCard(),
                  const SizedBox(height: 14),
                  _MenuTile(
                    icon: Icons.shield_outlined,
                    iconColor: const Color(0xFF6A95F5),
                    title: 'Account information',
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute<void>(
                          builder: (_) => const AccountInfoScreen(),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 10),
                  _MenuTile(
                    icon: Icons.notifications_none_rounded,
                    iconColor: const Color(0xFFEEA73E),
                    title: 'Notifications',
                    badgeText: '3',
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute<void>(
                          builder: (_) => const NotificationsScreen(),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 10),
                  _MenuTile(
                    icon: Icons.bar_chart_rounded,
                    iconColor: const Color(0xFF43C88E),
                    title: 'Learning Progress',
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute<void>(
                          builder: (_) => const LearningProgressScreen(),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 10),
                  _MenuTile(
                    icon: Icons.language_rounded,
                    iconColor: const Color(0xFF8B74E8),
                    title: 'App Language',
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute<void>(
                          builder: (_) => const AppLanguageScreen(),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 10),
                  _MenuTile(
                    icon: Icons.help_outline_rounded,
                    iconColor: const Color(0xFF4DC6A6),
                    title: 'Help Center',
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute<void>(
                          builder: (_) => const HelpCenterScreen(),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 10),
                  _MenuTile(
                    icon: Icons.restart_alt_rounded,
                    iconColor: const Color(0xFF9AA4B8),
                    title: 'Reset practice progress',
                    onTap: () => showResetLearningProgressDialog(context),
                  ),
                  const SizedBox(height: 10),
                  _MenuTile(
                    icon: Icons.logout_rounded,
                    iconColor: const Color(0xFFE25775),
                    title: 'Sign Out',
                    titleColor: const Color(0xFFCC3B5A),
                    onTap: () async => AuthService().signOut(),
                  ),
                ],
              ),
            );
              },
            ),
            Positioned(
              left: 0,
              right: 0,
              bottom: 18,
              child: Center(
                child: Container(
                  width: 188,
                  height: 68,
                  decoration: BoxDecoration(
                    color: const Color(0xFFE8EEF8),
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _BottomNavItem(
                        icon: Icons.home_outlined,
                        label: 'Home',
                        selected: false,
                        onTap: () {
                          Navigator.of(context).pushReplacement(
                            MaterialPageRoute<void>(
                              builder: (_) => const SimpleHomeScreen(),
                            ),
                          );
                        },
                      ),
                      const _BottomNavItem(
                        icon: Icons.person_rounded,
                        label: 'Me',
                        selected: true,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StatsCard extends StatelessWidget {
  const _StatsCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 14),
      decoration: BoxDecoration(
        color: const Color(0xFFE8EEF8),
        borderRadius: BorderRadius.circular(16),
      ),
      child: const Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _StatItem(
            icon: Icons.local_fire_department_rounded,
            iconBg: Color(0xFFFFF1DC),
            iconColor: Color(0xFFFFB352),
            value: '0 días',
            label: 'Racha',
          ),
          _StatItem(
            icon: Icons.emoji_events_outlined,
            iconBg: Color(0xFFFFF7D9),
            iconColor: Color(0xFFFFCD4C),
            value: '0',
            label: 'Puntos',
          ),
          _StatItem(
            icon: Icons.menu_book_rounded,
            iconBg: Color(0xFFE8FCF3),
            iconColor: Color(0xFF49CE93),
            value: '0',
            label: 'Lecciones',
          ),
          _StatItem(
            icon: Icons.av_timer_rounded,
            iconBg: Color(0xFFE8F2FF),
            iconColor: Color(0xFF76A9E8),
            value: '0h',
            label: 'Horas',
          ),
        ],
      ),
    );
  }
}

class _StatItem extends StatelessWidget {
  const _StatItem({
    required this.icon,
    required this.iconBg,
    required this.iconColor,
    required this.value,
    required this.label,
  });

  final IconData icon;
  final Color iconBg;
  final Color iconColor;
  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: 24,
          height: 24,
          decoration: BoxDecoration(
            color: iconBg,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, size: 13, color: iconColor),
        ),
        const SizedBox(height: 8),
        Text(
          value,
          style: const TextStyle(
            fontSize: 18,
            color: Color(0xFF202C44),
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: const TextStyle(
            fontSize: 11,
            color: Color(0xFF9CA8BA),
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}

class _ProfileActionChip extends StatelessWidget {
  const _ProfileActionChip({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(20),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: const Color(0xFFE9EEF6),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 14, color: const Color(0xFF7A869A)),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                color: Color(0xFF5D6B82),
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MenuTile extends StatelessWidget {
  const _MenuTile({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.onTap,
    this.badgeText,
    this.titleColor,
  });

  final IconData icon;
  final Color iconColor;
  final String title;
  final VoidCallback onTap;
  final String? badgeText;
  final Color? titleColor;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: onTap,
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
          decoration: BoxDecoration(
            color: const Color(0xFFEFF3FA),
            borderRadius: BorderRadius.circular(14),
          ),
          child: Row(
            children: [
              Icon(icon, color: iconColor, size: 18),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    fontSize: 14,
                    color: titleColor ?? FluidLearnColors.brandBlue,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              if (badgeText != null) ...[
                Container(
                  width: 20,
                  height: 20,
                  decoration: const BoxDecoration(
                    color: FluidLearnColors.brandBlue,
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Text(
                      badgeText!,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
              ],
              const Icon(
                Icons.chevron_right_rounded,
                color: Color(0xFFB0BAC9),
                size: 18,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _BottomNavItem extends StatelessWidget {
  const _BottomNavItem({
    required this.icon,
    required this.label,
    required this.selected,
    this.onTap,
  });

  final IconData icon;
  final String label;
  final bool selected;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(18),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: selected ? FluidLearnColors.brandBlue : Colors.transparent,
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              color: selected
                  ? Colors.white
                  : FluidLearnColors.brandBlueMuted(0.55),
              size: 20,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: TextStyle(
              fontSize: 13,
              color: selected
                  ? FluidLearnColors.brandBlue
                  : FluidLearnColors.brandBlueMuted(0.72),
              fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
