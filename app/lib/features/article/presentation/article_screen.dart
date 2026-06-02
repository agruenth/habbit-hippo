import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_theme.dart';

class ArticleScreen extends ConsumerWidget {
  const ArticleScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Container(
              color: AppColors.background,
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 12),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => context.go('/habits'),
                    child: const Text('←', style: TextStyle(fontSize: 20, color: AppColors.primary, fontWeight: FontWeight.w700)),
                  ),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('ARTICLE OF THE DAY', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: AppColors.textSoft, letterSpacing: 0.8)),
                        Text('Monday, Jun 2', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: AppColors.text)),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
                    decoration: BoxDecoration(color: AppColors.greenLight, borderRadius: BorderRadius.circular(10)),
                    child: const Text('3-day streak 🔥', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: AppColors.green)),
                  ),
                ],
              ),
            ),

            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    // Hero card
                    _ArticleHero(),
                    const SizedBox(height: 14),

                    // Streak card
                    _StreakCard(),
                    const SizedBox(height: 14),

                    // Rewards
                    _RewardsCard(),
                    const SizedBox(height: 14),

                    // Mood bonus
                    _MoodBonusCard(),
                    const SizedBox(height: 14),

                    // Yesterday
                    const Padding(
                      padding: EdgeInsets.fromLTRB(20, 0, 20, 6),
                      child: Align(alignment: Alignment.centerLeft, child: Text('YESTERDAY', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: AppColors.textSoft, letterSpacing: 0.8))),
                    ),
                    _YesterdayCard(),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ArticleHero extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(colors: [Color(0xFF3D2B7A), Color(0xFF6B4FA0), Color(0xFF9B72CF)], begin: Alignment.topLeft, end: Alignment.bottomRight),
        borderRadius: BorderRadius.circular(22),
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  decoration: BoxDecoration(color: Colors.white24, borderRadius: BorderRadius.circular(20)),
                  child: const Text('🌿 Nature · Fungi', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: Colors.white90)),
                ),
                const SizedBox(height: 12),
                const Center(child: Text('🍄', style: TextStyle(fontSize: 56))),
                const SizedBox(height: 10),
                const Text('The Secret Language of Mycelium Networks', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: Colors.white, height: 1.3)),
                const SizedBox(height: 6),
                const Text('Smithsonian Magazine', style: TextStyle(fontSize: 12, color: Colors.white60, fontWeight: FontWeight.w600)),
                const SizedBox(height: 10),
                Row(children: ['⏱ ~10 min', '📖 Not yet read', '💡 Science'].map((label) => Padding(
                  padding: const EdgeInsets.only(right: 6),
                  child: Container(padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4), decoration: BoxDecoration(color: Colors.white24, borderRadius: BorderRadius.circular(10)), child: Text(label, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: Colors.white90))),
                )).toList()),
              ],
            ),
          ),
          Container(
            decoration: const BoxDecoration(color: Colors.black26, borderRadius: BorderRadius.only(bottomLeft: Radius.circular(22), bottomRight: Radius.circular(22))),
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                const Text(
                  'Beneath every forest floor lies an intricate web of fungal threads called mycelium — a network so sophisticated that some scientists call it the "wood wide web." Trees use it to communicate, share nutrients, and even warn each other of threats.',
                  style: TextStyle(fontSize: 13, color: Colors.white80, height: 1.55),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white.withOpacity(0.9),
                      foregroundColor: const Color(0xFF3D2B7A),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                      padding: const EdgeInsets.symmetric(vertical: 13),
                    ),
                    onPressed: () {},
                    child: const Text('Start Reading →', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w800)),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _StreakCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        gradient: const LinearGradient(colors: [AppColors.yellow, AppColors.orange]),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          const Text('🔥', style: TextStyle(fontSize: 32)),
          const SizedBox(width: 12),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('3', style: TextStyle(fontSize: 28, fontWeight: FontWeight.w900, color: Colors.white)),
                Text('day reading streak', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: Colors.white80)),
                Text("Keep it up — you're building a habit!", style: TextStyle(fontSize: 11, color: Colors.white70)),
              ],
            ),
          ),
          const Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text('7', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: Colors.white90)),
              Text('best streak', style: TextStyle(fontSize: 11, color: Colors.white70, fontWeight: FontWeight.w600)),
            ],
          ),
        ],
      ),
    );
  }
}

class _RewardsCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: AppColors.border)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('WORLD REWARDS', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: AppColors.textSoft, letterSpacing: 0.8)),
          const SizedBox(height: 10),
          _RewardRow(icon: '📚', label: 'Library Tile', sub: 'Unlock a bookshelf tile in Milo\'s world', progress: 0.6, progressText: '3 / 5'),
          const SizedBox(height: 8),
          _RewardRow(icon: '🦉', label: 'Reading Nook + Owl', sub: 'A wise owl moves in at 20 articles', progress: 0.15, progressText: '3 / 20'),
        ],
      ),
    );
  }
}

class _RewardRow extends StatelessWidget {
  final String icon, label, sub, progressText;
  final double progress;
  const _RewardRow({required this.icon, required this.label, required this.sub, required this.progress, required this.progressText});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        SizedBox(width: 32, child: Text(icon, style: const TextStyle(fontSize: 20), textAlign: TextAlign.center)),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.text)),
              Text(sub, style: const TextStyle(fontSize: 11, color: AppColors.textSoft)),
              const SizedBox(height: 5),
              Row(
                children: [
                  Expanded(child: ClipRRect(borderRadius: BorderRadius.circular(3), child: LinearProgressIndicator(value: progress, backgroundColor: AppColors.border, valueColor: const AlwaysStoppedAnimation(AppColors.primary), minHeight: 5))),
                  const SizedBox(width: 6),
                  Text(progressText, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: AppColors.textSoft)),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _MoodBonusCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(color: AppColors.primaryLight, borderRadius: BorderRadius.circular(14)),
      child: const Row(
        children: [
          Text('🦛', style: TextStyle(fontSize: 22)),
          SizedBox(width: 10),
          Expanded(
            child: Text(
              'Reading today\'s article gives Milo a +0.5 mood bonus — just enough to tip Content → Thriving!',
              style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.primary, height: 1.4),
            ),
          ),
        ],
      ),
    );
  }
}

class _YesterdayCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.all(13),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: AppColors.border)),
      child: Row(
        children: [
          const Text('🌌', style: TextStyle(fontSize: 26)),
          const SizedBox(width: 12),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("Dark Matter: The Universe's Missing Mass", style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.text)),
                Text('Quanta Magazine · Read Jun 1', style: TextStyle(fontSize: 11, color: AppColors.textSoft, fontWeight: FontWeight.w600)),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
            decoration: BoxDecoration(color: AppColors.greenLight, borderRadius: BorderRadius.circular(10)),
            child: const Text('💡 Eureka', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: AppColors.green)),
          ),
        ],
      ),
    );
  }
}
