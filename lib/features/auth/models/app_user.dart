enum UserRole { parent, child }

extension UserRoleX on UserRole {
  String get value => name;

  static UserRole fromString(String? raw) {
    return UserRole.values.firstWhere(
      (r) => r.name == raw,
      orElse: () => UserRole.child,
    );
  }
}

class AppUser {
  const AppUser({
    required this.uid,
    required this.email,
    required this.name,
    required this.role,
    this.familyId,
  });

  final String uid;
  final String email;
  final String name;
  final UserRole role;
  final String? familyId;

  bool get hasFamily => familyId != null && familyId!.isNotEmpty;

  bool get isParent => role == UserRole.parent;

  AppUser copyWith({
    String? name,
    UserRole? role,
    String? familyId,
    bool clearFamilyId = false,
  }) {
    return AppUser(
      uid: uid,
      email: email,
      name: name ?? this.name,
      role: role ?? this.role,
      familyId: clearFamilyId ? null : (familyId ?? this.familyId),
    );
  }

  factory AppUser.fromMap(String uid, Map<String, dynamic> data) {
    return AppUser(
      uid: uid,
      email: data['email'] as String? ?? '',
      name: data['name'] as String? ?? '',
      role: UserRoleX.fromString(data['role'] as String?),
      familyId: data['familyId'] as String?,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'email': email,
      'name': name,
      'role': role.value,
      'familyId': familyId,
    };
  }
}
