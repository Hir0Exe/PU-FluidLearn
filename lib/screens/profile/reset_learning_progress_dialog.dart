import 'package:flutter/material.dart';
import '../../app_state.dart';
import '../../services/learning_log_service.dart';

/// Diálogo + escritura en Firestore. Usar desde Me o desde Progreso de aprendizaje.
Future<void> showResetLearningProgressDialog(BuildContext context) async {
  final uid = authController.currentUser?.uid;
  if (uid == null) return;

  final ok = await showDialog<bool>(
    context: context,
    builder: (ctx) => AlertDialog(
      title: const Text('¿Reiniciar progreso de práctica?'),
      content: const Text(
        'Se pondrán a cero: porcentaje por skill en la app, actividades completadas, '
        'racha y avisos del feed. No borra tu cuenta, nombre ni correo.',
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(ctx, false),
          child: const Text('Cancelar'),
        ),
        FilledButton(
          onPressed: () => Navigator.pop(ctx, true),
          child: const Text('Reiniciar'),
        ),
      ],
    ),
  );
  if (ok != true || !context.mounted) return;

  final nav = Navigator.of(context, rootNavigator: true);
  showDialog<void>(
    context: context,
    barrierDismissible: false,
    useRootNavigator: true,
    builder: (ctx) => const PopScope(
      canPop: false,
      child: Center(child: CircularProgressIndicator()),
    ),
  );

  try {
    await LearningLogService.instance.resetLearningProgressForTesting(uid);
    nav.pop();
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Progreso reiniciado. Vuelve al inicio para ver 0% y tareas sin marcar.',
          ),
        ),
      );
    }
  } catch (e) {
    nav.pop();
    if (context.mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('No se pudo reiniciar: $e')));
    }
  }
}
