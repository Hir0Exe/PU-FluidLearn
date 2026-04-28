import 'package:flutter/material.dart';
import '../../app_state.dart';
import '../../services/auth_service.dart';

<<<<<<< HEAD
/// Pantalla principal mínima tras autenticación y perfil completo.
class SimpleHomeScreen extends StatelessWidget {
  const SimpleHomeScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    const primary = Color(0xFF1565C0);
    final user = authController.currentUser;
    final profile = authController.appUser;

    return Scaffold(
      appBar: AppBar(
        title: const Text('FluidLearn'),
        backgroundColor: primary,
        foregroundColor: Colors.white,
        actions: [
          TextButton(
            onPressed: () async {
              await AuthService().signOut();
            },
            child: const Text(
              'Salir',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Validación de nivel de inglés',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Universidad Simón Bolívar',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey.shade700,
              ),
            ),
            const SizedBox(height: 32),
            if (profile != null) ...[
              Text(
                'Hola, ${profile.fullName}',
                style: const TextStyle(fontSize: 18),
              ),
              const SizedBox(height: 8),
              Text(
                'Carnet: ${profile.studentId}',
                style: TextStyle(color: Colors.grey.shade600),
              ),
            ] else if (user != null) ...[
              Text(
                'Sesión: ${user.email ?? ""}',
                style: const TextStyle(fontSize: 16),
              ),
            ],
            const SizedBox(height: 40),
            Text(
              'Aquí irá el contenido principal de la app (evaluaciones, '
              'niveles, historial, etc.). Por ahora es solo un punto de partida.',
              style: TextStyle(
                fontSize: 15,
                height: 1.5,
                color: Colors.grey.shade800,
=======
class SimpleHomeScreen extends StatelessWidget {
  const SimpleHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final profile = authController.appUser;
    final firstName = _extractFirstName(profile?.fullName);

    return Scaffold(
      backgroundColor: const Color(0xFFF4F8FE),
      body: SafeArea(
        child: Stack(
          children: [
            SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 120),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const _HeaderLogoAvatar(),
                      const SizedBox(width: 10),
                      const Text(
                        'FluidLearn',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF24324A),
                        ),
                      ),
                      const Spacer(),
                      _TopIconButton(
                        icon: Icons.notifications_none_rounded,
                        onTap: () {},
                      ),
                      const SizedBox(width: 10),
                      _TopIconButton(
                        icon: Icons.menu_rounded,
                        onTap: () async {
                          await AuthService().signOut();
                        },
                      ),
                    ],
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
                      color: Color(0xFF1D2A44),
                      height: 1.05,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Elige una habilidad para practicar hoy',
                    style: TextStyle(fontSize: 18, color: Color(0xFF9AA4B2)),
                  ),
                  const SizedBox(height: 24),
                  _buildDailyStreakCard(),
                  const SizedBox(height: 18),
                  _buildTipCard(),
                  const SizedBox(height: 24),
                  _buildSectionTitle('Habilidades'),
                  const SizedBox(height: 14),
                  GridView.count(
                    shrinkWrap: true,
                    crossAxisCount: 2,
                    physics: const NeverScrollableScrollPhysics(),
                    childAspectRatio: 0.86,
                    crossAxisSpacing: 14,
                    mainAxisSpacing: 14,
                    children: const [
                      _SkillCard(
                        level: 'B2',
                        title: 'Listening',
                        subtitle: 'Comprensión auditiva',
                        progress: 0.72,
                        icon: Icons.headset_rounded,
                        iconColor: Color(0xFF20CE9F),
                        progressColor: Color(0xFF39D0A7),
                        background: Color(0xFFEFFBF7),
                      ),
                      _SkillCard(
                        level: 'B1',
                        title: 'Speaking',
                        subtitle: 'Expresión oral',
                        progress: 0.58,
                        icon: Icons.mic_rounded,
                        iconColor: Color(0xFFFFC229),
                        progressColor: Color(0xFFF6D44D),
                        background: Color(0xFFFFFAEC),
                      ),
                      _SkillCard(
                        level: 'C1',
                        title: 'Reading',
                        subtitle: 'Comprensión lectora',
                        progress: 0.85,
                        icon: Icons.menu_book_rounded,
                        iconColor: Color(0xFFF36D86),
                        progressColor: Color(0xFFE86A8B),
                        background: Color(0xFFFFF3F6),
                      ),
                      _SkillCard(
                        level: 'A2',
                        title: 'Writing',
                        subtitle: 'Expresión escrita',
                        progress: 0.45,
                        icon: Icons.edit_rounded,
                        iconColor: Color(0xFF9A78FF),
                        progressColor: Color(0xFF9C87F6),
                        background: Color(0xFFF7F3FF),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  _buildSectionTitle('Actividad reciente'),
                  const SizedBox(height: 14),
                  const _ActivityCard(
                    icon: Icons.headset_rounded,
                    title: 'Listening — Nivel 3',
                    subtitle: 'Hace 2 horas',
                    points: '+12 pts',
                    iconColor: Color(0xFF3DD3A4),
                    iconBg: Color(0xFFE9FAF4),
                  ),
                  const SizedBox(height: 10),
                  const _ActivityCard(
                    icon: Icons.menu_book_rounded,
                    title: 'Reading — Texto corto',
                    subtitle: 'Ayer',
                    points: '+8 pts',
                    iconColor: Color(0xFFF36D86),
                    iconBg: Color(0xFFFFF1F4),
                  ),
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
                      const _BottomNavItem(
                        icon: Icons.person_outline_rounded,
                        label: 'Yo',
                        selected: false,
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

String _extractFirstName(String? fullName) {
  if (fullName == null || fullName.trim().isEmpty) return 'Freddy';
  return fullName.trim().split(RegExp(r'\s+')).first;
}

Widget _buildDailyStreakCard() {
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
            'Racha diaria',
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
              child: const LinearProgressIndicator(
                minHeight: 6,
                value: 0.62,
                backgroundColor: Color(0xFFE5EAF2),
                valueColor: AlwaysStoppedAnimation(Color(0xFFD98B43)),
              ),
            ),
          ),
          const SizedBox(width: 10),
          const Text(
            '3 dias',
            style: TextStyle(
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

Widget _buildTipCard() {
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
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Consejo del dia',
            style: TextStyle(color: Colors.white70, fontSize: 16),
          ),
          SizedBox(height: 8),
          Text(
            'Practica 15 min diarios\ny mejora un nivel en 30 dias',
            style: TextStyle(
              color: Colors.white,
              fontSize: 22,
              fontWeight: FontWeight.w700,
              height: 1.2,
            ),
          ),
          SizedBox(height: 14),
          _StartButton(),
        ],
      ),
    ),
  );
}

Widget _buildSectionTitle(String title) {
  return Row(
    children: [
      Text(
        title,
        style: const TextStyle(
          fontSize: 34,
          fontWeight: FontWeight.w800,
          color: Color(0xFF1E2A44),
          height: 1.05,
        ),
      ),
      const Spacer(),
      const _ViewAllButton(),
    ],
  );
}

class _HeaderLogoAvatar extends StatefulWidget {
  const _HeaderLogoAvatar();

  @override
  State<_HeaderLogoAvatar> createState() => _HeaderLogoAvatarState();
}

class _HeaderLogoAvatarState extends State<_HeaderLogoAvatar> {
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
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 140),
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: _isHovered ? const Color(0xFFF5F8FE) : Colors.white,
            borderRadius: BorderRadius.circular(18),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF0B3D91).withAlpha(_isHovered ? 38 : 26),
                blurRadius: _isHovered ? 14 : 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Center(
            child: ClipOval(
              child: Image.asset(
                'assets/images/new_logo.png',
                width: 26,
                height: 26,
                fit: BoxFit.cover,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _ViewAllButton extends StatefulWidget {
  const _ViewAllButton();

  @override
  State<_ViewAllButton> createState() => _ViewAllButtonState();
}

class _ViewAllButtonState extends State<_ViewAllButton> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      cursor: SystemMouseCursors.click,
      child: AnimatedScale(
        duration: const Duration(milliseconds: 140),
        scale: _isHovered ? 1.04 : 1.0,
        child: AnimatedDefaultTextStyle(
          duration: const Duration(milliseconds: 140),
          style: TextStyle(
            color: _isHovered
                ? const Color(0xFF6F7E95)
                : const Color(0xFF9BA7B8),
            fontSize: 15,
            fontWeight: FontWeight.w600,
          ),
          child: Row(
            children: [
              const Text('Ver todas'),
              const SizedBox(width: 4),
              Icon(
                Icons.chevron_right_rounded,
                color: _isHovered
                    ? const Color(0xFF6F7E95)
                    : const Color(0xFF9BA7B8),
                size: 18,
              ),
            ],
          ),
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
  const _StartButton();

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
          onTap: () {},
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
              'Empezar ahora',
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
    required this.level,
    required this.title,
    required this.subtitle,
    required this.progress,
    required this.icon,
    required this.iconColor,
    required this.progressColor,
    required this.background,
  });

  final String level;
  final String title;
  final String subtitle;
  final double progress;
  final IconData icon;
  final Color iconColor;
  final Color progressColor;
  final Color background;

  @override
  Widget build(BuildContext context) {
    return _HoverLiftCard(
      borderRadius: 18,
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
                Text(
                  level,
                  style: TextStyle(
                    color: const Color(0xFF28344A).withAlpha(204),
                    fontWeight: FontWeight.w700,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              title,
              style: const TextStyle(
                fontSize: 32,
                color: Color(0xFF27334A),
                fontWeight: FontWeight.w700,
                height: 1.0,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              subtitle,
              style: const TextStyle(fontSize: 13, color: Color(0xFFA0AABC)),
            ),
            const Spacer(),
            const Text(
              'Progreso.',
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
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final String points;
  final Color iconColor;
  final Color iconBg;

  @override
  Widget build(BuildContext context) {
    return _HoverLiftCard(
      borderRadius: 16,
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
    );
  }
}

class _BottomNavItem extends StatefulWidget {
  const _BottomNavItem({
    required this.icon,
    required this.label,
    required this.selected,
  });

  final IconData icon;
  final String label;
  final bool selected;

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
                    ? const Color(0xFF111D33)
                    : (_isHovered
                          ? const Color(0xFFD9E2F1)
                          : Colors.transparent),
                shape: BoxShape.circle,
              ),
              child: Icon(
                widget.icon,
                color: widget.selected ? Colors.white : const Color(0xFF8C99AD),
                size: 20,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              widget.label,
              style: TextStyle(
                fontSize: 13,
                color: widget.selected
                    ? const Color(0xFF1A2438)
                    : (_isHovered
                          ? const Color(0xFF6F7D93)
                          : const Color(0xFFA8B2C2)),
                fontWeight: widget.selected ? FontWeight.w700 : FontWeight.w500,
>>>>>>> 2736943 (Se agrega el Proyecto)
              ),
            ),
          ],
        ),
      ),
    );
  }
}
