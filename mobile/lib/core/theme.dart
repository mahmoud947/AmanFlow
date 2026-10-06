import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class AppColors {
  static const primary = Color(0xFF0A6F82);
  static const primaryDark = Color(0xFF065666);
  static const primaryLight = Color(0xFFDCEFF2);
  static const accent = Color(0xFFE06F2C); // orange call-to-action
  static const surface = Color(0xFFF5F8F8);
  static const ink = Color(0xFF16323A);
  static const muted = Color(0xFF6C7F85);
  static const debit = Color(0xFF16323A);
  static const credit = Color(0xFF0A8A6A);
  static const border = Color(0xFFE3EBED);
}

class AppSpacing {
  static const xs = 4.0, sm = 8.0, md = 16.0, lg = 24.0;
}

ThemeData buildTheme() {
  final scheme = ColorScheme.fromSeed(
    seedColor: AppColors.primary,
    primary: AppColors.primary,
    secondary: AppColors.accent,
    surface: Colors.white,
  );
  return ThemeData(
    useMaterial3: true,
    colorScheme: scheme,
    scaffoldBackgroundColor: AppColors.surface,
    appBarTheme: const AppBarTheme(
      backgroundColor: AppColors.surface,
      foregroundColor: AppColors.ink,
      elevation: 0,
      scrolledUnderElevation: 0,
    ),
    textTheme: const TextTheme(
      headlineSmall: TextStyle(
        fontSize: 22,
        fontWeight: FontWeight.w700,
        color: AppColors.primary,
      ),
      titleMedium: TextStyle(
        fontSize: 15,
        fontWeight: FontWeight.w600,
        color: AppColors.ink,
      ),
      bodyMedium: TextStyle(fontSize: 14, color: AppColors.ink),
      bodySmall: TextStyle(fontSize: 12, color: AppColors.muted),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(foregroundColor: AppColors.primary),
    ),
  );
}

final _amount = NumberFormat('#,##0.00', 'en');

String formatEgp(num value) => 'EGP ${_amount.format(value)}';
String formatDate(DateTime d) =>
    DateFormat('d MMM, h:mm a').format(d.toLocal());

/// Soft white card used across the app.
BoxDecoration cardDecoration({double radius = 16}) => BoxDecoration(
  color: Colors.white,
  borderRadius: BorderRadius.circular(radius),
  border: Border.all(color: AppColors.border),
  boxShadow: [
    BoxShadow(
      color: AppColors.primary.withValues(alpha: 0.06),
      blurRadius: 12,
      offset: const Offset(0, 4),
    ),
  ],
);
