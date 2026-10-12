import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../auth/models/app_user.dart';
import '../../auth/providers/session_controller.dart';
import '../services/family_service.dart';

class OnboardingFamilyScreen extends StatefulWidget {
  const OnboardingFamilyScreen({super.key});

  @override
  State<OnboardingFamilyScreen> createState() => _OnboardingFamilyScreenState();
}

class _OnboardingFamilyScreenState extends State<OnboardingFamilyScreen> {
  final _familyName = TextEditingController();
  final _inviteCode = TextEditingController();
  bool _busy = false;
  String? _error;

  @override
  void dispose() {
    _familyName.dispose();
    _inviteCode.dispose();
    super.dispose();
  }

  Future<void> _create(AppUser user) async {
    if (_familyName.text.trim().isEmpty) {
      setState(() => _error = 'Enter a family name');
      return;
    }
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      await context.read<FamilyService>().createFamily(
            user: user,
            familyName: _familyName.text,
          );
    } catch (e) {
      if (!mounted) return;
      setState(() => _error = e.toString());
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _join(AppUser user) async {
    if (_inviteCode.text.trim().isEmpty) {
      setState(() => _error = 'Enter an invite code');
      return;
    }
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      await context.read<FamilyService>().joinFamily(
            user: user,
            inviteCode: _inviteCode.text,
          );
    } catch (e) {
      if (!mounted) return;
      setState(() => _error = e.toString());
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final session = context.watch<SessionController>();
    final user = session.user;
    if (user == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Join your family'),
        actions: [
          TextButton(
            onPressed: () => session.signOut(),
            child: const Text('Sign out'),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          Text('Hi ${user.name}', style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 8),
          Text(
            user.isParent
                ? 'Create a family and share the invite code with your kids.'
                : 'Ask a parent for the invite code to join.',
          ),
          const SizedBox(height: 24),
          if (user.isParent) ...[
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      'Create family',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: _familyName,
                      decoration: const InputDecoration(
                        labelText: 'Family name',
                        hintText: 'e.g. The Khans',
                      ),
                    ),
                    const SizedBox(height: 12),
                    FilledButton(
                      onPressed: _busy ? null : () => _create(user),
                      child: const Text('Create family'),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            const Center(child: Text('or')),
            const SizedBox(height: 16),
          ],
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    'Join with invite code',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _inviteCode,
                    textCapitalization: TextCapitalization.characters,
                    decoration: const InputDecoration(
                      labelText: 'Invite code',
                      hintText: '6 characters',
                    ),
                  ),
                  const SizedBox(height: 12),
                  FilledButton.tonal(
                    onPressed: _busy ? null : () => _join(user),
                    child: const Text('Join family'),
                  ),
                ],
              ),
            ),
          ),
          if (_error != null) ...[
            const SizedBox(height: 16),
            Text(
              _error!,
              style: TextStyle(color: Theme.of(context).colorScheme.error),
            ),
          ],
          if (_busy) ...[
            const SizedBox(height: 16),
            const Center(child: CircularProgressIndicator()),
          ],
        ],
      ),
    );
  }
}
