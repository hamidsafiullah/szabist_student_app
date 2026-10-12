import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../auth/providers/session_controller.dart';
import '../services/family_service.dart';

class HomeShellScreen extends StatelessWidget {
  const HomeShellScreen({
    super.key,
    required this.navigationShell,
  });

  final StatefulNavigationShell navigationShell;

  void _onTap(int index) {
    navigationShell.goBranch(
      index,
      initialLocation: index == navigationShell.currentIndex,
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = context.watch<SessionController>().user;
    final isParent = user?.isParent ?? false;

    final destinations = <NavigationDestination>[
      const NavigationDestination(
        icon: Icon(Icons.chat_bubble_outline),
        selectedIcon: Icon(Icons.chat_bubble),
        label: 'Chat',
      ),
      const NavigationDestination(
        icon: Icon(Icons.checklist_outlined),
        selectedIcon: Icon(Icons.checklist),
        label: 'Tasks',
      ),
      if (isParent)
        const NavigationDestination(
          icon: Icon(Icons.admin_panel_settings_outlined),
          selectedIcon: Icon(Icons.admin_panel_settings),
          label: 'Admin',
        ),
      const NavigationDestination(
        icon: Icon(Icons.person_outline),
        selectedIcon: Icon(Icons.person),
        label: 'Profile',
      ),
    ];

    // Map shell index when child has no Admin tab
    final shellIndex = navigationShell.currentIndex;
    int selectedIndex = shellIndex;
    if (!isParent) {
      // Branches: 0 chat, 1 tasks, 2 admin, 3 profile
      // Destinations: 0 chat, 1 tasks, 2 profile
      if (shellIndex >= 3) {
        selectedIndex = 2;
      } else if (shellIndex == 2) {
        selectedIndex = 0;
      }
    }

    return Scaffold(
      body: navigationShell,
      bottomNavigationBar: NavigationBar(
        selectedIndex: selectedIndex.clamp(0, destinations.length - 1),
        destinations: destinations,
        onDestinationSelected: (i) {
          if (!isParent) {
            // Map UI index → branch index (skip admin=2)
            final branch = i < 2 ? i : 3;
            _onTap(branch);
          } else {
            _onTap(i);
          }
        },
      ),
    );
  }
}

class ChatPlaceholderScreen extends StatelessWidget {
  const ChatPlaceholderScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Family chat')),
      body: const Center(
        child: Padding(
          padding: EdgeInsets.all(24),
          child: Text(
            'Chat arrives in Phase 1.\nYou are signed in and in a family — foundation is ready.',
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }
}

class TasksPlaceholderScreen extends StatelessWidget {
  const TasksPlaceholderScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Tasks')),
      body: const Center(
        child: Padding(
          padding: EdgeInsets.all(24),
          child: Text(
            'Task assignment arrives in Phase 1.',
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }
}

class AdminPlaceholderScreen extends StatelessWidget {
  const AdminPlaceholderScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final familyId = context.watch<SessionController>().user?.familyId;
    if (familyId == null) {
      return const Scaffold(body: Center(child: Text('No family')));
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Family admin')),
      body: StreamBuilder(
        stream: context.read<FamilyService>().watchFamily(familyId),
        builder: (context, familySnap) {
          final family = familySnap.data;
          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              if (family != null) ...[
                ListTile(
                  title: Text(family.name),
                  subtitle: Text('Invite code: ${family.inviteCode}'),
                ),
                const Divider(),
              ],
              const Padding(
                padding: EdgeInsets.all(8),
                child: Text(
                  'Full admin controls (remove member, regenerate code) land in Phase 1. '
                  'Invite code is shown so you can share it now.',
                ),
              ),
              StreamBuilder(
                stream: context.read<FamilyService>().watchMembers(familyId),
                builder: (context, membersSnap) {
                  final members = membersSnap.data ?? [];
                  return Column(
                    children: members
                        .map(
                          (m) => ListTile(
                            leading: const Icon(Icons.person),
                            title: Text(m.displayName),
                            subtitle: Text(m.role),
                          ),
                        )
                        .toList(),
                  );
                },
              ),
            ],
          );
        },
      ),
    );
  }
}
