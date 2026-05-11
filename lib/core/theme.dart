// lib/core/theme_cubit/theme_cubit.dart

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeCubit extends Cubit<ThemeMode> {
  static const String _key = 'theme_mode';

  ThemeCubit() : super(ThemeMode.light) {
    _loadTheme();
  }

  Future<void> _loadTheme() async {
    final prefs = await SharedPreferences.getInstance();
    final savedTheme = prefs.getString(_key);

    if (savedTheme == 'dark') {
      emit(ThemeMode.dark);
    } else {
      emit(ThemeMode.light);
    }
  }

  Future<void> setDarkTheme() async {
    emit(ThemeMode.dark);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_key, 'dark');
  }

  Future<void> setLightTheme() async {
    emit(ThemeMode.light);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_key, 'light');
  }
}
