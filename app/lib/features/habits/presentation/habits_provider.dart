import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/habits_repository.dart';
import '../domain/habit_models.dart';

class HabitsNotifier extends AsyncNotifier<List<HabitDefinition>> {
  @override
  Future<List<HabitDefinition>> build() => ref.read(habitsRepositoryProvider).list();

  Future<void> refresh() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() => ref.read(habitsRepositoryProvider).list());
  }

  Future<void> toggle(String habitId, bool completed) async {
    await ref.read(habitsRepositoryProvider).log(habitId: habitId, completed: completed);
    await refresh();
  }
}

final habitsProvider = AsyncNotifierProvider<HabitsNotifier, List<HabitDefinition>>(HabitsNotifier.new);
