import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/home_filter_provider.dart';
import 'home_filter_bar.dart' as new_bar;
import 'home_all_tab.dart';
import 'home_music_following_tab.dart';
import 'home_podcasts_following_tab.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final filter = ref.watch(homeFilterProvider);

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            new_bar.HomeFilterBar(
              currentFilter: _mapFilterToNew(filter),
              showFollowing: filter == HomeFilter.musicFollowing || filter == HomeFilter.podcastsFollowing,
              onFilterChanged: (newFilter) {
                if (newFilter == new_bar.HomeFilter.all) ref.read(homeFilterProvider.notifier).setFilter(HomeFilter.all);
                if (newFilter == new_bar.HomeFilter.music) ref.read(homeFilterProvider.notifier).setFilter(HomeFilter.music);
                if (newFilter == new_bar.HomeFilter.podcasts) ref.read(homeFilterProvider.notifier).setFilter(HomeFilter.podcasts);
              },
              onFollowingChanged: (following) {
                if (filter == HomeFilter.music || filter == HomeFilter.musicFollowing) {
                  ref.read(homeFilterProvider.notifier).setFilter(following ? HomeFilter.musicFollowing : HomeFilter.music);
                } else if (filter == HomeFilter.podcasts || filter == HomeFilter.podcastsFollowing) {
                  ref.read(homeFilterProvider.notifier).setFilter(following ? HomeFilter.podcastsFollowing : HomeFilter.podcasts);
                }
              },
              onAvatarTap: () {
                Scaffold.of(context).openDrawer();
              },
            ),
            Expanded(
              child: _buildBody(filter),
            ),
          ],
        ),
      ),
    );
  }

  new_bar.HomeFilter _mapFilterToNew(HomeFilter filter) {
    switch (filter) {
      case HomeFilter.all: return new_bar.HomeFilter.all;
      case HomeFilter.music:
      case HomeFilter.musicFollowing: return new_bar.HomeFilter.music;
      case HomeFilter.podcasts:
      case HomeFilter.podcastsFollowing: return new_bar.HomeFilter.podcasts;
    }
  }

  Widget _buildBody(HomeFilter filter) {
    switch (filter) {
      case HomeFilter.all:
        return const HomeAllTab();
      case HomeFilter.music:
        return const Center(child: Text('Music Section'));
      case HomeFilter.musicFollowing:
        return const HomeMusicFollowingTab();
      case HomeFilter.podcasts:
        return const Center(child: Text('Podcasts Section'));
      case HomeFilter.podcastsFollowing:
        return const HomePodcastsFollowingTab();
    }
  }
}
