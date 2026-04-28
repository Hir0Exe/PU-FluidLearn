import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'app_state.dart';
import 'firebase_options.dart';
import 'screens/auth/login_screen.dart';
import 'screens/auth/complete_profile_screen.dart';
import 'screens/home/simple_home_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  initAppState();

  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
<<<<<<< HEAD
  const MyApp({Key? key}) : super(key: key);
=======
  const MyApp({super.key});
>>>>>>> 2736943 (Se agrega el Proyecto)

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  static const _primary = Color(0xFF1565C0);

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
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    Widget home;
    String screenKey;

    if (authController.isLoading) {
      screenKey = 'loading';
      home = const Scaffold(
        body: Center(
          child: CircularProgressIndicator(color: _primary),
        ),
      );
    } else if (!authController.isAuthenticated) {
      screenKey = 'login';
      home = const LoginScreen();
    } else if (authController.needsProfileCompletion) {
      screenKey = 'profile_${authController.currentUser!.uid}';
      home = const CompleteProfileScreen();
    } else {
      screenKey = 'home_${authController.currentUser!.uid}';
      home = const SimpleHomeScreen();
    }

    return MaterialApp(
      key: ValueKey(screenKey),
      title: 'FluidLearn',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: _primary,
          brightness: Brightness.light,
        ),
        useMaterial3: true,
        scaffoldBackgroundColor: Colors.white,
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: _primary,
            foregroundColor: Colors.white,
          ),
        ),
      ),
      home: home,
    );
  }
}
