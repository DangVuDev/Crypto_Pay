import 'package:flutter/material.dart';

abstract class AppColors {
  // Light Theme Colors
  static const primary = Color(0xFF1A73E8);
  static const secondary = Color(0xFF673AB7);
  static const accent = Color(0xFFFFA000);
  static const success = Color(0xFF4CAF50);
  static const warning = Color(0xFFFF9800);
  static const error = Color(0xFFE53935);
  
  static const backgroundLight = Color(0xFFF5F5F7);
  static const surfaceLight = Colors.white;
  static const cardLight = Colors.white;
  static const borderLight = Color(0xFFE0E0E0);
  static const dividerLight = Color(0xFFE0E0E0);
  static const inputBackgroundLight = Colors.white;
  
  static const textPrimaryLight = Color(0xFF212121);
  static const textSecondaryLight = Color(0xFF757575);
  static const textTertiaryLight = Color(0xFFBDBDBD);
  
  // Dark Theme Colors
  static const primaryDark = Color(0xFF4285F4);
  static const secondaryDark = Color(0xFF9575CD);
  static const accentDark = Color(0xFFFFB300);
  static const successDark = Color(0xFF66BB6A);
  static const warningDark = Color(0xFFFFA726);
  static const errorDark = Color(0xFFEF5350);
  
  static const backgroundDark = Color(0xFF121212);
  static const surfaceDark = Color(0xFF1E1E1E);
  static const cardDark = Color(0xFF2A2A2A);
  static const borderDark = Color(0xFF424242);
  static const dividerDark = Color(0xFF424242);
  static const inputBackgroundDark = Color(0xFF2A2A2A);
  
  static const textPrimaryDark = Color(0xFFE0E0E0);
  static const textSecondaryDark = Color(0xFFB0B0B0);
  static const textTertiaryDark = Color(0xFF707070);
  
  // Crypto Asset Colors
  static const bitcoin = Color(0xFFFF9800);
  static const ethereum = Color(0xFF673AB7);
  static const usdt = Color(0xFF4CAF50);
  
  // Gradient Colors
  static const gradientPrimaryStart = Color(0xFF1A73E8);
  static const gradientPrimaryEnd = Color(0xFF6AB7FF);
  
  static const gradientSecondaryStart = Color(0xFF673AB7);
  static const gradientSecondaryEnd = Color(0xFF9575CD);
  
  static const gradientWarningStart = Color(0xFFFF9800);
  static const gradientWarningEnd = Color(0xFFFFCC80);
}