import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:archive/archive.dart';
import 'package:drift/drift.dart' show Value;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:raspisanie_app/core/backup/backup_service.dart';
import 'package:raspisanie_app/core/database/database.dart';
import 'package:raspisanie_app/core/settings/app_settings.dart';
import 'package:raspisanie_app/core/utils/week_utils.dart';
import 'package:raspisanie_app/features/schedule/data/datasources/markdown_schedule_parser.dart';
import 'package:raspisanie_app/features/schedule/data/repositories/schedule_repository_impl.dart';
import 'package:raspisanie_app/features/substitutions/data/datasources/docx_parser.dart';
import 'package:raspisanie_app/features/substitutions/data/datasources/substitutions_remote_data_source.dart';
import 'package:raspisanie_app/features/substitutions/data/repositories/substitutions_repository_impl.dart';
import 'package:shared_preferences/shared_preferences.dart';

const _months = [
  'января', 'февраля', 'марта', 'апреля', 'мая', 'июня',
  'июля', 'августа', 'сентября', 'октября', 'ноября', 'декабря',
];

/// Документ замен на [date] с заданными строками таблицы.
Uint8List _docx(DateTime date, List<List<String>> rows) {
  String cell(String t) => '<w:tc><w:p><w:r><w:t>$t</w:t></w:r></w:p></w:tc>';
  String row(List<String> cells) => '<w:tr>${cells.map(cell).join()}</w:tr>';
  final xml = '<?xml version="1.0" encoding="UTF-8"?>'
      '<w:document xmlns:w="http://schemas.openxmlformats.org/wordprocessingml/2006/main">'
      '<w:body><w:p><w:r><w:t>Замены на ${date.day} ${_months[date.month - 1]} '
      '${date.year}</w:t></w:r></w:p><w:tbl>'
      '${row(['Группа', 'Пара', 'Предмет', 'Преподаватель', 'Аудитория'])}'
      '${rows.map(row).join()}</w:tbl></w:body></w:document>';
  final bytes = utf8.encode(xml);
  final archive = Archive()
    ..addFile(ArchiveFile('word/document.xml', bytes.length, bytes));
  return Uint8List.fromList(ZipEncoder().encode(archive)!);
}

class _Site implements SubstitutionsRemoteDataSource {
  _Site(this.documents, this.links);

  final Map<String, Uint8List> documents;
  List<SourceLink> links;

  @override
  Future<List<SourceLink>> findLinks(String pageUrl) async => links;

  @override
  Future<Uint8List> download(String url) async => documents[url]!;
}

void main() {
  late AppDatabase database;
  late AppSettings settings;

  final today = WeekUtils.dayKey(DateTime.now());
  final tomorrow = today.add(const Duration(days: 1));

  setUp(() async {
    database = AppDatabase.forTesting(NativeDatabase.memory());
    SharedPreferences.setMockInitialValues({});
    settings = await AppSettings.load();
    await settings.setSelectedGroup('СА-2124');
  });

  tearDown(() => database.close());

  SubstitutionsRepositoryImpl repositoryFor(_Site site) =>
      SubstitutionsRepositoryImpl(
        remoteDataSource: site,
        parser: const DocxParser(),
        database: database,
        settings: settings,
      );

  /// Два корпуса за сегодня: совмещённая с нами группа — в первом.
  _Site twoBuildings() => _Site(
        {
          'k1': _docx(today, [['СА-2125', '2', 'Сети', 'Иванов И.И.', '301']]),
          'k2': _docx(today, [['ТМ-2201', '1', 'Физика', 'Сидоров С.С.', '105']]),
        },
        [
          SourceLink(url: 'k1', title: 'Корпус № 1', date: today, building: 1),
          SourceLink(url: 'k2', title: 'Корпус № 2', date: today, building: 2),
        ],
      );

  Future<Set<String>> groupsToday() async =>
      {for (final r in await database.getSubstitutionsOnDate(today)) r.groupName};

  group('документы разных корпусов за один день', () {
    test('не затирают друг друга', () async {
      await repositoryFor(twoBuildings()).refresh(targetDate: today);
      expect(await groupsToday(), {'СА-2125', 'ТМ-2201'});
    });

    test('совмещёнка держится на всех путях обновления', () async {
      // Ровно тот баг: «Обновить» на завтрашнем дне и перезапуск брали
      // документ второго корпуса и стирали первый — совмещёнка пропадала.
      await database.replaceLessons([
        LessonsCompanion.insert(
          groupName: 'СА-2124',
          dayOfWeek: today.weekday,
          pairNumber: 2,
          subject: 'Сети',
          teacher: const Value('Иванов И.И.'),
        ),
      ]);
      final substitutions = repositoryFor(twoBuildings());
      final schedule = ScheduleRepositoryImpl(
        database: database,
        parser: const MarkdownScheduleParser(),
      );
      Future<List<String>> joint() async => (await schedule
              .watchDay(groupName: 'СА-2124', date: today)
              .first)
          .slots
          .single
          .jointGroups;

      final paths = <String, Future<void> Function()>{
        '«Обновить» на сегодня': () => substitutions.refresh(targetDate: today),
        '«Обновить» на завтра': () => substitutions.refresh(targetDate: tomorrow),
        'обновление при запуске': () => substitutions.refresh(),
        'фоновая проверка': () => substitutions.refreshUpcoming(),
      };
      for (final entry in paths.entries) {
        await entry.value();
        expect(await joint(), ['СА-2125'], reason: 'после: ${entry.key}');
      }
    });

    test('исправленный документ корпуса заменяет только свой корпус', () async {
      final site = twoBuildings();
      final repository = repositoryFor(site);
      await repository.refresh();

      // Завуч перезалил документ первого корпуса под другим именем:
      // замену у СА-2125 убрали, добавили СА-2126.
      site.documents['k1-v2'] =
          _docx(today, [['СА-2126', '3', 'ОС', 'Петров П.П.', '305']]);
      site.links = [
        SourceLink(url: 'k1-v2', title: 'Корпус № 1', date: today, building: 1),
        site.links.last,
      ];
      await repository.refresh();

      expect(await groupsToday(), {'СА-2126', 'ТМ-2201'},
          reason: 'старая строка первого корпуса ушла, второй корпус цел');
    });

    test('строки старой версии без источника заменяются', () async {
      await database.replaceSubstitutionsForDate(today, [
        SubstitutionsCompanion.insert(
          date: today,
          groupName: 'УСТАРЕВШАЯ',
          pairNumber: 1,
        ),
      ]);

      await repositoryFor(twoBuildings()).refresh();

      expect(await groupsToday(), {'СА-2125', 'ТМ-2201'});
    });

    test('«Обновить» на дне без документа не трогает другие дни', () async {
      final repository = repositoryFor(twoBuildings());
      await repository.refresh(targetDate: today);
      final before = await groupsToday();

      final report = (await repository.refresh(targetDate: tomorrow))
          .getOrElse(() => fail('ожидался успех'));

      expect(await groupsToday(), before);
      expect(await database.getSubstitutionsOnDate(tomorrow), isEmpty,
          reason: 'сегодняшний документ не должен лечь на завтра');
      expect(report.date, today,
          reason: 'отчёт честно говорит, какой день обновлён');
    });

    test('отчёт складывает корпуса одного дня', () async {
      final report = (await repositoryFor(twoBuildings()).refresh())
          .getOrElse(() => fail('ожидался успех'));

      expect(report.importedCount, 2);
      expect(report.source, 'Корпус № 1 + Корпус № 2');
    });
  });

  group('какие документы качать', () {
    final now = DateTime(2026, 9, 29, 10);
    final yesterday = DateTime(2026, 9, 28);
    final day = DateTime(2026, 9, 29);
    final next = DateTime(2026, 9, 30);

    List<String> urls(List<SourceLink> links) => [for (final l in links) l.url];

    test('всё с сегодняшнего дня, все корпуса', () {
      final links = [
        SourceLink(url: 'old', title: '', date: yesterday),
        SourceLink(url: 'k1', title: '', date: day, building: 1),
        SourceLink(url: 'k2', title: '', date: day, building: 2),
        SourceLink(url: 'next', title: '', date: next),
      ];
      expect(urls(linksToRefresh(links, now: now)), ['k1', 'k2', 'next']);
    });

    test('прошедший день берётся, только если его смотрят', () {
      final links = [
        SourceLink(url: 'old', title: '', date: yesterday),
        SourceLink(url: 'k1', title: '', date: day),
      ];
      expect(urls(linksToRefresh(links, now: now, targetDate: yesterday)),
          ['old', 'k1']);
    });

    test('будущих нет — все корпуса самой свежей даты', () {
      final links = [
        SourceLink(url: 'older', title: '', date: DateTime(2026, 9, 25)),
        SourceLink(url: 'a', title: '', date: yesterday, building: 1),
        SourceLink(url: 'b', title: '', date: yesterday, building: 2),
      ];
      expect(urls(linksToRefresh(links, now: now)), ['a', 'b']);
    });

    test('дат нет — первая ссылка на документ', () {
      final links = [
        const SourceLink(url: 'https://site/page', title: ''),
        const SourceLink(url: 'https://site/z.docx', title: ''),
      ];
      expect(urls(linksToRefresh(links, now: now)), ['https://site/z.docx']);
    });

    test('источник — корпус, а не адрес', () {
      expect(sourceKeyFor(const SourceLink(url: 'a', title: '', building: 1)),
          sourceKeyFor(const SourceLink(url: 'b', title: '', building: 1)));
      expect(sourceKeyFor(const SourceLink(url: 'a', title: '', building: 1)),
          isNot(sourceKeyFor(const SourceLink(url: 'a', title: '', building: 2))));
    });
  });

  test('резервная копия до версии 1.8 восстанавливается', () async {
    final service = BackupService(database: database, settings: settings);
    final backup = {
      'backupFormatVersion': 1,
      'lessons': [],
      'homeworks': [],
      'appMeta': [],
      // Строка в формате 1.7: колонки source ещё не было.
      'substitutions': [
        {
          'id': 1,
          'date': today.millisecondsSinceEpoch,
          'groupName': 'СА-2124',
          'pairNumber': 2,
          'subgroup': null,
          'subject': 'Сети',
          'teacher': 'Иванов И.И.',
          'room': '301',
          'isCancelled': false,
          'note': null,
        },
      ],
    };

    await service.restore(Uint8List.fromList(utf8.encode(jsonEncode(backup))));

    final rows = await database.getSubstitutionsOnDate(today);
    expect(rows.single.groupName, 'СА-2124');
    expect(rows.single.source, '');
  });

  test('база версии 3 обновляется до 4 без потери замен', () async {
    // Именно открытие базы когда-то вешало приложение на заставке, поэтому
    // проверяем настоящий файл, пережитый миграцией, а не пустую базу.
    final dir = await Directory.systemTemp.createTemp('raspisanie_migration');
    addTearDown(() => dir.delete(recursive: true));
    final file = File('${dir.path}/db.sqlite');

    final v4 = AppDatabase.forTesting(NativeDatabase(file));
    await v4.replaceSubstitutionsForDate(today, [
      SubstitutionsCompanion.insert(
        date: today,
        groupName: 'СА-2124',
        pairNumber: 2,
      ),
    ]);
    // Откатываем файл к версии 3: убираем колонку и номер схемы.
    await v4.customStatement('ALTER TABLE substitutions DROP COLUMN source');
    await v4.customStatement('PRAGMA user_version = 3');
    await v4.close();

    final upgraded = AppDatabase.forTesting(NativeDatabase(file));
    final rows = await upgraded.getSubstitutionsOnDate(today);
    await upgraded.close();

    expect(rows.single.groupName, 'СА-2124');
    expect(rows.single.source, '');
  });
}
