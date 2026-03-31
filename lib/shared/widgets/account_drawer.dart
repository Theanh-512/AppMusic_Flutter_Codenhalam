import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:go_router/go_router.dart';
import '../../features/auth/providers/auth_provider.dart';
import 'letter_avatar.dart';

class AccountDrawer extends ConsumerWidget {
  const AccountDrawer({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(currentUserProvider);
    final isAuthenticated = ref.watch(isAuthenticatedProvider);

    return Drawer(
      backgroundColor: const Color(0xFF121212), // Deep black background
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.zero, // Keep it flush for a premium side-panel look
      ),
      child: Column(
        children: [
          // Header Section
          DrawerHeader(
            decoration: const BoxDecoration(
              color: Color(0xFF1E1E1E),
              border: Border(bottom: BorderSide(color: Colors.white10)),
            ),
            child: Row(
              children: [
                LetterAvatar(
                  size: 64,
                  name: user?.userMetadata?['display_name'] ?? 
                        (user?.email?.split('@')[0] ?? 'Guest'),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        user?.userMetadata?['display_name'] ?? (isAuthenticated ? 'User' : 'Guest'),
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        user?.email ?? 'Sign in to sync your music',
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.white54,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Menu Items
          Expanded(
            child: ListView(
              padding: EdgeInsets.zero,
              children: [
                const _DrawerSectionHeader(title: 'Account'),
                
                if (!isAuthenticated)
                  ListTile(
                    leading: const Icon(LucideIcons.logIn, color: Colors.white),
                    title: const Text('Log in / Sign up', style: TextStyle(color: Colors.white)),
                    onTap: () {
                      Navigator.pop(context); // Close drawer
                      context.push('/login');
                    },
                  ),

                ListTile(
                  leading: const Icon(LucideIcons.settings, color: Colors.white),
                  title: const Text('Settings', style: TextStyle(color: Colors.white)),
                  onTap: () {},
                ),
                
                ListTile(
                  leading: const Icon(LucideIcons.history, color: Colors.white),
                  title: const Text('Listening History', style: TextStyle(color: Colors.white)),
                  onTap: () {},
                ),

                const Divider(color: Colors.white10),
                const _DrawerSectionHeader(title: 'Subscription'),
                
                ListTile(
                  leading: const Icon(LucideIcons.sparkles, color: Colors.amber),
                  title: const Text('Get Premium', style: TextStyle(color: Colors.white)),
                  onTap: () {},
                ),

                const Divider(color: Colors.white10),
                const _DrawerSectionHeader(title: 'Support'),
                
                ListTile(
                  leading: const Icon(LucideIcons.helpCircle, color: Colors.white),
                  title: const Text('Help and Support', style: TextStyle(color: Colors.white)),
                  onTap: () {},
                ),
              ],
            ),
          ),

          // Footer Section (Logout)
          if (isAuthenticated)
            Container(
              padding: const EdgeInsets.all(16),
              decoration: const BoxDecoration(
                border: Border(top: BorderSide(color: Colors.white10)),
              ),
              child: ListTile(
                leading: const Icon(LucideIcons.logOut, color: Colors.redAccent),
                title: const Text(
                  'Log out',
                  style: TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold),
                ),
                onTap: () async {
                  // Perform logout
                  await ref.read(authRepositoryProvider).signOut();
                  if (context.mounted) {
                    Navigator.pop(context); // Close drawer
                    context.go('/login');
                  }
                },
              ),
            ),
        ],
      ),
    );
  }
}

class _DrawerSectionHeader extends StatelessWidget {
  final String title;
  const _DrawerSectionHeader({required this.title});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Text(
        title.toUpperCase(),
        style: const TextStyle(
          color: Colors.white38,
          fontSize: 11,
          fontWeight: FontWeight.bold,
          letterSpacing: 1.2,
        ),
      ),
    );
  }
}
