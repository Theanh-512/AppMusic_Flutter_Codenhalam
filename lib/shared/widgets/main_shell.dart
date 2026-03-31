import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../features/player/presentation/mini_player.dart';
import 'account_drawer.dart';
import 'app_bottom_navigation_bar.dart';

class MainShell extends StatelessWidget {
  final StatefulNavigationShell navigationShell;

  const MainShell({super.key, required this.navigationShell});

  void _onItemTapped(BuildContext context, int index) {
    if (index == 3) {
      _showCreateBottomSheet(context);
    } else {
      navigationShell.goBranch(
        index,
        initialLocation: index == navigationShell.currentIndex,
      );
    }
  }

  void _showCreateBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Padding(
                padding: EdgeInsets.all(16.0),
                child: Text('Create', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              ),
              ListTile(
                leading: const Icon(LucideIcons.listMusic),
                title: const Text('Playlist'),
                onTap: () {
                  Navigator.pop(context);
                },
              ),
              ListTile(
                leading: const Icon(LucideIcons.users),
                title: const Text('Collaborative Playlist'),
                trailing: const Text('Coming soon', style: TextStyle(color: Colors.grey, fontSize: 12)),
                onTap: () {},
              ),
              ListTile(
                leading: const Icon(LucideIcons.merge),
                title: const Text('Blend'),
                trailing: const Text('Coming soon', style: TextStyle(color: Colors.grey, fontSize: 12)),
                onTap: () {},
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: const AccountDrawer(),
      body: Column(
        children: [
          Expanded(child: navigationShell),
          const MiniPlayer(),
        ],
      ),
      bottomNavigationBar: AppBottomNavigationBar(
        currentIndex: navigationShell.currentIndex,
        onTap: (index) => _onItemTapped(context, index),
      ),
    );
  }
}

