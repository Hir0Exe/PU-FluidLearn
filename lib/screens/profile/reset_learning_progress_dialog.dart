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
      title: const Text('Reset practice progress?'),
      content: const Text(
        'The following will be set to zero: percentage by skill in the app, completed activities, '
        'streak and feed notifications. It does not delete your account, name or email.',
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(ctx, false),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: () => Navigator.pop(ctx, true),
          child: const Text('Reset'),
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
            'Progress reset. Go back to the home screen to see 0% and tasks without marking.',
          ),
        ),
      );
    }
  } catch (e) {
    nav.pop();
    if (context.mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Could not reset: $e')));
    }
  }
}
