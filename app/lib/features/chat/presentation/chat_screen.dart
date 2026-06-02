import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_theme.dart';

class ChatScreen extends ConsumerStatefulWidget {
  final String friendId;
  const ChatScreen({super.key, required this.friendId});

  @override
  ConsumerState<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends ConsumerState<ChatScreen> {
  final _controller = TextEditingController();
  final _scrollCtrl = ScrollController();

  // Static messages matching the mockup
  final _messages = [
    _Message(text: 'Did you hit 8k steps today? 🏃', mine: false, time: '9:12'),
    _Message(text: 'Almost! 6,200 so far 💪 Evening walk will do it', mine: true, time: '9:14'),
    _Message(text: 'Ollie is in a great mood today too 🌿 Content for 3 days', mine: false, time: '9:15'),
    _Message(text: 'Our pond is at 75% — we need to chat more 😄 last week it was nearly dry!', mine: true, time: '9:16'),
    _Message(text: 'Haha yes I saw the cracked ground 😬 scary stuff', mine: false, time: '9:18'),
    _Message(text: 'Have you read today\'s article yet? About mycelium networks! 🍄', mine: true, time: '9:19'),
    _Message(text: 'Not yet! Just unlocked my library tile though 📚 so cool', mine: false, time: '9:21'),
  ];

  @override
  void dispose() {
    _controller.dispose();
    _scrollCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Container(
              color: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => context.go('/friends'),
                    child: const Text('←', style: TextStyle(fontSize: 20, color: AppColors.primary, fontWeight: FontWeight.w700)),
                  ),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Tom 🦛', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: AppColors.text)),
                        Text('Ollie is Content · Online', style: TextStyle(fontSize: 11, color: AppColors.green, fontWeight: FontWeight.w600)),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(color: AppColors.primaryLight, borderRadius: BorderRadius.circular(10)),
                    child: const Text('💧 75%', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: AppColors.primary)),
                  ),
                ],
              ),
            ),
            const Divider(height: 1, color: AppColors.border),

            // Messages
            Expanded(
              child: ListView.builder(
                controller: _scrollCtrl,
                padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
                itemCount: _messages.length + 1,
                itemBuilder: (_, i) {
                  if (i == 0) return const Padding(padding: EdgeInsets.only(bottom: 8), child: Center(child: Text('Monday, Jun 2', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: AppColors.textSoft))));
                  return _MessageBubble(msg: _messages[i - 1]);
                },
              ),
            ),

            // Input
            Container(
              color: Colors.white,
              padding: const EdgeInsets.fromLTRB(14, 10, 14, 10),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _controller,
                      decoration: InputDecoration(
                        hintText: 'Message Tom…',
                        filled: true,
                        fillColor: AppColors.background,
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(20), borderSide: const BorderSide(color: AppColors.border)),
                        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(20), borderSide: const BorderSide(color: AppColors.border)),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    width: 36, height: 36,
                    decoration: const BoxDecoration(color: AppColors.primary, shape: BoxShape.circle),
                    child: const Icon(Icons.send, color: Colors.white, size: 16),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Message {
  final String text;
  final bool mine;
  final String time;
  const _Message({required this.text, required this.mine, required this.time});
}

class _MessageBubble extends StatelessWidget {
  final _Message msg;
  const _MessageBubble({required this.msg});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 9),
      child: Row(
        mainAxisAlignment: msg.mine ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (!msg.mine) ...[
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(msg.time, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: AppColors.textSoft)),
                Container(
                  constraints: const BoxConstraints(maxWidth: 220),
                  padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 9),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: const BorderRadius.only(topLeft: Radius.circular(18), topRight: Radius.circular(18), bottomRight: Radius.circular(18), bottomLeft: Radius.circular(4)),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: Text(msg.text, style: const TextStyle(fontSize: 13, color: AppColors.text, height: 1.4)),
                ),
              ],
            ),
          ],
          if (msg.mine) ...[
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(msg.time, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: AppColors.textSoft)),
                Container(
                  constraints: const BoxConstraints(maxWidth: 220),
                  padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 9),
                  decoration: const BoxDecoration(
                    color: AppColors.primary,
                    borderRadius: BorderRadius.only(topLeft: Radius.circular(18), topRight: Radius.circular(18), bottomLeft: Radius.circular(18), bottomRight: Radius.circular(4)),
                  ),
                  child: Text(msg.text, style: const TextStyle(fontSize: 13, color: Colors.white, height: 1.4)),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}
