import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/network/api_client.dart';
import '../domain/habit_models.dart';

class HabitsRepository {
  Future<List<HabitDefinition>> list() async {
    final resp = await ApiClient.instance.get('/habits');
    return (resp.data as List).map((e) => HabitDefinition.fromJson(e as Map<String, dynamic>)).toList();
  }

  Future<HabitDefinition> create({
    required String name,
    required String icon,
    required String category,
  }) async {
    final resp = await ApiClient.instance.post('/habits', data: {
      'name': name,
      'icon': icon,
      'category': category,
    });
    return HabitDefinition.fromJson(resp.data as Map<String, dynamic>);
  }

  Future<void> log({required String habitId, required bool completed, String? date}) async {
    await ApiClient.instance.post('/habits/$habitId/log', data: {
      'completed': completed,
      if (date != null) 'date': date,
    });
  }
}

final habitsRepositoryProvider = Provider((_) => HabitsRepository());
