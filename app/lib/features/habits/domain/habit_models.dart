class HabitDefinition {
  final String id;
  final String name;
  final String icon;
  final String category;
  final bool active;
  final int sortOrder;

  const HabitDefinition({
    required this.id,
    required this.name,
    required this.icon,
    required this.category,
    this.active = true,
    this.sortOrder = 0,
  });

  factory HabitDefinition.fromJson(Map<String, dynamic> json) => HabitDefinition(
        id: json['id'] as String,
        name: json['name'] as String,
        icon: json['icon'] as String,
        category: json['category'] as String,
        active: (json['active'] as bool?) ?? true,
        sortOrder: (json['sort_order'] as int?) ?? 0,
      );
}

class HabitWithLog extends HabitDefinition {
  final bool completed;
  final int streak;

  const HabitWithLog({
    required super.id,
    required super.name,
    required super.icon,
    required super.category,
    super.active,
    super.sortOrder,
    this.completed = false,
    this.streak = 0,
  });

  factory HabitWithLog.fromJson(Map<String, dynamic> json) => HabitWithLog(
        id: json['id'] as String,
        name: json['name'] as String,
        icon: json['icon'] as String,
        category: json['category'] as String,
        active: (json['active'] as bool?) ?? true,
        sortOrder: (json['sort_order'] as int?) ?? 0,
        completed: (json['completed'] as bool?) ?? false,
        streak: (json['streak'] as int?) ?? 0,
      );
}
