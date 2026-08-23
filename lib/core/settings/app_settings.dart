import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Настройки приложения. Всё хранится локально в SharedPreferences —
/// сервера у приложения нет.
class AppSettings extends ChangeNotifier {
  AppSettings(this._prefs);

  final SharedPreferences _prefs;

  static const _kGroup = 'selected_group';
  static const _kSubgroup = 'selected_subgroup';
  static const _kInvertWeek = 'invert_week_parity';
  static const _kThemeMode = 'theme_mode';
  static const _kSourcePageUrl = 'source_page_url';
  static const _kManualLink = 'manual_substitutions_link';
  static const _kAutoRefresh = 'auto_refresh_on_launch';

  /// Страница учебного заведения, где завуч публикует ссылки на замены.
  static const defaultSourcePageUrl =
      'https://www.khamk.ru/studentu/uchebnye-plany-po-spetsialnostyam';

  static Future<AppSettings> load() async =>
      AppSettings(await SharedPreferences.getInstance());

  /// Группа, расписание которой показывается на главном экране.
  String? get selectedGroup => _prefs.getString(_kGroup);

  /// Подгруппа пользователя: '1', '2' или null (все пары).
  String? get subgroup => _prefs.getString(_kSubgroup);

  /// Инвертировать отсчёт числителя/знаменателя.
  bool get invertWeekParity => _prefs.getBool(_kInvertWeek) ?? false;

  ThemeMode get themeMode => switch (_prefs.getString(_kThemeMode)) {
        'light' => ThemeMode.light,
        'dark' => ThemeMode.dark,
        _ => ThemeMode.system,
      };

  String get sourcePageUrl =>
      _prefs.getString(_kSourcePageUrl) ?? defaultSourcePageUrl;

  /// Прямая ссылка на облако, заданная вручную. Если задана — сайт не парсим.
  String? get manualLink {
    final value = _prefs.getString(_kManualLink)?.trim();
    return (value == null || value.isEmpty) ? null : value;
  }

  bool get autoRefreshOnLaunch => _prefs.getBool(_kAutoRefresh) ?? true;

  Future<void> setSelectedGroup(String? value) async {
    if (value == null) {
      await _prefs.remove(_kGroup);
    } else {
      await _prefs.setString(_kGroup, value);
    }
    notifyListeners();
  }

  Future<void> setSubgroup(String? value) async {
    if (value == null) {
      await _prefs.remove(_kSubgroup);
    } else {
      await _prefs.setString(_kSubgroup, value);
    }
    notifyListeners();
  }

  Future<void> setInvertWeekParity(bool value) async {
    await _prefs.setBool(_kInvertWeek, value);
    notifyListeners();
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    await _prefs.setString(_kThemeMode, mode.name);
    notifyListeners();
  }

  Future<void> setSourcePageUrl(String value) async {
    final trimmed = value.trim();
    await _prefs.setString(
      _kSourcePageUrl,
      trimmed.isEmpty ? defaultSourcePageUrl : trimmed,
    );
    notifyListeners();
  }

  Future<void> setManualLink(String? value) async {
    final trimmed = value?.trim() ?? '';
    if (trimmed.isEmpty) {
      await _prefs.remove(_kManualLink);
    } else {
      await _prefs.setString(_kManualLink, trimmed);
    }
    notifyListeners();
  }

  Future<void> setAutoRefreshOnLaunch(bool value) async {
    await _prefs.setBool(_kAutoRefresh, value);
    notifyListeners();
  }
}
