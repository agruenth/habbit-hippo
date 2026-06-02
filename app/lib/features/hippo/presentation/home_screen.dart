import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_theme.dart';
import '../../habits/presentation/habits_provider.dart';
import 'hippo_provider.dart';
import 'hippo_widget.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final hippoAsync = ref.watch(hippoProvider);
    final habitsAsync = ref.watch(habitsProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () => ref.read(hippoProvider.notifier).refresh(),
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            child: hippoAsync.when(
              loading: () => const SizedBox(height: 600, child: Center(child: CircularProgressIndicator())),
              error: (e, _) => Center(child: Text('Error: $e')),
              data: (hippo) => Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header
                  Padding(
                    padding: const EdgeInsets.fromLTRB(24, 12, 24, 0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        RichText(
                          text: TextSpan(
                            style: const TextStyle(fontSize: 14, color: AppColors.textSoft, fontFamily: 'Nunito', fontWeight: FontWeight.w600),
                            children: [
                              const TextSpan(text: 'Good morning, '),
                              TextSpan(text: hippo.hippo.name, style: const TextStyle(color: AppColors.text, fontWeight: FontWeight.w700)),
                              const TextSpan(text: ' ☀️'),
                            ],
                          ),
                        ),
                        const Icon(Icons.settings_outlined, color: AppColors.textSoft),
                      ],
                    ),
                  ),

                  // Hippo stage
                  Column(
                    children: [
                      const SizedBox(height: 8),
                      MoodBadge(mood: hippo.mood),
                      const SizedBox(height: 4),
                      HippoWidget(mood: hippo.mood, colorHex: hippo.hippo.colorHex),
                      const SizedBox(height: 4),
                      _SpeechBubble(
                        text: hippo.mood.speechBubble.replaceAll(
                          '{steps}',
                          hippo.steps?.toStringAsFixed(0) ?? '0',
                        ),
                      ),
                    ],
                  ),

                  // Stats row
                  _StatsRow(hippo: hippo),
                  const SizedBox(height: 14),

                  // Article of the day mini-card
                  _ArticleMiniCard(onTap: () => context.go('/article')),
                  const SizedBox(height: 8),

                  // Today's habits
                  const Padding(
                    padding: EdgeInsets.fromLTRB(24, 4, 24, 10),
                    child: Text('Today\'s Habits', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: AppColors.textSoft, letterSpacing: 0.8)),
                  ),
                  habitsAsync.when(
                    loading: () => const SizedBox(height: 100, child: Center(child: CircularProgressIndicator())),
                    error: (e, _) => const SizedBox.shrink(),
                    data: (habits) => Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Column(
                        children: habits.take(4).map((h) => _QuickHabitRow(habit: h)).toList(),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _SpeechBubble extends StatelessWidget {
  final String text;
  const _SpeechBubble({required this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 6),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      constraints: const BoxConstraints(maxWidth: 280),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.border),
      ),
      child: Text(text, textAlign: TextAlign.center, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.text, height: 1.4)),
    );
  }
}

class _StatsRow extends StatelessWidget {
  final dynamic hippo;
  const _StatsRow({required this.hippo});

  @override
  Widget build(BuildContext context) {
    final steps = hippo.steps ?? 0.0;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        children: [
          _StatCard(icon: '🏃', value: steps >= 1000 ? '${(steps / 1000).toStringAsFixed(1)}k' : steps.toStringAsFixed(0), label: 'of 8,000 steps', fill: (steps / 8000).clamp(0.0, 1.0), color: AppColors.green),
          const SizedBox(width: 10),
          _StatCard(icon: '✅', value: '—', label: 'habits done', fill: 0.6, color: AppColors.primary),
          const SizedBox(width: 10),
          _StatCard(icon: '🔥', value: '—', label: 'streak', fill: 0.4, color: AppColors.orange),
        ],
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String icon, value, label;
  final double fill;
  final Color color;
  const _StatCard({required this.icon, required this.value, required this.label, required this.fill, required this.color});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.border),
        ),
        child: Column(
          children: [
            Text(icon, style: const TextStyle(fontSize: 18)),
            const SizedBox(height: 4),
            Text(value, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w800, color: AppColors.text)),
            Text(label, style: const TextStyle(fontSize: 10, color: AppColors.textSoft, fontWeight: FontWeight.w600), textAlign: TextAlign.center),
            const SizedBox(height: 6),
            ClipRRect(
              borderRadius: BorderRadius.circular(2),
              child: LinearProgressIndicator(value: fill, backgroundColor: AppColors.border, valueColor: AlwaysStoppedAnimation(color), minHeight: 4),
            ),
          ],
        ),
      ),
    );
  }
}

class _ArticleMiniCard extends StatelessWidget {
  final VoidCallback onTap;
  const _ArticleMiniCard({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 20),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          gradient: const LinearGradient(colors: [Color(0xFF2D3561), Color(0xFF4a6fa5)]),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: [
            const Text('🍄', style: TextStyle(fontSize: 32)),
            const SizedBox(width: 12),
            const Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('📖 ARTICLE OF THE DAY · NATURE', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: Colors.white60, letterSpacing: 0.5)),
                  SizedBox(height: 3),
                  Text('The Secret Language of Mycelium Networks', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: Colors.white, height: 1.3)),
                  SizedBox(height: 2),
                  Text('Smithsonian · ~10 min · Not yet read', style: TextStyle(fontSize: 11, color: Colors.white60, fontWeight: FontWeight.w600)),
                ],
              ),
            ),
            const Text('→', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w700)),
          ],
        ),
      ),
    );
  }
}

class _QuickHabitRow extends StatelessWidget {
  final dynamic habit;
  const _QuickHabitRow({required this.habit});

  @override
  Widget build(BuildContext context) {
    final done = habit.completed ?? false;
    return Container(
      margin: const EdgeInsets.only(bottom: 7),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          Container(
            width: 22, height: 22,
            decoration: BoxDecoration(
              color: done ? AppColors.green : Colors.transparent,
              borderRadius: BorderRadius.circular(7),
              border: Border.all(color: done ? AppColors.green : AppColors.border, width: 2),
            ),
            child: done ? const Icon(Icons.check, size: 13, color: Colors.white) : null,
          ),
          const SizedBox(width: 10),
          Text(habit.icon ?? '✅', style: const TextStyle(fontSize: 16)),
          const SizedBox(width: 8),
          Expanded(child: Text(habit.name ?? '', style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.text))),
          Text(done ? '${habit.streak ?? 0}d 🔥' : '—', style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: AppColors.textSoft)),
        ],
      ),
    );
  }
}
