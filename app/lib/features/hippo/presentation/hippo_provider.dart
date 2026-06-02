import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/hippo_repository.dart';
import '../domain/hippo_models.dart';

class HippoNotifier extends AsyncNotifier<HippoState> {
  @override
  Future<HippoState> build() => ref.read(hippoRepositoryProvider).get();

  Future<void> refresh() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() => ref.read(hippoRepositoryProvider).get());
  }
}

final hippoProvider = AsyncNotifierProvider<HippoNotifier, HippoState>(HippoNotifier.new);
