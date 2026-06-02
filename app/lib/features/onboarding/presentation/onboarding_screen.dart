import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_theme.dart';
import '../../hippo/presentation/hippo_widget.dart';
import '../../hippo/domain/hippo_models.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final _pageCtrl = PageController();
  int _page = 0;

  final _nameCtrl = TextEditingController(text: 'Milo');
  String _selectedColor = '#A8D8EA';

  static const _colors = ['#A8D8EA', '#FFD3B6', '#A8E6CF', '#D4A5C9', '#FFE4A0'];

  @override
  void dispose() {
    _pageCtrl.dispose();
    _nameCtrl.dispose();
    super.dispose();
  }

  void _next() {
    if (_page < 2) {
      _pageCtrl.nextPage(duration: const Duration(milliseconds: 300), curve: Curves.easeInOut);
    } else {
      context.go('/');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: PageView(
          controller: _pageCtrl,
          onPageChanged: (i) => setState(() => _page = i),
          children: [
            _WelcomePage(onNext: _next, page: _page),
            _NamePage(controller: _nameCtrl, selectedColor: _selectedColor, colors: _colors, onColorSelect: (c) => setState(() => _selectedColor = c), onNext: _next, page: _page),
            _PermissionsPage(onNext: _next, page: _page),
          ],
        ),
      ),
    );
  }
}

class _DotRow extends StatelessWidget {
  final int current;
  const _DotRow({required this.current});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(3, (i) => AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: const EdgeInsets.symmetric(horizontal: 3),
        width: i == current ? 20 : 8,
        height: 8,
        decoration: BoxDecoration(
          color: i == current ? AppColors.primary : AppColors.border,
          borderRadius: BorderRadius.circular(4),
        ),
      )),
    );
  }
}

class _WelcomePage extends StatelessWidget {
  final VoidCallback onNext;
  final int page;
  const _WelcomePage({required this.onNext, required this.page});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(28),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _DotRow(current: page),
          const SizedBox(height: 20),
          HippoWidget(mood: HippoMood.thriving),
          const SizedBox(height: 18),
          const Text('Meet your wellness companion', textAlign: TextAlign.center, style: TextStyle(fontSize: 24, fontWeight: FontWeight.w800, color: AppColors.text, height: 1.25)),
          const SizedBox(height: 10),
          const Text('Your hippo lives and grows with you. Walk more, build good habits, stay connected, read daily — and watch your world bloom. 🌱', textAlign: TextAlign.center, style: TextStyle(fontSize: 14, color: AppColors.textSoft, height: 1.5)),
          const SizedBox(height: 28),
          SizedBox(width: double.infinity, child: FilledButton(onPressed: onNext, child: const Text('Get started →'))),
        ],
      ),
    );
  }
}

class _NamePage extends StatelessWidget {
  final TextEditingController controller;
  final String selectedColor;
  final List<String> colors;
  final ValueChanged<String> onColorSelect;
  final VoidCallback onNext;
  final int page;

  const _NamePage({required this.controller, required this.selectedColor, required this.colors, required this.onColorSelect, required this.onNext, required this.page});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(28),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _DotRow(current: page),
          const SizedBox(height: 14),
          HippoWidget(mood: HippoMood.content, colorHex: selectedColor),
          const SizedBox(height: 14),
          const Text('Name your hippo', textAlign: TextAlign.center, style: TextStyle(fontSize: 24, fontWeight: FontWeight.w800, color: AppColors.text)),
          const SizedBox(height: 10),
          const Text('This is your companion for the journey.', textAlign: TextAlign.center, style: TextStyle(fontSize: 14, color: AppColors.textSoft)),
          const SizedBox(height: 28),
          TextField(
            controller: controller,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: AppColors.text),
            decoration: InputDecoration(
              hintText: 'e.g. Milo, Bubbles, Hugo…',
              filled: true,
              fillColor: Colors.white,
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: const BorderSide(color: AppColors.border)),
              enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: const BorderSide(color: AppColors.border)),
            ),
          ),
          const SizedBox(height: 14),
          const Text('Pick a colour', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.textSoft)),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: colors.map((hex) {
              final color = Color(int.parse('FF${hex.replaceFirst('#', '')}', radix: 16));
              return GestureDetector(
                onTap: () => onColorSelect(hex),
                child: Container(
                  width: 32, height: 32,
                  margin: const EdgeInsets.symmetric(horizontal: 5),
                  decoration: BoxDecoration(
                    color: color,
                    shape: BoxShape.circle,
                    border: Border.all(color: selectedColor == hex ? AppColors.text : Colors.transparent, width: 3),
                  ),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 22),
          SizedBox(width: double.infinity, child: FilledButton(onPressed: onNext, child: Text("That's ${controller.text} →"))),
        ],
      ),
    );
  }
}

class _PermissionsPage extends StatelessWidget {
  final VoidCallback onNext;
  final int page;
  const _PermissionsPage({required this.onNext, required this.page});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(28),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _DotRow(current: page),
          const SizedBox(height: 12),
          const Text('💪', style: TextStyle(fontSize: 38)),
          const SizedBox(height: 12),
          const Text('Let Milo feel your steps', textAlign: TextAlign.center, style: TextStyle(fontSize: 24, fontWeight: FontWeight.w800, color: AppColors.text)),
          const SizedBox(height: 10),
          const Text('Milo reads your activity automatically so you don\'t have to log everything by hand.', textAlign: TextAlign.center, style: TextStyle(fontSize: 14, color: AppColors.textSoft, height: 1.5)),
          const SizedBox(height: 28),
          _PermCard(icon: '🏃', title: 'Steps & Activity', desc: 'Daily step count drives Milo\'s mood and unlocks meadow tiles.'),
          const SizedBox(height: 10),
          _PermCard(icon: '😴', title: 'Sleep (optional)', desc: 'Sleep data adds depth to Milo\'s energy levels.'),
          const SizedBox(height: 10),
          _PermCard(icon: '📖', title: 'Article of the Day', desc: 'One curated 10-min read per day. Builds your library in the world map.'),
          const SizedBox(height: 16),
          SizedBox(width: double.infinity, child: FilledButton(onPressed: onNext, child: const Text('Allow & Start →'))),
          const SizedBox(height: 10),
          const Text('Your health data never leaves your device. Only aggregates are synced.', textAlign: TextAlign.center, style: TextStyle(fontSize: 12, color: AppColors.textSoft)),
        ],
      ),
    );
  }
}

class _PermCard extends StatelessWidget {
  final String icon, title, desc;
  const _PermCard({required this.icon, required this.title, required this.desc});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(18), border: Border.all(color: AppColors.border)),
      child: Row(
        children: [
          Text(icon, style: const TextStyle(fontSize: 26)),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: AppColors.text)),
                const SizedBox(height: 2),
                Text(desc, style: const TextStyle(fontSize: 12, color: AppColors.textSoft, height: 1.4)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
