import '../../features/schedule/domain/entities/bell_schedule.dart';
import '../../features/schedule/domain/repositories/schedule_repository.dart';
import '../settings/app_settings.dart';
import '../utils/week_utils.dart';
import 'notification_service.dart';

/// Собирает напоминания из расписания и передаёт их в [NotificationService].
///
/// Вызывается после любого изменения данных: импорта расписания, загрузки
/// замен, правки звонков и смены настроек уведомлений.
class ReminderScheduler {
  ReminderScheduler({
    required this.repository,
    required this.settings,
    required this.notifications,
  });

  final ScheduleRepository repository;
  final AppSettings settings;
  final NotificationService notifications;

  /// На сколько дней вперёд планируем. Больше недели смысла нет — данные
  /// всё равно поменяются, а список будильников не резиновый.
  static const _horizonDays = 7;

  /// Перепланирует напоминания. Возвращает, сколько уведомлений поставлено.
  Future<int> refresh() async {
    if (!settings.notificationsEnabled) {
      await notifications.cancelAll();
      return 0;
    }

    final group = settings.selectedGroup;
    if (group == null) {
      await notifications.cancelAll();
      return 0;
    }

    final reminders = await buildReminders(group);
    return notifications.reschedule(reminders, exact: settings.exactAlarms);
  }

  /// Собирает список напоминаний на ближайшие дни.
  /// Вынесено отдельно, чтобы можно было проверить логику тестом.
  Future<List<LessonReminder>> buildReminders(String group) async {
    final schedules = await repository.getBellSchedules();
    if (schedules.isEmpty) return const [];

    final minutesBefore = settings.reminderMinutes;
    final now = DateTime.now();
    final today = WeekUtils.dayKey(now);
    final reminders = <LessonReminder>[];

    for (var offset = 0; offset < _horizonDays; offset++) {
      final date = today.add(Duration(days: offset));
      final bells = bellScheduleForWeekday(schedules, date.weekday);
      if (bells == null) continue;

      final day = await repository
          .watchDay(
            groupName: group,
            date: date,
            subgroup: settings.subgroup,
            invertWeekParity: settings.invertWeekParity,
          )
          .first;

      for (final slot in day.slots) {
        if (slot.isCancelled) continue;

        final bell = bells.timeFor(slot.pairNumber);
        if (bell == null) continue;

        final start = _combine(date, bell.start);
        if (start == null) continue;

        final when = start.subtract(Duration(minutes: minutesBefore));
        if (!when.isAfter(now)) continue;

        reminders.add(LessonReminder(
          when: when,
          bellTime: bell.start,
          minutesBefore: minutesBefore,
          subject: slot.subject,
          pairNumber: slot.pairNumber,
          room: slot.room,
          teacher: slot.teacher,
          isSubstitution: slot.isSubstitution,
        ));
      }
    }

    reminders.sort((a, b) => a.when.compareTo(b.when));
    return reminders;
  }

  /// «08:30» + дата → DateTime. null, если время записано криво.
  static DateTime? _combine(DateTime date, String hhmm) {
    final parts = hhmm.split(':');
    if (parts.length != 2) return null;
    final hour = int.tryParse(parts[0]);
    final minute = int.tryParse(parts[1]);
    if (hour == null || minute == null) return null;
    return DateTime(date.year, date.month, date.day, hour, minute);
  }
}
