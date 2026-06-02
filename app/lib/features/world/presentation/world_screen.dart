import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_theme.dart';

// Static world grid matching the mockup — will be replaced by API data
const _grid = [
  // row, [x coords], offset
  // Row 0 (no offset): empty, locked, forest, locked, empty
  // Row 1 (offset): locked, meadow, meadow, locked
  // Row 2 (no offset): meadow, meadow, home, meadow, library
  // Row 3 (offset): meadow, meadow, meadow, locked
  // Row 4 (no offset): 5x locked
  // Row 5 (offset): pond, pond, pond, locked
];

class WorldScreen extends ConsumerWidget {
  const WorldScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 14, 24, 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("Milo's World", style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: AppColors.text)),
                      Text('8 tiles unlocked', style: TextStyle(fontSize: 12, color: AppColors.textSoft, fontWeight: FontWeight.w600)),
                    ],
                  ),
                  const Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text('🦔 7 animals met', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: AppColors.textSoft)),
                      Text('📚 Library: 3 / 5', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: AppColors.textSoft)),
                    ],
                  ),
                ],
              ),
            ),

            // Hex grid
            Expanded(
              child: InteractiveViewer(
                minScale: 0.6,
                maxScale: 2.0,
                child: Center(child: _HexGrid()),
              ),
            ),

            // Legend
            _Legend(),
            const SizedBox(height: 4),

            // Unlock progress
            _UnlockBar(),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }
}

class _HexGrid extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    const hexW = 54.0;
    const hexH = 62.0;
    const gap = 5.0;
    const colSpacing = hexW + gap;
    const rowSpacing = hexH * 0.75 + gap;

    // Define the grid: (x, y, zone, animal)
    final rows = [
      [null, _Hex('locked', '🔒'), _Hex('forest', '🌲'), _Hex('locked', '🔒'), null],
      [_Hex('locked', '🔒'), _Hex('meadow', '🌿'), _Hex('meadow', '🌸'), _Hex('locked', '🔒')],
      [_Hex('meadow', '🐇'), _Hex('meadow', '🌻'), _Hex('home', '🏠'), _Hex('meadow', '🐝'), _Hex('library', '📚')],
      [_Hex('meadow', '🦔'), _Hex('meadow', '🌸'), _Hex('meadow', '🌿'), _Hex('locked', '🔒')],
      [_Hex('locked', '🔒'), _Hex('locked', '🔒'), _Hex('locked', '🔒'), _Hex('locked', '🔒'), _Hex('locked', '🔒')],
      [_Hex('pond', '🐸'), _Hex('pond_friend', '💧'), _Hex('pond', '🦆'), _Hex('locked', '🔒')],
    ];

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: rows.asMap().entries.map((entry) {
        final rowIdx = entry.key;
        final row = entry.value;
        final isOffset = rowIdx.isOdd;
        return Padding(
          padding: EdgeInsets.only(
            left: isOffset ? colSpacing / 2 : 0,
            bottom: rowIdx < rows.length - 1 ? rowSpacing - hexH : 0,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: row.where((e) => e != null).map((hex) {
              return Padding(
                padding: const EdgeInsets.only(right: gap),
                child: _HexTile(hex: hex!, size: Size(hexW, hexH)),
              );
            }).toList(),
          ),
        );
      }).toList(),
    );
  }
}

class _Hex {
  final String zone;
  final String emoji;
  const _Hex(this.zone, this.emoji);
}

class _HexTile extends StatelessWidget {
  final _Hex hex;
  final Size size;
  const _HexTile({required this.hex, required this.size});

  Color get _color => switch (hex.zone) {
        'home' => AppColors.tileHome,
        'meadow' => AppColors.tileMeadow,
        'forest' => AppColors.tileForest,
        'pond' || 'pond_friend' => AppColors.tilePond,
        'library' => AppColors.tileLibrary,
        _ => AppColors.tileLocked,
      };

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size.width,
      height: size.height,
      child: ClipPath(
        clipper: _HexClipper(),
        child: Container(
          color: _color,
          child: Center(
            child: Stack(
              alignment: Alignment.center,
              children: [
                Text(hex.emoji, style: TextStyle(fontSize: hex.zone == 'locked' ? 14 : 20)),
                if (hex.zone == 'pond_friend')
                  Positioned(
                    bottom: 12, right: 8,
                    child: Container(
                      width: 16, height: 16,
                      decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
                      child: const Text('🦛', style: TextStyle(fontSize: 9)),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _HexClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final w = size.width;
    final h = size.height;
    return Path()
      ..moveTo(w * 0.5, 0)
      ..lineTo(w, h * 0.25)
      ..lineTo(w, h * 0.75)
      ..lineTo(w * 0.5, h)
      ..lineTo(0, h * 0.75)
      ..lineTo(0, h * 0.25)
      ..close();
  }

  @override
  bool shouldReclip(_) => false;
}

class _Legend extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final items = [
      ('Home', AppColors.tileHome),
      ('Meadow', AppColors.tileMeadow),
      ('Forest', AppColors.tileForest),
      ('Pond', AppColors.tilePond),
      ('Library', AppColors.tileLibrary),
      ('Locked', AppColors.tileLocked),
    ];
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
      child: Wrap(
        spacing: 12,
        runSpacing: 4,
        children: items.map((item) => Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(width: 10, height: 10, decoration: BoxDecoration(color: item.$2, borderRadius: BorderRadius.circular(2))),
            const SizedBox(width: 4),
            Text(item.$1, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: AppColors.textSoft)),
          ],
        )).toList(),
      ),
    );
  }
}

class _UnlockBar extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('🔓 Next unlock: Meadow SE corner', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.text)),
          const SizedBox(height: 2),
          const Text('Walk 3,800 more steps · 6,200 / 10,000 today', style: TextStyle(fontSize: 11, color: AppColors.textSoft)),
          const SizedBox(height: 7),
          ClipRRect(
            borderRadius: BorderRadius.circular(3),
            child: const LinearProgressIndicator(value: 0.62, backgroundColor: AppColors.border, valueColor: AlwaysStoppedAnimation(AppColors.green), minHeight: 6),
          ),
        ],
      ),
    );
  }
}
