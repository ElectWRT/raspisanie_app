import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:raspisanie_app/core/database/database.dart';
import 'package:raspisanie_app/features/schedule/data/datasources/markdown_schedule_parser.dart';
import 'package:raspisanie_app/features/schedule/data/repositories/schedule_repository_impl.dart';

/// Проверяет ровно тот путь, который выполняется при запуске приложения.
/// Если поток групп не отдаёт первое значение на пустой базе — на телефоне
/// это выглядит как вечная крутилка.
void main() {
  late AppDatabase database;
  late ScheduleRepositoryImpl repository;

  setUp(() {
    database = AppDatabase.forTesting(NativeDatabase.memory());
    repository = ScheduleRepositoryImpl(
      database: database,
      parser: const MarkdownScheduleParser(),
    );
  });

  tearDown(() => database.close());

  test('на пустой базе поток групп сразу отдаёт пустой список', () async {
    final groups = await repository.watchGroups().first.timeout(
          const Duration(seconds: 5),
          onTimeout: () => throw StateError('поток групп не отдал значение'),
        );

    expect(groups, isEmpty);
  });

  test('на пустой базе звонки читаются без ошибки', () async {
    final schedules = await repository.getBellSchedules().timeout(
          const Duration(seconds: 5),
        );

    expect(schedules, isEmpty);
  });

  test('поток дня отдаёт значение, даже когда пар нет', () async {
    final day = await repository
        .watchDay(groupName: 'СА-2124', date: DateTime(2026, 9, 1))
        .first
        .timeout(
          const Duration(seconds: 5),
          onTimeout: () => throw StateError('поток дня не отдал значение'),
        );

    expect(day.slots, isEmpty);
    expect(day.groupName, 'СА-2124');
  });

  test('поток дней с заменами отдаёт значение на пустой базе', () async {
    final days = await repository
        .watchSubstitutionWeekdays(
          groupName: 'СА-2124',
          weekStart: DateTime(2026, 8, 31),
        )
        .first
        .timeout(
          const Duration(seconds: 5),
          onTimeout: () => throw StateError('поток недели не отдал значение'),
        );

    expect(days, isEmpty);
  });
}
