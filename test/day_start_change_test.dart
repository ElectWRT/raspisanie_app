import 'package:flutter_test/flutter_test.dart';
import 'package:raspisanie_app/core/background/background_refresh.dart';
import 'package:raspisanie_app/features/schedule/domain/entities/bell_schedule.dart';
import 'package:raspisanie_app/features/schedule/domain/entities/schedule_slot.dart';
import 'package:raspisanie_app/features/substitutions/domain/day_start_change.dart';

void main() {
  const bells = BellSchedule(
    name: 'Будни',
    times: [
      BellTime(pairNumber: 1, start: '08:30', end: '10:00'),
      BellTime(pairNumber: 2, start: '10:10', end: '11:40'),
      BellTime(pairNumber: 3, start: '12:10', end: '13:40'),
    ],
  );

  ScheduleSlot pair(int number, {bool cancelled = false, bool extra = false}) =>
      ScheduleSlot(
        pairNumber: number,
        subject: cancelled ? '' : 'Сети',
        isCancelled: cancelled,
        isExtra: extra,
        isSubstitution: cancelled || extra,
      );

  group('как замены сдвинули начало дня', () {
    test('первую пару сняли — приходить ко второй', () {
      final change = describeDayStart(
        [pair(1, cancelled: true), pair(2), pair(3)],
        bells: bells,
      );

      expect(change.shift, DayStartShift.later);
      expect(change.firstPair, 2);
      expect(change.startsAt, '10:10');
      expect(change.message, 'Первых пар не будет — к 10:10.');
    });

    test('сняли две первые — считается по первой оставшейся', () {
      final change = describeDayStart(
        [pair(1, cancelled: true), pair(2, cancelled: true), pair(3)],
        bells: bells,
      );

      expect(change.firstPair, 3);
      expect(change.startsAt, '12:10');
    });

    test('пару добавили в начало — приходить раньше', () {
      final change = describeDayStart([pair(1, extra: true), pair(2)], bells: bells);

      expect(change.shift, DayStartShift.earlier);
      expect(change.message, 'Добавили пару в начало — к 08:30.');
    });

    test('сняли весь день', () {
      final change = describeDayStart(
        [pair(1, cancelled: true), pair(2, cancelled: true)],
        bells: bells,
      );

      expect(change.shift, DayStartShift.freeDay);
      expect(change.message, 'Занятий нет — весь день сняли.');
    });

    test('замена в середине дня начало не двигает', () {
      final change = describeDayStart(
        [pair(1), pair(2, cancelled: true), pair(3)],
        bells: bells,
      );

      expect(change.isEmpty, isTrue);
      expect(change.message, isNull);
    });

    test('обычный день без замен', () {
      expect(describeDayStart([pair(1), pair(2)], bells: bells).isEmpty, isTrue);
    });

    test('пустой день', () {
      expect(describeDayStart(const [], bells: bells).isEmpty, isTrue);
    });

    test('без звонков говорит номером пары', () {
      final change = describeDayStart([pair(1, cancelled: true), pair(2)]);

      expect(change.startsAt, isNull);
      expect(change.message, 'Первых пар не будет — начало со 2-й.');
    });
  });

  group('текст уведомления', () {
    final date = DateTime(2026, 10, 1);

    test('сдвиг начала идёт первой строкой', () {
      final body = substitutionAlertBody(
        date: date,
        count: 3,
        group: 'СА-2124',
        startChange: const DayStartChange(
          shift: DayStartShift.later,
          firstPair: 2,
          startsAt: '10:10',
        ),
      );

      expect(body, startsWith('Первых пар не будет — к 10:10.'));
      expect(body, contains('3 замены'));
    });

    test('без сдвига — как раньше', () {
      final body = substitutionAlertBody(date: date, count: 1, group: 'СА-2124');

      expect(body, contains('1 замена'));
      expect(body, contains('Откройте'));
    });
  });
}
