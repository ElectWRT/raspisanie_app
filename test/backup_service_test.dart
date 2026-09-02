import 'dart:convert';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:raspisanie_app/core/backup/backup_service.dart';
import 'package:raspisanie_app/core/database/database.dart';
import 'package:raspisanie_app/core/settings/app_settings.dart';
import 'package:shared_preferences/shared_preferences.dart';

Uint8List _bytesOf(Map<String, dynamic> json) =>
    Uint8List.fromList(utf8.encode(jsonEncode(json)));

void main() {
  late AppDatabase database;
  late AppSettings settings;
  late BackupService service;

  setUp(() async {
    database = AppDatabase.forTesting(NativeDatabase.memory());
    SharedPreferences.setMockInitialValues({});
    settings = await AppSettings.load();
    service = BackupService(database: database, settings: settings);
  });

  tearDown(() => database.close());

  Future<void> seed() async {
    await database.replaceLessons([
      LessonsCompanion.insert(
        groupName: 'СА-2124',
        dayOfWeek: 1,
        pairNumber: 1,
        subject: 'Сети',
        teacher: const Value('Иванов И.И.'),
        room: const Value('301'),
      ),
    ]);
    await database.replaceSubstitutionsForDate(
      DateTime(2026, 9, 1),
      [
        SubstitutionsCompanion.insert(
          date: DateTime(2026, 9, 1),
          groupName: 'СА-2124',
          pairNumber: 1,
          subject: const Value('Замена'),
        ),
      ],
    );
    await database.insertHomework(HomeworksCompanion.insert(
      groupName: 'СА-2124',
      subject: 'Сети',
      description: 'Параграф 3',
      dueDate: DateTime(2026, 9, 5),
    ));
    await database.setMeta('bell_schedules', '[{"name":"Основные"}]');

    await settings.setInvertWeekParity(true);
    await settings.setAccentId('teal');
    await settings.setHomeworkDaysBefore(2);
    await settings.setReminderMinutes(30);
  }

  test('restore заменяет данные содержимым файла (без saveFile)', () async {
    await seed();

    final tables = await database.exportAllTables();
    final payload = {
      'backupFormatVersion': 1,
      'appVersion': '1.2.0',
      'createdAt': '2026-08-20T10:00:00.000',
      'settings': settings.exportForBackup(),
      ...tables,
    };
    final bytes = _bytesOf(payload);

    final preview = service.inspect(bytes);
    expect(preview.summary.lessons, 1);
    expect(preview.summary.substitutions, 1);
    expect(preview.summary.homeworks, 1);
    expect(preview.appVersion, '1.2.0');
    expect(preview.createdAt, DateTime(2026, 8, 20, 10, 0));

    await database.clearLessons();
    await database.clearSubstitutions();
    await settings.setInvertWeekParity(false);
    await settings.setAccentId('blue');

    await service.restore(bytes);

    expect(await database.getGroupNames(), ['СА-2124']);

    final subs = await database.getSubstitutionsOnDate(DateTime(2026, 9, 1));
    expect(subs, hasLength(1));
    expect(subs.single.subject, 'Замена');

    final homeworks = await database.getPendingHomeworks('СА-2124');
    expect(homeworks, hasLength(1));

    expect(settings.invertWeekParity, isTrue);
    expect(settings.accentId, 'teal');
    expect(settings.homeworkDaysBefore, 2);
    expect(settings.reminderMinutes, 30);

    expect(await database.getMeta('bell_schedules'), '[{"name":"Основные"}]');
  });

  test('отметки посещения и профили предметов переживают экспорт и импорт',
      () async {
    await database.setAttendance(
      date: DateTime(2026, 9, 15),
      groupName: 'СА-2124',
      pairNumber: 2,
      subject: 'Математика',
      status: AttendanceStatus.absent,
    );
    await database.upsertSubjectProfile(
      groupName: 'СА-2124',
      subject: 'Базы данных',
      isMajor: true,
      items: 'Ноутбук',
    );

    final exported = await database.exportAllTables();

    await database.clearAttendance(
      date: DateTime(2026, 9, 15),
      groupName: 'СА-2124',
      pairNumber: 2,
    );
    await database.importAllTables(exported);

    final rows = await database.getAttendance('СА-2124');
    final profiles = await database.getSubjectProfiles('СА-2124');

    expect(rows.single.status, AttendanceStatus.absent);
    expect(rows.single.subject, 'Математика');
    expect(profiles.single.isMajor, isTrue);
    expect(profiles.single.items, 'Ноутбук');
  });

  test('бэкап без учёта пропусков восстанавливается, таблицы просто пустые',
      () async {
    await database.setAttendance(
      date: DateTime(2026, 9, 15),
      groupName: 'СА-2124',
      pairNumber: 1,
      subject: 'Сети',
      status: AttendanceStatus.present,
    );

    // Копия, снятая до появления учёта пропусков: ключей нет вовсе.
    await service.restore(_bytesOf({
      'backupFormatVersion': 1,
      'lessons': [],
      'substitutions': [],
      'homeworks': [],
      'appMeta': [],
    }));

    expect(await database.getAttendance('СА-2124'), isEmpty);
  });

  test('старые бэкапы без новых настроек не ломают импорт', () async {
    await seed();

    final data = {
      'backupFormatVersion': 1,
      'lessons': [],
      'substitutions': [],
      'homeworks': [],
      'appMeta': [],
      // settings нет вовсе — как в бэкапе версии, где такой функции не было.
    };

    await service.restore(_bytesOf(data));

    expect(await database.getGroupNames(), isEmpty);
  });

  test('файл из будущей версии формата отклоняется с понятной ошибкой', () {
    final data = {'backupFormatVersion': 99, 'lessons': []};
    expect(
      () => service.inspect(_bytesOf(data)),
      throwsA(isA<BackupFormatException>()),
    );
  });

  test('битый JSON отклоняется с понятной ошибкой', () {
    final bytes = Uint8List.fromList(utf8.encode('не json совсем'));
    expect(
      () => service.inspect(bytes),
      throwsA(isA<BackupFormatException>()),
    );
  });

  test('пустые списки в файле не роняют восстановление', () async {
    final data = {
      'backupFormatVersion': 1,
      'lessons': [],
      'substitutions': [],
      'homeworks': [],
      'appMeta': [],
      'settings': <String, dynamic>{},
    };

    await service.restore(_bytesOf(data));
    expect(await database.getGroupNames(), isEmpty);
  });
}
