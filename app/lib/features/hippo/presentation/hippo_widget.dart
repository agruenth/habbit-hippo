import 'package:flutter/material.dart';
import '../domain/hippo_models.dart';
import '../../../core/constants/app_theme.dart';

class HippoWidget extends StatefulWidget {
  final HippoMood mood;
  final String colorHex;

  const HippoWidget({super.key, required this.mood, this.colorHex = '#A8D8EA'});

  @override
  State<HippoWidget> createState() => _HippoWidgetState();
}

class _HippoWidgetState extends State<HippoWidget> with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _breathe;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this, duration: const Duration(seconds: 3))
      ..repeat(reverse: true);
    _breathe = Tween<double>(begin: 0, end: -5).animate(
      CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  Color get _hippoColor {
    try {
      final hex = widget.colorHex.replaceFirst('#', '');
      return Color(int.parse('FF$hex', radix: 16));
    } catch (_) {
      return AppColors.hippo;
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _breathe,
      builder: (_, child) => Transform.translate(
        offset: Offset(0, _breathe.value),
        child: child,
      ),
      child: CustomPaint(
        size: const Size(190, 172),
        painter: _HippoPainter(color: _hippoColor, mood: widget.mood),
      ),
    );
  }
}

class _HippoPainter extends CustomPainter {
  final Color color;
  final HippoMood mood;

  const _HippoPainter({required this.color, required this.mood});

  @override
  void paint(Canvas canvas, Size size) {
    // Scale to match the SVG viewBox 100x90
    canvas.scale(size.width / 100, size.height / 90);

    final paint = Paint()..style = PaintingStyle.fill;
    final darkColor = Color.lerp(color, Colors.black, 0.12)!;

    // Body
    paint.color = color;
    canvas.drawOval(Rect.fromCenter(center: const Offset(50, 70), width: 64, height: 36), paint);
    canvas.drawCircle(const Offset(50, 42), 24, paint);

    // Snout
    paint.color = darkColor;
    canvas.drawOval(Rect.fromCenter(center: const Offset(50, 56), width: 30, height: 20), paint);

    // Ears
    paint.color = color;
    canvas.drawOval(Rect.fromCenter(center: const Offset(32, 24), width: 14, height: 14), paint);
    canvas.drawOval(Rect.fromCenter(center: const Offset(68, 24), width: 14, height: 14), paint);

    // Legs
    canvas.drawOval(Rect.fromCenter(center: const Offset(32, 80), width: 20, height: 14), paint);
    canvas.drawOval(Rect.fromCenter(center: const Offset(68, 80), width: 20, height: 14), paint);

    // Eyes
    paint.color = const Color(0xFF2D3561);
    canvas.drawCircle(const Offset(43, 34), 4.5, paint);
    canvas.drawCircle(const Offset(57, 34), 4.5, paint);

    // Eye shine
    paint.color = Colors.white;
    canvas.drawCircle(const Offset(44.5, 32.5), 1.8, paint);
    canvas.drawCircle(const Offset(58.5, 32.5), 1.8, paint);

    // Nostrils
    paint.color = darkColor;
    canvas.drawCircle(const Offset(46, 54), 2.2, paint);
    canvas.drawCircle(const Offset(54, 54), 2.2, paint);

    // Mouth
    final mouthPaint = Paint()
      ..color = const Color(0xFF2D3561)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.5
      ..strokeCap = StrokeCap.round;
    final path = Path()
      ..moveTo(43, 62)
      ..quadraticBezierTo(50, 68, 57, 62);
    canvas.drawPath(path, mouthPaint);

    // Mood indicator (crown for thriving)
    if (mood == HippoMood.thriving) {
      paint
        ..color = AppColors.yellow.withOpacity(0.9)
        ..style = PaintingStyle.fill;
      canvas.drawCircle(const Offset(50, 18), 5, paint);
      paint.color = AppColors.orange;
      canvas.drawCircle(const Offset(50, 13), 3.5, paint);
    }
  }

  @override
  bool shouldRepaint(_HippoPainter old) => old.color != color || old.mood != mood;
}

class MoodBadge extends StatelessWidget {
  final HippoMood mood;

  const MoodBadge({super.key, required this.mood});

  Color get _color => switch (mood) {
        HippoMood.thriving => AppColors.yellow,
        HippoMood.content => AppColors.green,
        HippoMood.resting => AppColors.moodResting,
        HippoMood.needsLove => AppColors.redSoft,
      };

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 5),
      decoration: BoxDecoration(
        color: _color,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        '${mood.emoji} ${mood.label}',
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w800,
          color: mood == HippoMood.thriving ? AppColors.text : Colors.white,
        ),
      ),
    );
  }
}
