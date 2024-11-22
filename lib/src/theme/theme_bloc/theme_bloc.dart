// Theme events
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tick_task/src/theme/app_theme.dart';

import '../../services/app_preferences_service.dart';

// Base class for theme-related events
abstract class ThemeEvent {}

// Event to change the current theme and dark mode setting
class ChangeThemeEvent extends ThemeEvent {
  final String themeName;
  final bool isDarkMode;
  ChangeThemeEvent(this.themeName, this.isDarkMode);
}

// Event to load the saved theme from preferences
class LoadSavedTheme extends ThemeEvent {}

// Base class for theme-related states
abstract class ThemeState {}

// State containing current theme settings
class ThemeInitial extends ThemeState {
  final String currentTheme;
  final bool isDarkMode;
  ThemeInitial(this.currentTheme, this.isDarkMode);
}

// BLoC for managing theme state and changes
class ThemeBloc extends Bloc<ThemeEvent, ThemeState> {
  // Service for persisting theme preferences
  final AppPreferencesService _appPreferencesService;

  // Constructor initializes bloc with saved theme preferences
  ThemeBloc({required AppPreferencesService appPreferencesService})
      : _appPreferencesService = appPreferencesService,
        super(ThemeInitial(
          appPreferencesService.getTheme(),
          appPreferencesService.getDarkMode(),
        )) {
    on<ChangeThemeEvent>(_onChangeTheme);
    on<LoadSavedTheme>(_onLoadSavedTheme);
  }

  // Handle theme change events
  Future<void> _onChangeTheme(
    ChangeThemeEvent event,
    Emitter<ThemeState> emit,
  ) async {
    await _appPreferencesService.saveTheme(event.themeName);
    await _appPreferencesService.saveDarkMode(event.isDarkMode);
    emit(ThemeInitial(event.themeName, event.isDarkMode));
  }

  // Handle loading saved theme preferences
  void _onLoadSavedTheme(
    LoadSavedTheme event,
    Emitter<ThemeState> emit,
  ) {
    final savedTheme = _appPreferencesService.getTheme();
    final isDarkMode = _appPreferencesService.getDarkMode();
    emit(ThemeInitial(savedTheme, isDarkMode));
  }

  // Get ThemeData based on theme name and dark mode setting
  ThemeData getTheme(String themeName, bool isDark) {
    switch (themeName) {
      case 'SoftPastel':
        return isDark ? SoftPastelTheme.darkTheme : SoftPastelTheme.lightTheme;
      case 'Earthy':
        return isDark
            ? ModernEarthyTheme.darkTheme
            : ModernEarthyTheme.lightTheme;
      case 'Vibrant':
        return isDark
            ? BoldVibrantTheme.darkTheme
            : BoldVibrantTheme.lightTheme;
      default:
        return SoftPastelTheme.lightTheme;
    }
  }
}
