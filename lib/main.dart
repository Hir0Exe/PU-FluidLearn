import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'app_state.dart';
import 'firebase_options.dart';
import 'theme/fluidlearn_colors.dart';
import 'screens/auth/login_screen.dart';
import 'screens/auth/complete_profile_screen.dart';
import 'screens/home/simple_home_screen.dart';
import 'screens/splash/fluidlearn_intro_splash.dart';
import 'data/local_skill_questions.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  await LocalSkillQuestions.load();

  initAppState();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  static const _primary = FluidLearnColors.brandBlue;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'FluidLearn',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: _primary,
          brightness: Brightness.light,
        ),
        useMaterial3: true,
        scaffoldBackgroundColor: FluidLearnColors.scaffold,
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: _primary,
            foregroundColor: Colors.white,
          ),
        ),
      ),
      home: const _AppBootstrap(),
    );
  }
}

/// Pantalla de destino según auth; mismo color base que el intro mientras carga Firebase.
class _AppBootstrap extends StatefulWidget {
  const _AppBootstrap();

  @override
  State<_AppBootstrap> createState() => _AppBootstrapState();
}

class _AppBootstrapState extends State<_AppBootstrap> {
  static const _loadingBg = Color(0xFF0D1B2E);

  bool _introVisualDone = false;
  bool _splashOverlayVisible = true;
  bool _splashFadingOut = false;

  @override
  void initState() {
    super.initState();
    authController.addListener(_onAuthChanged);
  }

  @override
  void dispose() {
    authController.removeListener(_onAuthChanged);
    super.dispose();
  }

  void _onAuthChanged() {
    if (!mounted) return;
    setState(() {
      if (_introVisualDone &&
          !authController.isLoading &&
          !_splashFadingOut &&
          _splashOverlayVisible) {
        _splashFadingOut = true;
      }
    });
  }

  void _onIntroComplete() {
    if (!mounted) return;
    setState(() {
      _introVisualDone = true;
      if (!authController.isLoading &&
          !_splashFadingOut &&
          _splashOverlayVisible) {
        _splashFadingOut = true;
      }
    });
  }

  String get _screenKey {
    if (authController.isLoading) return 'loading';
    if (!authController.isAuthenticated) return 'login';
    if (authController.needsProfileCompletion) {
      return 'profile_${authController.currentUser!.uid}';
    }
    return 'home_${authController.currentUser!.uid}';
  }

  Widget _destination() {
    if (authController.isLoading) {
      return const ColoredBox(
        color: _loadingBg,
        child: SizedBox.expand(),
      );
    }
    if (!authController.isAuthenticated) {
      return const LoginScreen();
    }
    if (authController.needsProfileCompletion) {
      return const CompleteProfileScreen();
    }
    return const SimpleHomeScreen();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        KeyedSubtree(
          key: ValueKey(_screenKey),
          child: _destination(),
        ),
        if (_splashOverlayVisible)
          Positioned.fill(
            child: AnimatedOpacity(
              opacity: _splashFadingOut ? 0 : 1,
              duration: const Duration(milliseconds: 520),
              curve: Curves.easeOutCubic,
              onEnd: () {
                if (_splashFadingOut && mounted) {
                  setState(() => _splashOverlayVisible = false);
                }
              },
              child: FluidLearnIntroSplash(onIntroComplete: _onIntroComplete),
            ),
          ),
      ],
    );
  }
}
