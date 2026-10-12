import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../models/app_user.dart';

class AuthService {
  AuthService({
    FirebaseAuth? auth,
    FirebaseFirestore? firestore,
  })  : _auth = auth ?? FirebaseAuth.instance,
        _db = firestore ?? FirebaseFirestore.instance;

  final FirebaseAuth _auth;
  final FirebaseFirestore _db;

  Stream<User?> get authStateChanges => _auth.authStateChanges();

  User? get currentFirebaseUser => _auth.currentUser;

  CollectionReference<Map<String, dynamic>> get _users =>
      _db.collection('users');

  Future<AppUser?> fetchProfile(String uid) async {
    final snap = await _users.doc(uid).get();
    if (!snap.exists || snap.data() == null) return null;
    return AppUser.fromMap(uid, snap.data()!);
  }

  Stream<AppUser?> watchProfile(String uid) {
    return _users.doc(uid).snapshots().map((snap) {
      if (!snap.exists || snap.data() == null) return null;
      return AppUser.fromMap(uid, snap.data()!);
    });
  }

  Future<AppUser> register({
    required String name,
    required String email,
    required String password,
    required UserRole role,
  }) async {
    final cred = await _auth.createUserWithEmailAndPassword(
      email: email.trim(),
      password: password,
    );
    final user = cred.user!;
    await user.updateDisplayName(name.trim());

    final profile = AppUser(
      uid: user.uid,
      email: email.trim(),
      name: name.trim(),
      role: role,
    );

    await _users.doc(user.uid).set({
      ...profile.toMap(),
      'fcmTokens': <String>[],
      'createdAt': FieldValue.serverTimestamp(),
    });

    return profile;
  }

  Future<AppUser> signIn({
    required String email,
    required String password,
  }) async {
    final cred = await _auth.signInWithEmailAndPassword(
      email: email.trim(),
      password: password,
    );
    final profile = await fetchProfile(cred.user!.uid);
    if (profile == null) {
      throw StateError('User profile missing in Firestore.');
    }
    return profile;
  }

  Future<void> signOut() => _auth.signOut();

  Future<void> updateDisplayName(String uid, String name) async {
    await _users.doc(uid).update({'name': name.trim()});
    await _auth.currentUser?.updateDisplayName(name.trim());
  }
}
