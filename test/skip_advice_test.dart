import 'package:flutter_test/flutter_test.dart';
import 'package:raspisanie_app/features/attendance/domain/skip_advice.dart';

void main() {
  const limits = SkipLimits(perSubject: 4, perMajorSubject: 2);

  SkipPair pair(
    String subject, {
    int missed = 0,
    bool major = false,
    bool cancelled = false,
    int number = 1,
  }) =>
      SkipPair(
        pairNumber: number,
        subject: subject,
        missedBefore: missed,
        isMajor: major,
        isCancelled: cancelled,
      );

  group('вердикт по одной паре', () {
    test('запас есть — можно', () {
      final advice = adviseSkip(
        pairs: [pair('Математика', missed: 1)],
        limits: limits,
      );

      expect(advice.verdict, SkipVerdict.allowed);
      expect(advice.reasons, isEmpty);
    });

    test('последний пропуск до лимита — не стоит', () {
      final advice = adviseSkip(
        pairs: [pair('Математика', missed: 3)],
        limits: limits,
      );

      expect(advice.verdict, SkipVerdict.notAdvised);
      expect(advice.reasons.single, contains('4 из 4'));
    });

    test('лимит уже выбран — критично', () {
      final advice = adviseSkip(
        pairs: [pair('Математика', missed: 4)],
        limits: limits,
      );

      expect(advice.verdict, SkipVerdict.critical);
      expect(advice.reasons.single, contains('лимите 4'));
    });

    test('профильный предмет не бывает «просто можно»', () {
      final advice = adviseSkip(
        pairs: [pair('Базы данных', major: true)],
        limits: limits,
      );

      expect(advice.verdict, SkipVerdict.notAdvised);
      expect(advice.reasons.single, contains('профильный'));
    });

    test('у профильного свой, более строгий лимит', () {
      // Два пропуска: для обычного предмета это ещё запас, для
      // профильного — уже перебор.
      final ordinary = adviseSkip(
        pairs: [pair('Физкультура', missed: 2)],
        limits: limits,
      );
      final major = adviseSkip(
        pairs: [pair('Базы данных', missed: 2, major: true)],
        limits: limits,
      );

      expect(ordinary.verdict, SkipVerdict.allowed);
      expect(major.verdict, SkipVerdict.critical);
    });
  });

  group('вердикт по дню', () {
    test('берётся худшая пара дня', () {
      final advice = adviseSkip(
        pairs: [
          pair('Физкультура', number: 1),
          pair('Математика', number: 2, missed: 4),
          pair('История', number: 3),
        ],
        limits: limits,
      );

      expect(advice.verdict, SkipVerdict.critical);
      expect(advice.consideredPairs, 3);
    });

    test('снятые заменой пары в анализ не идут', () {
      final advice = adviseSkip(
        pairs: [
          pair('Математика', number: 1, missed: 9, cancelled: true),
          pair('История', number: 2),
        ],
        limits: limits,
      );

      expect(advice.verdict, SkipVerdict.allowed,
          reason: 'снятую пару пропустить нельзя — её и так нет');
      expect(advice.consideredPairs, 1);
    });

    test('день целиком снят — считать нечего', () {
      final advice = adviseSkip(
        pairs: [pair('Математика', missed: 9, cancelled: true)],
        limits: limits,
      );

      expect(advice.isEmpty, isTrue);
      expect(advice.verdict, SkipVerdict.allowed);
    });

    test('пар нет вовсе', () {
      expect(adviseSkip(pairs: const []).isEmpty, isTrue);
    });

    test('причины собираются по всем проблемным парам', () {
      final advice = adviseSkip(
        pairs: [
          pair('Базы данных', number: 1, major: true),
          pair('Математика', number: 2, missed: 4),
          pair('История', number: 3),
        ],
        limits: limits,
      );

      expect(advice.reasons, hasLength(2));
      expect(advice.reasons.any((r) => r.contains('История')), isFalse);
    });
  });
}
