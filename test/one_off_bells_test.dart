import 'package:flutter_test/flutter_test.dart';
import 'package:raspisanie_app/features/schedule/domain/entities/bell_schedule.dart';
import 'package:raspisanie_app/features/schedule/domain/entities/schedule_slot.dart';

void main() {
  const weekday = BellSchedule(
    name: 'Будни',
    days: {1, 2, 3, 4, 5},
    times: [BellTime(pairNumber: 1, start: '08:30', end: '10:00')],
  );
  const fallback = BellSchedule(
    name: 'Основные',
    times: [BellTime(pairNumber: 1, start: '09:00', end: '10:30')],
  );

  final date = DateTime(2026, 10, 1); // четверг
  final shortened = BellSchedule(
    name: 'Сокращённые',
    date: date,
    times: const [BellTime(pairNumber: 1, start: '08:30', end: '09:10')],
  );

  group('разовый набор звонков', () {
    test('в свой день сильнее набора по дням недели', () {
      final bells = bellScheduleForDate([weekday, fallback, shortened], date);
      expect(bells?.name, 'Сокращённые');
      expect(bells?.timeFor(1)?.end, '09:10');
    });

    test('в другой день не применяется', () {
      final bells = bellScheduleForDate(
        [weekday, fallback, shortened],
        date.add(const Duration(days: 1)),
      );
      expect(bells?.name, 'Будни');
    });

    test('время в дате не мешает', () {
      final bells = bellScheduleForDate(
        [weekday, shortened],
        DateTime(2026, 10, 1, 14, 35),
      );
      expect(bells?.name, 'Сокращённые');
    });

    test('не считается основным набором и не подменяет выходные', () {
      // Воскресенья нет ни в одном наборе по дням недели: должен достаться
      // основной, а не разовый — иначе он расползётся на весь год.
      final sunday = DateTime(2026, 10, 4);
      expect(shortened.isDefault, isFalse);
      expect(bellScheduleForDate([weekday, fallback, shortened], sunday)?.name,
          'Основные');
    });

    test('по дню недели разовый набор не выбирается', () {
      expect(bellScheduleForWeekday([shortened], date.weekday), isNull);
    });
  });

  group('хранение', () {
    test('дата переживает сохранение и чтение', () {
      final restored = BellSchedule.fromJson(shortened.toJson());

      expect(restored.date, DateTime(2026, 10, 1));
      expect(restored.name, 'Сокращённые');
      expect(restored.times.single.end, '09:10');
      expect(restored, shortened);
    });

    test('у обычного набора ключа даты нет — старые звонки читаются как были', () {
      expect(weekday.toJson().containsKey('date'), isFalse);
      expect(BellSchedule.fromJson(weekday.toJson()), weekday);
      expect(
        BellSchedule.fromJson(const {
          'name': 'Старый',
          'days': [6],
          'times': [
            {'pair': 1, 'start': '09:00', 'end': '10:00'},
          ],
        }).date,
        isNull,
      );
    });
  });
}
