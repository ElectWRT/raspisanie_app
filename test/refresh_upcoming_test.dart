import 'dart:convert';
import 'dart:typed_data';

import 'package:archive/archive.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:raspisanie_app/core/background/background_refresh.dart';
import 'package:raspisanie_app/core/database/database.dart';
import 'package:raspisanie_app/core/settings/app_settings.dart';
import 'package:raspisanie_app/core/utils/week_utils.dart';
import 'package:raspisanie_app/features/substitutions/data/datasources/docx_parser.dart';
import 'package:raspisanie_app/features/substitutions/data/datasources/substitutions_remote_data_source.dart';
import 'package:raspisanie_app/features/substitutions/data/repositories/substitutions_repository_impl.dart';
import 'package:shared_preferences/shared_preferences.dart';

const _months = [
  'января', 'февраля', 'марта', 'апреля', 'мая', 'июня',
  'июля', 'августа', 'сентября', 'октября', 'ноября', 'декабря',
];

/// Документ замен с одной строкой для группы на дату [date].
Uint8List _docxFor(DateTime date, {String subject = 'Математика'}) {
  String cell(String t) => '<w:tc><w:p><w:r><w:t>$t</w:t></w:r></w:p></w:tc>';
  String row(List<String> cells) => '<w:tr>${cells.map(cell).join()}</w:tr>';

  final xml = '<?xml version="1.0" encoding="UTF-8"?>'
      '<w:document xmlns:w="http://schemas.openxmlformats.org/wordprocessingml/2006/main">'
      '<w:body>'
      '<w:p><w:r><w:t>Замены на ${date.day} ${_months[date.month - 1]} '
      '${date.year}</w:t></w:r></w:p>'
      '<w:tbl>'
      '${row(['Группа', 'Пара', 'Предмет', 'Преподаватель', 'Аудитория'])}'
      '${row(['СА-2124', '2', subject, 'Иванов И.И.', '301'])}'
      '</w:tbl></w:body></w:document>';

  final bytes = utf8.encode(xml);
  final archive = Archive()
    ..addFile(ArchiveFile('word/document.xml', bytes.length, bytes));
  return Uint8List.fromList(ZipEncoder().encode(archive)!);
}

/// Подставной сайт: отдаёт заданные ссылки и документы по адресу.
class _FakeSite implements SubstitutionsRemoteDataSource {
  _FakeSite(this.documents, {List<SourceLink>? links})
      : links = links ?? const [];

  final Map<String, Uint8List> documents;
  final List<SourceLink> links;
  final downloaded = <String>[];

  @override
  Future<List<SourceLink>> findLinks(String pageUrl) async => links;

  @override
  Future<Uint8List> download(String url) async {
    downloaded.add(url);
    return documents[url]!;
  }
}

void main() {
  late AppDatabase database;
  late AppSettings settings;

  final today = WeekUtils.dayKey(DateTime.now());
  final tomorrow = today.add(const Duration(days: 1));
  final yesterday = today.subtract(const Duration(days: 1));

  setUp(() async {
    database = AppDatabase.forTesting(NativeDatabase.memory());
    SharedPreferences.setMockInitialValues({});
    settings = await AppSettings.load();
    await settings.setSelectedGroup('СА-2124');
  });

  tearDown(() => database.close());

  SubstitutionsRepositoryImpl repositoryWith(_FakeSite site) =>
      SubstitutionsRepositoryImpl(
        remoteDataSource: site,
        parser: const DocxParser(),
        database: database,
        settings: settings,
      );

  group('refreshUpcoming', () {
    test('качает и сегодняшний, и завтрашний документ', () async {
      // Ровно тот случай, из-за которого не приходили уведомления: замены
      // на завтра уже выложены, а сегодняшний документ ещё висит.
      final site = _FakeSite(
        {'today.docx': _docxFor(today), 'tomorrow.docx': _docxFor(tomorrow)},
        links: [
          SourceLink(url: 'today.docx', title: 'Сегодня', date: today),
          SourceLink(url: 'tomorrow.docx', title: 'Завтра', date: tomorrow),
        ],
      );

      final outcome = await repositoryWith(site).refreshUpcoming();
      final reports = outcome.getOrElse(() => fail('ожидался успех'));

      expect(reports.map((r) => r.date), [today, tomorrow]);
      expect(await database.getSubstitutionsOnDate(tomorrow), hasLength(1));
    });

    test('прошлые документы не качает', () async {
      final site = _FakeSite(
        {'old.docx': _docxFor(yesterday), 'today.docx': _docxFor(today)},
        links: [
          SourceLink(url: 'old.docx', title: 'Вчера', date: yesterday),
          SourceLink(url: 'today.docx', title: 'Сегодня', date: today),
        ],
      );

      await repositoryWith(site).refreshUpcoming();

      expect(site.downloaded, ['today.docx']);
    });

    test('чужой корпус пропускается', () async {
      await settings.setPreferredBuilding(1);
      final site = _FakeSite(
        {'k1.docx': _docxFor(tomorrow), 'k2.docx': _docxFor(tomorrow)},
        links: [
          SourceLink(url: 'k1.docx', title: 'Корпус 1', date: tomorrow, building: 1),
          SourceLink(url: 'k2.docx', title: 'Корпус 2', date: tomorrow, building: 2),
        ],
      );

      await repositoryWith(site).refreshUpcoming();

      expect(site.downloaded, ['k1.docx']);
    });

    test('слепок пишется отдельно на каждую дату', () async {
      final site = _FakeSite(
        {'today.docx': _docxFor(today), 'tomorrow.docx': _docxFor(tomorrow)},
        links: [
          SourceLink(url: 'today.docx', title: '', date: today),
          SourceLink(url: 'tomorrow.docx', title: '', date: tomorrow),
        ],
      );

      await repositoryWith(site).refreshUpcoming();

      final todaySignature = await database.getMeta(notifiedSignatureKey(today));
      final tomorrowSignature =
          await database.getMeta(notifiedSignatureKey(tomorrow));

      expect(todaySignature, isNotNull);
      expect(tomorrowSignature, isNotNull);
      expect(todaySignature, isNot(tomorrowSignature),
          reason: 'с одним общим ключом документы затирали бы слепки '
              'друг друга, и уведомление приходило бы при каждой проверке');
    });

    test('без дат в ссылках ведёт себя как обычное обновление', () async {
      final site = _FakeSite(
        {'a.docx': _docxFor(today)},
        links: const [SourceLink(url: 'a.docx', title: 'Замены')],
      );

      final outcome = await repositoryWith(site).refreshUpcoming();

      expect(outcome.isRight(), isTrue);
      expect(site.downloaded, ['a.docx']);
    });

    test('повторная загрузка того же документа слепок не меняет', () async {
      final site = _FakeSite(
        {'tomorrow.docx': _docxFor(tomorrow)},
        links: [SourceLink(url: 'tomorrow.docx', title: '', date: tomorrow)],
      );
      final repository = repositoryWith(site);

      await repository.refreshUpcoming();
      final first = await database.getMeta(notifiedSignatureKey(tomorrow));
      await repository.refreshUpcoming();
      final second = await database.getMeta(notifiedSignatureKey(tomorrow));

      expect(second, first, reason: 'иначе уведомление приходило бы '
          'после каждой проверки, а не только при новых заменах');
    });
  });

  group('заголовок уведомления', () {
    test('сегодня, завтра и дальше', () {
      expect(substitutionAlertTitle(date: today, today: today),
          'Замены на сегодня');
      expect(substitutionAlertTitle(date: tomorrow, today: today),
          'Замены на завтра');
      expect(
        substitutionAlertTitle(
          date: today.add(const Duration(days: 3)),
          today: today,
        ),
        'Новые замены',
      );
    });

    test('daysBetween не зависит от времени суток', () {
      expect(daysBetween(DateTime(2026, 9, 22, 23, 50), DateTime(2026, 9, 23)), 1);
      expect(daysBetween(DateTime(2026, 9, 22), DateTime(2026, 9, 22, 18)), 0);
    });
  });
}
