import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../repositories/base_repository.dart';
import '../repositories/song_repository.dart';
import '../repositories/artist_repository.dart';
import '../repositories/playlist_repository.dart';
import '../../features/auth/providers/auth_provider.dart';

class UserInteractionsRepository with SupabaseRepositoryHelper {
  final SupabaseClient _client;
  UserInteractionsRepository(this._client);

  Future<Set<int>> getLikedSongIds(String userId) {
    return runAction(() async {
      final res = await _client.from('favorites').select('song_id').eq('user_id', userId);
      return (res as List).map((e) => e['song_id'] as int).toSet();
    });
  }

  Future<Set<String>> getFollowedArtistIds(String userId) {
    return runAction(() async {
      final res = await _client.from('user_followed_artists').select('artist_id').eq('user_id', userId);
      return (res as List).map((e) => e['artist_id'] as String).toSet();
    });
  }

  Future<Set<int>> getSavedPlaylistIds(String userId) {
    return runAction(() async {
      final res = await _client.from('user_saved_playlists').select('playlist_id').eq('user_id', userId);
      return (res as List).map((e) => e['playlist_id'] as int).toSet();
    });
  }
}

final interactionsRepoProvider = Provider((ref) => UserInteractionsRepository(Supabase.instance.client));

class LikedSongsNotifier extends AsyncNotifier<Set<int>> {
  @override
  Future<Set<int>> build() async {
    final user = ref.watch(currentUserProvider);
    if (user == null) return {};
    return ref.read(interactionsRepoProvider).getLikedSongIds(user.id);
  }

  Future<void> toggleLike(int songId) async {
    final user = ref.read(currentUserProvider);
    if (user == null) return; // Prompt login in real app
    
    final current = state.value ?? {};
    final isLiked = current.contains(songId);
    
    // Optimistic update
    final updated = Set<int>.from(current);
    if (isLiked) {
      updated.remove(songId);
    } else {
      updated.add(songId);
    }
    state = AsyncData(updated);

    try {
      if (isLiked) {
        await ref.read(songRepositoryProvider).unlikeSong(songId);
      } else {
        await ref.read(songRepositoryProvider).likeSong(songId);
      }
    } catch (e) {
      // Revert on error
      state = AsyncData(current);
      // Optional: Show error via a global messenger or logging
    }
  }
}

final likedSongsProvider = AsyncNotifierProvider<LikedSongsNotifier, Set<int>>(() {
  return LikedSongsNotifier();
});

class FollowedArtistsNotifier extends AsyncNotifier<Set<String>> {
  @override
  Future<Set<String>> build() async {
    final user = ref.watch(currentUserProvider);
    if (user == null) return {};
    return ref.read(interactionsRepoProvider).getFollowedArtistIds(user.id);
  }

  Future<void> toggleFollow(String artistId) async {
    final user = ref.read(currentUserProvider);
    if (user == null) return;

    final current = state.value ?? {};
    final isFollowed = current.contains(artistId);

    final updated = Set<String>.from(current);
    if (isFollowed) {
      updated.remove(artistId);
    } else {
      updated.add(artistId);
    }
    state = AsyncData(updated);

    try {
      if (isFollowed) {
        await ref.read(artistRepositoryProvider).unfollowArtist(artistId);
      } else {
        await ref.read(artistRepositoryProvider).followArtist(artistId);
      }
    } catch (e) {
      state = AsyncData(current);
    }
  }
}

final followedArtistsProvider = AsyncNotifierProvider<FollowedArtistsNotifier, Set<String>>(() {
  return FollowedArtistsNotifier();
});

class SavedPlaylistsNotifier extends AsyncNotifier<Set<int>> {
  @override
  Future<Set<int>> build() async {
    final user = ref.watch(currentUserProvider);
    if (user == null) return {};
    return ref.read(interactionsRepoProvider).getSavedPlaylistIds(user.id);
  }

  Future<void> toggleSave(int playlistId) async {
    final user = ref.read(currentUserProvider);
    if (user == null) return;

    final current = state.value ?? {};
    final isSaved = current.contains(playlistId);

    final updated = Set<int>.from(current);
    if (isSaved) {
      updated.remove(playlistId);
    } else {
      updated.add(playlistId);
    }
    state = AsyncData(updated);

    try {
      if (isSaved) {
        await ref.read(playlistRepositoryProvider).unsavePlaylist(playlistId);
      } else {
        await ref.read(playlistRepositoryProvider).savePlaylist(playlistId);
      }
    } catch (e) {
      state = AsyncData(current);
    }
  }
}

final savedPlaylistsProvider = AsyncNotifierProvider<SavedPlaylistsNotifier, Set<int>>(() {
  return SavedPlaylistsNotifier();
});
