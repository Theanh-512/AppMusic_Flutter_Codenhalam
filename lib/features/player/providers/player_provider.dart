import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/models/playback_item.dart';
import '../../../core/repositories/playback_state_repository.dart';
import '../../auth/providers/auth_provider.dart';
import 'package:just_audio/just_audio.dart';

// Provides a singleton AudioPlayer instance.
final audioPlayerProvider = Provider<AudioPlayer>((ref) {
  final player = AudioPlayer();
  ref.onDispose(() => player.dispose());
  return player;
});

class PlayerStateData {
  final PlaybackItem? currentItem;
  final bool isPlaying;
  final Duration position;
  final Duration bufferedPosition;
  final Duration totalDuration;

  const PlayerStateData({
    this.currentItem,
    this.isPlaying = false,
    this.position = Duration.zero,
    this.bufferedPosition = Duration.zero,
    this.totalDuration = Duration.zero,
  });

  PlayerStateData copyWith({
    PlaybackItem? currentItem,
    bool? isPlaying,
    Duration? position,
    Duration? bufferedPosition,
    Duration? totalDuration,
  }) {
    return PlayerStateData(
      currentItem: currentItem ?? this.currentItem,
      isPlaying: isPlaying ?? this.isPlaying,
      position: position ?? this.position,
      bufferedPosition: bufferedPosition ?? this.bufferedPosition,
      totalDuration: totalDuration ?? this.totalDuration,
    );
  }
}

class PlayerNotifier extends Notifier<PlayerStateData> {
  @override
  PlayerStateData build() {
    _listenToPlayer();
    return const PlayerStateData();
  }

  void _listenToPlayer() {
    final player = ref.read(audioPlayerProvider);

    player.playingStream.listen((playing) {
      state = state.copyWith(isPlaying: playing);
      _persistStateThrottled();
    });

    player.positionStream.listen((position) {
      state = state.copyWith(position: position);
      // Don't persist on every tick to avoid breaking Supabase limits.
      // Usually, throttle this to every 10-30 seconds or on pause.
    });

    player.bufferedPositionStream.listen((buffered) {
      state = state.copyWith(bufferedPosition: buffered);
    });

    player.durationStream.listen((duration) {
      if (duration != null) {
        state = state.copyWith(totalDuration: duration);
      }
    });

    player.playerStateStream.listen((playerState) {
      if (playerState.processingState == ProcessingState.completed) {
        // Handle next song or queue logic here
      }
    });
  }

  // Throttle helper state
  DateTime? _lastPersistTime;

  Future<void> _persistStateThrottled() async {
    final now = DateTime.now();
    if (_lastPersistTime != null && now.difference(_lastPersistTime!).inSeconds < 10) {
      return; 
    }
    _lastPersistTime = now;

    final user = ref.read(currentUserProvider);
    if (user == null || state.currentItem == null) return;

    final isSong = state.currentItem!.type == PlaybackItemType.song;
    int? currentSongId = isSong ? int.tryParse(state.currentItem!.id.replaceFirst('song_', '')) : null;

    try {
      await ref.read(playbackStateRepositoryProvider).setUserPlayerState(
            currentSongId: currentSongId,
            positionSeconds: state.position.inSeconds,
            isPlaying: state.isPlaying,
          );
    } catch (e) {
      // Intentionally ignore persistence errors in the background
    }
  }

  Future<void> playItem(PlaybackItem item) async {
    final player = ref.read(audioPlayerProvider);
    state = state.copyWith(currentItem: item);
    
    // In strict environments, setup AudioSource properly
    final source = AudioSource.uri(
      Uri.parse(item.audioUrl), 
      tag: item, // Passing item as tag helps background audio
    );

    await player.setAudioSource(source);
    await player.play();
  }

  Future<void> pause() async {
    await ref.read(audioPlayerProvider).pause();
  }

  Future<void> resume() async {
    await ref.read(audioPlayerProvider).play();
  }

  Future<void> seek(Duration position) async {
    await ref.read(audioPlayerProvider).seek(position);
  }
}

final playerNotifierProvider = NotifierProvider<PlayerNotifier, PlayerStateData>(() {
  return PlayerNotifier();
});
