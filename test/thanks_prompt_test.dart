import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:raspisanie_app/core/app_info.dart';
import 'package:raspisanie_app/core/settings/app_settings.dart';
import 'package:raspisanie_app/features/settings/domain/thanks_prompt.dart';
import 'package:raspisanie_app/features/settings/presentation/widgets/thanks_dialog.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  final now = DateTime(2026, 9, 22, 12);

  group('когда показывать окно благодарности', () {
    test('не на первых запусках', () {
      for (var launch = 1; launch < thanksFirstLaunch; launch++) {
        expect(
          shouldShowThanks(launchCount: launch, lastShown: null, now: now),
          isFalse,
          reason: 'запуск $launch — рано',
        );
      }
    });

    test('впервые — на пятом запуске', () {
      expect(
        shouldShowThanks(launchCount: 5, lastShown: null, now: now),
        isTrue,
      );
    });

    test('после показа — не раньше чем через 30 дней', () {
      final shown = now.subtract(const Duration(days: 29));
      expect(
        shouldShowThanks(launchCount: 40, lastShown: shown, now: now),
        isFalse,
      );
      expect(
        shouldShowThanks(
          launchCount: 40,
          lastShown: now.subtract(const Duration(days: 30)),
          now: now,
        ),
        isTrue,
      );
    });
  });

  group('счётчик запусков в настройках', () {
    test('считает запуски и помнит дату показа', () async {
      SharedPreferences.setMockInitialValues({});
      final settings = await AppSettings.load();

      await settings.recordLaunch();
      await settings.recordLaunch();
      await settings.setThanksShownAt(now);

      expect(settings.launchCount, 2);
      expect(settings.thanksShownAt, now);
    });

    test('счётчик не попадает в резервную копию', () async {
      SharedPreferences.setMockInitialValues({});
      final settings = await AppSettings.load();
      await settings.recordLaunch();

      final backup = settings.exportForBackup();

      expect(backup.keys, isNot(contains('launchCount')));
      expect(backup.keys, isNot(contains('thanksShownAt')));
    });
  });

  group('ссылки', () {
    test('новый issue открывается с заготовкой и версией приложения', () {
      final uri = Uri.parse(AppInfo.newIssueUrl);

      expect(uri.host, 'github.com');
      expect(uri.path, '/ElectWRT/raspisanie_app/issues/new');
      expect(uri.queryParameters['body'], contains('Версия приложения: '
          '${AppInfo.version}'));
    });

    test('поделиться отправляет ссылку на последний релиз', () {
      expect(AppInfo.shareText, contains(AppInfo.latestReleaseUrl));
      expect(AppInfo.latestReleaseUrl, endsWith('/releases/latest'));
    });
  });

  testWidgets('окно показывает текст и три кнопки', (tester) async {
    await tester.pumpWidget(MaterialApp(
      home: Builder(
        builder: (context) => Scaffold(
          body: TextButton(
            onPressed: () => showThanksDialog(context),
            child: const Text('открыть'),
          ),
        ),
      ),
    ));

    await tester.tap(find.text('открыть'));
    await tester.pumpAndSettle();

    expect(find.text('Спасибо, что пользуетесь приложением!'), findsOneWidget);
    expect(find.text('Нашёл ошибку'), findsOneWidget);
    expect(find.text('Поделиться'), findsOneWidget);
    expect(find.text('Оставить звезду на GitHub'), findsOneWidget);

    await tester.tap(find.text('Закрыть'));
    await tester.pumpAndSettle();
    expect(find.text('Нашёл ошибку'), findsNothing);
  });
}
