import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

import '../models/app_user.dart';
import '../services/auth_service.dart';

enum SessionStatus { loading, unauthenticated, needsFamily, ready }

class SessionController extends ChangeNotifier {
  SessionController(this._authService) {
    _authSub = _authService.authStateChanges.listen(_onAuthChanged);
  }

  final AuthService _authService;

  StreamSubscription<User?>? _authSub;
  StreamSubscription<AppUser?>? _profileSub;

  SessionStatus status = SessionStatus.loading;
  AppUser? user;
  String? errorMessage;

  Future<void> _onAuthChanged(User? firebaseUser) async {
    await _profileSub?.cancel();
    _profileSub = null;

    if (firebaseUser == null) {
      user = null;
      status = SessionStatus.unauthenticated;
      notifyListeners();
      return;
    }

    status = SessionStatus.loading;
    notifyListeners();

    _profileSub = _authService.watchProfile(firebaseUser.uid).listen((profile) {
      user = profile;
      if (profile == null) {
        status = SessionStatus.unauthenticated;
      } else if (!profile.hasFamily) {
        status = SessionStatus.needsFamily;
      } else {
        status = SessionStatus.ready;
      }
      notifyListeners();
    }, onError: (Object e) {
      errorMessage = e.toString();
      status = SessionStatus.unauthenticated;
      notifyListeners();
    });
  }

  Future<void> register({
    required String name,
    required String email,
    required String password,
    required UserRole role,
  }) async {
    errorMessage = null;
    try {
      await _authService.register(
        name: name,
        email: email,
        password: password,
        role: role,
      );
    } on FirebaseAuthException catch (e) {
      errorMessage = e.message ?? e.code;
      notifyListeners();
      rethrow;
    } catch (e) {
      errorMessage = e.toString();
      notifyListeners();
      rethrow;
    }
  }

  Future<void> signIn({
    required String email,
    required String password,
  }) async {
    errorMessage = null;
    try {
      await _authService.signIn(email: email, password: password);
    } on FirebaseAuthException catch (e) {
      errorMessage = e.message ?? e.code;
      notifyListeners();
      rethrow;
    } catch (e) {
      errorMessage = e.toString();
      notifyListeners();
      rethrow;
    }
  }

  Future<void> signOut() => _authService.signOut();

  Future<void> updateDisplayName(String name) async {
    final current = user;
    if (current == null) return;
    await _authService.updateDisplayName(current.uid, name);
  }

  @override
  void dispose() {
    _authSub?.cancel();
    _profileSub?.cancel();
    super.dispose();
  }
}
