import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:tick_task/src/services/app_preferences_service.dart';

import 'app_themes.mocks.dart';

// Import the service to be tested

@GenerateMocks([SharedPreferences])
void main() {
  late AppPreferencesService preferencesService;
  late MockSharedPreferences mockSharedPreferences;

  setUp(() async {
    // Initialize mock SharedPreferences
    mockSharedPreferences = MockSharedPreferences();

    // Create an instance of AppPreferencesService and inject mock SharedPreferences
    preferencesService = AppPreferencesService.instance;

    // Use reflection or modify constructor to inject mock for testing
    // This might require a slight modification to the original service class
    preferencesService.prefs = mockSharedPreferences;
  });

  group('AppPreferencesService Tests', () {
    test('getLocale returns default locale when not set', () {
      // Arrange
      when(mockSharedPreferences.getString('selected_locale'))
          .thenReturn(null);

      // Act
      final locale = preferencesService.getLocale();

      // Assert
      expect(locale, 'en');
    });

    test('getLocale returns saved locale', () {
      // Arrange
      when(mockSharedPreferences.getString('selected_locale'))
          .thenReturn('fr');

      // Act
      final locale = preferencesService.getLocale();

      // Assert
      expect(locale, 'fr');
    });


    test('getDarkMode returns default false when not set', () {
      // Arrange
      when(mockSharedPreferences.getBool('is_dark_mode'))
          .thenReturn(null);

      // Act
      final isDarkMode = preferencesService.getDarkMode();

      // Assert
      expect(isDarkMode, false);
    });

    test('getDarkMode returns saved dark mode value', () {
      // Arrange
      when(mockSharedPreferences.getBool('is_dark_mode'))
          .thenReturn(true);

      // Act
      final isDarkMode = preferencesService.getDarkMode();

      // Assert
      expect(isDarkMode, true);
    });

  });
}