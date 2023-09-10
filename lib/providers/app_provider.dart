import 'package:flutter/material.dart';
import 'package:food_recipes_app/models/difficulty.dart';
import 'package:food_recipes_app/models/language.dart';
import 'package:food_recipes_app/models/settings.dart';
import 'package:food_recipes_app/services/api_repository.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../Theme/style.dart';
import '../preferences/session_manager.dart';

class AppProvider extends ChangeNotifier {
  AppProvider() {
    getTheme();
  }

  Settings? _settings;
  List<Difficulty> _difficulties = [];
  List<Language> _languages = [];
  int _recipeClickCount = 0;
  ThemeData _theme = appTheme;
  bool _isDark = false;

  bool get isDark => _isDark;

  set isDark(bool value) {
    _isDark = value;
    notifyListeners();
  }

  Settings? get settings => _settings;

  List<Difficulty> get difficulties => _difficulties;

  List<Language> get languages => _languages;

  int get recipeClickCount => _recipeClickCount;

  ThemeData get theme => _theme;

  // set theme(ThemeData value) {
  //   _theme = value;
  //   notifyListeners();
  // }

  getTheme() async {
    bool? isDark = await SessionManager().getTheme();
    _isDark = (isDark ?? false);
    ThemeData theme = _isDark ? darkTheme : appTheme;
    _theme = theme;
    notifyListeners();
  }

  void setTheme() async {
    // _isDark = isDark;
    ThemeData theme = _isDark ? darkTheme : appTheme;
    _theme = theme;
    SessionManager().saveTheme(_isDark);
    notifyListeners();
  }

  Future fetchSettings() async {
    http.Response? response = await ApiRepository.fetchSettings();
    print('MK: settings:  ${response?.body}');
    _settings = settingsFromJson(response!.body);
    notifyListeners();
  }

  Future fetchDifficulties() async {
    if (_difficulties.isNotEmpty) {
      return;
    }
    http.Response? response = await ApiRepository.fetchDifficulties();
    _difficulties = difficultyFromJson(response!.body);
    print(response.body);
    notifyListeners();
  }

  Future fetchLanguages() async {
    if (_languages.isNotEmpty) {
      return;
    }
    http.Response? response = await ApiRepository.fetchLanguages();
    _languages = languageFromJson(response!.body);
    print(response.body);
    notifyListeners();
  }

  Future incrementAdClickCount() async {
    _recipeClickCount++;
    notifyListeners();
  }

  resetAdClickCount() {
    _recipeClickCount = 0;
  }

  emptyDifficultiesLists() {
    _difficulties.clear();
  }

  notifyListeners();
}
