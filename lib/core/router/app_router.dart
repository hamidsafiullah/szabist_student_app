import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../features/auth/providers/session_controller.dart';
import '../../features/auth/screens/firebase_setup_screen.dart';
import '../../features/auth/screens/login_screen.dart';
import '../../features/auth/screens/profile_screen.dart';
import '../../features/auth/screens/register_screen.dart';
import '../../features/family/screens/home_shell_screen.dart';
import '../../features/family/screens/onboarding_family_screen.dart';
import '../../firebase_options.dart';

class GoRouterRefreshStream extends ChangeNotifier {
  GoRouterRefreshStream(Listenable listenable) {
    listenable.addListener(notifyListeners);
    _listenable = listenable;
  }

  late final Listenable _listenable;

  @override
  void dispose() {
    _listenable.removeListener(notifyListeners);
    super.dispose();
  }
}

GoRouter createAppRouter(SessionController session) {
  return GoRouter(
    initialLocation: '/login',
    refreshListenable: GoRouterRefreshStream(session),
    redirect: (context, state) {
      if (!DefaultFirebaseOptions.isConfigured) {
        return state.matchedLocation == '/setup' ? null : '/setup';
      }

      final loc = state.matchedLocation;
      final status = session.status;

      if (status == SessionStatus.loading) {
        return loc == '/splash' ? null : '/splash';
      }

      final loggedOut = status == SessionStatus.unauthenticated;
      final needsFamily = status == SessionStatus.needsFamily;
      final ready = status == SessionStatus.ready;

      final onAuth = loc == '/login' || loc == '/register';
      final onFamily = loc == '/onboarding-family';
      final onSplash = loc == '/splash';
      final onSetup = loc == '/setup';

      if (loggedOut) {
        return onAuth ? null : '/login';
      }
      if (needsFamily) {
        return onFamily ? null : '/onboarding-family';
      }
      if (ready) {
        if (onAuth || onFamily || onSplash || onSetup) {
          return '/chat';
        }
      }
      return null;
    },
    routes: [
      GoRoute(
        path: '/setup',
        builder: (context, state) => const FirebaseSetupScreen(),
      ),
      GoRoute(
        path: '/splash',
        builder: (context, state) => const Scaffold(
          body: Center(child: CircularProgressIndicator()),
        ),
      ),
      GoRoute(
        path: '/login',
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: '/register',
        builder: (context, state) => const RegisterScreen(),
      ),
      GoRoute(
        path: '/onboarding-family',
        builder: (context, state) => const OnboardingFamilyScreen(),
      ),
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) {
          return HomeShellScreen(navigationShell: navigationShell);
        },
        branches: [
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/chat',
                builder: (context, state) => const ChatPlaceholderScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/tasks',
                builder: (context, state) => const TasksPlaceholderScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/admin',
                builder: (context, state) => const AdminPlaceholderScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/profile',
                builder: (context, state) => const ProfileScreen(),
              ),
            ],
          ),
        ],
      ),
    ],
  );
}

/// Helper so widgets can read the router without storing it globally incorrectly.
extension AppRouterX on BuildContext {
  SessionController get session => read<SessionController>();
}
