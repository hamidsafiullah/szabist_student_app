import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../shared/widgets/avatar_placeholder.dart';
import '../../family/services/family_service.dart';
import '../models/app_user.dart';
import '../providers/session_controller.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _name = TextEditingController();
  bool _editing = false;
  bool _busy = false;

  @override
  void dispose() {
    _name.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    setState(() => _busy = true);
    try {
      await context.read<SessionController>().updateDisplayName(_name.text);
      if (mounted) setState(() => _editing = false);
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

    if (!_editing && _name.text != user.name) {
      _name.text = user.name;
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
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
          Center(child: AvatarPlaceholder(name: user.name, radius: 40)),
          const SizedBox(height: 16),
          if (_editing) ...[
            TextField(
              controller: _name,
              decoration: const InputDecoration(labelText: 'Display name'),
            ),
            const SizedBox(height: 12),
            FilledButton(
              onPressed: _busy ? null : _save,
              child: const Text('Save'),
            ),
            TextButton(
              onPressed: () => setState(() => _editing = false),
              child: const Text('Cancel'),
            ),
          ] else ...[
            ListTile(
              title: Text(user.name),
              subtitle: Text(user.email),
              trailing: IconButton(
                icon: const Icon(Icons.edit_outlined),
                onPressed: () => setState(() => _editing = true),
              ),
            ),
          ],
          const Divider(),
          ListTile(
            leading: const Icon(Icons.badge_outlined),
            title: const Text('Role'),
            subtitle: Text(user.role.value),
          ),
          if (user.familyId != null)
            StreamBuilder(
              stream:
                  context.read<FamilyService>().watchFamily(user.familyId!),
              builder: (context, snap) {
                final family = snap.data;
                return ListTile(
                  leading: const Icon(Icons.home_outlined),
                  title: const Text('Family'),
                  subtitle: Text(
                    family == null
                        ? user.familyId!
                        : '${family.name} · code ${family.inviteCode}',
                  ),
                );
              },
            ),
        ],
      ),
    );
  }
}
