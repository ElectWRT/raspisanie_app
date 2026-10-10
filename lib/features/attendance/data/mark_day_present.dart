import '../../../core/database/database.dart';
import '../../../core/settings/app_settings.dart';
import '../../../core/utils/week_utils.dart';
import '../../schedule/data/datasources/markdown_schedule_parser.dart';
import '../../schedule/data/repositories/schedule_repository_impl.dart';

/// Отмечает все неотмеченные пары дня как посещённые.
///
/// Обычный день — «был на всех», поэтому его закрывают одной кнопкой прямо
/// из уведомления. Уже проставленные отметки не трогаем: если человек
/// отметил пропуск, кнопка не должна его затирать. Снятые заменой пары
/// пропускаем — отмечать нечего.
///
/// Возвращает, сколько пар отмечено.
Future<int> markDayPresent({
  required AppDatabase database,
  required AppSettings settings,
  required DateTime date,
}) async {
  final group = settings.selectedGroup;
  if (group == null) return 0;

  final day = WeekUtils.dayKey(date);
  final schedule = ScheduleRepositoryImpl(
    database: database,
    parser: const MarkdownScheduleParser(),
  );

  final slots = (await schedule
          .watchDay(
            groupName: group,
            date: day,
            subgroup: settings.subgroup,
            invertWeekParity: settings.invertWeekParity,
          )
          .first)
      .slots;

  final marked = await database.markedKeysForDay(groupName: group, date: day);
  var count = 0;

  for (final slot in slots) {
    if (slot.isCancelled) continue;
    if (marked.contains(attendanceKey(slot.pairNumber, slot.subgroup))) {
      continue;
    }
    await database.setAttendance(
      date: day,
      groupName: group,
      pairNumber: slot.pairNumber,
      subgroup: slot.subgroup,
      subject: slot.subject,
      status: AttendanceStatus.present,
    );
    count++;
  }

  return count;
}
