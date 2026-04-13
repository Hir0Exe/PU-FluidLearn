import 'controllers/auth_controller.dart';

/// Instancia global del controlador de auth. Inicializar con [initAppState]
/// después de [Firebase.initializeApp].
late final AuthController authController;

void initAppState() {
  authController = AuthController();
}
