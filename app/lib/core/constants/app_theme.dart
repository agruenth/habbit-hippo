import 'package:flutter/material.dart';

abstract final class AppColors {
  static const background = Color(0xFFFAF8F5);
  static const card = Color(0xFFFFFFFF);
  static const primary = Color(0xFF4A90D9);
  static const primaryLight = Color(0xFFE8F4FD);
  static const green = Color(0xFF52C78F);
  static const greenLight = Color(0xFFE8F8F0);
  static const yellow = Color(0xFFFFD43B);
  static const orange = Color(0xFFFF8C42);
  static const redSoft = Color(0xFFFF7070);
  static const text = Color(0xFF2D3561);
  static const textSoft = Color(0xFF6B7280);
  static const border = Color(0xFFE8E4DF);
  static const hippo = Color(0xFFA8D8EA);
  static const hippoDark = Color(0xFF7EC4DA);

  static const tileMeadow = Color(0xFFA8D5A2);
  static const tileForest = Color(0xFF4A7C59);
  static const tilePond = Color(0xFF7EC8E3);
  static const tileHome = Color(0xFFFFD93D);
  static const tileLocked = Color(0xFFD1D5DB);
  static const tileLibrary = Color(0xFFE8D5A3);

  static const moodThriving = Color(0xFFFFD43B);
  static const moodContent = Color(0xFF52C78F);
  static const moodResting = Color(0xFF9CA3AF);
  static const moodNeedsLove = Color(0xFFFF7070);
}

ThemeData buildTheme() {
  return ThemeData(
    useMaterial3: true,
    fontFamily: 'Nunito',
    scaffoldBackgroundColor: AppColors.background,
    colorScheme: ColorScheme.fromSeed(
      seedColor: AppColors.primary,
      background: AppColors.background,
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: AppColors.background,
      foregroundColor: AppColors.text,
      elevation: 0,
      surfaceTintColor: Colors.transparent,
    ),
    cardTheme: CardThemeData(
      color: AppColors.card,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: const BorderSide(color: AppColors.border),
      ),
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        padding: const EdgeInsets.symmetric(vertical: 15),
        textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800, fontFamily: 'Nunito'),
      ),
    ),
  );
}
