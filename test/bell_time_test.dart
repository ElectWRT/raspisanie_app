import 'package:flutter_test/flutter_test.dart';
import 'package:raspisanie_app/features/schedule/domain/entities/schedule_slot.dart';

void main() {
  const bell = BellTime(pairNumber: 1, start: '08:30', end: '10:00');
  final day = DateTime(2026, 9, 1);

  group('BellTime.isNow', () {
    test('во время пары — true', () {
      expect(bell.isNow(DateTime(2026, 9, 1, 9, 15), day), isTrue);
    });

    test('ровно в начале — true', () {
      expect(bell.isNow(DateTime(2026, 9, 1, 8, 30), day), isTrue);
    });

    test('ровно в конце — уже false', () {
      expect(bell.isNow(DateTime(2026, 9, 1, 10, 0), day), isFalse);
    });

    test('до начала — false', () {
      expect(bell.isNow(DateTime(2026, 9, 1, 8, 29), day), isFalse);
    });

    test('в другой день в то же время — false', () {
      expect(bell.isNow(DateTime(2026, 9, 2, 9, 15), day), isFalse);
    });
  });

  group('BellTime.isPast', () {
    test('после конца — true', () {
      expect(bell.isPast(DateTime(2026, 9, 1, 10, 1), day), isTrue);
    });

    test('во время пары — false', () {
      expect(bell.isPast(DateTime(2026, 9, 1, 9, 0), day), isFalse);
    });

    test('на следующий день — true', () {
      expect(bell.isPast(DateTime(2026, 9, 2, 8, 0), day), isTrue);
    });
  });

  test('битое время не роняет приложение', () {
    const broken = BellTime(pairNumber: 1, start: 'что-то', end: '10:00');
    expect(broken.isNow(DateTime(2026, 9, 1, 9, 0), day), isFalse);
    expect(broken.isPast(DateTime(2026, 9, 1, 11, 0), day), isTrue);
  });
}
