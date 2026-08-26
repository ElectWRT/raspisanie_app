import 'dart:io';

import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:timezone/data/latest_all.dart' as tz_data;
import 'package:timezone/timezone.dart' as tz;

/// Одно запланированное напоминание о паре.
class LessonReminder {
  /// Момент, когда показать уведомление.
  final DateTime when;

  /// Время звонка, «10:10».
  final String bellTime;

  /// За сколько минут до звонка.
  final int minutesBefore;

  final String subject;
  final String room;
  final String teacher;
  final int pairNumber;

  /// Пара пришла из документа замен — помечаем в тексте.
  final bool isSubstitution;

  const LessonReminder({
    required this.when,
    required this.bellTime,
    required this.minutesBefore,
    required this.subject,
    required this.pairNumber,
    this.room = '',
    this.teacher = '',
    this.isSubstitution = false,
  });

  String get title {
    final prefix = isSubstitution ? 'Замена · ' : '';
    return '$prefix$subject';
  }

  String get body {
    final parts = <String>[
      'Звонок в $bellTime — через $minutesBefore ${_minutesWord(minutesBefore)}',
      if (room.isNotEmpty) 'ауд. $room',
      if (teacher.isNotEmpty) teacher,
    ];
    return parts.join(' · ');
  }

  static String _minutesWord(int minutes) {
    final mod10 = minutes % 10;
    final mod100 = minutes % 100;
    if (mod10 == 1 && mod100 != 11) return 'минуту';
    if (mod10 >= 2 && mod10 <= 4 && (mod100 < 12 || mod100 > 14)) {
      return 'минуты';
    }
    return 'минут';
  }
}

/// Локальные уведомления о начале пар. Никакого сервера — всё планируется
/// на устройстве и переживает перезагрузку.
class NotificationService {
  NotificationService(this._plugin);

  final FlutterLocalNotificationsPlugin _plugin;

  static const _channelId = 'lesson_reminders';
  static const _channelName = 'Напоминания о парах';
  static const _channelDescription =
      'Уведомление незадолго до звонка на пару';

  /// Запоминаем сам Future, а не флаг: параллельные вызовы init()
  /// должны ждать одну и ту же инициализацию, а не запускать вторую.
  Future<void>? _initFuture;

  static NotificationService create() =>
      NotificationService(FlutterLocalNotificationsPlugin());

  Future<void> init() => _initFuture ??= _doInit();

  Future<void> _doInit() async {
    tz_data.initializeTimeZones();

    // Плагин может не ответить (нет сервиса, урезанная прошивка).
    // Таймаут важнее точной зоны — иначе повиснет весь запуск.
    try {
      final info = await FlutterTimezone.getLocalTimezone()
          .timeout(const Duration(seconds: 5));
      tz.setLocalLocation(tz.getLocation(info.identifier));
    } catch (_) {
      // Оставляем UTC: напоминания сместятся, но приложение запустится.
    }

    try {
      await _plugin
          .initialize(
            settings: const InitializationSettings(
              android: AndroidInitializationSettings('@mipmap/ic_launcher'),
            ),
          )
          .timeout(const Duration(seconds: 5));
    } catch (_) {
      // Уведомления не заработают, но экран расписания должен открыться.
    }
  }

  /// Спрашивает разрешение на уведомления (Android 13+).
  /// Возвращает false, если пользователь отказал.
  Future<bool> requestPermission() async {
    if (!Platform.isAndroid) return true;
    final android = _plugin.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();
    return await android?.requestNotificationsPermission() ?? false;
  }

  /// Разрешение на точное время срабатывания (Android 12+).
  Future<bool> requestExactAlarmPermission() async {
    if (!Platform.isAndroid) return true;
    final android = _plugin.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();
    return await android?.requestExactAlarmsPermission() ?? false;
  }

  /// Перепланирует все напоминания: старые снимаются, новые ставятся.
  ///
  /// [exact] требует разрешения на точные будильники. Без него Android
  /// доставляет уведомление приблизительно — обычно с задержкой до
  /// нескольких минут.
  Future<int> reschedule(
    List<LessonReminder> reminders, {
    bool exact = false,
  }) async {
    await init();
    await cancelAll();

    final now = DateTime.now();
    var scheduled = 0;

    for (final reminder in reminders) {
      if (!reminder.when.isAfter(now)) continue;

      await _plugin.zonedSchedule(
        id: scheduled,
        title: reminder.title,
        body: reminder.body,
        scheduledDate: tz.TZDateTime.from(reminder.when, tz.local),
        notificationDetails: const NotificationDetails(
          android: AndroidNotificationDetails(
            _channelId,
            _channelName,
            channelDescription: _channelDescription,
            importance: Importance.high,
            priority: Priority.high,
            category: AndroidNotificationCategory.reminder,
          ),
        ),
        androidScheduleMode: exact
            ? AndroidScheduleMode.exactAllowWhileIdle
            : AndroidScheduleMode.inexactAllowWhileIdle,
      );
      scheduled++;
    }

    return scheduled;
  }

  Future<void> cancelAll() => _plugin.cancelAll();

  Future<List<PendingNotificationRequest>> pending() =>
      _plugin.pendingNotificationRequests();
}
