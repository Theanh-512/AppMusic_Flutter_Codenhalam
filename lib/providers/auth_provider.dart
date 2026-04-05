import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/profile.dart';
import 'supabase_provider.dart';

class AuthStateNotifier extends Notifier<Profile?> {
  @override
  Profile? build() => ref.read(authRepositoryProvider).currentUser;

  Future<bool> login(String email, String password) async {
    try {
      await ref.read(authRepositoryProvider).signInWithEmail(email, password);
      state = ref.read(authRepositoryProvider).currentUser;
      return true;
    } catch (e) {
      rethrow;
    }
  }

  Future<bool> register({
    required String email,
    required String password,
    required String displayName,
    bool isArtist = false,
  }) async {
    try {
      await ref.read(authRepositoryProvider).signUpWithEmail(email, password, displayName, isArtist);
      state = ref.read(authRepositoryProvider).currentUser;
      return true;
    } catch (e) {
      rethrow;
    }
  }

  Future<void> logout() async {
    await ref.read(authRepositoryProvider).signOut();
    state = null;
  }

  void setProfile(Profile? profile) => state = profile;
}

final authStateProvider = NotifierProvider<AuthStateNotifier, Profile?>(AuthStateNotifier.new);

final profileProvider = FutureProvider<Profile?>((ref) async {
  final profile = ref.watch(authStateProvider);
  if (profile == null) return null;

  final repo = ref.read(authRepositoryProvider);
  return await repo.getProfile();
});
