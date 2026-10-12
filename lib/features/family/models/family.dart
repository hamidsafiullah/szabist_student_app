class Family {
  const Family({
    required this.id,
    required this.name,
    required this.inviteCode,
    required this.createdBy,
  });

  final String id;
  final String name;
  final String inviteCode;
  final String createdBy;

  factory Family.fromMap(String id, Map<String, dynamic> data) {
    return Family(
      id: id,
      name: data['name'] as String? ?? '',
      inviteCode: data['inviteCode'] as String? ?? '',
      createdBy: data['createdBy'] as String? ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'inviteCode': inviteCode,
      'createdBy': createdBy,
    };
  }
}

class FamilyMember {
  const FamilyMember({
    required this.uid,
    required this.displayName,
    required this.role,
  });

  final String uid;
  final String displayName;
  final String role;

  factory FamilyMember.fromMap(String uid, Map<String, dynamic> data) {
    return FamilyMember(
      uid: uid,
      displayName: data['displayName'] as String? ?? '',
      role: data['role'] as String? ?? 'child',
    );
  }
}
