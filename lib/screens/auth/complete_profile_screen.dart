import 'package:flutter/material.dart';
import '../../app_state.dart';
import '../../services/auth_service.dart';

/// Tras Google (o si faltan datos obligatorios), el estudiante completa carnet y nombre.
class CompleteProfileScreen extends StatefulWidget {
<<<<<<< HEAD
  const CompleteProfileScreen({Key? key}) : super(key: key);
=======
  const CompleteProfileScreen({super.key});
>>>>>>> 2736943 (Se agrega el Proyecto)

  @override
  State<CompleteProfileScreen> createState() => _CompleteProfileScreenState();
}

class _CompleteProfileScreenState extends State<CompleteProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final _fullNameController = TextEditingController();
  final _studentIdController = TextEditingController();
  final _authService = AuthService();
  bool _isLoading = false;

  @override
  void dispose() {
    _fullNameController.dispose();
    _studentIdController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    final user = authController.currentUser;
    if (user == null) return;

    setState(() => _isLoading = true);
    try {
      await _authService.completeStudentProfile(
        uid: user.uid,
        email: user.email ?? '',
        fullName: _fullNameController.text,
        studentId: _studentIdController.text,
      );
      await authController.refreshProfile();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    const primary = Color(0xFF1565C0);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Completa tu perfil'),
        backgroundColor: primary,
        foregroundColor: Colors.white,
        automaticallyImplyLeading: false,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Text(
                  'Aunque hayas iniciado sesión con Google, necesitamos tus datos '
                  'como estudiante de la USB para continuar.',
                  style: TextStyle(fontSize: 15, height: 1.4),
                ),
                const SizedBox(height: 24),
                TextFormField(
                  controller: _fullNameController,
                  decoration: const InputDecoration(
                    labelText: 'Nombre completo',
                    border: OutlineInputBorder(),
                  ),
                  textCapitalization: TextCapitalization.words,
                  validator: (v) {
                    if (v == null || v.trim().length < 3) {
                      return 'Ingresa tu nombre completo';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _studentIdController,
                  decoration: const InputDecoration(
                    labelText: 'Carnet / código estudiantil',
                    border: OutlineInputBorder(),
                  ),
                  validator: (v) {
                    if (v == null || v.trim().isEmpty) {
                      return 'Ingresa tu carnet o código';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 28),
                ElevatedButton(
                  onPressed: _isLoading ? null : _submit,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primary,
                    padding: const EdgeInsets.all(16),
                  ),
                  child: _isLoading
                      ? const SizedBox(
                          height: 22,
                          width: 22,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Text('Guardar y continuar'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
