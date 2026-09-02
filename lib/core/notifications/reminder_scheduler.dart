import '../../features/attendance/domain/repositories/attendance_repository.dart';
import '../../features/homework/domain/homework_priority_ui.dart';
import '../../features/homework/domain/repositories/homework_repository.dart';
import '../../features/schedule/domain/entities/bell_schedule.dart';
import '../../features/schedule/domain/repositories/schedule_repository.dart';
import '../database/database.dart';
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
    required this.homework,
    required this.attendance,
    required this.settings,
    required this.notifications,
  });

  final ScheduleRepository repository;
  final HomeworkRepository homework;
  final AttendanceRepository attendance;
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

    final reminders = <PendingReminder>[
      ...await buildReminders(group),
      if (settings.homeworkReminders) ...await buildHomeworkReminders(group),
      if (settings.attendanceRemindersEnabled)
        ...await buildAttendanceReminders(group),
    ]..sort((a, b) => a.when.compareTo(b.when));

    return notifications.reschedule(reminders, exact: settings.exactAlarms);
  }

  /// Через сколько минут после последней пары напомнить об отметках.
  /// Сразу по звонку рано: студент ещё собирается и выходит.
  static const _attendanceDelayMinutes = 20;

  /// Напоминания «отметьте пропуски» — по одному на день, после последней
  /// пары и только если в этом дне что-то ещё не отмечено.
  ///
  /// Планируем и на сегодня, и на будущие дни: на будущие отметок нет
  /// по определению, а к вечеру они появятся — уведомление тогда просто
  /// окажется лишним, и это дешевле, чем не напомнить вовсе.
  Future<List<AttendanceReminder>> buildAttendanceReminders(
    String group,
  ) async {
    final schedules = await repository.getBellSchedules();
    if (schedules.isEmpty) return const [];

    final now = DateTime.now();
    final today = WeekUtils.dayKey(now);
    final reminders = <AttendanceReminder>[];

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

      // Снятые пары отмечать нечего.
      final slots = day.slots.where((s) => !s.isCancelled).toList();
      if (slots.isEmpty) continue;

      final marked = await attendance.markedKeys(
        groupName: group,
        date: date,
      );
      final unmarked = slots
          .where((s) => !marked.contains(attendanceKey(s.pairNumber, s.subgroup)))
          .length;
      if (unmarked == 0) continue;

      final lastPair = slots.map((s) => s.pairNumber).reduce((a, b) => a > b ? a : b);
      final bell = bells.timeFor(lastPair);
      if (bell == null) continue;

      final end = _combine(date, bell.end);
      if (end == null) continue;

      final when = end.add(const Duration(minutes: _attendanceDelayMinutes));
      if (!when.isAfter(now)) continue;

      reminders.add(AttendanceReminder(
        when: when,
        date: date,
        unmarked: unmarked,
      ));
    }

    return reminders;
  }

  /// Собирает напоминания о домашке: одно на задание, за
  /// [AppSettings.homeworkDaysBefore] дней до срока.
  ///
  /// О заданиях с приоритетом «не критично» не напоминаем — иначе шторка
  /// превращается в шум, и важное в ней теряется.
  Future<List<HomeworkReminder>> buildHomeworkReminders(String group) async {
    final tasks = await homework.pending(group);
    if (tasks.isEmpty) return const [];

    final now = DateTime.now();
    final daysBefore = settings.homeworkDaysBefore;
    final hour = settings.homeworkReminderHour;
    final reminders = <HomeworkReminder>[];

    for (final task in tasks) {
      if (!task.priority.deservesReminder) continue;

      final due = WeekUtils.dayKey(task.dueDate);
      final remindDay = due.subtract(Duration(days: daysBefore));
      final when = DateTime(
        remindDay.year,
        remindDay.month,
        remindDay.day,
        hour,
      );

      if (!when.isAfter(now)) continue;

      reminders.add(HomeworkReminder(
        when: when,
        homeworkId: task.id,
        subject: task.subject,
        description: task.description,
        daysLeft: due.difference(WeekUtils.dayKey(when)).inDays,
        priorityLabel: task.priority.label,
      ));
    }

    return reminders;
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
          date: date,
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
