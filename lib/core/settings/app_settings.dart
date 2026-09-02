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
  static const _kBuilding = 'preferred_building';
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
  static const _kBackgroundRefresh = 'background_refresh_enabled';
  static const _kBackgroundHours = 'background_refresh_hours';
  static const _kAttendanceReminders = 'attendance_reminders_enabled';
  static const _kShowSkipAdvice = 'show_skip_advice';
  static const _kSkipLimit = 'skip_limit_per_subject';
  static const _kSkipLimitMajor = 'skip_limit_per_major_subject';

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

  /// Проверять замены в фоне, даже когда приложение закрыто.
  bool get backgroundRefreshEnabled =>
      _prefs.getBool(_kBackgroundRefresh) ?? false;

  /// Как часто проверять. Android не запускает задачи чаще раза в 15 минут,
  /// а для замен разумный шаг — часы.
  int get backgroundRefreshHours => _prefs.getInt(_kBackgroundHours) ?? 3;

  String get sourcePageUrl =>
      _prefs.getString(_kSourcePageUrl) ?? defaultSourcePageUrl;

  /// Корпус, чьи замены нужны. null — брать любые: на сайте заведения
  /// замены выкладывают отдельным файлом на каждый корпус.
  int? get preferredBuilding {
    final value = _prefs.getInt(_kBuilding);
    return (value == null || value <= 0) ? null : value;
  }

  /// Прямая ссылка на файл, заданная вручную. Если задана — сайт не парсим.
  String? get manualLink {
    final value = _prefs.getString(_kManualLink)?.trim();
    return (value == null || value.isEmpty) ? null : value;
  }

  bool get autoRefreshOnLaunch => _prefs.getBool(_kAutoRefresh) ?? true;

  /// Напоминать вечером отметить пропуски.
  bool get attendanceRemindersEnabled =>
      _prefs.getBool(_kAttendanceReminders) ?? true;

  /// Показывать над расписанием вердикт «можно ли пропустить».
  bool get showSkipAdvice => _prefs.getBool(_kShowSkipAdvice) ?? true;

  /// Сколько пар по обычному предмету можно пропустить без последствий.
  /// Общего стандарта нет — в каждом заведении считают по-своему.
  int get skipLimitPerSubject => _prefs.getInt(_kSkipLimit) ?? 4;

  /// То же для профильных предметов — по ним спрашивают строже.
  int get skipLimitPerMajorSubject => _prefs.getInt(_kSkipLimitMajor) ?? 2;

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

  Future<void> setPreferredBuilding(int? value) async {
    if (value == null) {
      await _prefs.remove(_kBuilding);
    } else {
      await _prefs.setInt(_kBuilding, value);
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

  Future<void> setBackgroundRefreshEnabled(bool value) async {
    await _prefs.setBool(_kBackgroundRefresh, value);
    notifyListeners();
  }

  Future<void> setBackgroundRefreshHours(int value) async {
    await _prefs.setInt(_kBackgroundHours, value.clamp(1, 24));
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

  Future<void> setAttendanceRemindersEnabled(bool value) async {
    await _prefs.setBool(_kAttendanceReminders, value);
    notifyListeners();
  }

  Future<void> setShowSkipAdvice(bool value) async {
    await _prefs.setBool(_kShowSkipAdvice, value);
    notifyListeners();
  }

  Future<void> setSkipLimitPerSubject(int value) async {
    await _prefs.setInt(_kSkipLimit, value.clamp(1, 40));
    notifyListeners();
  }

  Future<void> setSkipLimitPerMajorSubject(int value) async {
    await _prefs.setInt(_kSkipLimitMajor, value.clamp(1, 40));
    notifyListeners();
  }

  /// Настройки для резервной копии. Не включает выбранную группу и
  /// подгруппу: они привязаны к расписанию, которое бэкап восстанавливает
  /// отдельно, и их некорректно тащить в файл вслепую.
  Map<String, dynamic> exportForBackup() => {
        'invertWeekParity': invertWeekParity,
        'themeMode': themeMode.name,
        'accentId': accentId,
        'useDynamicColor': useDynamicColor,
        'amoledDark': amoledDark,
        'textScale': textScale,
        'compactCards': compactCards,
        'showWeekends': showWeekends,
        'highlightCurrentLesson': highlightCurrentLesson,
        'notificationsEnabled': notificationsEnabled,
        'reminderMinutes': reminderMinutes,
        'exactAlarms': exactAlarms,
        'homeworkReminders': homeworkReminders,
        'homeworkDaysBefore': homeworkDaysBefore,
        'homeworkReminderHour': homeworkReminderHour,
        'backgroundRefreshEnabled': backgroundRefreshEnabled,
        'backgroundRefreshHours': backgroundRefreshHours,
        'sourcePageUrl': sourcePageUrl,
        'manualLink': manualLink,
        'preferredBuilding': preferredBuilding,
        'autoRefreshOnLaunch': autoRefreshOnLaunch,
        'attendanceRemindersEnabled': attendanceRemindersEnabled,
        'showSkipAdvice': showSkipAdvice,
        'skipLimitPerSubject': skipLimitPerSubject,
        'skipLimitPerMajorSubject': skipLimitPerMajorSubject,
      };

  /// Восстанавливает настройки из резервной копии. Пропускает ключи,
  /// которых нет в файле, — так старые бэкапы не роняют импорт после
  /// того, как в приложении появятся новые настройки.
  Future<void> importFromBackup(Map<String, dynamic> data) async {
    bool? asBool(String key) => data[key] as bool?;
    int? asInt(String key) => (data[key] as num?)?.toInt();
    double? asDouble(String key) => (data[key] as num?)?.toDouble();
    String? asString(String key) => data[key] as String?;

    if (data.containsKey('invertWeekParity')) {
      await setInvertWeekParity(asBool('invertWeekParity') ?? false);
    }
    final themeName = asString('themeMode');
    if (themeName != null) {
      await setThemeMode(ThemeMode.values.firstWhere(
        (m) => m.name == themeName,
        orElse: () => ThemeMode.system,
      ));
    }
    final accent = asString('accentId');
    if (accent != null) await setAccentId(accent);
    if (data.containsKey('useDynamicColor')) {
      await setUseDynamicColor(asBool('useDynamicColor') ?? false);
    }
    if (data.containsKey('amoledDark')) {
      await setAmoledDark(asBool('amoledDark') ?? false);
    }
    final scale = asDouble('textScale');
    if (scale != null) await setTextScale(scale);
    if (data.containsKey('compactCards')) {
      await setCompactCards(asBool('compactCards') ?? false);
    }
    if (data.containsKey('showWeekends')) {
      await setShowWeekends(asBool('showWeekends') ?? true);
    }
    if (data.containsKey('highlightCurrentLesson')) {
      await setHighlightCurrentLesson(
          asBool('highlightCurrentLesson') ?? true);
    }
    if (data.containsKey('notificationsEnabled')) {
      await setNotificationsEnabled(asBool('notificationsEnabled') ?? false);
    }
    final minutes = asInt('reminderMinutes');
    if (minutes != null) await setReminderMinutes(minutes);
    if (data.containsKey('exactAlarms')) {
      await setExactAlarms(asBool('exactAlarms') ?? false);
    }
    if (data.containsKey('homeworkReminders')) {
      await setHomeworkReminders(asBool('homeworkReminders') ?? true);
    }
    final hwDays = asInt('homeworkDaysBefore');
    if (hwDays != null) await setHomeworkDaysBefore(hwDays);
    final hwHour = asInt('homeworkReminderHour');
    if (hwHour != null) await setHomeworkReminderHour(hwHour);
    if (data.containsKey('backgroundRefreshEnabled')) {
      await setBackgroundRefreshEnabled(
          asBool('backgroundRefreshEnabled') ?? false);
    }
    final bgHours = asInt('backgroundRefreshHours');
    if (bgHours != null) await setBackgroundRefreshHours(bgHours);
    final pageUrl = asString('sourcePageUrl');
    if (pageUrl != null) await setSourcePageUrl(pageUrl);
    if (data.containsKey('manualLink')) {
      await setManualLink(asString('manualLink'));
    }
    if (data.containsKey('preferredBuilding')) {
      await setPreferredBuilding(asInt('preferredBuilding'));
    }
    if (data.containsKey('autoRefreshOnLaunch')) {
      await setAutoRefreshOnLaunch(asBool('autoRefreshOnLaunch') ?? true);
    }
    if (data.containsKey('attendanceRemindersEnabled')) {
      await setAttendanceRemindersEnabled(
          asBool('attendanceRemindersEnabled') ?? true);
    }
    if (data.containsKey('showSkipAdvice')) {
      await setShowSkipAdvice(asBool('showSkipAdvice') ?? true);
    }
    final skipLimit = asInt('skipLimitPerSubject');
    if (skipLimit != null) await setSkipLimitPerSubject(skipLimit);
    final skipLimitMajor = asInt('skipLimitPerMajorSubject');
    if (skipLimitMajor != null) {
      await setSkipLimitPerMajorSubject(skipLimitMajor);
    }
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
