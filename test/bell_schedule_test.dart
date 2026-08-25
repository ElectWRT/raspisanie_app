import 'package:flutter_test/flutter_test.dart';
import 'package:raspisanie_app/features/schedule/domain/entities/bell_schedule.dart';
import 'package:raspisanie_app/features/schedule/domain/entities/schedule_slot.dart';

void main() {
  const weekdays = BellSchedule(
    name: 'Будни',
    days: {1, 2, 3, 4, 5},
    times: [BellTime(pairNumber: 1, start: '08:30', end: '10:00')],
  );
  const saturday = BellSchedule(
    name: 'Суббота',
    days: {6},
    times: [BellTime(pairNumber: 1, start: '08:30', end: '09:30')],
  );
  const fallback = BellSchedule(
    name: 'Основные',
    times: [BellTime(pairNumber: 1, start: '09:00', end: '10:30')],
  );

  group('bellScheduleForWeekday', () {
    test('находит набор по дню недели', () {
      final result = bellScheduleForWeekday([weekdays, saturday], 6);
      expect(result?.name, 'Суббота');
    });

    test('день, покрытый диапазоном будней', () {
      final result = bellScheduleForWeekday([weekdays, saturday], 3);
      expect(result?.name, 'Будни');
    });

    test('непокрытый день берёт набор по умолчанию', () {
      final result = bellScheduleForWeekday([weekdays, saturday, fallback], 7);
      expect(result?.name, 'Основные');
    });

    test('явный набор приоритетнее набора по умолчанию', () {
      final result = bellScheduleForWeekday([fallback, saturday], 6);
      expect(result?.name, 'Суббота');
    });

    test('когда наборов нет — null', () {
      expect(bellScheduleForWeekday(const [], 1), isNull);
    });

    test('нет ни подходящего дня, ни набора по умолчанию — null', () {
      expect(bellScheduleForWeekday([saturday], 2), isNull);
    });
  });

  group('сериализация', () {
    test('переживает круг json', () {
      final restored = BellSchedule.fromJson(saturday.toJson());
      expect(restored, saturday);
    });

    test('набор по умолчанию сохраняет пустой список дней', () {
      final restored = BellSchedule.fromJson(fallback.toJson());
      expect(restored.isDefault, isTrue);
      expect(restored.times.single.start, '09:00');
    });
  });

  test('timeFor находит пару по номеру', () {
    expect(weekdays.timeFor(1)?.end, '10:00');
    expect(weekdays.timeFor(9), isNull);
  });
}
