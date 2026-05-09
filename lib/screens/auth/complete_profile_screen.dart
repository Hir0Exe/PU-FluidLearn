import 'dart:async';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../../app_state.dart';
import '../../services/auth_service.dart';
import '../../theme/fluidlearn_colors.dart';

class CompleteProfileScreen extends StatefulWidget {
  const CompleteProfileScreen({super.key});

  @override
  State<CompleteProfileScreen> createState() => _CompleteProfileScreenState();
}

class _CompleteProfileScreenState extends State<CompleteProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final _auth = AuthService();
  late final TextEditingController _nameCtrl;
  late final TextEditingController _sidCtrl;
  late final TextEditingController _bioCtrl;

  XFile? _pickedImage;
  Uint8List? _pickedPreviewBytes;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    final u = authController.appUser;
    _nameCtrl = TextEditingController(text: u?.fullName ?? '');
    _sidCtrl = TextEditingController(text: u?.studentId ?? '');
    _bioCtrl = TextEditingController(text: u?.bio ?? '');
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _sidCtrl.dispose();
    _bioCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickPhoto() async {
    final picked = await ImagePicker().pickImage(
      source: ImageSource.gallery,
      maxWidth: 1024,
      maxHeight: 1024,
      imageQuality: 85,
    );
    if (picked == null || !mounted) return;
    final bytes = await picked.readAsBytes();
    setState(() {
      _pickedImage = picked;
      _pickedPreviewBytes = bytes;
    });
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    final uid = authController.currentUser?.uid;
    final email = authController.currentUser?.email;
    if (uid == null || email == null) return;

    setState(() => _saving = true);
    try {
      var photoUrl = authController.appUser?.profilePhotoUrl;
      if (_pickedImage != null) {
        String? uploaded;
        try {
          uploaded = await _auth
              .uploadProfilePhoto(
                uid: uid,
                file: _pickedImage!,
                bytes: _pickedPreviewBytes,
              )
              .timeout(const Duration(seconds: 90));
        } on TimeoutException {
          if (!mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                'La foto tardó demasiado. En el navegador suele deberse a '
                'reglas/CORS de Firebase Storage; revisa la consola del proyecto.',
              ),
              backgroundColor: Color(0xFFC67D00),
            ),
          );
          return;
        }
        if (uploaded == null) {
          if (!mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                'No se pudo subir la foto. Revisa conexión y permisos de Storage.',
              ),
              backgroundColor: Color(0xFFC67D00),
            ),
          );
          return;
        }
        photoUrl = uploaded;
      }

      try {
        await _auth
            .completeStudentProfile(
              uid: uid,
              email: email,
              fullName: _nameCtrl.text,
              studentId: _sidCtrl.text,
              bio: _bioCtrl.text,
              profilePhotoUrl: photoUrl,
            )
            .timeout(const Duration(seconds: 45));
        await authController
            .refreshProfile()
            .timeout(const Duration(seconds: 30));
      } on TimeoutException {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Guardar el perfil tardó demasiado. Revisa conexión o reglas de Firestore.',
            ),
            backgroundColor: Color(0xFFC67D00),
          ),
        );
        return;
      }

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Profile saved')),
      );
      Navigator.of(context).pop();
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

  @override
  Widget build(BuildContext context) {
    final existingUrl = authController.appUser?.profilePhotoUrl;

    ImageProvider<Object>? avatarImage;
    if (_pickedPreviewBytes != null) {
      avatarImage = MemoryImage(_pickedPreviewBytes!);
    } else if (existingUrl != null && existingUrl.trim().isNotEmpty) {
      avatarImage = NetworkImage(existingUrl);
    }

    return Scaffold(
      backgroundColor: FluidLearnColors.scaffold,
      appBar: AppBar(
        title: const Text('Edit profile'),
        backgroundColor: FluidLearnColors.scaffold,
        foregroundColor: FluidLearnColors.textPrimary,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Center(
                child: Stack(
                  clipBehavior: Clip.none,
                  children: [
                    CircleAvatar(
                      radius: 56,
                      backgroundColor: const Color(0xFFDADDE3),
                      backgroundImage: avatarImage,
                      child: avatarImage == null
                          ? const Icon(
                              Icons.person_outline_rounded,
                              size: 48,
                              color: Color(0xFF697386),
                            )
                          : null,
                    ),
                    Positioned(
                      bottom: -2,
                      right: -2,
                      child: Material(
                        color: FluidLearnColors.brandBlue,
                        shape: const CircleBorder(),
                        elevation: 2,
                        child: IconButton(
                          icon: const Icon(
                            Icons.camera_alt_rounded,
                            color: Colors.white,
                            size: 22,
                          ),
                          tooltip: 'Upload profile photo',
                          onPressed: _pickPhoto,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'JPG / PNG from gallery',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 12,
                  color: FluidLearnColors.textSecondary,
                ),
              ),
              const SizedBox(height: 24),
              TextFormField(
                controller: _nameCtrl,
                decoration: const InputDecoration(
                  labelText: 'Full name',
                  border: OutlineInputBorder(),
                ),
                textCapitalization: TextCapitalization.words,
                validator: (v) =>
                    v == null || v.trim().isEmpty ? 'Enter your name' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _sidCtrl,
                decoration: const InputDecoration(
                  labelText: 'USB student ID',
                  border: OutlineInputBorder(),
                ),
                validator: (v) =>
                    v == null || v.trim().isEmpty ? 'Enter your student ID' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _bioCtrl,
                decoration: const InputDecoration(
                  labelText: 'Bio (optional)',
                  hintText: 'e.g. Passionate about language learning',
                  border: OutlineInputBorder(),
                  alignLabelWithHint: true,
                ),
                maxLines: 3,
              ),
              const SizedBox(height: 28),
              FilledButton(
                onPressed: _saving ? null : _save,
                style: FilledButton.styleFrom(
                  backgroundColor: FluidLearnColors.brandBlue,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: _saving
                    ? const SizedBox(
                        height: 22,
                        width: 22,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Text('Save changes'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
