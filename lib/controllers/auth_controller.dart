import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/auth_service.dart';
import '../models/user_model.dart';

/// Controlador singleton de autenticación y perfil de estudiante.
class AuthController extends ChangeNotifier {
  static final AuthController _instance = AuthController._internal();
  factory AuthController() => _instance;

  final _authService = AuthService();
  User? _currentUser;
  UserModel? _appUser;
  bool _isLoading = true;

  User? get currentUser => _currentUser;
  UserModel? get appUser => _appUser;
  bool get isLoading => _isLoading;
  bool get isAuthenticated => _currentUser != null;

  /// Perfil incompleto (p. ej. registro con Google sin carnet/nombre).
  bool get needsProfileCompletion =>
      isAuthenticated &&
      (_appUser == null || !_appUser!.isProfileComplete);

  AuthController._internal() {
    FirebaseAuth.instance.authStateChanges().listen((User? user) async {
      _currentUser = user;
      _isLoading = true;
      notifyListeners();

      if (user != null) {
        _appUser = await _authService.getUserProfile(user.uid);
      } else {
        _appUser = null;
      }

      _isLoading = false;
      notifyListeners();
    });
  }

  /// Refrescar perfil desde Firestore (tras completar datos).
  Future<void> refreshProfile() async {
    final user = _currentUser;
    if (user == null) return;
    _appUser = await _authService.getUserProfile(user.uid);
    notifyListeners();
  }
}
