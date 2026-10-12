import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';

import '../../auth/models/app_user.dart';
import '../models/family.dart';
import '../../../core/constants/app_constants.dart';

class FamilyService {
  FamilyService({FirebaseFirestore? firestore})
      : _db = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _db;
  final _random = Random.secure();

  CollectionReference<Map<String, dynamic>> get _families =>
      _db.collection('families');

  CollectionReference<Map<String, dynamic>> get _users =>
      _db.collection('users');

  String _generateInviteCode() {
    const chars = 'ABCDEFGHJKLMNPQRSTUVWXYZ23456789';
    return List.generate(
      AppConstants.inviteCodeLength,
      (_) => chars[_random.nextInt(chars.length)],
    ).join();
  }

  Future<Family> createFamily({
    required AppUser user,
    required String familyName,
  }) async {
    if (!user.isParent) {
      throw StateError('Only parents can create a family.');
    }
    if (user.hasFamily) {
      throw StateError('You already belong to a family.');
    }

    final inviteCode = _generateInviteCode();
    final doc = _families.doc();
    final family = Family(
      id: doc.id,
      name: familyName.trim(),
      inviteCode: inviteCode,
      createdBy: user.uid,
    );

    final batch = _db.batch();
    batch.set(doc, {
      ...family.toMap(),
      'createdAt': FieldValue.serverTimestamp(),
    });
    batch.set(doc.collection('members').doc(user.uid), {
      'role': user.role.value,
      'displayName': user.name,
      'joinedAt': FieldValue.serverTimestamp(),
    });
    batch.update(_users.doc(user.uid), {'familyId': doc.id});
    await batch.commit();

    return family;
  }

  Future<Family> joinFamily({
    required AppUser user,
    required String inviteCode,
  }) async {
    if (user.hasFamily) {
      throw StateError('You already belong to a family.');
    }

    final code = inviteCode.trim().toUpperCase();
    final query = await _families
        .where('inviteCode', isEqualTo: code)
        .limit(1)
        .get();

    if (query.docs.isEmpty) {
      throw StateError('Invalid invite code.');
    }

    final familyDoc = query.docs.first;
    final family = Family.fromMap(familyDoc.id, familyDoc.data());

    final batch = _db.batch();
    batch.set(familyDoc.reference.collection('members').doc(user.uid), {
      'role': user.role.value,
      'displayName': user.name,
      'joinedAt': FieldValue.serverTimestamp(),
    });
    batch.update(_users.doc(user.uid), {'familyId': family.id});
    await batch.commit();

    return family;
  }

  Future<Family?> getFamily(String familyId) async {
    final snap = await _families.doc(familyId).get();
    if (!snap.exists || snap.data() == null) return null;
    return Family.fromMap(snap.id, snap.data()!);
  }

  Stream<Family?> watchFamily(String familyId) {
    return _families.doc(familyId).snapshots().map((snap) {
      if (!snap.exists || snap.data() == null) return null;
      return Family.fromMap(snap.id, snap.data()!);
    });
  }

  Stream<List<FamilyMember>> watchMembers(String familyId) {
    return _families.doc(familyId).collection('members').snapshots().map(
          (snap) => snap.docs
              .map((d) => FamilyMember.fromMap(d.id, d.data()))
              .toList(),
        );
  }
}
