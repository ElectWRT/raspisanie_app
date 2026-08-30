import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:raspisanie_app/core/error/failures.dart';
import 'package:raspisanie_app/core/notifications/notification_service.dart';
import 'package:raspisanie_app/core/notifications/reminder_scheduler.dart';
import 'package:raspisanie_app/core/settings/app_settings.dart';
import 'package:raspisanie_app/features/schedule/data/datasources/markdown_schedule_parser.dart';
import 'package:raspisanie_app/features/schedule/domain/entities/bell_schedule.dart';
import 'package:raspisanie_app/core/database/database.dart';
import 'package:raspisanie_app/core/utils/week_utils.dart';
import 'package:raspisanie_app/features/homework/domain/repositories/homework_repository.dart';
import 'package:raspisanie_app/features/schedule/domain/entities/schedule_slot.dart';
import 'package:raspisanie_app/features/schedule/domain/repositories/schedule_repository.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Подставной репозиторий: отдаёт заранее заданные пары и звонки.
class _FakeScheduleRepository implements ScheduleRepository {
  _FakeScheduleRepository({required this.bells, required this.slotsByWeekday});

  final List<BellSchedule> bells;
  final Map<int, List<ScheduleSlot>> slotsByWeekday;

  @override
  Future<List<BellSchedule>> getBellSchedules() async => bells;

  @override
  Future<List<String>> subjects(String groupName) async =>
      slotsByWeekday.values
          .expand((slots) => slots.map((s) => s.subject))
          .toSet()
          .toList();

  @override
  Stream<DaySchedule> watchDay({
    required String groupName,
    required DateTime date,
    String? subgroup,
    bool invertWeekParity = false,
  }) async* {
    yield DaySchedule(
      date: date,
      groupName: groupName,
      weekType: WeekType.every,
      slots: slotsByWeekday[date.weekday] ?? const [],
    );
  }

  @override
  Stream<List<String>> watchGroups() => Stream.value(const ['СА-2124']);

  @override
  Stream<Set<int>> watchSubstitutionWeekdays({
    required String groupName,
    required DateTime weekStart,
  }) =>
      Stream.value(const {});

  @override
  Future<bool> get hasSchedule async => true;

  @override
  Either<Failure, ScheduleImportResult> preview(String markdown) =>
      throw UnimplementedError();

  @override
  Future<Either<Failure, Unit>> commitImport(ScheduleImportResult result) =>
      throw UnimplementedError();

  @override
  Future<void> saveBellSchedules(List<BellSchedule> schedules) async {}

  @override
  Future<void> clearSchedule() async {}
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late AppSettings settings;

  const bells = [
    BellSchedule(
      name: 'Будни',
      days: {1, 2, 3, 4, 5},
      times: [
        BellTime(pairNumber: 1, start: '08:30', end: '10:00'),
        BellTime(pairNumber: 2, start: '10:10', end: '11:40'),
      ],
    ),
    BellSchedule(
      name: 'Суббота',
      days: {6},
      times: [BellTime(pairNumber: 1, start: '09:00', end: '10:00')],
    ),
  ];

  ReminderScheduler build({
    required Map<int, List<ScheduleSlot>> slots,
    List<BellSchedule> schedules = bells,
    List<Homework> homeworks = const [],
  }) {
    return ReminderScheduler(
      repository:
          _FakeScheduleRepository(bells: schedules, slotsByWeekday: slots),
      homework: _FakeHomeworkRepository(homeworks),
      settings: settings,
      notifications: NotificationService.create(),
    );
  }

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    settings = await AppSettings.load();
    await settings.setSelectedGroup('СА-2124');
    await settings.setNotificationsEnabled(true);
  });

  test('строит напоминания на все пары ближайших дней', () async {
    final scheduler = build(slots: {
      for (var day = 1; day <= 7; day++)
        day: const [
          ScheduleSlot(pairNumber: 1, subject: 'Сети'),
          ScheduleSlot(pairNumber: 2, subject: 'ОС'),
        ],
    });

    final reminders = await scheduler.buildReminders('СА-2124');

    expect(reminders, isNotEmpty);
    // Все напоминания в будущем и отсортированы по времени.
    final now = DateTime.now();
    expect(reminders.every((r) => r.when.isAfter(now)), isTrue);
    for (var i = 1; i < reminders.length; i++) {
      expect(reminders[i].when.isBefore(reminders[i - 1].when), isFalse);
    }
  });

  test('в субботу берутся субботние звонки, второй пары там нет', () async {
    final scheduler = build(slots: {
      6: const [
        ScheduleSlot(pairNumber: 1, subject: 'Сети'),
        ScheduleSlot(pairNumber: 2, subject: 'ОС'),
      ],
    });

    final reminders = await scheduler.buildReminders('СА-2124');
    final saturday = reminders.where((r) => r.when.weekday == 6).toList();

    // В субботнем наборе описана только первая пара — вторая без звонка
    // и напоминания не получает.
    expect(saturday.every((r) => r.pairNumber == 1), isTrue);
    expect(saturday.every((r) => r.bellTime == '09:00'), isTrue);
  });

  test('снятые пары напоминаний не получают', () async {
    final scheduler = build(slots: {
      for (var day = 1; day <= 7; day++)
        day: const [
          ScheduleSlot(pairNumber: 1, subject: '', isCancelled: true),
          ScheduleSlot(pairNumber: 2, subject: 'ОС'),
        ],
    });

    final reminders = await scheduler.buildReminders('СА-2124');
    expect(reminders.every((r) => r.pairNumber == 2), isTrue);
  });

  test('без звонков напоминаний нет', () async {
    final scheduler = build(
      schedules: const [],
      slots: {
        for (var day = 1; day <= 7; day++)
          day: const [ScheduleSlot(pairNumber: 1, subject: 'Сети')],
      },
    );

    expect(await scheduler.buildReminders('СА-2124'), isEmpty);
  });

  test('напоминание встаёт ровно за выбранное число минут', () async {
    await settings.setReminderMinutes(10);

    final scheduler = build(slots: {
      for (var day = 1; day <= 7; day++)
        day: const [ScheduleSlot(pairNumber: 2, subject: 'ОС')],
    });

    final reminders = await scheduler.buildReminders('СА-2124');
    final weekday = reminders.firstWhere((r) => r.when.weekday <= 5);

    expect(weekday.minutesBefore, 10);
    expect(weekday.bellTime, '10:10');
    // 10:10 минус 10 минут.
    expect(weekday.when.hour, 10);
    expect(weekday.when.minute, 0);
  });

  group('текст уведомления', () {
    test('содержит время звонка и остаток', () {
      final reminder = LessonReminder(
        when: _anyTime,
        date: _anyTime,
        bellTime: '10:10',
        minutesBefore: 15,
        subject: 'Компьютерные сети',
        pairNumber: 2,
        room: '305',
        teacher: 'Иванов И.И.',
      );

      expect(reminder.title, 'Компьютерные сети');
      expect(reminder.body, contains('Звонок в 10:10'));
      expect(reminder.body, contains('через 15 минут'));
      expect(reminder.body, contains('ауд. 305'));
    });

    test('замена помечается в заголовке', () {
      final reminder = LessonReminder(
        when: _anyTime,
        date: _anyTime,
        bellTime: '08:30',
        minutesBefore: 1,
        subject: 'Физика',
        pairNumber: 1,
        isSubstitution: true,
      );

      expect(reminder.title, startsWith('Замена · '));
      expect(reminder.body, contains('через 1 минуту'));
    });

    test('склонение для 2, 5 и 21 минуты', () {
      String bodyFor(int minutes) => LessonReminder(
            when: _anyTime,
            date: _anyTime,
            bellTime: '08:30',
            minutesBefore: minutes,
            subject: 'Физика',
            pairNumber: 1,
          ).body;

      expect(bodyFor(2), contains('через 2 минуты'));
      expect(bodyFor(5), contains('через 5 минут'));
      expect(bodyFor(21), contains('через 21 минуту'));
    });
  });
  group('напоминания о домашке', () {
    Homework task({
      required DateTime due,
      HomeworkPriority priority = HomeworkPriority.required,
      bool isDone = false,
      String subject = 'Математика',
    }) {
      return Homework(
        id: due.millisecondsSinceEpoch % 100000,
        groupName: 'СА-2124',
        subject: subject,
        description: 'Задачи 1-5',
        dueDate: due,
        priority: priority,
        isDone: isDone,
        createdAt: DateTime.now(),
      );
    }

    test('напоминает за указанное число дней в заданный час', () async {
      await settings.setHomeworkDaysBefore(2);
      await settings.setHomeworkReminderHour(19);

      final due = WeekUtils.dayKey(DateTime.now().add(const Duration(days: 5)));
      final scheduler = build(slots: const {}, homeworks: [task(due: due)]);

      final reminders = await scheduler.buildHomeworkReminders('СА-2124');

      expect(reminders, hasLength(1));
      final when = reminders.single.when;
      expect(WeekUtils.dayKey(when), due.subtract(const Duration(days: 2)));
      expect(when.hour, 19);
      expect(reminders.single.daysLeft, 2);
    });

    test('о необязательном не напоминает', () async {
      final due = WeekUtils.dayKey(DateTime.now().add(const Duration(days: 5)));
      final scheduler = build(slots: const {}, homeworks: [
        task(due: due, priority: HomeworkPriority.optional),
      ]);

      expect(await scheduler.buildHomeworkReminders('СА-2124'), isEmpty);
    });

    test('о сделанном не напоминает', () async {
      final due = WeekUtils.dayKey(DateTime.now().add(const Duration(days: 5)));
      final scheduler = build(slots: const {}, homeworks: [
        task(due: due, isDone: true),
      ]);

      expect(await scheduler.buildHomeworkReminders('СА-2124'), isEmpty);
    });

    test('момент в прошлом не планируется', () async {
      final due = WeekUtils.dayKey(
        DateTime.now().subtract(const Duration(days: 3)),
      );
      final scheduler = build(slots: const {}, homeworks: [task(due: due)]);

      expect(await scheduler.buildHomeworkReminders('СА-2124'), isEmpty);
    });

    test('текст содержит предмет, срок и приоритет', () async {
      await settings.setHomeworkDaysBefore(1);
      final due = WeekUtils.dayKey(DateTime.now().add(const Duration(days: 4)));
      final scheduler = build(slots: const {}, homeworks: [task(due: due)]);

      final reminder =
          (await scheduler.buildHomeworkReminders('СА-2124')).single;

      expect(reminder.title, contains('Математика'));
      expect(reminder.body, contains('Обязательно'));
      expect(reminder.body, contains('сдавать завтра'));
      expect(reminder.body, contains('Задачи 1-5'));
    });
  });
}

final _anyTime = DateTime(2026, 9, 1, 10, 0);

/// Подставной репозиторий домашки: отдаёт заранее заданный список.
class _FakeHomeworkRepository implements HomeworkRepository {
  _FakeHomeworkRepository(this.items);

  final List<Homework> items;

  @override
  Future<List<Homework>> pending(String groupName) async =>
      items.where((h) => !h.isDone).toList();

  @override
  Stream<List<Homework>> watch({
    required String groupName,
    bool includeDone = false,
  }) =>
      Stream.value(items);

  @override
  Stream<Map<String, int>> watchCountsBySubject(String groupName) =>
      Stream.value(const {});

  @override
  Future<void> add({
    required String groupName,
    required String subject,
    required String description,
    required DateTime dueDate,
    required HomeworkPriority priority,
  }) async {}

  @override
  Future<void> save(Homework item) async {}

  @override
  Future<void> setDone(int id, bool done) async {}

  @override
  Future<void> remove(int id) async {}

  @override
  Future<void> purgeOld() async {}
}
