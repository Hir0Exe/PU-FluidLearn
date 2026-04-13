import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_model.dart';

class AuthService {
  static final AuthService _instance = AuthService._internal();
  factory AuthService() => _instance;
  AuthService._internal();

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Stream<User?> get authStateChanges => _auth.authStateChanges();

  User? get currentUser => _auth.currentUser;

  Future<UserModel?> getUserProfile(String uid) async {
    try {
      final doc = await _firestore.collection('users').doc(uid).get();
      if (!doc.exists || doc.data() == null) return null;
      return UserModel.fromMap(doc.data()!);
    } catch (e) {
      print('Error obteniendo perfil: $e');
      return null;
    }
  }

  /// Registro con correo: crea usuario en Auth y perfil completo en Firestore.
  Future<UserCredential?> signUpWithEmail({
    required String email,
    required String password,
    required String fullName,
    required String studentId,
  }) async {
    try {
      final UserCredential userCredential =
          await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      await _firestore.collection('users').doc(userCredential.user!.uid).set({
        'uid': userCredential.user!.uid,
        'email': email,
        'fullName': fullName.trim(),
        'studentId': studentId.trim(),
        'profileComplete': true,
        'createdAt': DateTime.now().toIso8601String(),
      });

      return userCredential;
    } on FirebaseAuthException catch (e) {
      print('Error en registro: ${e.message}');
      rethrow;
    }
  }

  Future<UserCredential?> signInWithEmail({
    required String email,
    required String password,
  }) async {
    try {
      return await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
    } on FirebaseAuthException catch (e) {
      print('Error en inicio de sesión: ${e.message}');
      rethrow;
    }
  }

  /// Google: si es usuario nuevo, crea documento mínimo; debe completar datos en la app.
  Future<UserCredential?> signInWithGoogle() async {
    try {
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();

      if (googleUser == null) {
        return null;
      }

      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final UserCredential userCredential =
          await _auth.signInWithCredential(credential);

      if (userCredential.additionalUserInfo?.isNewUser ?? false) {
        await _firestore.collection('users').doc(userCredential.user!.uid).set({
          'uid': userCredential.user!.uid,
          'email': userCredential.user!.email ?? '',
          'fullName': '',
          'studentId': '',
          'profileComplete': false,
          'createdAt': DateTime.now().toIso8601String(),
        });
      }

      return userCredential;
    } catch (e) {
      print('Error en inicio de sesión con Google: $e');
      rethrow;
    }
  }

  Future<void> completeStudentProfile({
    required String uid,
    required String email,
    required String fullName,
    required String studentId,
  }) async {
    final ref = _firestore.collection('users').doc(uid);
    final snap = await ref.get();
    final data = <String, dynamic>{
      'uid': uid,
      'email': email,
      'fullName': fullName.trim(),
      'studentId': studentId.trim(),
      'profileComplete': true,
    };
    if (!snap.exists) {
      data['createdAt'] = DateTime.now().toIso8601String();
    }
    await ref.set(data, SetOptions(merge: true));
  }

  Future<void> signOut() async {
    await _googleSignIn.signOut();
    await _auth.signOut();
  }

  Future<void> deleteAccount() async {
    final user = _auth.currentUser;
    if (user == null) {
      throw Exception('No hay usuario autenticado');
    }

    final uid = user.uid;
    await _firestore.collection('users').doc(uid).delete();
    await user.delete();
  }
}
