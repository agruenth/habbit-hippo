import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_theme.dart';
import '../../hippo/presentation/hippo_widget.dart';
import '../../hippo/domain/hippo_models.dart';

class FriendsScreen extends ConsumerWidget {
  const FriendsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Padding(
                padding: EdgeInsets.fromLTRB(24, 14, 24, 2),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Your Pond', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: AppColors.text)),
                    Text('Chat to keep the river flowing 💧', style: TextStyle(fontSize: 12, color: AppColors.textSoft, fontWeight: FontWeight.w600)),
                  ],
                ),
              ),
              const SizedBox(height: 12),

              // Pond view
              _PondView(),
              const SizedBox(height: 12),

              // Water meter
              _WaterMeter(level: 0.75),
              const SizedBox(height: 12),

              const Padding(
                padding: EdgeInsets.fromLTRB(20, 4, 20, 8),
                child: Text('FRIENDS (2)', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: AppColors.textSoft, letterSpacing: 0.6)),
              ),

              // Friend list
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  children: [
                    _FriendItem(
                      name: 'Tom',
                      hippoName: 'Ollie',
                      mood: 'Content 🌿',
                      lastSeen: '2h ago',
                      online: true,
                      colorHex: '#FFD3B6',
                      onChat: () => context.go('/chat/tom'),
                    ),
                    const SizedBox(height: 8),
                    _FriendItem(
                      name: 'Sarah',
                      hippoName: 'Luna',
                      mood: 'Thriving ✨',
                      lastSeen: '1h ago',
                      online: false,
                      colorHex: '#A8E6CF',
                      onChat: () {},
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 10),

              // Add friend
              GestureDetector(
                onTap: () {},
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 20),
                  padding: const EdgeInsets.symmetric(vertical: 11),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: AppColors.border, width: 2, style: BorderStyle.solid),
                  ),
                  alignment: Alignment.center,
                  child: const Text('+ Add a friend by username', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.textSoft)),
                ),
              ),
              const SizedBox(height: 10),

              // Pending request
              Container(
                margin: const EdgeInsets.fromLTRB(20, 0, 20, 16),
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFF3E0),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFFFFCC80)),
                ),
                child: const Text('⚠️ 1 pending request from james_k — Accept or Decline', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Color(0xFFB45309))),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PondView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      height: 140,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFB8E8F8), Color(0xFF7EC8E3), Color(0xFF5AADCF)],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          _FriendHippo(name: "Tom's Ollie", colorHex: '#FFD3B6', online: true),
          _FriendHippo(name: "Sarah's Luna", colorHex: '#A8E6CF', online: false),
        ],
      ),
    );
  }
}

class _FriendHippo extends StatelessWidget {
  final String name;
  final String colorHex;
  final bool online;
  const _FriendHippo({required this.name, required this.colorHex, required this.online});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(width: 48, height: 42, child: HippoWidget(mood: HippoMood.content, colorHex: colorHex)),
          const SizedBox(height: 4),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
            decoration: BoxDecoration(color: Colors.white.withOpacity(0.9), borderRadius: BorderRadius.circular(8)),
            child: Text(name, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w800, color: AppColors.text)),
          ),
          const SizedBox(height: 3),
          Container(
            width: 7, height: 7,
            decoration: BoxDecoration(
              color: online ? AppColors.green : AppColors.yellow,
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white, width: 1.5),
            ),
          ),
        ],
      ),
    );
  }
}

class _WaterMeter extends StatelessWidget {
  final double level;
  const _WaterMeter({required this.level});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(14), border: Border.all(color: AppColors.border)),
      child: Row(
        children: [
          const Text('💧', style: TextStyle(fontSize: 16)),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('River water level', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: AppColors.textSoft)),
                const SizedBox(height: 5),
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: level,
                    backgroundColor: AppColors.border,
                    valueColor: const AlwaysStoppedAnimation(AppColors.primary),
                    minHeight: 7,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          Text('${(level * 100).toInt()}%', style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w800, color: AppColors.primary)),
        ],
      ),
    );
  }
}

class _FriendItem extends StatelessWidget {
  final String name, hippoName, mood, lastSeen, colorHex;
  final bool online;
  final VoidCallback onChat;

  const _FriendItem({
    required this.name,
    required this.hippoName,
    required this.mood,
    required this.lastSeen,
    required this.online,
    required this.colorHex,
    required this.onChat,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(11),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: AppColors.border)),
      child: Row(
        children: [
          Stack(
            children: [
              Container(
                width: 38, height: 38,
                decoration: BoxDecoration(color: AppColors.primaryLight, shape: BoxShape.circle),
                child: const Center(child: Text('🦛', style: TextStyle(fontSize: 18))),
              ),
              Positioned(
                bottom: 1, right: 1,
                child: Container(
                  width: 9, height: 9,
                  decoration: BoxDecoration(
                    color: online ? AppColors.green : AppColors.textSoft,
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 1.5),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: AppColors.text)),
                Text('$hippoName · $mood · $lastSeen', style: const TextStyle(fontSize: 11, color: AppColors.textSoft, fontWeight: FontWeight.w600)),
              ],
            ),
          ),
          GestureDetector(
            onTap: onChat,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 6),
              decoration: BoxDecoration(color: AppColors.primaryLight, borderRadius: BorderRadius.circular(10)),
              child: const Text('Chat 💬', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.primary)),
            ),
          ),
        ],
      ),
    );
  }
}
