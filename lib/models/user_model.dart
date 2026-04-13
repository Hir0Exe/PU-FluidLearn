/// Perfil de estudiante para validación de nivel de inglés (USB).
class UserModel {
  final String uid;
  final String email;
  final String fullName;
  final String studentId;
  final bool profileComplete;
  final DateTime createdAt;

  const UserModel({
    required this.uid,
    required this.email,
    required this.fullName,
    required this.studentId,
    required this.profileComplete,
    required this.createdAt,
  });

  bool get isProfileComplete =>
      profileComplete ||
      (fullName.trim().isNotEmpty && studentId.trim().isNotEmpty);

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'email': email,
      'fullName': fullName,
      'studentId': studentId,
      'profileComplete': profileComplete,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory UserModel.fromMap(Map<String, dynamic> map) {
    final createdRaw = map['createdAt'];
    DateTime created;
    if (createdRaw is String) {
      created = DateTime.tryParse(createdRaw) ?? DateTime.now();
    } else {
      created = DateTime.now();
    }

    final full = (map['fullName'] ?? '') as String;
    final sid = (map['studentId'] ?? '') as String;
    final explicit = map['profileComplete'] == true;

    return UserModel(
      uid: map['uid'] ?? '',
      email: map['email'] ?? '',
      fullName: full,
      studentId: sid,
      profileComplete: explicit || (full.trim().isNotEmpty && sid.trim().isNotEmpty),
      createdAt: created,
    );
  }
}
