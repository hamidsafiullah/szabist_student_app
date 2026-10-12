import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import 'core/constants/app_constants.dart';
import 'core/router/app_router.dart';
import 'core/theme/app_theme.dart';
import 'features/auth/providers/session_controller.dart';
import 'features/auth/screens/firebase_setup_screen.dart';
import 'features/auth/services/auth_service.dart';
import 'features/family/services/family_service.dart';
import 'firebase_options.dart';

class FamilyConnectApp extends StatelessWidget {
  const FamilyConnectApp({super.key});

  @override
  Widget build(BuildContext context) {
    if (!DefaultFirebaseOptions.isConfigured) {
      return MaterialApp(
        title: AppConstants.appName,
        theme: AppTheme.light,
        debugShowCheckedModeBanner: false,
        home: const FirebaseSetupScreen(),
      );
    }

    return const _ConfiguredApp();
  }
}

class _ConfiguredApp extends StatefulWidget {
  const _ConfiguredApp();

  @override
  State<_ConfiguredApp> createState() => _ConfiguredAppState();
}

class _ConfiguredAppState extends State<_ConfiguredApp> {
  late final AuthService _authService;
  late final FamilyService _familyService;
  late final SessionController _session;
  late final GoRouter _router;

  @override
  void initState() {
    super.initState();
    _authService = AuthService();
    _familyService = FamilyService();
    _session = SessionController(_authService);
    _router = createAppRouter(_session);
  }

  @override
  void dispose() {
    _session.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        Provider.value(value: _authService),
        Provider.value(value: _familyService),
        ChangeNotifierProvider.value(value: _session),
      ],
      child: MaterialApp.router(
        title: AppConstants.appName,
        theme: AppTheme.light,
        routerConfig: _router,
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}
