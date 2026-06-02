import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_theme.dart';
import 'habits_provider.dart';

class HabitsScreen extends ConsumerWidget {
  const HabitsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final habitsAsync = ref.watch(habitsProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 16, 24, 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Habits', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: AppColors.text)),
                  GestureDetector(
                    onTap: () {}, // TODO: add habit dialog
                    child: Container(
                      width: 34, height: 34,
                      decoration: BoxDecoration(color: AppColors.primary, borderRadius: BorderRadius.circular(10)),
                      child: const Icon(Icons.add, color: Colors.white),
                    ),
                  ),
                ],
              ),
            ),

            // Wellbeing dashboard
            _WellbeingDash(),
            const SizedBox(height: 14),

            // Article of the day card
            _ArticleCard(onTap: () => context.go('/article')),
            const SizedBox(height: 14),

            Padding(
              padding: const EdgeInsets.fromLTRB(24, 0, 24, 8),
              child: Text(
                'Monday, Jun 2 · ${habitsAsync.value?.length ?? 0} habits',
                style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.textSoft),
              ),
            ),

            Expanded(
              child: habitsAsync.when(
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (e, _) => Center(child: Text('Error: $e')),
                data: (habits) => RefreshIndicator(
                  onRefresh: () => ref.read(habitsProvider.notifier).refresh(),
                  child: ListView.separated(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    itemCount: habits.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 8),
                    itemBuilder: (_, i) => _HabitItem(
                      habit: habits[i],
                      onToggle: (v) => ref.read(habitsProvider.notifier).toggle(habits[i].id, v),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _WellbeingDash extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(colors: [Color(0xFF2D3561), AppColors.primary], begin: Alignment.topLeft, end: Alignment.bottomRight),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('YOUR WELLBEING TODAY', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: Colors.white60, letterSpacing: 0.8)),
          const SizedBox(height: 12),
          Row(
            children: [
              _DashItem(icon: '🏃', value: '6,200', label: 'Steps', fill: 0.78),
              _DashItem(icon: '✅', value: '3/5', label: 'Habits', fill: 0.6),
              _DashItem(icon: '💬', value: 'Active', label: 'Social', fill: 0.75),
            ],
          ),
        ],
      ),
    );
  }
}

class _DashItem extends StatelessWidget {
  final String icon, value, label;
  final double fill;
  const _DashItem({required this.icon, required this.value, required this.label, required this.fill});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        children: [
          Text(icon, style: const TextStyle(fontSize: 20)),
          const SizedBox(height: 3),
          Text(value, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w800, color: Colors.white)),
          Text(label, style: const TextStyle(fontSize: 10, color: Colors.white60, fontWeight: FontWeight.w600)),
          const SizedBox(height: 5),
          ClipRRect(
            borderRadius: BorderRadius.circular(2),
            child: LinearProgressIndicator(value: fill, backgroundColor: Colors.white24, valueColor: const AlwaysStoppedAnimation(Colors.white), minHeight: 3),
          ),
        ],
      ),
    );
  }
}

class _ArticleCard extends StatelessWidget {
  final VoidCallback onTap;
  const _ArticleCard({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 20),
        decoration: BoxDecoration(
          gradient: const LinearGradient(colors: [Color(0xFF3D2B7A), Color(0xFF6B4FA0)]),
          borderRadius: BorderRadius.circular(18),
        ),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(14),
              child: Row(
                children: [
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _Badge(),
                        SizedBox(height: 6),
                        Text('The Secret Language of Mycelium Networks', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: Colors.white, height: 1.3)),
                        SizedBox(height: 4),
                        Text('Smithsonian Magazine · ~10 min read', style: TextStyle(fontSize: 11, color: Colors.white60, fontWeight: FontWeight.w600)),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  const Text('🍄', style: TextStyle(fontSize: 44)),
                ],
              ),
            ),
            Container(
              decoration: const BoxDecoration(
                color: Colors.black26,
                borderRadius: BorderRadius.only(bottomLeft: Radius.circular(18), bottomRight: Radius.circular(18)),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              child: Row(
                children: [
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      decoration: BoxDecoration(color: Colors.white24, borderRadius: BorderRadius.circular(10)),
                      alignment: Alignment.center,
                      child: const Text('Start Reading →', style: TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w700)),
                    ),
                  ),
                  const SizedBox(width: 10),
                  const Text('📚 3/5 for Library tile', style: TextStyle(color: Colors.white60, fontSize: 11, fontWeight: FontWeight.w600)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Badge extends StatelessWidget {
  const _Badge();
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
      decoration: BoxDecoration(color: Colors.white24, borderRadius: BorderRadius.circular(10)),
      child: const Text('📖 Article of the Day  ·  🌿 Nature', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: Colors.white90)),
    );
  }
}

class _HabitItem extends StatelessWidget {
  final dynamic habit;
  final ValueChanged<bool> onToggle;
  const _HabitItem({required this.habit, required this.onToggle});

  @override
  Widget build(BuildContext context) {
    final done = (habit.completed ?? false) as bool;
    return GestureDetector(
      onTap: () => onToggle(!done),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: done ? AppColors.greenLight : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: done ? AppColors.green : AppColors.border),
        ),
        child: Row(
          children: [
            Container(
              width: 24, height: 24,
              decoration: BoxDecoration(
                color: done ? AppColors.green : Colors.transparent,
                shape: BoxShape.circle,
                border: Border.all(color: done ? AppColors.green : AppColors.border, width: 2.5),
              ),
              child: done ? const Icon(Icons.check, size: 13, color: Colors.white) : null,
            ),
            const SizedBox(width: 10),
            Text(habit.icon ?? '✅', style: const TextStyle(fontSize: 18)),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(habit.name ?? '', style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: AppColors.text)),
                  Text(habit.category ?? '', style: const TextStyle(fontSize: 11, color: AppColors.textSoft, fontWeight: FontWeight.w600)),
                ],
              ),
            ),
            Text(done ? '${habit.streak ?? 0}d 🔥' : '—', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: done ? AppColors.orange : AppColors.textSoft)),
          ],
        ),
      ),
    );
  }
}
