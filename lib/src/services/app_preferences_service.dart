import 'package:shared_preferences/shared_preferences.dart';

// Service class for managing app preferences using SharedPreferences
class AppPreferencesService {
  // Keys for storing preferences
  static const String _localeKey = 'selected_locale';
  static const String _themeNameKey = 'selected_theme';
  static const String _isDarkModeKey = 'is_dark_mode';

  // Singleton instance
  static final AppPreferencesService instance =
      AppPreferencesService._internal();
  late SharedPreferences _prefs;

  // Factory constructor that returns singleton instance
  factory AppPreferencesService() {
    return instance;
  }

  // Private constructor for singleton pattern
  AppPreferencesService._internal();

  // Getter for SharedPreferences instance
  SharedPreferences get prefs => _prefs;

  // Initialize SharedPreferences instance
  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  // Setter for SharedPreferences instance (mainly for testing)
  set prefs(SharedPreferences pref) => _prefs = pref;

  // Save selected locale to preferences
  Future<void> saveLocale(String locale) async {
    await _prefs.setString(_localeKey, locale);
  }

  // Get saved locale, defaults to 'en' if not set
  String getLocale() {
    return _prefs.getString(_localeKey) ?? 'en';
  }

  // Save selected theme name to preferences
  Future<void> saveTheme(String themeName) async {
    await _prefs.setString(_themeNameKey, themeName);
  }

  // Get saved theme name, defaults to 'SoftPastel' if not set
  String getTheme() {
    return _prefs.getString(_themeNameKey) ?? 'SoftPastel';
  }

  // Save dark mode preference
  Future<void> saveDarkMode(bool isDarkMode) async {
    await _prefs.setBool(_isDarkModeKey, isDarkMode);
  }

  // Get dark mode preference, defaults to false if not set
  bool getDarkMode() {
    return _prefs.getBool(_isDarkModeKey) ?? false;
  }
}
