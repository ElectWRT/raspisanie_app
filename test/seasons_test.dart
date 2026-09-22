import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:raspisanie_app/core/settings/app_settings.dart';
import 'package:raspisanie_app/features/seasons/domain/density_governor.dart';
import 'package:raspisanie_app/features/seasons/domain/season.dart';
import 'package:raspisanie_app/features/seasons/presentation/festive_garland.dart';
import 'package:raspisanie_app/features/seasons/presentation/seasonal_backdrop.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  group('сезон по дате', () {
    test('месяцы раскладываются по сезонам', () {
      expect(seasonFor(DateTime(2026, 9, 1)), Season.autumn);
      expect(seasonFor(DateTime(2026, 11, 30)), Season.autumn);
      expect(seasonFor(DateTime(2026, 12, 1)), Season.winter);
      expect(seasonFor(DateTime(2027, 2, 28)), Season.winter);
      expect(seasonFor(DateTime(2027, 3, 1)), Season.spring);
      expect(seasonFor(DateTime(2027, 6, 1)), Season.summer);
    });

    test('новогодние каникулы — с 20 декабря по 10 января', () {
      expect(isNewYearPeriod(DateTime(2026, 12, 19)), isFalse);
      expect(isNewYearPeriod(DateTime(2026, 12, 20)), isTrue);
      expect(isNewYearPeriod(DateTime(2027, 1, 1)), isTrue);
      expect(isNewYearPeriod(DateTime(2027, 1, 10)), isTrue);
      expect(isNewYearPeriod(DateTime(2027, 1, 11)), isFalse);
    });

    test('поздравление до и после полуночи 31 декабря', () {
      expect(festiveGreeting(DateTime(2026, 12, 25)), 'С наступающим Новым годом!');
      expect(festiveGreeting(DateTime(2027, 1, 3)), 'С Новым годом!');
    });
  });

  group('выбор пользователя', () {
    final newYear = DateTime(2026, 12, 28);

    test('по календарю под Новый год — зима с праздником', () {
      expect(
        resolveSeasonLook(newYear, SeasonMode.auto),
        const SeasonLook(season: Season.winter, festive: true),
      );
    });

    test('закреплённая осень гирлянды в январе не получает', () {
      expect(
        resolveSeasonLook(DateTime(2027, 1, 2), SeasonMode.autumn),
        const SeasonLook(season: Season.autumn),
      );
    });

    test('закреплённая зима праздник получает', () {
      expect(resolveSeasonLook(newYear, SeasonMode.winter)?.festive, isTrue);
    });

    test('выключено — оформления нет', () {
      expect(resolveSeasonLook(newYear, SeasonMode.off), isNull);
    });

    test('под Новый год снега гуще', () {
      const festive = SeasonLook(season: Season.winter, festive: true);
      const plain = SeasonLook(season: Season.winter);
      expect(seasonDensityFactor(festive), greaterThan(seasonDensityFactor(plain)));
    });
  });

  group('подбор плотности под устройство', () {
    const budget = Duration(microseconds: 16667); // 60 Гц
    const slow = Duration(milliseconds: 20);
    const fast = Duration(milliseconds: 5);
    const okay = Duration(milliseconds: 11);

    void feed(DensityGovernor g, Duration cost, {int windows = 1}) {
      for (var i = 0; i < g.windowSize * windows; i++) {
        g.addFrame(cost, budget);
      }
    }

    test('не успевает — частиц сразу на треть меньше', () {
      final g = DensityGovernor(maxCount: 30, initial: 20);
      feed(g, slow);
      expect(g.count, 14);
    });

    test('упорно не успевает — доходит до нуля, а не тормозит дальше', () {
      final g = DensityGovernor(maxCount: 30, initial: 20);
      feed(g, slow, windows: 20);
      expect(g.count, 0);
    });

    test('с запасом — прибавляет осторожно, только после трёх окон', () {
      final g = DensityGovernor(maxCount: 30, initial: 10);
      feed(g, fast, windows: 2);
      expect(g.count, 10, reason: 'двух секунд запаса мало');
      feed(g, fast);
      expect(g.count, 12);
    });

    test('выше потолка экрана не поднимается', () {
      final g = DensityGovernor(maxCount: 14, initial: 12);
      feed(g, fast, windows: 30);
      expect(g.count, 14);
    });

    test('впритык, но успевает — ничего не трогает', () {
      final g = DensityGovernor(maxCount: 30, initial: 15);
      feed(g, okay, windows: 10);
      expect(g.count, 15);
    });

    test('единичный тяжёлый кадр не срезает частицы', () {
      // Например, открытие экрана: один кадр долгий, остальные лёгкие.
      final g = DensityGovernor(maxCount: 30, initial: 15);
      g.addFrame(const Duration(milliseconds: 80), budget);
      for (var i = 1; i < g.windowSize; i++) {
        g.addFrame(okay, budget);
      }
      expect(g.count, 15);
    });

    test('на 120 Гц бюджет вдвое меньше — те же кадры уже медленные', () {
      final g = DensityGovernor(maxCount: 30, initial: 20);
      for (var i = 0; i < g.windowSize; i++) {
        g.addFrame(okay, const Duration(microseconds: 8333));
      }
      expect(g.count, lessThan(20));
    });

    test('на планшете потолок выше, чем на телефоне', () {
      final phone = DensityGovernor.maxForArea(400, 700);
      final tablet = DensityGovernor.maxForArea(800, 1200);
      expect(tablet, greaterThan(phone));
      expect(DensityGovernor.maxForArea(10, 10), 4, reason: 'нижняя граница');
      expect(DensityGovernor.maxForArea(5000, 5000), 45, reason: 'верхняя');
    });

    test('стартовое значение не выходит за потолок', () {
      expect(DensityGovernor(maxCount: 10, initial: 99).count, 10);
    });
  });

  group('настройки сезона', () {
    setUp(() => SharedPreferences.setMockInitialValues({}));

    test('по умолчанию — по календарю и с движением', () async {
      final settings = await AppSettings.load();
      expect(settings.seasonMode, SeasonMode.auto);
      expect(settings.seasonalMotion, isTrue);
      expect(settings.seasonalParticleCount, isNull);
    });

    test('в копию идут выбор сезона и движение, но не число частиц', () async {
      final settings = await AppSettings.load();
      await settings.setSeasonMode(SeasonMode.winter);
      await settings.setSeasonalMotion(false);
      await settings.setSeasonalParticleCount(17);

      final backup = settings.exportForBackup();
      expect(backup['seasonMode'], 'winter');
      expect(backup['seasonalMotion'], false);
      expect(backup.values, isNot(contains(17)));

      SharedPreferences.setMockInitialValues({});
      final restored = await AppSettings.load();
      await restored.importFromBackup(backup);
      expect(restored.seasonMode, SeasonMode.winter);
      expect(restored.seasonalMotion, isFalse);
    });

    test('сброс внешнего вида возвращает сезон по календарю', () async {
      final settings = await AppSettings.load();
      await settings.setSeasonMode(SeasonMode.off);
      await settings.resetAppearance();
      expect(settings.seasonMode, SeasonMode.auto);
    });
  });

  group('фон на экране', () {
    Widget host({
      required SeasonLook? look,
      bool motion = true,
      bool reduceMotion = false,
    }) =>
        MaterialApp(
          home: MediaQuery(
            data: MediaQueryData(disableAnimations: reduceMotion),
            child: Scaffold(
              body: SeasonalBackdrop(
                look: look,
                motion: motion,
                child: const Center(child: Text('расписание')),
              ),
            ),
          ),
        );

    for (final season in Season.values) {
      testWidgets('${season.name}: частицы летят без ошибок', (tester) async {
        await tester.pumpWidget(host(look: SeasonLook(season: season)));
        for (var i = 0; i < 30; i++) {
          await tester.pump(const Duration(milliseconds: 16));
        }
        expect(tester.takeException(), isNull);
        expect(find.text('расписание'), findsOneWidget);
      });
    }

    testWidgets('«Удалить анимации» в системе — таймер не крутится', (tester) async {
      await tester.pumpWidget(host(
        look: const SeasonLook(season: Season.autumn),
        reduceMotion: true,
      ));
      await tester.pump();
      expect(tester.binding.hasScheduledFrame, isFalse,
          reason: 'кадры не должны идти сами по себе — это батарея');
    });

    testWidgets('движение выключено — таймер не крутится', (tester) async {
      await tester.pumpWidget(host(
        look: const SeasonLook(season: Season.winter),
        motion: false,
      ));
      await tester.pump();
      expect(tester.binding.hasScheduledFrame, isFalse);
    });

    testWidgets('оформление выключено — только содержимое', (tester) async {
      await tester.pumpWidget(host(look: null));
      await tester.pump();
      expect(find.text('расписание'), findsOneWidget);
      expect(tester.binding.hasScheduledFrame, isFalse);
    });

    testWidgets('гирлянда с поздравлением рисуется', (tester) async {
      await tester.pumpWidget(const MaterialApp(
        home: Scaffold(
          body: FestiveGarland(greeting: 'С Новым годом!', motion: true),
        ),
      ));
      for (var i = 0; i < 10; i++) {
        await tester.pump(const Duration(milliseconds: 16));
      }
      expect(find.text('С Новым годом!'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  });
}
