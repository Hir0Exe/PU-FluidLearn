import 'package:flutter/material.dart';
import '../../app_state.dart';
import '../../services/auth_service.dart';

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
              ),
            ),
          ],
        ),
      ),
    );
  }
}
