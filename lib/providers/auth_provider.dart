import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/profile.dart';
import 'supabase_provider.dart';

class AuthStateNotifier extends Notifier<Profile?> {
  @override
  Profile? build() => null;

  void setProfile(Profile? profile) => state = profile;
}

final authStateProvider = NotifierProvider<AuthStateNotifier, Profile?>(AuthStateNotifier.new);

final profileProvider = FutureProvider<Profile?>((ref) async {
  final profile = ref.watch(authStateProvider);
  if (profile == null) return null;

  final repo = ref.read(authRepositoryProvider);
  return await repo.getProfile();
});
