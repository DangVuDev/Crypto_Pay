import 'package:flutter/material.dart';
import 'app_colors.dart';

abstract class TextStyles {
  // Headings
  static const heading1 = TextStyle(
    fontSize: 28.0,
    fontWeight: FontWeight.bold,
    height: 1.2,
    color: AppColors.textPrimaryLight,
  );
  
  static const heading2 = TextStyle(
    fontSize: 24.0,
    fontWeight: FontWeight.bold,
    height: 1.2,
    color: AppColors.textPrimaryLight,
  );
  
  static const heading3 = TextStyle(
    fontSize: 20.0,
    fontWeight: FontWeight.bold,
    height: 1.2,
    color: AppColors.textPrimaryLight,
  );
  
  static const heading4 = TextStyle(
    fontSize: 18.0,
    fontWeight: FontWeight.w600,
    height: 1.3,
    color: AppColors.textPrimaryLight,
  );
  
  static const heading5 = TextStyle(
    fontSize: 16.0,
    fontWeight: FontWeight.w600,
    height: 1.3,
    color: AppColors.textPrimaryLight,
  );
  
  // Body Text
  static const body1 = TextStyle(
    fontSize: 16.0,
    fontWeight: FontWeight.normal,
    height: 1.5,
    color: AppColors.textPrimaryLight,
  );
  
  static const body2 = TextStyle(
    fontSize: 14.0,
    fontWeight: FontWeight.normal,
    height: 1.5,
    color: AppColors.textPrimaryLight,
  );
  
  // Caption & Button
  static const caption = TextStyle(
    fontSize: 12.0,
    fontWeight: FontWeight.normal,
    height: 1.5,
    color: AppColors.textSecondaryLight,
  );
  
  static const button = TextStyle(
    fontSize: 16.0,
    fontWeight: FontWeight.w600,
    height: 1.5,
    letterSpacing: 0.5,
  );
  
  // Special Styles
  static const amount = TextStyle(
    fontSize: 36.0,
    fontWeight: FontWeight.bold,
    height: 1.1,
    color: AppColors.textPrimaryLight,
  );
  
  static const currencySymbol = TextStyle(
    fontSize: 20.0,
    fontWeight: FontWeight.bold,
    height: 1.1,
    color: AppColors.primary,
  );
  
  static const smallCaps = TextStyle(
    fontSize: 12.0,
    fontWeight: FontWeight.w600,
    letterSpacing: 1.0,
    height: 1.5,
    color: AppColors.textSecondaryLight,
  );
}