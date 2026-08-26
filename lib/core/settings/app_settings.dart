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
  static const _kAccent = 'accent_id';
  static const _kDynamicColor = 'use_dynamic_color';
  static const _kAmoled = 'amoled_dark';
  static const _kTextScale = 'text_scale';
  static const _kCompact = 'compact_cards';
  static const _kShowWeekends = 'show_weekends';
  static const _kHighlightCurrent = 'highlight_current_lesson';
  static const _kHomeworkReminders = 'homework_reminders_enabled';
  static const _kHomeworkDaysBefore = 'homework_days_before';
  static const _kHomeworkHour = 'homework_reminder_hour';
  static const _kNotifications = 'notifications_enabled';
  static const _kReminderMinutes = 'reminder_minutes';
  static const _kExactAlarms = 'exact_alarms';

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

  /// Идентификатор акцентного цвета из [AppAccents].
  String get accentId => _prefs.getString(_kAccent) ?? 'blue';

  /// Брать цвета из обоев системы (Android 12+).
  bool get useDynamicColor => _prefs.getBool(_kDynamicColor) ?? false;

  /// Чисто чёрный фон в тёмной теме — для OLED-экранов.
  bool get amoledDark => _prefs.getBool(_kAmoled) ?? false;

  /// Масштаб текста, 0.85–1.4.
  double get textScale => _prefs.getDouble(_kTextScale) ?? 1.0;

  /// Компактные карточки пар — на экран влезает больше.
  bool get compactCards => _prefs.getBool(_kCompact) ?? false;

  /// Показывать субботу и воскресенье в переключателе дней.
  bool get showWeekends => _prefs.getBool(_kShowWeekends) ?? true;

  /// Напоминать о домашних заданиях.
  bool get homeworkReminders => _prefs.getBool(_kHomeworkReminders) ?? true;

  /// За сколько дней до сдачи напомнить.
  int get homeworkDaysBefore => _prefs.getInt(_kHomeworkDaysBefore) ?? 1;

  /// Во сколько часов присылать напоминание о домашке.
  int get homeworkReminderHour => _prefs.getInt(_kHomeworkHour) ?? 19;

  /// Подсвечивать пару, которая идёт прямо сейчас.
  bool get highlightCurrentLesson =>
      _prefs.getBool(_kHighlightCurrent) ?? true;

  /// Напоминать о начале пары.
  bool get notificationsEnabled => _prefs.getBool(_kNotifications) ?? false;

  /// За сколько минут до звонка приходит напоминание.
  int get reminderMinutes => _prefs.getInt(_kReminderMinutes) ?? 15;

  /// Точное время срабатывания. Требует отдельного разрешения Android;
  /// без него уведомления приходят приблизительно.
  bool get exactAlarms => _prefs.getBool(_kExactAlarms) ?? false;

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

  Future<void> setAccentId(String value) async {
    await _prefs.setString(_kAccent, value);
    notifyListeners();
  }

  Future<void> setUseDynamicColor(bool value) async {
    await _prefs.setBool(_kDynamicColor, value);
    notifyListeners();
  }

  Future<void> setAmoledDark(bool value) async {
    await _prefs.setBool(_kAmoled, value);
    notifyListeners();
  }

  Future<void> setTextScale(double value) async {
    await _prefs.setDouble(_kTextScale, value.clamp(0.85, 1.4));
    notifyListeners();
  }

  Future<void> setCompactCards(bool value) async {
    await _prefs.setBool(_kCompact, value);
    notifyListeners();
  }

  Future<void> setShowWeekends(bool value) async {
    await _prefs.setBool(_kShowWeekends, value);
    notifyListeners();
  }

  Future<void> setHighlightCurrentLesson(bool value) async {
    await _prefs.setBool(_kHighlightCurrent, value);
    notifyListeners();
  }

  Future<void> setNotificationsEnabled(bool value) async {
    await _prefs.setBool(_kNotifications, value);
    notifyListeners();
  }

  Future<void> setReminderMinutes(int value) async {
    await _prefs.setInt(_kReminderMinutes, value);
    notifyListeners();
  }

  Future<void> setExactAlarms(bool value) async {
    await _prefs.setBool(_kExactAlarms, value);
    notifyListeners();
  }

  Future<void> setHomeworkReminders(bool value) async {
    await _prefs.setBool(_kHomeworkReminders, value);
    notifyListeners();
  }

  Future<void> setHomeworkDaysBefore(int value) async {
    await _prefs.setInt(_kHomeworkDaysBefore, value);
    notifyListeners();
  }

  Future<void> setHomeworkReminderHour(int value) async {
    await _prefs.setInt(_kHomeworkHour, value.clamp(0, 23));
    notifyListeners();
  }

  /// Сбрасывает только внешний вид, не трогая расписание и источники.
  Future<void> resetAppearance() async {
    await Future.wait([
      _prefs.remove(_kThemeMode),
      _prefs.remove(_kAccent),
      _prefs.remove(_kDynamicColor),
      _prefs.remove(_kAmoled),
      _prefs.remove(_kTextScale),
      _prefs.remove(_kCompact),
      _prefs.remove(_kShowWeekends),
      _prefs.remove(_kHighlightCurrent),
    ]);
    notifyListeners();
  }
}
