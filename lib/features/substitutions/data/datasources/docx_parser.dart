import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:archive/archive.dart';
import 'package:xml/xml.dart';

import '../../../../core/error/exceptions.dart';
import '../models/substitution_model.dart';

/// Что удалось вытащить из документа с заменами.
class DocxParseResult {
  /// Дата, на которую выложены замены. null — в документе её не нашли.
  final DateTime? date;
  final List<SubstitutionModel> items;

  /// Строки, которые парсер не понял, — показываем в диагностике.
  final List<String> warnings;

  /// Первые несколько килобайт текста документа. Нужен, чтобы подстроить
  /// парсер под реальный формат, не гадая.
  final String textPreview;

  const DocxParseResult({
    required this.date,
    required this.items,
    required this.warnings,
    required this.textPreview,
  });
}

/// Разбирает .docx с заменами.
///
/// Устроен так, чтобы пережить типичные вольности вёрстки завуча:
/// колонки ищутся по заголовкам, пустая ячейка группы наследуется от строки
/// выше (объединённые ячейки), лишние колонки игнорируются.
class DocxParser {
  const DocxParser();

  /// Похоже на код учебной группы: «СА-2124», «ИС 21», «4ТМ-9».
  static final RegExp _groupPattern = RegExp(
    r'^\d?[А-ЯЁA-Z]{1,4}\s?[-–—/]?\s?\d{1,4}(?:[-–—/]\d{1,2})?$',
    caseSensitive: false,
  );

  static final RegExp _numericDate =
      RegExp(r'(\d{1,2})[.\-/](\d{1,2})[.\-/](\d{2,4})');
  static final RegExp _textualDate = RegExp(
    r'(\d{1,2})\s+(январ|феврал|март|апрел|ма[йя]|июн|июл|август|сентябр|октябр|ноябр|декабр)\w*(?:\s+(\d{4}))?',
    caseSensitive: false,
  );

  static const List<String> _monthStems = [
    'январ',
    'феврал',
    'март',
    'апрел',
    'ма',
    'июн',
    'июл',
    'август',
    'сентябр',
    'октябр',
    'ноябр',
    'декабр',
  ];

  static const Set<String> _cancelKeywords = {
    'снять',
    'снята',
    'снят',
    'нет пары',
    'нет',
    'отменена',
    'отменено',
    'отмена',
    'гуляют',
    'гуляет',
    'свободны',
    'освобождены',
  };

  // Ключевые слова для распознавания колонок.
  static const Map<String, List<String>> _columnKeywords = {
    'group': ['группа', 'групп', 'гр.'],
    'pair': ['пара', 'урок', 'занятие', '№', 'номер'],
    'subject': ['предмет', 'дисциплина', 'заменяемая', 'наименование'],
    'teacher': ['преподаватель', 'фио', 'педагог', 'учитель', 'заменяющий'],
    'room': ['аудитория', 'кабинет', 'ауд', 'каб', 'помещение'],
    'note': ['примечание', 'приме', 'коммент'],
  };

  DocxParseResult parseFile(File docxFile) =>
      parseBytes(docxFile.readAsBytesSync());

  DocxParseResult parseBytes(Uint8List bytes) {
    final XmlDocument document;
    try {
      final archive = ZipDecoder().decodeBytes(bytes);
      final content = archive.findFile('word/document.xml');
      if (content == null) {
        throw ParsingException(
          'Это не .docx — внутри архива нет word/document.xml. '
          'Возможно, файл в формате .doc или .pdf.',
        );
      }
      document = XmlDocument.parse(utf8.decode(content.content as List<int>));
    } on ParsingException {
      rethrow;
    } catch (e) {
      throw ParsingException('Не удалось открыть документ: $e');
    }

    final warnings = <String>[];
    final items = <SubstitutionModel>[];
    final fullText = _documentText(document);
    final date = _findDate(fullText);

    for (final table in document.findAllElements('w:tbl')) {
      final rows = table
          .findElements('w:tr')
          .map(_rowCells)
          .where((cells) => cells.any((c) => c.isNotEmpty))
          .toList();
      if (rows.isEmpty) continue;

      final layout = _detectLayout(rows);
      String? lastGroup;

      for (var i = layout.firstDataRow; i < rows.length; i++) {
        final cells = rows[i];

        // Строка-разделитель вроде «2 КУРС». Пропускаем молча и, что важнее,
        // не запоминаем как последнюю группу — иначе её текст протёк бы
        // в следующую строку, где ячейка группы пустая.
        if (_isSectionHeader(cells)) continue;

        final rawGroup = layout.pick(cells, 'group');
        final group = rawGroup.isNotEmpty ? _cleanGroup(rawGroup) : lastGroup;
        if (group == null || group.isEmpty) {
          if (cells.join().trim().isNotEmpty) {
            warnings.add('Пропущена строка без группы: ${_preview(cells)}');
          }
          continue;
        }
        lastGroup = group;

        final pairRaw = layout.pick(cells, 'pair');
        final pairNumber = _parsePairNumber(pairRaw);
        if (pairNumber == null) {
          warnings.add(
            'Не понял номер пары «$pairRaw» в строке: ${_preview(cells)}',
          );
          continue;
        }

        final subject = layout.pick(cells, 'subject');
        final teacher = layout.pick(cells, 'teacher');
        final room = layout.pick(cells, 'room');
        final note = layout.pick(cells, 'note');
        final cancelled = _looksCancelled(subject) || _looksCancelled(note);

        if (subject.isEmpty && !cancelled) {
          warnings.add('Пустой предмет в строке: ${_preview(cells)}');
          continue;
        }

        items.add(SubstitutionModel(
          groupName: group,
          pairNumber: pairNumber,
          subgroup: _parseSubgroup(pairRaw) ?? _parseSubgroup(subject),
          subject: cancelled ? '' : subject,
          teacher: teacher,
          room: room,
          isCancelled: cancelled,
          note: note.isEmpty ? null : note,
        ));
      }
    }

    if (items.isEmpty) {
      throw ParsingException(
        'В документе не нашлось ни одной строки замены. '
        'Откройте диагностику, чтобы посмотреть, что удалось прочитать.',
      );
    }

    return DocxParseResult(
      date: date,
      items: items,
      warnings: warnings,
      textPreview:
          fullText.length > 4000 ? fullText.substring(0, 4000) : fullText,
    );
  }

  // ------------------------------------------------------------------ layout

  /// Раскладка колонок таблицы: какой индекс за что отвечает.
  static _TableLayout _detectLayout(List<List<String>> rows) {
    // Заголовок ищем среди первых трёх строк.
    for (var i = 0; i < rows.length && i < 3; i++) {
      final mapping = <String, int>{};
      for (var c = 0; c < rows[i].length; c++) {
        final cell = rows[i][c].toLowerCase().replaceAll('ё', 'е');
        if (cell.isEmpty) continue;
        for (final entry in _columnKeywords.entries) {
          if (mapping.containsKey(entry.key)) continue;
          if (entry.value.any(cell.contains)) {
            mapping[entry.key] = c;
            break;
          }
        }
      }
      // Заголовок засчитываем, только если нашлись и группа, и предмет.
      if (mapping.containsKey('group') && mapping.containsKey('subject')) {
        return _TableLayout(mapping: mapping, firstDataRow: i + 1);
      }
    }

    // Заголовка нет — считаем порядок стандартным.
    return const _TableLayout(
      mapping: {'group': 0, 'pair': 1, 'subject': 2, 'teacher': 3, 'room': 4},
      firstDataRow: 0,
    );
  }

  /// Текст ячейки: собираем все w:t, переносы строк внутри ячейки схлопываем.
  static List<String> _rowCells(XmlElement row) => row
      .findElements('w:tc')
      .map((tc) => tc
          .findAllElements('w:t')
          .map((n) => n.innerText)
          .join()
          .replaceAll(RegExp(r'\s+'), ' ')
          .trim())
      .toList();

  static String _documentText(XmlDocument document) => document
      .findAllElements('w:p')
      .map((p) => p.findAllElements('w:t').map((n) => n.innerText).join())
      .where((line) => line.trim().isNotEmpty)
      .join('\n');

  // ----------------------------------------------------------------- helpers

  static DateTime? _findDate(String text) {
    final textual = _textualDate.firstMatch(text);
    if (textual != null) {
      final day = int.parse(textual.group(1)!);
      final stem = textual.group(2)!.toLowerCase();
      final month = _monthStems.indexWhere(stem.startsWith) + 1;
      final year = int.tryParse(textual.group(3) ?? '') ?? DateTime.now().year;
      if (month > 0) return DateTime(year, month, day);
    }

    final numeric = _numericDate.firstMatch(text);
    if (numeric != null) {
      final day = int.parse(numeric.group(1)!);
      final month = int.parse(numeric.group(2)!);
      var year = int.parse(numeric.group(3)!);
      if (year < 100) year += 2000;
      if (month >= 1 && month <= 12 && day >= 1 && day <= 31) {
        return DateTime(year, month, day);
      }
    }
    return null;
  }

  /// Разделитель курса внутри таблицы: «2 КУРС», «1 курс».
  static final RegExp _sectionHeader =
      RegExp(r'^\d{1,2}\s*курс$', caseSensitive: false);

  /// Строка-заголовок раздела, а не замена: непустая ячейка ровно одна,
  /// и в ней стоит «N курс».
  static bool _isSectionHeader(List<String> cells) {
    final filled = cells.where((c) => c.trim().isNotEmpty).toList();
    if (filled.length != 1) return false;
    return _sectionHeader.hasMatch(filled.first.trim());
  }

  static String _cleanGroup(String value) {
    final cleaned = value.replaceAll(RegExp(r'^(группа|гр\.?)\s*',
            caseSensitive: false), '')
        .replaceAll(RegExp(r'\s+'), '')
        .trim();
    return _groupPattern.hasMatch(cleaned) ? cleaned.toUpperCase() : cleaned;
  }

  static int? _parsePairNumber(String value) {
    final match = RegExp(r'\d{1,2}').firstMatch(value);
    if (match == null) return null;
    final number = int.parse(match.group(0)!);
    return (number >= 0 && number <= 12) ? number : null;
  }

  /// «2 пара (1 п/г)», «3 [2]» → номер подгруппы.
  static String? _parseSubgroup(String value) {
    final match = RegExp(r'(?:\[|\()\s*(\d)\s*(?:\]|подгр\w*|п/?г\s*\))')
        .firstMatch(value.toLowerCase());
    return match?.group(1);
  }

  static bool _looksCancelled(String value) {
    final normalized = value.toLowerCase().replaceAll('ё', 'е').trim();
    if (normalized.isEmpty) return false;
    return _cancelKeywords.any(normalized.contains);
  }

  static String _preview(List<String> cells) {
    final text = cells.where((c) => c.isNotEmpty).join(' | ');
    return text.length > 120 ? '${text.substring(0, 120)}…' : text;
  }
}

class _TableLayout {
  final Map<String, int> mapping;
  final int firstDataRow;

  const _TableLayout({required this.mapping, required this.firstDataRow});

  String pick(List<String> cells, String key) {
    final index = mapping[key];
    if (index == null || index >= cells.length) return '';
    return cells[index];
  }
}
