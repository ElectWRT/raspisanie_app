import 'package:drift/drift.dart';

import '../../../../core/database/database.dart';
import '../../../../core/error/exceptions.dart';
import '../../domain/entities/schedule_slot.dart';

/// Результат разбора Markdown-файла с расписанием.
class ScheduleImportResult {
  final List<LessonsCompanion> lessons;
  final List<BellTime> bells;

  /// Сколько пар распознано по каждой группе — показываем в предпросмотре.
  final Map<String, int> lessonsPerGroup;

  /// Строки, которые парсер не понял. Не ошибка, но пользователю стоит видеть.
  final List<String> warnings;

  const ScheduleImportResult({
    required this.lessons,
    required this.bells,
    required this.lessonsPerGroup,
    required this.warnings,
  });

  bool get isEmpty => lessons.isEmpty;

  List<String> get groups => lessonsPerGroup.keys.toList()..sort();
}

/// Разбирает расписание в Markdown. Формат описан в `docs/SCHEDULE_FORMAT.md`.
///
///     # Звонки
///     1. 08:30 - 10:00
///
///     # СА-2124
///     ## Понедельник
///     1. Компьютерные сети | Иванов И.И. | 301
///     2. (числ) Математика | Петрова А.А. | 210
///     3. [1] Английский | Смирнова О.П. | 208
class MarkdownScheduleParser {
  const MarkdownScheduleParser();

  static final RegExp _heading = RegExp(r'^(#{1,6})\s*(.+?)\s*#*$');
  static final RegExp _numberedLine =
      RegExp(r'^\s*(?:[-*+]\s*)?(\d{1,2})\s*[.)\-–—:]\s*(.+)$');
  static final RegExp _bellLine = RegExp(
    r'^\s*(?:[-*+]\s*)?(\d{1,2})\s*[.)\-–—:]\s*'
    r'(\d{1,2}[:.]\d{2})\s*[-–—]+\s*(\d{1,2}[:.]\d{2})',
  );
  static final RegExp _subgroupMarker =
      RegExp(r'^\s*(?:\[\s*(\d)\s*\]|\(\s*(\d)\s*(?:подгр\w*|п/?г)\s*\))\s*');
  static final RegExp _weekMarker = RegExp(
    r'^\s*\(\s*(числ\w*|знам\w*|ч|з|верх\w*|нижн\w*|над|под)\s*\.?\s*\)\s*',
    caseSensitive: false,
  );
  static final RegExp _groupPrefix =
      RegExp(r'^(группа|group|гр\.?)\s*[:\-]?\s*', caseSensitive: false);
  static final RegExp _tableRow = RegExp(r'^\s*\|(.+)\|\s*$');
  static final RegExp _separatorOnly = RegExp(r'^[-=_*\s|:]+$');

  static const Set<String> _emptyDayMarkers = {
    'нет пар',
    'нет занятий',
    'выходной',
    'пар нет',
    'занятий нет',
    'свободный день',
    '-',
    '—',
  };

  static const Map<String, int> _dayTokens = {
    'понедельник': 1,
    'пн': 1,
    'пнд': 1,
    'вторник': 2,
    'вт': 2,
    'втр': 2,
    'среда': 3,
    'ср': 3,
    'срд': 3,
    'четверг': 4,
    'чт': 4,
    'чтв': 4,
    'пятница': 5,
    'пт': 5,
    'птн': 5,
    'суббота': 6,
    'сб': 6,
    'сбт': 6,
    'воскресенье': 7,
    'вс': 7,
    'вск': 7,
  };

  ScheduleImportResult parse(String source) {
    if (source.trim().isEmpty) {
      throw ParsingException('Файл пустой.');
    }

    final lessons = <LessonsCompanion>[];
    final bells = <BellTime>[];
    final perGroup = <String, int>{};
    final warnings = <String>[];

    String? currentGroup;
    int? currentDay;
    var inBellsSection = false;
    var inCodeFence = false;

    final lines = source.split(RegExp(r'\r?\n'));

    for (var i = 0; i < lines.length; i++) {
      final line = lines[i].trim();
      final lineNo = i + 1;

      if (line.startsWith('```') || line.startsWith('~~~')) {
        inCodeFence = !inCodeFence;
        continue;
      }
      if (inCodeFence || line.isEmpty) continue;

      // Горизонтальные линии и разделители Markdown-таблиц пропускаем молча.
      if (_separatorOnly.hasMatch(line)) continue;

      final heading = _heading.firstMatch(line);
      if (heading != null) {
        final level = heading.group(1)!.length;
        final title = heading.group(2)!.trim();
        final normalized = _normalize(title);

        if (_isBellsHeading(normalized)) {
          inBellsSection = true;
          currentDay = null;
          continue;
        }

        final day = _dayFor(normalized);
        if (day != null) {
          inBellsSection = false;
          currentDay = day;
          if (currentGroup == null) {
            warnings.add(
              'Строка $lineNo: день «$title» встретился до названия группы — '
              'пары пропущены. Добавьте выше заголовок «# НАЗВАНИЕ-ГРУППЫ».',
            );
          }
          continue;
        }

        // Заголовок верхнего уровня без дня недели — считаем названием группы.
        if (level <= 2) {
          inBellsSection = false;
          currentGroup = title.replaceFirst(_groupPrefix, '').trim();
          currentDay = null;
          perGroup.putIfAbsent(currentGroup, () => 0);
        }
        continue;
      }

      if (inBellsSection) {
        final bell = _bellLine.firstMatch(line);
        if (bell != null) {
          bells.add(BellTime(
            pairNumber: int.parse(bell.group(1)!),
            start: _normalizeTime(bell.group(2)!),
            end: _normalizeTime(bell.group(3)!),
          ));
        } else {
          warnings.add('Строка $lineNo: не похоже на время звонка — «$line».');
        }
        continue;
      }

      if (_emptyDayMarkers.contains(_normalize(line))) continue;

      if (currentGroup == null || currentDay == null) {
        warnings.add('Строка $lineNo: пропущена — неясно, к какой группе и '
            'дню она относится: «$line».');
        continue;
      }

      final content = _stripTableRow(line);
      final numbered = _numberedLine.firstMatch(content);
      if (numbered == null) {
        warnings.add('Строка $lineNo: не найден номер пары — «$line».');
        continue;
      }

      final pairNumber = int.parse(numbered.group(1)!);
      var body = numbered.group(2)!.trim();

      if (_emptyDayMarkers.contains(_normalize(body))) continue;

      var weekType = WeekType.every;
      String? subgroup;

      // Маркеры могут идти в любом порядке: «(числ) [1] Предмет».
      for (var pass = 0; pass < 2; pass++) {
        final week = _weekMarker.firstMatch(body);
        if (week != null) {
          weekType = _weekTypeFor(week.group(1)!);
          body = body.substring(week.end);
        }
        final sub = _subgroupMarker.firstMatch(body);
        if (sub != null) {
          subgroup = sub.group(1) ?? sub.group(2);
          body = body.substring(sub.end);
        }
      }

      final parts = body.split('|').map((e) => e.trim()).toList();
      final subject = parts.isNotEmpty ? parts[0] : '';
      if (subject.isEmpty) {
        warnings.add('Строка $lineNo: пустое название предмета — «$line».');
        continue;
      }

      lessons.add(LessonsCompanion.insert(
        groupName: currentGroup,
        dayOfWeek: currentDay,
        pairNumber: pairNumber,
        weekType: Value(weekType),
        subgroup: Value(subgroup),
        subject: subject,
        teacher: Value(parts.length > 1 ? parts[1] : ''),
        room: Value(parts.length > 2 ? parts[2] : ''),
      ));
      perGroup[currentGroup] = (perGroup[currentGroup] ?? 0) + 1;
    }

    if (lessons.isEmpty) {
      throw ParsingException(
        'Не удалось распознать ни одной пары. Проверьте, что в файле есть '
        'заголовок с группой («# СА-2124») и дни недели («## Понедельник»).',
      );
    }

    bells.sort((a, b) => a.pairNumber.compareTo(b.pairNumber));
    return ScheduleImportResult(
      lessons: lessons,
      bells: bells,
      lessonsPerGroup: perGroup,
      warnings: warnings,
    );
  }

  // ---------------------------------------------------------------- helpers

  static String _normalize(String value) => value
      .toLowerCase()
      .replaceAll('ё', 'е')
      .replaceAll(RegExp(r'[.:,;!?*_`]'), '')
      .trim();

  static bool _isBellsHeading(String normalized) =>
      normalized.startsWith('звонк') ||
      normalized.startsWith('расписание звонк') ||
      normalized == 'время пар' ||
      normalized == 'bells';

  static int? _dayFor(String normalized) {
    final direct = _dayTokens[normalized];
    if (direct != null) return direct;
    // «Понедельник (числитель)», «Пн, 1 сентября» и т.п.
    final firstWord = normalized.split(RegExp(r'[\s(,]')).first;
    return _dayTokens[firstWord];
  }

  static WeekType _weekTypeFor(String marker) {
    final m = marker.toLowerCase();
    if (m.startsWith('числ') || m == 'ч' || m.startsWith('верх') || m == 'над') {
      return WeekType.numerator;
    }
    return WeekType.denominator;
  }

  static String _normalizeTime(String value) {
    final parts = value.replaceAll('.', ':').split(':');
    return '${parts[0].padLeft(2, '0')}:${parts[1]}';
  }

  /// Превращает строку Markdown-таблицы `| 1 | Предмет | Иванов |`
  /// в обычную строку `1. Предмет | Иванов`.
  static String _stripTableRow(String line) {
    final match = _tableRow.firstMatch(line);
    if (match == null) return line;
    final cells = match.group(1)!.split('|').map((e) => e.trim()).toList();
    if (cells.isEmpty) return line;
    final first = cells.removeAt(0);
    return '$first. ${cells.join(' | ')}';
  }
}
