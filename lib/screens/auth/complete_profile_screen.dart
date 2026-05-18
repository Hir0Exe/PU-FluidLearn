import 'dart:async';

import 'package:flutter/material.dart';

import '../../app_state.dart';
import '../../services/auth_service.dart';
import '../../theme/fluidlearn_colors.dart';
import '../../widgets/user_avatar_view.dart';
import '../profile/avatar_picker_screen.dart';

class CompleteProfileScreen extends StatefulWidget {
  const CompleteProfileScreen({super.key});

  @override
  State<CompleteProfileScreen> createState() => _CompleteProfileScreenState();
}

class _CompleteProfileScreenState extends State<CompleteProfileScreen> {
  final _auth = AuthService();

  late String _fullName;
  late String _studentId;
  late String _bio;
  int? _avatarIndex;
  bool _saving = false;

  bool get _isOnboarding => authController.needsProfileCompletion;

  @override
  void initState() {
    super.initState();
    final u = authController.appUser;
    _fullName = u?.fullName ?? '';
    _studentId = u?.studentId ?? '';
    _bio = u?.bio ?? '';
    _avatarIndex = u?.avatarIndex;
  }

  Future<void> _persistProfile({
    int? avatarIndex,
    bool clearProfilePhoto = false,
    String? fullName,
    String? studentId,
    String? bio,
  }) async {
    final uid = authController.currentUser?.uid;
    final email = authController.currentUser?.email;
    if (uid == null || email == null) return;

    final name = (fullName ?? _fullName).trim();
    final sid = (studentId ?? _studentId).trim();
    if (name.isEmpty || (_isOnboarding && sid.isEmpty)) return;

    setState(() => _saving = true);
    try {
      await _auth
          .completeStudentProfile(
            uid: uid,
            email: email,
            fullName: name,
            studentId: sid,
            bio: bio ?? _bio,
            avatarIndex: avatarIndex ?? _avatarIndex,
            clearProfilePhoto: clearProfilePhoto,
          )
          .timeout(const Duration(seconds: 45));
      await authController.refreshProfile().timeout(
            const Duration(seconds: 30),
          );
      if (!mounted) return;
      if (!_isOnboarding) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Profile saved')),
        );
      }
    } on TimeoutException {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Saving took too long. Check your connection.',
          ),
          backgroundColor: Color(0xFFC67D00),
        ),
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Could not save: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  Future<void> _openAvatarPicker() async {
    final picked = await Navigator.of(context).push<int?>(
      MaterialPageRoute<int?>(
        builder: (_) => AvatarPickerScreen(initialIndex: _avatarIndex),
      ),
    );
    if (picked == null || !mounted) return;
    setState(() => _avatarIndex = picked);
    await _persistProfile(avatarIndex: picked, clearProfilePhoto: true);
  }

  Future<void> _showEditNameDialog() async {
    final ctrl = TextEditingController(text: _fullName);
    final saved = await showDialog<bool>(
      context: context,
      builder: (ctx) => _EditFieldDialog(
        title: 'Edit display name',
        controller: ctrl,
        validator: (v) =>
            v == null || v.trim().isEmpty ? 'Enter your name' : null,
      ),
    );
    if (saved != true || !mounted) return;
    setState(() => _fullName = ctrl.text.trim());
    await _persistProfile(fullName: _fullName);
  }

  Future<void> _showEditStudentIdDialog() async {
    final ctrl = TextEditingController(text: _studentId);
    final saved = await showDialog<bool>(
      context: context,
      builder: (ctx) => _EditFieldDialog(
        title: 'Edit USB student ID',
        controller: ctrl,
        validator: (v) =>
            v == null || v.trim().isEmpty ? 'Enter your student ID' : null,
      ),
    );
    if (saved != true || !mounted) return;
    setState(() => _studentId = ctrl.text.trim());
    await _persistProfile(studentId: _studentId);
  }

  Future<void> _showEditBioDialog() async {
    final ctrl = TextEditingController(text: _bio);
    final saved = await showDialog<bool>(
      context: context,
      builder: (ctx) => _EditFieldDialog(
        title: 'Edit bio',
        controller: ctrl,
        maxLines: 3,
        allowEmpty: true,
      ),
    );
    if (saved != true || !mounted) return;
    setState(() => _bio = ctrl.text.trim());
    await _persistProfile(bio: _bio);
  }

  @override
  Widget build(BuildContext context) {
    final canPop = Navigator.of(context).canPop();

    return Scaffold(
      backgroundColor: const Color(0xFFF4F6F8),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF4F6F8),
        elevation: 0,
        scrolledUnderElevation: 0,
        automaticallyImplyLeading: canPop,
        centerTitle: true,
        title: const Text(
          'Personal Data',
          style: TextStyle(
            color: FluidLearnColors.textPrimary,
            fontWeight: FontWeight.w700,
            fontSize: 18,
          ),
        ),
        foregroundColor: FluidLearnColors.textPrimary,
      ),
      body: _saving
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.fromLTRB(0, 8, 0, 32),
              children: [
                _PersonalDataRow(
                  label: 'Profile Photo',
                  onTap: _openAvatarPicker,
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      UserAvatarView(
                        avatarIndex: _avatarIndex,
                        profilePhotoUrl:
                            authController.appUser?.profilePhotoUrl,
                        size: 40,
                      ),
                      const SizedBox(width: 6),
                      const Icon(
                        Icons.chevron_right_rounded,
                        color: Color(0xFFB0BAC9),
                        size: 22,
                      ),
                    ],
                  ),
                ),
                const _RowDivider(),
                _PersonalDataRow(
                  label: 'Name',
                  value: _fullName.isEmpty ? 'No name' : _fullName,
                  onTap: _showEditNameDialog,
                ),
                if (_isOnboarding) ...[
                  const _RowDivider(),
                  _PersonalDataRow(
                    label: 'USB Student ID',
                    value: _studentId.isEmpty ? 'No student ID' : _studentId,
                    onTap: _showEditStudentIdDialog,
                  ),
                ],
                if (!_isOnboarding) ...[
                  const _RowDivider(),
                  _PersonalDataRow(
                    label: 'Bio',
                    value: _bio.isEmpty ? 'No bio' : _bio,
                    onTap: _showEditBioDialog,
                  ),
                ],
                if (_isOnboarding) ...[
                  const SizedBox(height: 28),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Text(
                      'Complete your name and USB student ID to continue.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 13,
                        color: FluidLearnColors.textSecondary,
                      ),
                    ),
                  ),
                ],
              ],
            ),
    );
  }
}

class _PersonalDataRow extends StatelessWidget {
  const _PersonalDataRow({
    required this.label,
    required this.onTap,
    this.value,
    this.trailing,
  });

  final String label;
  final String? value;
  final Widget? trailing;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Row(
            children: [
              Text(
                label,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: FluidLearnColors.textPrimary,
                ),
              ),
              const Spacer(),
              if (value != null)
                Flexible(
                  child: Text(
                    value!,
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.right,
                    style: const TextStyle(
                      fontSize: 15,
                      color: Color(0xFF7A879A),
                    ),
                  ),
                ),
              if (trailing != null) ...[
                if (value != null) const SizedBox(width: 8),
                trailing!,
              ] else ...[
                const SizedBox(width: 4),
                const Icon(
                  Icons.chevron_right_rounded,
                  color: Color(0xFFB0BAC9),
                  size: 22,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _RowDivider extends StatelessWidget {
  const _RowDivider();

  @override
  Widget build(BuildContext context) {
    return const Divider(
      height: 1,
      thickness: 1,
      indent: 20,
      endIndent: 20,
      color: Color(0xFFE8ECF2),
    );
  }
}

class _EditFieldDialog extends StatefulWidget {
  const _EditFieldDialog({
    required this.title,
    required this.controller,
    this.validator,
    this.maxLines = 1,
    this.allowEmpty = false,
  });

  final String title;
  final TextEditingController controller;
  final String? Function(String?)? validator;
  final int maxLines;
  final bool allowEmpty;

  @override
  State<_EditFieldDialog> createState() => _EditFieldDialogState();
}

class _EditFieldDialogState extends State<_EditFieldDialog> {
  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      insetPadding: const EdgeInsets.symmetric(horizontal: 28),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 22, 20, 12),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                widget.title,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w700,
                  color: FluidLearnColors.textPrimary,
                ),
              ),
              const SizedBox(height: 18),
              TextFormField(
                controller: widget.controller,
                autofocus: true,
                maxLines: widget.maxLines,
                decoration: InputDecoration(
                  filled: true,
                  fillColor: const Color(0xFFF4F6F8),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                  suffixIcon: IconButton(
                    icon: const Icon(Icons.close_rounded, size: 20),
                    color: const Color(0xFF9AA4B8),
                    onPressed: () => widget.controller.clear(),
                  ),
                ),
                validator: widget.allowEmpty
                    ? null
                    : widget.validator ??
                        (v) => v == null || v.trim().isEmpty
                            ? 'Required field'
                            : null,
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(false),
                    child: const Text(
                      'Cancel',
                      style: TextStyle(color: Color(0xFF7A879A)),
                    ),
                  ),
                  const Spacer(),
                  TextButton(
                    onPressed: () {
                      if (_formKey.currentState?.validate() != true) return;
                      Navigator.of(context).pop(true);
                    },
                    child: const Text(
                      'Save',
                      style: TextStyle(
                        color: FluidLearnColors.textPrimary,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
