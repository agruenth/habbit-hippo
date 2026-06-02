import 'package:flutter/material.dart';

enum TileZone { home, meadow, forest, pond, library, locked }

class WorldTile {
  final int x;
  final int y;
  final bool unlocked;
  final DateTime? unlockedAt;

  const WorldTile({required this.x, required this.y, required this.unlocked, this.unlockedAt});

  TileZone get zone {
    if (x == 0 && y == 0) return TileZone.home;
    if (x == 2 && (y == 0 || y == -1)) return TileZone.library;
    if (y <= -3) return TileZone.forest;
    if (y >= 3) return TileZone.pond;
    if ((x.abs() + y.abs()) <= 2) return TileZone.meadow;
    return TileZone.locked;
  }

  factory WorldTile.fromJson(Map<String, dynamic> json) => WorldTile(
        x: json['x'] as int,
        y: json['y'] as int,
        unlocked: json['unlocked_at'] != null,
      );
}

extension TileZoneX on TileZone {
  String get emoji => switch (this) {
        TileZone.home => '🏠',
        TileZone.meadow => '🌿',
        TileZone.forest => '🌲',
        TileZone.pond => '💧',
        TileZone.library => '📚',
        TileZone.locked => '🔒',
      };

  Color get color => switch (this) {
        TileZone.home => const Color(0xFFFFD93D),
        TileZone.meadow => const Color(0xFFA8D5A2),
        TileZone.forest => const Color(0xFF4A7C59),
        TileZone.pond => const Color(0xFF7EC8E3),
        TileZone.library => const Color(0xFFE8D5A3),
        TileZone.locked => const Color(0xFFD1D5DB),
      };
}
