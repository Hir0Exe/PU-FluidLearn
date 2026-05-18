import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../../app_state.dart';
import '../../data/pending_activity_catalog.dart';
import '../../models/user_model.dart';
import '../../services/auth_service.dart';
import '../../widgets/user_avatar_view.dart';
import '../../services/learning_log_service.dart';
import '../../theme/fluidlearn_colors.dart';
import '../../widgets/fluidlearn_logo_image.dart';
import '../profile/me_screen.dart';
import '../profile/profile_option_screens.dart';
import 'skill_activity_challenge_screen.dart';
import 'skill_activities_screen.dart';

class SimpleHomeScreen extends StatefulWidget {
  const SimpleHomeScreen({super.key});

  @override
  State<SimpleHomeScreen> createState() => _SimpleHomeScreenState();
}

class _SimpleHomeScreenState extends State<SimpleHomeScreen> {
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  final _scrollController = ScrollController();
  final _skillsSectionKey = GlobalKey();
  final _log = LearningLogService.instance;
  Timer? _tipTimer;

  late final List<String> _tips;
  int _tipIndex = 0;

  @override
  void initState() {
    super.initState();
    _tips = const [
      'Practice 15 minutes daily and improve a level in 30 days.',
      'Mix listening and speaking in the same session for better recall.',
      'Read aloud for 5 minutes to connect pronunciation and fluency.',
      'Write three sentences about your day — small habits build fluency.',
      'Review yesterday’s mistakes before starting new activities.',
    ];
    _tipTimer = Timer.periodic(const Duration(seconds: 10), (_) {
      if (!mounted) return;
      setState(() => _tipIndex = (_tipIndex + 1) % _tips.length);
    });
  }

  @override
  void dispose() {
    _tipTimer?.cancel();
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToSkills() {
    final ctx = _skillsSectionKey.currentContext;
    if (ctx != null) {
      Scrollable.ensureVisible(
        ctx,
        duration: const Duration(milliseconds: 450),
        curve: Curves.easeOutCubic,
        alignment: 0.1,
      );
    }
  }

  void _openNotificationsSheet(String? uid) {
    if (uid == null) return;
    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      backgroundColor: FluidLearnColors.scaffold,
      builder: (ctx) {
        return SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Padding(
                padding: EdgeInsets.fromLTRB(20, 8, 20, 12),
                child: Text(
                  'Notifications',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                    color: FluidLearnColors.brandBlue,
                  ),
                ),
              ),
              Expanded(
                child: StreamBuilder<List<FeedItem>>(
                  stream: _log.watchFeed(uid),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    final items = snapshot.data ?? [];
                    if (items.isEmpty) {
                      return Center(
                        child: Padding(
                          padding: const EdgeInsets.all(24),
                          child: Text(
                            'No notifications yet. Complete an activity or wait for your teacher to post new material.',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: Color(0xFF7A879A),
                              fontSize: 15,
                            ),
                          ),
                        ),
                      );
                    }
                    return ListView.separated(
                      padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                      itemCount: items.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 8),
                      itemBuilder: (context, i) {
                        final n = items[i];
                        final isTeacher = n.type == 'teacher';
                        return ListTile(
                          tileColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          leading: Icon(
                            isTeacher
                                ? Icons.school_outlined
                                : Icons.task_alt_rounded,
                            color: isTeacher
                                ? const Color(0xFF6A95F5)
                                : const Color(0xFF39CC9F),
                          ),
                          title: Text(
                            n.title,
                            style: const TextStyle(fontWeight: FontWeight.w600),
                          ),
                          subtitle: Text(n.body),
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final profile = authController.appUser;
    final firstName = _extractFirstName(profile?.fullName);
    final uid = authController.currentUser?.uid;
    final authService = AuthService();
    final progressStream = uid == null
        ? Stream<Map<String, double>>.value(_emptySkillProgress)
        : authService.watchSkillProgress(uid);
    final streakStream = uid == null
        ? Stream<({int days, double weekProgress})>.value((
            days: 0,
            weekProgress: 0.0,
          ))
        : _log.watchStreak(uid);

    void openSkill(String skillKey, String title, IconData icon, Color accent) {
      if (uid == null) return;
      Navigator.of(context).push(
        MaterialPageRoute<void>(
          builder: (_) => SkillActivitiesScreen(
            uid: uid,
            skillKey: skillKey,
            title: title,
            icon: icon,
            accentColor: accent,
          ),
        ),
      );
    }

    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: FluidLearnColors.scaffold,
      drawer: Drawer(
        backgroundColor: const Color(0xFFF8FAFF),
        child: SafeArea(
          child: ListView(
            padding: EdgeInsets.zero,
            children: [
              DrawerHeader(
                decoration: const BoxDecoration(color: Color(0xFFE8EEF8)),
                child: Align(
                  alignment: Alignment.bottomLeft,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const FluidLearnLogoImage(size: 40),
                      const SizedBox(height: 8),
                      const Text(
                        'FluidLearn',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w800,
                          color: FluidLearnColors.brandBlue,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              ListTile(
                leading: const Icon(
                  Icons.person_outline_rounded,
                  color: FluidLearnColors.brandBlue,
                ),
                title: const Text(
                  'Profile',
                  style: TextStyle(color: FluidLearnColors.brandBlue),
                ),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.of(context).push(
                    MaterialPageRoute<void>(builder: (_) => const MeScreen()),
                  );
                },
              ),
              ListTile(
                leading: const Icon(
                  Icons.bar_chart_rounded,
                  color: FluidLearnColors.brandBlue,
                ),
                title: const Text(
                  'Learning progress',
                  style: TextStyle(color: FluidLearnColors.brandBlue),
                ),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.of(context).push(
                    MaterialPageRoute<void>(
                      builder: (_) => const LearningProgressScreen(),
                    ),
                  );
                },
              ),
              ListTile(
                leading: const Icon(
                  Icons.help_outline_rounded,
                  color: FluidLearnColors.brandBlue,
                ),
                title: const Text(
                  'Help center',
                  style: TextStyle(color: FluidLearnColors.brandBlue),
                ),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.of(context).push(
                    MaterialPageRoute<void>(
                      builder: (_) => const HelpCenterScreen(),
                    ),
                  );
                },
              ),
              const Divider(),
              if (uid != null)
                ListTile(
                  leading: const Icon(
                    Icons.notifications_active_outlined,
                    color: FluidLearnColors.brandBlue,
                  ),
                  title: const Text(
                    'Demo: teacher posted activity',
                    style: TextStyle(color: FluidLearnColors.brandBlue),
                  ),
                  subtitle: const Text(
                    'Adds a sample notification (for testing)',
                    style: TextStyle(
                      fontSize: 12,
                      color: Color(0xFF9AA4B2),
                    ),
                  ),
                  onTap: () async {
                    Navigator.pop(context);
                    try {
                      await _log.addTeacherActivityNotice(uid: uid);
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Teacher notification added.'),
                          ),
                        );
                      }
                    } catch (e) {
                      if (context.mounted) {
                        ScaffoldMessenger.of(
                          context,
                        ).showSnackBar(SnackBar(content: Text('Error: $e')));
                      }
                    }
                  },
                ),
              ListTile(
                leading: const Icon(
                  Icons.logout_rounded,
                  color: Color(0xFFCC3B5A),
                ),
                title: const Text(
                  'Sign out',
                  style: TextStyle(color: Color(0xFFCC3B5A)),
                ),
                onTap: () async {
                  Navigator.pop(context);
                  await AuthService().signOut();
                },
              ),
            ],
          ),
        ),
      ),
      body: SafeArea(
        child: Stack(
          children: [
            SingleChildScrollView(
              controller: _scrollController,
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 120),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ListenableBuilder(
                    listenable: authController,
                    builder: (context, _) {
                      final profile = authController.appUser;
                      return Row(
                        children: [
                          _HeaderProfileAvatar(
                            profile: profile,
                            onTap: uid == null
                                ? null
                                : () {
                                    Navigator.of(context)
                                        .push<void>(
                                          MaterialPageRoute<void>(
                                            builder: (_) => const MeScreen(),
                                          ),
                                        )
                                        .then(
                                          (_) => authController.refreshProfile(),
                                        );
                                  },
                          ),
                          const SizedBox(width: 10),
                          const Text(
                            'FluidLearn',
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.w700,
                              color: FluidLearnColors.brandBlue,
                            ),
                          ),
                          const Spacer(),
                          _TopIconButton(
                            icon: Icons.notifications_none_rounded,
                            onTap: () => _openNotificationsSheet(uid),
                          ),
                          const SizedBox(width: 10),
                          _TopIconButton(
                            icon: Icons.menu_rounded,
                            onTap: () =>
                                _scaffoldKey.currentState?.openDrawer(),
                          ),
                        ],
                      );
                    },
                  ),
                  const SizedBox(height: 24),
                  const Text(
                    'Welcome',
                    style: TextStyle(fontSize: 16, color: Color(0xFFADB5C3)),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '$firstName 👋',
                    style: const TextStyle(
                      fontSize: 42,
                      fontWeight: FontWeight.w800,
                      color: FluidLearnColors.brandBlue,
                      height: 1.05,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Choose one skill to practice today',
                    style: TextStyle(fontSize: 18, color: Color(0xFF9AA4B2)),
                  ),
                  const SizedBox(height: 24),
                  StreamBuilder<({int days, double weekProgress})>(
                    stream: streakStream,
                    builder: (context, snap) {
                      final days = snap.data?.days ?? 0;
                      final weekProgress = snap.data?.weekProgress ?? 0.0;
                      return _buildDailyStreakCard(
                        days: days,
                        barValue: weekProgress.clamp(0.0, 1.0),
                      );
                    },
                  ),
                  const SizedBox(height: 18),
                  _buildTipCard(
                    tipText: _tips[_tipIndex],
                    onStartNow: _scrollToSkills,
                  ),
                  const SizedBox(height: 24),
                  _buildSectionTitle('Skills'),
                  const SizedBox(height: 14),
                  KeyedSubtree(
                    key: _skillsSectionKey,
                    child: StreamBuilder<Map<String, double>>(
                      stream: progressStream,
                      initialData: _emptySkillProgress,
                      builder: (context, snapshot) {
                        final p = snapshot.data ?? _emptySkillProgress;
                        return GridView.count(
                          shrinkWrap: true,
                          crossAxisCount: 2,
                          physics: const NeverScrollableScrollPhysics(),
                          childAspectRatio: 0.86,
                          crossAxisSpacing: 14,
                          mainAxisSpacing: 14,
                          children: [
                            _SkillCard(
                              levelLabel: _levelLabelForProgress(
                                p['listening'] ?? 0.0,
                              ),
                              title: 'Listening',
                              subtitle: 'Auditory comprehension',
                              progress: _clampUnit(p['listening'] ?? 0.0),
                              icon: Icons.headset_rounded,
                              iconColor: const Color(0xFF20CE9F),
                              progressColor: const Color(0xFF39D0A7),
                              background: const Color(0xFFEFFBF7),
                              onTap: () => openSkill(
                                'listening',
                                'Listening',
                                Icons.headset_rounded,
                                const Color(0xFF20CE9F),
                              ),
                            ),
                            _SkillCard(
                              levelLabel: _levelLabelForProgress(
                                p['speaking'] ?? 0.0,
                              ),
                              title: 'Speaking',
                              subtitle: 'Oral expression',
                              progress: _clampUnit(p['speaking'] ?? 0.0),
                              icon: Icons.mic_rounded,
                              iconColor: const Color(0xFFFFC229),
                              progressColor: const Color(0xFFF6D44D),
                              background: const Color(0xFFFFFAEC),
                              onTap: () => openSkill(
                                'speaking',
                                'Speaking',
                                Icons.mic_rounded,
                                const Color(0xFFFFC229),
                              ),
                            ),
                            _SkillCard(
                              levelLabel: _levelLabelForProgress(
                                p['reading'] ?? 0.0,
                              ),
                              title: 'Reading',
                              subtitle: 'Reading comprehension',
                              progress: _clampUnit(p['reading'] ?? 0.0),
                              icon: Icons.menu_book_rounded,
                              iconColor: const Color(0xFFF36D86),
                              progressColor: const Color(0xFFE86A8B),
                              background: const Color(0xFFFFF3F6),
                              onTap: () => openSkill(
                                'reading',
                                'Reading',
                                Icons.menu_book_rounded,
                                const Color(0xFFF36D86),
                              ),
                            ),
                            _SkillCard(
                              levelLabel: _levelLabelForProgress(
                                p['writing'] ?? 0.0,
                              ),
                              title: 'Writing',
                              subtitle: 'Written expression',
                              progress: _clampUnit(p['writing'] ?? 0.0),
                              icon: Icons.edit_rounded,
                              iconColor: const Color(0xFF9A78FF),
                              progressColor: const Color(0xFF9C87F6),
                              background: const Color(0xFFF7F3FF),
                              onTap: () => openSkill(
                                'writing',
                                'Writing',
                                Icons.edit_rounded,
                                const Color(0xFF9A78FF),
                              ),
                            ),
                          ],
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 24),
                  _buildSectionTitle('Recent Activity'),
                  const SizedBox(height: 14),
                  _buildRecentActivitiesSection(),
                ],
              ),
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
                      const _BottomNavItem(
                        icon: Icons.home_filled,
                        label: 'Home',
                        selected: true,
                      ),
                      _BottomNavItem(
                        icon: Icons.person_outline_rounded,
                        label: 'Me',
                        selected: false,
                        onTap: () {
                          Navigator.of(context).push(
                            MaterialPageRoute<void>(
                              builder: (_) => const MeScreen(),
                            ),
                          );
                        },
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

  Future<void> _openPendingChallenge(String uid, PendingActivityDef def) async {
    await Navigator.of(context).push<bool>(
      MaterialPageRoute<bool>(
        builder: (_) => SkillActivityChallengeScreen(
          uid: uid,
          skillKey: def.skillKey,
          taskId: def.taskId,
          taskTitle: def.title,
          icon: def.icon,
          accentColor: def.accentColor,
        ),
      ),
    );
    if (mounted) setState(() {});
  }

  Widget _buildRecentActivitiesSection() {
    final uid = authController.currentUser?.uid;
    if (uid == null) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 22),
        decoration: BoxDecoration(
          color: const Color(0xFFEDF3FB),
          borderRadius: BorderRadius.circular(16),
        ),
        child: const Text(
          'Sign in to see pending activities.',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 15,
            height: 1.35,
            color: Color(0xFF7A879A),
            fontWeight: FontWeight.w500,
          ),
        ),
      );
    }

    return StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
      stream:
          FirebaseFirestore.instance.collection('users').doc(uid).snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting &&
            !snapshot.hasData) {
          return const Padding(
            padding: EdgeInsets.all(24),
            child: Center(child: CircularProgressIndicator()),
          );
        }
        final done = Set<String>.from(
          snapshot.data?.data()?['completedTaskIds'] ?? [],
        );
        final pending = kPendingActivityCatalog
            .where((d) => !done.contains(d.taskId))
            .toList();

        if (pending.isEmpty) {
          return Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 22),
            decoration: BoxDecoration(
              color: const Color(0xFFEDF3FB),
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Text(
              'You have no pending activities to do',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 15,
                height: 1.35,
                color: Color(0xFF7A879A),
                fontWeight: FontWeight.w500,
              ),
            ),
          );
        }

        return Column(
          children: [
            for (var i = 0; i < pending.length; i++) ...[
              if (i > 0) const SizedBox(height: 10),
              _ActivityCard(
                icon: pending[i].icon,
                title: pending[i].title,
                subtitle: pending[i].subtitle,
                points: pending[i].pointsLabel,
                iconColor: pending[i].iconColor,
                iconBg: pending[i].iconBg,
                onTap: () => _openPendingChallenge(uid, pending[i]),
              ),
            ],
          ],
        );
      },
    );
  }
}

const Map<String, double> _emptySkillProgress = {
  'listening': 0.0,
  'speaking': 0.0,
  'reading': 0.0,
  'writing': 0.0,
};

double _clampUnit(double v) => v.clamp(0.0, 1.0);

String _levelLabelForProgress(double p) {
  final x = _clampUnit(p);
  if (x <= 0) return 'Unrated';
  if (x < 0.17) return 'A1';
  if (x < 0.34) return 'A2';
  if (x < 0.51) return 'B1';
  if (x < 0.68) return 'B2';
  if (x < 0.85) return 'C1';
  return 'C2';
}

String _extractFirstName(String? fullName) {
  if (fullName == null || fullName.trim().isEmpty) return 'Freddy';
  return fullName.trim().split(RegExp(r'\s+')).first;
}

Widget _buildDailyStreakCard({required int days, required double barValue}) {
  return _HoverLiftCard(
    borderRadius: 16,
    child: Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(
              color: const Color(0xFFFFEECF),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(
              Icons.local_fire_department_rounded,
              color: Color(0xFFFFAF26),
              size: 20,
            ),
          ),
          const SizedBox(width: 10),
          const Text(
            'Daily Streak',
            style: TextStyle(
              fontSize: 16,
              color: Color(0xFF7A869A),
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                minHeight: 6,
                value: barValue.clamp(0.0, 1.0),
                backgroundColor: const Color(0xFFE5EAF2),
                valueColor: const AlwaysStoppedAnimation(Color(0xFFD98B43)),
              ),
            ),
          ),
          const SizedBox(width: 10),
          Text(
            '$days days',
            style: const TextStyle(
              fontSize: 18,
              color: Color(0xFFD98B43),
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    ),
  );
}

Widget _buildTipCard({
  required String tipText,
  required VoidCallback onStartNow,
}) {
  return _HoverLiftCard(
    borderRadius: 20,
    child: Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF8DA0AB), Color(0xFF91E7DA), Color(0xFF79E4D4)],
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Daily Tip',
            style: TextStyle(color: Colors.white70, fontSize: 16),
          ),
          const SizedBox(height: 8),
          Text(
            tipText,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 22,
              fontWeight: FontWeight.w700,
              height: 1.2,
            ),
          ),
          const SizedBox(height: 14),
          _StartButton(onPressed: onStartNow),
        ],
      ),
    ),
  );
}

Widget _buildSectionTitle(String title) {
  return Text(
    title,
    style: const TextStyle(
      fontSize: 34,
      fontWeight: FontWeight.w800,
      color: FluidLearnColors.brandBlue,
      height: 1.05,
    ),
  );
}

/// Círculo superior izquierdo: mismo avatar que en Me.
class _HeaderProfileAvatar extends StatefulWidget {
  const _HeaderProfileAvatar({required this.profile, this.onTap});

  final UserModel? profile;
  final VoidCallback? onTap;

  @override
  State<_HeaderProfileAvatar> createState() => _HeaderProfileAvatarState();
}

class _HeaderProfileAvatarState extends State<_HeaderProfileAvatar> {
  bool _hover = false;

  @override
  Widget build(BuildContext context) {
    Widget avatarFace() {
      return UserAvatarView(
        key: ValueKey<int?>(widget.profile?.avatarIndex),
        profile: widget.profile,
        size: 30,
      );
    }

    final inner = Center(child: avatarFace());

    return MouseRegion(
      onEnter: (_) => setState(() => _hover = true),
      onExit: (_) => setState(() => _hover = false),
      cursor: widget.onTap != null
          ? SystemMouseCursors.click
          : MouseCursor.defer,
      child: AnimatedScale(
        duration: const Duration(milliseconds: 140),
        scale: (_hover && widget.onTap != null) ? 1.06 : 1.0,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 140),
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: _hover ? const Color(0xFFF5F8FE) : Colors.white,
            borderRadius: BorderRadius.circular(18),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF0B3D91).withAlpha(_hover ? 38 : 26),
                blurRadius: _hover ? 14 : 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: widget.onTap != null
              ? Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: widget.onTap,
                    borderRadius: BorderRadius.circular(18),
                    child: inner,
                  ),
                )
              : inner,
        ),
      ),
    );
  }

}

class _TopIconButton extends StatefulWidget {
  const _TopIconButton({required this.icon, required this.onTap});

  final IconData icon;
  final VoidCallback onTap;

  @override
  State<_TopIconButton> createState() => _TopIconButtonState();
}

class _TopIconButtonState extends State<_TopIconButton> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      cursor: SystemMouseCursors.click,
      child: AnimatedScale(
        duration: const Duration(milliseconds: 140),
        scale: _isHovered ? 1.06 : 1.0,
        child: InkWell(
          onTap: widget.onTap,
          borderRadius: BorderRadius.circular(16),
          hoverColor: const Color(0xFFDEE7F7),
          splashColor: const Color(0xFFC8D7F5),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 140),
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: _isHovered
                  ? const Color(0xFFE8EEF9)
                  : const Color(0xFFF2F5FA),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(widget.icon, color: const Color(0xFF717F95), size: 20),
          ),
        ),
      ),
    );
  }
}

class _HoverLiftCard extends StatefulWidget {
  const _HoverLiftCard({required this.child, this.borderRadius = 16});

  final Widget child;
  final double borderRadius;

  @override
  State<_HoverLiftCard> createState() => _HoverLiftCardState();
}

class _HoverLiftCardState extends State<_HoverLiftCard> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      cursor: SystemMouseCursors.click,
      child: AnimatedScale(
        duration: const Duration(milliseconds: 160),
        scale: _isHovered ? 1.015 : 1.0,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 160),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(widget.borderRadius),
            boxShadow: _isHovered
                ? [
                    BoxShadow(
                      color: const Color(0xFF1C335D).withAlpha(28),
                      blurRadius: 16,
                      offset: const Offset(0, 8),
                    ),
                  ]
                : const [],
          ),
          child: widget.child,
        ),
      ),
    );
  }
}

class _StartButton extends StatefulWidget {
  const _StartButton({this.onPressed});

  final VoidCallback? onPressed;

  @override
  State<_StartButton> createState() => _StartButtonState();
}

class _StartButtonState extends State<_StartButton> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      cursor: SystemMouseCursors.click,
      child: AnimatedScale(
        duration: const Duration(milliseconds: 160),
        scale: _isHovered ? 1.04 : 1.0,
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: widget.onPressed,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 160),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: _isHovered
                  ? Colors.white.withAlpha(110)
                  : Colors.white.withAlpha(69),
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Text(
              'Start Now',
              style: TextStyle(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _SkillCard extends StatelessWidget {
  const _SkillCard({
    required this.levelLabel,
    required this.title,
    required this.subtitle,
    required this.progress,
    required this.icon,
    required this.iconColor,
    required this.progressColor,
    required this.background,
    this.onTap,
  });

  /// Cuando el usuario acumule progreso, sustituir por el nivel real (A1, B2, etc.).
  final String levelLabel;
  final String title;
  final String subtitle;
  final double progress;
  final IconData icon;
  final Color iconColor;
  final Color progressColor;
  final Color background;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return _HoverLiftCard(
      borderRadius: 18,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(18),
          onTap: onTap,
          child: Container(
            padding: const EdgeInsets.fromLTRB(14, 14, 14, 12),
            decoration: BoxDecoration(
              color: background,
              borderRadius: BorderRadius.circular(18),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 34,
                      height: 34,
                      decoration: BoxDecoration(
                        color: Colors.white.withAlpha(191),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(icon, color: iconColor, size: 20),
                    ),
                    const Spacer(),
                    SizedBox(
                      width: 88,
                      child: Text(
                        levelLabel,
                        textAlign: TextAlign.right,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: const Color(0xFF28344A).withAlpha(204),
                          fontWeight: FontWeight.w600,
                          fontSize: 11,
                          height: 1.15,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 32,
                    color: FluidLearnColors.brandBlue,
                    fontWeight: FontWeight.w700,
                    height: 1.0,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: const TextStyle(
                    fontSize: 13,
                    color: Color(0xFFA0AABC),
                  ),
                ),
                const Spacer(),
                const Text(
                  'Progress',
                  style: TextStyle(color: Color(0xFFA0AABC), fontSize: 13),
                ),
                const SizedBox(height: 6),
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    minHeight: 6,
                    value: progress,
                    backgroundColor: Colors.white,
                    valueColor: AlwaysStoppedAnimation(progressColor),
                  ),
                ),
                const SizedBox(height: 8),
                Align(
                  alignment: Alignment.centerRight,
                  child: Text(
                    '${(progress * 100).round()}%',
                    style: const TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 18,
                      color: Color(0xFF27334A),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _ActivityCard extends StatelessWidget {
  const _ActivityCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.points,
    required this.iconColor,
    required this.iconBg,
    this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final String points;
  final Color iconColor;
  final Color iconBg;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return _HoverLiftCard(
      borderRadius: 16,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            decoration: BoxDecoration(
              color: const Color(0xFFEDF3FB),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              children: [
                Container(
                  width: 34,
                  height: 34,
                  decoration: BoxDecoration(
                    color: iconBg,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(icon, color: iconColor, size: 18),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          fontSize: 16,
                          color: Color(0xFF2B374E),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        subtitle,
                        style: const TextStyle(
                          fontSize: 14,
                          color: Color(0xFF9DA8BA),
                        ),
                      ),
                    ],
                  ),
                ),
                Text(
                  points,
                  style: const TextStyle(
                    color: Color(0xFF39CC9F),
                    fontWeight: FontWeight.w700,
                    fontSize: 18,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _BottomNavItem extends StatefulWidget {
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
  State<_BottomNavItem> createState() => _BottomNavItemState();
}

class _BottomNavItemState extends State<_BottomNavItem> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      cursor: SystemMouseCursors.click,
      child: InkWell(
        onTap: widget.onTap,
        borderRadius: BorderRadius.circular(18),
        child: AnimatedScale(
          duration: const Duration(milliseconds: 140),
          scale: _isHovered ? 1.05 : 1.0,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              AnimatedContainer(
                duration: const Duration(milliseconds: 140),
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: widget.selected
                      ? FluidLearnColors.brandBlue
                      : (_isHovered
                            ? const Color(0xFFD9E2F1)
                            : Colors.transparent),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  widget.icon,
                  color: widget.selected
                      ? Colors.white
                      : const Color(0xFF8C99AD),
                  size: 20,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                widget.label,
                style: TextStyle(
                  fontSize: 13,
                  color: widget.selected
                      ? FluidLearnColors.brandBlue
                      : FluidLearnColors.brandBlueMuted(
                          _isHovered ? 0.85 : 0.72,
                        ),
                  fontWeight: widget.selected
                      ? FontWeight.w700
                      : FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
