import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  // Primary Brand — Orange (admin_home_dashboard)
  static const Color primary = Color(0xFFEC5B13);
  static const Color primaryLight = Color(0xFFFCEEE6);
  static const Color primaryDark = Color(0xFFB5420B);

  // Accent Brand — Deep Navy (splash_screen)
  static const Color accent = Color(0xFF001F3F);
  static const Color accentLight = Color(0xFF1A3A5C);

  // Transaction Types (Emerald / Rose)
  static const Color income = Color(0xFF059669); // emerald-600
  static const Color incomeLight = Color(0xFFD1FAE5); // emerald-100
  static const Color expense = Color(0xFFE11D48); // rose-600
  static const Color expenseLight = Color(0xFFFFE4E6); // rose-100

  // Backgrounds
  static const Color background = Color(0xFFF8F6F6); // background-light
  static const Color backgroundDark = Color(0xFF221610); // background-dark
  static const Color surface = Color(0xFFFFFFFF);
  static const Color cardBackground = Color(0xFFFFFFFF);

  // Text
  static const Color textPrimary = Color(0xFF0F172A); // slate-900
  static const Color textSecondary = Color(0xFF64748B); // slate-500
  static const Color textHint = Color(0xFF94A3B8); // slate-400
  static const Color textOnPrimary = Color(0xFFFFFFFF);

  // Border & Divider
  static const Color border = Color(0xFFE2E8F0); // slate-200
  static const Color divider = Color(0xFFF1F5F9); // slate-100

  // Status
  static const Color success = Color(0xFF059669);
  static const Color warning = Color(0xFFF59E0B);
  static const Color error = Color(0xFFE11D48);
  static const Color info = Color(0xFF3B82F6);

  // Role chips
  static const Color superAdminChip = Color(0xFF001F3F);
  static const Color adminChip = Color(0xFFEC5B13);
  static const Color partnerChip = Color(0xFF64748B);

  // Shadow
  static const Color shadow = Color(0x1A000000);
  static const Color shadowLight = Color(0x0D000000);
}
