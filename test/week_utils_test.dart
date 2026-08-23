import 'package:flutter_test/flutter_test.dart';
import 'package:raspisanie_app/core/database/database.dart';
import 'package:raspisanie_app/core/utils/week_utils.dart';
import 'package:raspisanie_app/features/substitutions/data/datasources/substitutions_remote_data_source.dart';

void main() {
  group('WeekUtils', () {
    test('dayKey обнуляет время', () {
      expect(
        WeekUtils.dayKey(DateTime(2026, 9, 7, 23, 59, 59)),
        DateTime(2026, 9, 7),
      );
    });

    test('startOfWeek возвращает понедельник', () {
      // 2026-09-13 — воскресенье.
      expect(WeekUtils.startOfWeek(DateTime(2026, 9, 13)), DateTime(2026, 9, 7));
      expect(WeekUtils.startOfWeek(DateTime(2026, 9, 7)), DateTime(2026, 9, 7));
    });

    test('isoWeekNumber совпадает с ISO-8601', () {
      expect(WeekUtils.isoWeekNumber(DateTime(2026, 1, 1)), 1);
      expect(WeekUtils.isoWeekNumber(DateTime(2026, 9, 7)), 37);
      // 2027-01-01 — пятница, относится к 53-й неделе 2026 года.
      expect(WeekUtils.isoWeekNumber(DateTime(2027, 1, 1)), 53);
    });

    test('соседние недели имеют разную чётность', () {
      final first = WeekUtils.weekTypeFor(DateTime(2026, 9, 7));
      final next = WeekUtils.weekTypeFor(DateTime(2026, 9, 14));
      expect(first, isNot(next));
    });

    test('invert меняет чётность местами', () {
      final date = DateTime(2026, 9, 7);
      expect(
        WeekUtils.weekTypeFor(date, invert: true),
        isNot(WeekUtils.weekTypeFor(date)),
      );
      expect(
        {WeekUtils.weekTypeFor(date), WeekUtils.weekTypeFor(date, invert: true)},
        {WeekType.numerator, WeekType.denominator},
      );
    });

    test('formatFullDate по-русски', () {
      expect(
        WeekUtils.formatFullDate(DateTime(2026, 9, 7)),
        '7 сентября, понедельник',
      );
    });
  });

  group('распознавание даты в тексте ссылки', () {
    final now = DateTime(2026, 9, 10);

    test('словесная дата', () {
      expect(
        SubstitutionsRemoteDataSourceImpl.parseDate(
          'Замены на 15 сентября, 1 корпус',
          now: now,
        ),
        DateTime(2026, 9, 15),
      );
    });

    test('числовая дата с годом', () {
      expect(
        SubstitutionsRemoteDataSourceImpl.parseDate(
          'Замены 01.10.2026',
          now: now,
        ),
        DateTime(2026, 10, 1),
      );
    });

    test('без года берётся ближайший', () {
      // 3 января ближе к 10 сентября 2026 как январь 2027, а не 2026.
      expect(
        SubstitutionsRemoteDataSourceImpl.parseDate('Замены на 3 января', now: now),
        DateTime(2027, 1, 3),
      );
    });

    test('когда даты нет — null', () {
      expect(
        SubstitutionsRemoteDataSourceImpl.parseDate('Замены', now: now),
        isNull,
      );
    });
  });
}
