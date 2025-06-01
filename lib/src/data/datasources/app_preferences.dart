import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/material.dart';

class AppPreferences {
  final SharedPreferences _prefs;
  
  AppPreferences(this._prefs);
  
  // Theme Preferences
  static const _themeKey = 'app_theme';
  
  Future<void> setThemeMode(ThemeMode mode) async {
    await _prefs.setString(_themeKey, mode.name);
  }
  
  ThemeMode getThemeMode() {
    final theme = _prefs.getString(_themeKey);
    if (theme == null) return ThemeMode.system;
    
    return ThemeMode.values.firstWhere(
      (e) => e.name == theme,
      orElse: () => ThemeMode.system,
    );
  }
  
  // Language Preferences
  static const _localeKey = 'app_locale';
  
  Future<void> setLocale(Locale locale) async {
    await _prefs.setString(_localeKey, '${locale.languageCode}_${locale.countryCode}');
  }
  
  Locale? getLocale() {
    final localeStr = _prefs.getString(_localeKey);
    if (localeStr == null) return null;
    
    final parts = localeStr.split('_');
    if (parts.length == 2) {
      return Locale(parts[0], parts[1]);
    }
    return Locale(parts[0]);
  }
  
  // Onboarding Status
  static const _onboardingKey = 'onboarding_completed';
  
  Future<void> setOnboardingCompleted(bool completed) async {
    await _prefs.setBool(_onboardingKey, completed);
  }
  
  bool isOnboardingCompleted() {
    return _prefs.getBool(_onboardingKey) ?? false;
  }
  
  // Generic List Storage
  Future<void> setStringList(String key, List<String> value) async {
    await _prefs.setStringList(key, value);
  }
  
  List<String>? getStringList(String key) {
    return _prefs.getStringList(key);
  }
  
  // Generic Object Storage
  Future<void> setObject(String key, Map<String, dynamic> value) async {
    await _prefs.setString(key, jsonEncode(value));
  }
  
  Map<String, dynamic>? getObject(String key) {
    final json = _prefs.getString(key);
    if (json == null) return null;
    
    try {
      return jsonDecode(json) as Map<String, dynamic>;
    } catch (_) {
      return null;
    }
  }
  
  // Generic List of Objects Storage
  Future<void> setObjectList(String key, List<Map<String, dynamic>> value) async {
    await _prefs.setString(key, jsonEncode(value));
  }
  
  List<Map<String, dynamic>>? getObjectList(String key) {
    final json = _prefs.getString(key);
    if (json == null) return null;
    
    try {
      final list = jsonDecode(json) as List;
      return list.cast<Map<String, dynamic>>();
    } catch (_) {
      return null;
    }
  }
  
  // Clear Preferences
  Future<void> clearAll() async {
    await _prefs.clear();
  }
}