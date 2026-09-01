import 'dart:convert';
import 'dart:typed_data';

import 'package:archive/archive.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:raspisanie_app/core/error/exceptions.dart';
import 'package:raspisanie_app/features/substitutions/data/datasources/docx_parser.dart';

/// Собирает минимальный .docx: заголовочные абзацы + одна таблица.
Uint8List buildDocx({
  required List<String> paragraphs,
  required List<List<String>> rows,
}) {
  String paragraph(String text) =>
      '<w:p><w:r><w:t>${_escape(text)}</w:t></w:r></w:p>';
  String cell(String text) => '<w:tc>${paragraph(text)}</w:tc>';
  String row(List<String> cells) =>
      '<w:tr>${cells.map(cell).join()}</w:tr>';

  final xml = '<?xml version="1.0" encoding="UTF-8"?>'
      '<w:document xmlns:w="http://schemas.openxmlformats.org/wordprocessingml/2006/main">'
      '<w:body>'
      '${paragraphs.map(paragraph).join()}'
      '<w:tbl>${rows.map(row).join()}</w:tbl>'
      '</w:body></w:document>';

  final archive = Archive()
    ..addFile(ArchiveFile.string('word/document.xml', xml));
  return Uint8List.fromList(ZipEncoder().encode(archive)!);
}

String _escape(String value) =>
    value.replaceAll('&', '&amp;').replaceAll('<', '&lt;');

void main() {
  const parser = DocxParser();

  test('читает таблицу с заголовком и находит дату', () {
    final bytes = buildDocx(
      paragraphs: const ['Замены на 15 сентября 2026 г.'],
      rows: const [
        ['Группа', 'Пара', 'Предмет', 'Преподаватель', 'Аудитория'],
        ['СА-2124', '2', 'Философия', 'Орлов О.О.', '404'],
        ['ИС-21', '1', 'Базы данных', 'Гусев Г.Г.', '210'],
      ],
    );

    final result = parser.parseBytes(bytes);

    expect(result.date, DateTime(2026, 9, 15));
    expect(result.items, hasLength(2));
    expect(result.items.first.groupName, 'СА-2124');
    expect(result.items.first.pairNumber, 2);
    expect(result.items.first.subject, 'Философия');
    expect(result.items.first.teacher, 'Орлов О.О.');
    expect(result.items.first.room, '404');
    expect(result.warnings, isEmpty);
  });

  test('строка-разделитель «2 КУРС» не считается заменой', () {
    // Так устроены настоящие документы khamk.ru: курсы разделены
    // строкой с одной заполненной ячейкой.
    final bytes = buildDocx(
      paragraphs: const ['Замены на 02.09.2026'],
      rows: const [
        ['Группа', 'Пара', 'Предмет', 'Преподаватель', 'Аудитория'],
        ['2 КУРС', '', '', '', ''],
        ['ДС-2125', '2', 'Осн.фин.грам', 'Румянцева В.А.', '31'],
      ],
    );

    final result = parser.parseBytes(bytes);

    expect(result.items, hasLength(1));
    expect(result.items.single.groupName, 'ДС-2125');
    expect(result.warnings, isEmpty, reason: 'разделитель — не ошибка');
  });

  test('разделитель курса не подставляется как группа в следующую строку', () {
    // Группа берётся из предыдущей строки, когда ячейка пустая. Если бы
    // «2 КУРС» запомнился как группа, он протёк бы сюда.
    final bytes = buildDocx(
      paragraphs: const ['Замены на 02.09.2026'],
      rows: const [
        ['Группа', 'Пара', 'Предмет', 'Преподаватель', 'Аудитория'],
        ['ДС-2125', '2', 'Физика', 'Иванов И.И.', '31'],
        ['2 КУРС', '', '', '', ''],
        ['', '3', 'История', 'Бельды А.А.', '20п'],
      ],
    );

    final result = parser.parseBytes(bytes);

    expect(result.items, hasLength(2));
    expect(result.items.last.groupName, 'ДС-2125');
  });

  test('колонки ищутся по заголовкам, а не по позиции', () {
    final bytes = buildDocx(
      paragraphs: const ['Замены 01.10.2026'],
      rows: const [
        ['№', 'Аудитория', 'Группа', 'Дисциплина', 'ФИО преподавателя'],
        ['3', '112', 'СА-2124', 'Физика', 'Кузнецов В.В.'],
      ],
    );

    final item = parser.parseBytes(bytes).items.single;

    expect(item.pairNumber, 3);
    expect(item.room, '112');
    expect(item.subject, 'Физика');
    expect(item.teacher, 'Кузнецов В.В.');
  });

  test('без заголовка используется стандартный порядок колонок', () {
    final bytes = buildDocx(
      paragraphs: const ['Замены на 5 сентября'],
      rows: const [
        ['СА-2124', '1', 'Сети', 'Иванов И.И.', '301'],
      ],
    );

    final item = parser.parseBytes(bytes).items.single;

    expect(item.groupName, 'СА-2124');
    expect(item.subject, 'Сети');
  });

  test('пустая ячейка группы наследуется от строки выше', () {
    final bytes = buildDocx(
      paragraphs: const ['Замены на 5 сентября'],
      rows: const [
        ['Группа', 'Пара', 'Предмет', 'Преподаватель', 'Аудитория'],
        ['СА-2124', '1', 'Сети', 'Иванов И.И.', '301'],
        ['', '2', 'ОС', 'Петров П.П.', '305'],
      ],
    );

    final items = parser.parseBytes(bytes).items;

    expect(items, hasLength(2));
    expect(items.last.groupName, 'СА-2124');
    expect(items.last.pairNumber, 2);
  });

  test('снятая пара распознаётся', () {
    final bytes = buildDocx(
      paragraphs: const ['Замены на 5 сентября'],
      rows: const [
        ['Группа', 'Пара', 'Предмет', 'Преподаватель', 'Аудитория'],
        ['СА-2124', '4', 'Снять', '', ''],
      ],
    );

    final item = parser.parseBytes(bytes).items.single;

    expect(item.isCancelled, isTrue);
    expect(item.subject, '');
  });

  test('«нет» внутри названия предмета не отменяет пару', () {
    final bytes = buildDocx(
      paragraphs: const ['Замены на 5 сентября'],
      rows: const [
        ['Группа', 'Пара', 'Предмет', 'Преподаватель', 'Аудитория'],
        ['СА-2124', '3', 'Основы Интернет-технологий', 'Иванов И.И.', '301'],
        ['СА-2125', '4', 'Генетика', 'Петров П.П.', '210'],
      ],
    );

    final items = parser.parseBytes(bytes).items;

    expect(
      items.map((i) => i.isCancelled),
      everyElement(isFalse),
      reason: 'подстрока «нет» сидит в «Интернет» и «Генетика»',
    );
    expect(items.first.subject, 'Основы Интернет-технологий');
    expect(items.last.subject, 'Генетика');
  });

  test('слово «нет» отдельным словом отменяет пару', () {
    final bytes = buildDocx(
      paragraphs: const ['Замены на 5 сентября'],
      rows: const [
        ['Группа', 'Пара', 'Предмет', 'Преподаватель', 'Аудитория'],
        ['СА-2124', '4', 'нет пары', '', ''],
      ],
    );

    expect(parser.parseBytes(bytes).items.single.isCancelled, isTrue);
  });

  test('номер подгруппы читается из номера пары', () {
    final bytes = buildDocx(
      paragraphs: const ['Замены на 5 сентября'],
      rows: const [
        ['Группа', 'Пара', 'Предмет', 'Преподаватель', 'Аудитория'],
        ['СА-2124', '3 (1 п/г)', 'Английский', 'Смирнова О.П.', '208'],
      ],
    );

    final item = parser.parseBytes(bytes).items.single;

    expect(item.pairNumber, 3);
    expect(item.subgroup, '1');
  });

  test('нераспознанные строки попадают в warnings, а не роняют разбор', () {
    final bytes = buildDocx(
      paragraphs: const ['Замены на 5 сентября'],
      rows: const [
        ['Группа', 'Пара', 'Предмет', 'Преподаватель', 'Аудитория'],
        ['СА-2124', '1', 'Сети', 'Иванов И.И.', '301'],
        ['СА-2124', 'третья', 'ОС', 'Петров П.П.', '305'],
      ],
    );

    final result = parser.parseBytes(bytes);

    expect(result.items, hasLength(1));
    expect(result.warnings, hasLength(1));
    expect(result.warnings.single, contains('третья'));
  });

  test('не-docx даёт понятную ошибку', () {
    expect(
      () => parser.parseBytes(Uint8List.fromList(utf8.encode('не архив'))),
      throwsA(isA<ParsingException>()),
    );
  });

  test('документ без строк замен даёт понятную ошибку', () {
    final bytes = buildDocx(
      paragraphs: const ['Объявление'],
      rows: const [
        ['Группа', 'Пара', 'Предмет', 'Преподаватель', 'Аудитория'],
      ],
    );

    expect(() => parser.parseBytes(bytes), throwsA(isA<ParsingException>()));
  });
}
