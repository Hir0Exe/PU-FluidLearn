import 'package:flutter/material.dart';
import '../../app_state.dart';
import '../../services/auth_service.dart';
import 'reset_learning_progress_dialog.dart';

class AccountInfoScreen extends StatelessWidget {
  const AccountInfoScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final profile = authController.appUser;
    final email = authController.currentUser?.email ?? 'Whitout E-mail';
    final uid = authController.currentUser?.uid ?? 'Whitout UID';

    return Scaffold(
      appBar: AppBar(title: const Text('Account Information')),
      backgroundColor: const Color(0xFFF4F8FE),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _InfoTile(
            label: 'Full Name',
            value: profile?.fullName ?? 'Without data',
          ),
          _InfoTile(label: 'E-mail', value: email),
          _InfoTile(label: 'Student ID', value: profile?.studentId ?? 'Without data'),
          _InfoTile(label: 'User ID', value: uid),
        ],
      ),
    );
  }
}

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  final _authService = AuthService();
  bool reminders = true;
  bool pendingActivities = true;
  bool levelUpdates = true;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadPreferences();
  }

  Future<void> _loadPreferences() async {
    final uid = authController.currentUser?.uid;
    if (uid == null) {
      setState(() => _isLoading = false);
      return;
    }
    final settings = await _authService.getUserSettings(uid);
    final notifications =
        settings['notifications'] as Map<String, dynamic>? ??
        const <String, dynamic>{};
    if (!mounted) return;
    setState(() {
      reminders = notifications['dailyReminders'] as bool? ?? true;
      pendingActivities = notifications['pendingActivities'] as bool? ?? true;
      levelUpdates = notifications['levelUpdates'] as bool? ?? true;
      _isLoading = false;
    });
  }

  Future<void> _savePreferences() async {
    final uid = authController.currentUser?.uid;
    if (uid == null) return;
    await _authService.updateNotificationPreferences(
      uid: uid,
      dailyReminders: reminders,
      pendingActivities: pendingActivities,
      levelUpdates: levelUpdates,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Notifications')),
      backgroundColor: const Color(0xFFF4F8FE),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                SwitchListTile(
                  value: reminders,
                  title: const Text('Daily Reminders'),
                  subtitle: const Text('Receive reminders to practice'),
                  onChanged: (value) async {
                    setState(() => reminders = value);
                    await _savePreferences();
                  },
                ),
                SwitchListTile(
                  value: pendingActivities,
                  title: const Text('Pending Activities'),
                  subtitle: const Text('Notifications of tasks to do'),
                  onChanged: (value) async {
                    setState(() => pendingActivities = value);
                    await _savePreferences();
                  },
                ),
                SwitchListTile(
                  value: levelUpdates,
                  title: const Text('Level Updates'),
                  subtitle: const Text('Notification when you level up'),
                  onChanged: (value) async {
                    setState(() => levelUpdates = value);
                    await _savePreferences();
                  },
                ),
              ],
            ),
    );
  }
}

class LearningProgressScreen extends StatelessWidget {
  const LearningProgressScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final uid = authController.currentUser?.uid;
    final authService = AuthService();
    return Scaffold(
      appBar: AppBar(title: const Text('Learning Progress')),
      backgroundColor: const Color(0xFFF4F8FE),
      body: uid == null
          ? const Center(child: Text('No authenticated user.'))
          : StreamBuilder<Map<String, double>>(
              stream: authService.watchSkillProgress(uid),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }
                final progress = snapshot.data ?? const <String, double>{};
                return ListView(
                  padding: const EdgeInsets.all(16),
                  children: [
                    _ProgressTile(
                      skill: 'Listening',
                      progress: progress['listening'] ?? 0.0,
                    ),
                    _ProgressTile(
                      skill: 'Speaking',
                      progress: progress['speaking'] ?? 0.0,
                    ),
                    _ProgressTile(
                      skill: 'Reading',
                      progress: progress['reading'] ?? 0.0,
                    ),
                    _ProgressTile(
                      skill: 'Writing',
                      progress: progress['writing'] ?? 0.0,
                    ),
                    const SizedBox(height: 28),
                    OutlinedButton.icon(
                      onPressed: () => showResetLearningProgressDialog(context),
                      icon: const Icon(Icons.restart_alt_rounded),
                      label: const Text('Reset practice progress'),
                    ),
                  ],
                );
              },
            ),
    );
  }
}

class AppLanguageScreen extends StatefulWidget {
  const AppLanguageScreen({super.key});

  @override
  State<AppLanguageScreen> createState() => _AppLanguageScreenState();
}

class _AppLanguageScreenState extends State<AppLanguageScreen> {
  final _authService = AuthService();
  String language = 'es';
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadLanguage();
  }

  Future<void> _loadLanguage() async {
    final uid = authController.currentUser?.uid;
    if (uid == null) {
      setState(() => _isLoading = false);
      return;
    }
    final settings = await _authService.getUserSettings(uid);
    if (!mounted) return;
    setState(() {
      language = (settings['appLanguage'] as String?) ?? 'es';
      _isLoading = false;
    });
  }

  Future<void> _saveLanguage(String newLanguage) async {
    final uid = authController.currentUser?.uid;
    if (uid == null) return;
    await _authService.updateAppLanguage(uid: uid, languageCode: newLanguage);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('App Language')),
      backgroundColor: const Color(0xFFF4F8FE),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                const Text(
                  'Select the app language',
                  style: TextStyle(fontSize: 15, color: Color(0xFF5F6F86)),
                ),
                const SizedBox(height: 12),
                SegmentedButton<String>(
                  segments: const [
                    ButtonSegment<String>(value: 'es', label: Text('Spanish')),
                    ButtonSegment<String>(value: 'en', label: Text('English')),
                  ],
                  selected: {language},
                  onSelectionChanged: (selection) async {
                    final selected = selection.first;
                    setState(() => language = selected);
                    await _saveLanguage(selected);
                  },
                ),
                const SizedBox(height: 12),
                Text(
                  'Current language: ${language == 'es' ? 'Spanish' : 'English'}',
                  style: const TextStyle(
                    fontSize: 14,
                    color: Color(0xFF7A879A),
                  ),
                ),
              ],
            ),
    );
  }
}

class HelpCenterScreen extends StatelessWidget {
  const HelpCenterScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Help Center')),
      backgroundColor: const Color(0xFFF4F8FE),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const ExpansionTile(
            title: Text('How to level up?'),
            children: [
              Padding(
                padding: EdgeInsets.all(16),
                child: Text(
                  'Complete activities of each skill to increase your progress.',
                ),
              ),
            ],
          ),
          const ExpansionTile(
            title: Text('What happens to the resolved activities?'),
            children: [
              Padding(
                padding: EdgeInsets.all(16),
                child: Text(
                  'The resolved activities must disappear from the pending list.',
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          ElevatedButton.icon(
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Support contacted. We will respond soon.'),
                ),
              );
            },
            icon: const Icon(Icons.support_agent_rounded),
            label: const Text('Contact support'),
          ),
        ],
      ),
    );
  }
}

class _InfoTile extends StatelessWidget {
  const _InfoTile({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(title: Text(label), subtitle: Text(value)),
    );
  }
}

class _ProgressTile extends StatelessWidget {
  const _ProgressTile({required this.skill, required this.progress});

  final String skill;
  final double progress;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              skill,
              style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 16),
            ),
            const SizedBox(height: 8),
            LinearProgressIndicator(value: progress),
            const SizedBox(height: 6),
            Text('${(progress * 100).round()}%'),
          ],
        ),
      ),
    );
  }
}
