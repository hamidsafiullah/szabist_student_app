import 'package:flutter/material.dart';

import '../../../core/constants/app_constants.dart';

class FirebaseSetupScreen extends StatelessWidget {
  const FirebaseSetupScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: ListView(
            children: [
              Text(
                AppConstants.appName,
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 8),
              Text(
                'Firebase is not configured yet',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 16),
              const Text(
                'Phase 0 needs a Firebase project (free Spark tier). '
                'Do this once on your Windows machine:',
              ),
              const SizedBox(height: 16),
              const _Step(
                number: '1',
                text:
                    'Create a project at https://console.firebase.google.com',
              ),
              const _Step(
                number: '2',
                text:
                    'Enable Authentication → Email/Password and create a Firestore database.',
              ),
              const _Step(
                number: '3',
                text:
                    'Add an Android app with package name '
                    'com.familyconnect.family_connect and download '
                    'google-services.json into android/app/.',
              ),
              const _Step(
                number: '4',
                text:
                    'Run:\n'
                    '  dart pub global activate flutterfire_cli\n'
                    '  flutterfire configure\n'
                    'This rewrites lib/firebase_options.dart.',
              ),
              const _Step(
                number: '5',
                text:
                    'In lib/firebase_options.dart set '
                    'DefaultFirebaseOptions.isConfigured = true',
              ),
              const SizedBox(height: 24),
              Text(
                'See FIREBASE_SETUP.md in the repo for details.',
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Step extends StatelessWidget {
  const _Step({required this.number, required this.text});

  final String number;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: 14,
            child: Text(number, style: const TextStyle(fontSize: 12)),
          ),
          const SizedBox(width: 12),
          Expanded(child: Text(text)),
        ],
      ),
    );
  }
}
