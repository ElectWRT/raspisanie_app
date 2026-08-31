import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:raspisanie_app/features/substitutions/data/datasources/substitutions_remote_data_source.dart';

/// Разметка взята с реальной страницы khamk.ru — именно на ней прежняя
/// версия ничего не находила: ссылка обёрнута в собственный <span>,
/// внутри которого кроме неё ничего нет, а подпись «Замены учебных
/// занятий» стоит уровнем выше.
const _realPageFragment = '''
<html><body>
<div>
<ul>
<li><span style="font-size: medium;">Замены учебных занятий&nbsp;(<span><a
  style="text-decoration: none;"
  href="https://www.khamk.ru/file_download/3572/replacements_020926_1_frame.docx"
  >Корпус № 1</a></span>)</span></li>
<li>
<p><span style="font-size: medium;">Замены учебных занятий<span>&nbsp;</span>(<span><a
  href="https://www.khamk.ru/file_download/3573/replacements_020926_2_frame.docx"
  >Корпус № 2</a></span>)</span></p>
</li>
</ul>
</div>
<hr />
<ul>
<li>
<p><span style="font-size: medium;">Расписание занятий 1 курс (<span><a
  href="https://www.khamk.ru/file_download/3567/1_semester_2026-2027_1_frame.xls"
  >Корпус № 1</a></span>)</span></p>
</li>
</ul>
</body></html>
''';

void main() {
  group('поиск ссылок на реальной странице khamk.ru', () {
    late SubstitutionsRemoteDataSourceImpl source;

    setUp(() {
      final dio = Dio();
      dio.httpClientAdapter = _FakeAdapter(_realPageFragment);
      source = SubstitutionsRemoteDataSourceImpl(dio);
    });

    test('находит обе ссылки на замены', () async {
      final links = await source.findLinks('https://www.khamk.ru/page');

      expect(links, hasLength(2));
      expect(links.every((l) => l.url.contains('replacements_')), isTrue);
    });

    test('расписание в .xls не принимается за замены', () async {
      final links = await source.findLinks('https://www.khamk.ru/page');

      expect(
        links.any((l) => l.url.contains('1_semester')),
        isFalse,
        reason: 'у него та же подпись «Корпус № 1», но это не замены',
      );
    });

    test('корпус распознаётся у каждой ссылки', () async {
      final links = await source.findLinks('https://www.khamk.ru/page');

      expect(links.map((l) => l.building).toList(), [1, 2]);
    });

    test('дата берётся из имени файла, её нет в тексте', () async {
      final links = await source.findLinks('https://www.khamk.ru/page');

      for (final link in links) {
        expect(link.date, DateTime(2026, 9, 2));
      }
    });
  });

  group('дата из имени файла', () {
    test('ддММгг разбирается верно', () {
      expect(
        SubstitutionsRemoteDataSourceImpl.parseDateFromUrl(
          'https://www.khamk.ru/file_download/3572/replacements_020926_1_frame.docx',
        ),
        DateTime(2026, 9, 2),
      );
    });

    test('год из имени файла расписания не принимается за дату', () {
      // 2026-2027 — это учебный год, а не 20.26.20; шестизначной группы
      // цифр подряд здесь нет.
      expect(
        SubstitutionsRemoteDataSourceImpl.parseDateFromUrl(
          'https://www.khamk.ru/file_download/3567/1_semester_2026-2027_1_frame.xls',
        ),
        isNull,
      );
    });

    test('несуществующая дата отбрасывается', () {
      // 31 февраля: DateTime молча перенёс бы на март.
      expect(
        SubstitutionsRemoteDataSourceImpl.parseDateFromUrl('file_310226.docx'),
        isNull,
      );
    });

    test('месяц больше 12 отбрасывается', () {
      expect(
        SubstitutionsRemoteDataSourceImpl.parseDateFromUrl('file_011326.docx'),
        isNull,
      );
    });
  });

  group('номер корпуса', () {
    test('из текста ссылки', () {
      expect(SubstitutionsRemoteDataSourceImpl.parseBuilding('Корпус № 1'), 1);
      expect(SubstitutionsRemoteDataSourceImpl.parseBuilding('корпус 2'), 2);
    });

    test('из имени файла', () {
      expect(
        SubstitutionsRemoteDataSourceImpl.parseBuilding(
          'replacements_020926_2_frame.docx',
        ),
        2,
      );
    });

    test('когда корпуса нет — null', () {
      expect(
        SubstitutionsRemoteDataSourceImpl.parseBuilding('Замены на завтра'),
        isNull,
      );
    });
  });
}

/// Отдаёт заранее заданный HTML вместо реального сетевого запроса.
class _FakeAdapter implements HttpClientAdapter {
  _FakeAdapter(this.body);

  final String body;

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async =>
      ResponseBody.fromString(body, 200, headers: {
        Headers.contentTypeHeader: [Headers.jsonContentType],
      });

  @override
  void close({bool force = false}) {}
}
