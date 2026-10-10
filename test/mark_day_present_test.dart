import 'package:drift/drift.dart' show Value;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:raspisanie_app/core/database/database.dart';
import 'package:raspisanie_app/core/notifications/notification_service.dart';
import 'package:raspisanie_app/core/settings/app_settings.dart';
import 'package:raspisanie_app/core/utils/week_utils.dart';
import 'package:raspisanie_app/features/attendance/data/mark_day_present.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  late AppDatabase database;
  late AppSettings settings;

  final date = WeekUtils.dayKey(DateTime(2026, 10, 1));

  setUp(() async {
    database = AppDatabase.forTesting(NativeDatabase.memory());
    SharedPreferences.setMockInitialValues({});
    settings = await AppSettings.load();
    await settings.setSelectedGroup('СА-2124');

    await database.replaceLessons([
      for (var pair = 1; pair <= 3; pair++)
        LessonsCompanion.insert(
          groupName: 'СА-2124',
          dayOfWeek: date.weekday,
          pairNumber: pair,
          subject: 'Предмет $pair',
          teacher: const Value('Иванов И.И.'),
        ),
    ]);
  });

  tearDown(() => database.close());

  Future<List<Attendance>> marks() async {
    final rows = await database.getAttendance('СА-2124');
    return rows..sort((a, b) => a.pairNumber.compareTo(b.pairNumber));
  }

  test('кнопка в шторке отмечает все пары дня', () async {
    final count = await markDayPresent(
      database: database,
      settings: settings,
      date: date,
    );

    expect(count, 3);
    expect(await marks(), hasLength(3));
    expect((await marks()).every((m) => m.status == AttendanceStatus.present),
        isTrue);
    expect((await marks()).first.subject, 'Предмет 1');
  });

  test('уже проставленную отметку не затирает', () async {
    // Человек отметил пропуск сам — кнопка «был на всех» не должна его стереть.
    await database.setAttendance(
      date: date,
      groupName: 'СА-2124',
      pairNumber: 2,
      subject: 'Предмет 2',
      status: AttendanceStatus.absent,
    );

    final count = await markDayPresent(
      database: database,
      settings: settings,
      date: date,
    );

    expect(count, 2, reason: 'отмечены только две оставшиеся пары');
    final second = (await marks()).firstWhere((m) => m.pairNumber == 2);
    expect(second.status, AttendanceStatus.absent);
  });

  test('снятые заменой пары не отмечает', () async {
    await database.replaceSubstitutionsForDate(date, [
      SubstitutionsCompanion.insert(
        date: date,
        groupName: 'СА-2124',
        pairNumber: 1,
        isCancelled: const Value(true),
      ),
    ]);

    final count = await markDayPresent(
      database: database,
      settings: settings,
      date: date,
    );

    expect(count, 2);
    expect((await marks()).map((m) => m.pairNumber), [2, 3]);
  });

  test('предмет берётся с учётом замены', () async {
    await database.replaceSubstitutionsForDate(date, [
      SubstitutionsCompanion.insert(
        date: date,
        groupName: 'СА-2124',
        pairNumber: 2,
        subject: const Value('Физика'),
      ),
    ]);

    await markDayPresent(database: database, settings: settings, date: date);

    final second = (await marks()).firstWhere((m) => m.pairNumber == 2);
    expect(second.subject, 'Физика');
  });

  test('повторное нажатие ничего не меняет', () async {
    await markDayPresent(database: database, settings: settings, date: date);
    final again = await markDayPresent(
      database: database,
      settings: settings,
      date: date,
    );

    expect(again, 0);
    expect(await marks(), hasLength(3));
  });

  test('без выбранной группы ничего не делает', () async {
    await settings.setSelectedGroup(null);

    expect(
      await markDayPresent(database: database, settings: settings, date: date),
      0,
    );
    expect(await marks(), isEmpty);
  });

  group('payload уведомления', () {
    test('дата разбирается обратно', () {
      final payload = NotificationPayload.forAttendance(date);

      expect(payload, 'attendance:2026-10-01');
      expect(NotificationPayload.dateOf(payload), date);
    });

    test('мусор не разбирается', () {
      expect(NotificationPayload.dateOf(null), isNull);
      expect(NotificationPayload.dateOf('attendance'), isNull);
      expect(NotificationPayload.dateOf('homework:17'), isNull);
    });
  });
}
