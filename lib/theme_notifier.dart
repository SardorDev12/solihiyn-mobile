import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeNotifier extends ChangeNotifier {
  ThemeData _currentTheme = darkTheme;
  SharedPreferences? _prefs;
  bool _isLoaded = false;

  ThemeNotifier() {
    loadFromPrefs();
  }

  ThemeData getTheme() => _currentTheme;
  bool get isLoaded => _isLoaded;

  Future<void> _initPrefs() async {
    _prefs = await SharedPreferences.getInstance();
  }

  Future<void> loadFromPrefs() async {
    await _initPrefs();
    final isDarkMode = _prefs?.getBool('isDarkMode') ?? false;
    _currentTheme = isDarkMode ? darkTheme : lightTheme;
    _isLoaded = true;
    notifyListeners();

    if (!isDarkMode) {
      toggleTheme();
    }
  }

  Future<void> saveToPrefs() async {
    await _initPrefs();
    _prefs?.setBool('isDarkMode', _currentTheme == darkTheme);
  }

  void toggleTheme() async {
    _currentTheme = _currentTheme == darkTheme ? lightTheme : darkTheme;
    saveToPrefs();
    notifyListeners();
  }
}

final lightTheme = ThemeData(
  brightness: Brightness.light,
  colorScheme: const ColorScheme.light(
    primary: Color.fromARGB(255, 151, 136, 117),
  ),
);

final darkTheme = ThemeData(
  brightness: Brightness.dark,
  colorScheme: const ColorScheme.dark(
    primary: Color.fromARGB(255, 44, 99, 119),
  ),
);
