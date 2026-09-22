/// Сведения о приложении, показываемые на экране «О приложении».
class AppInfo {
  const AppInfo._();

  /// Должна совпадать с `version:` в pubspec.yaml.
  /// За этим следит тест `test/app_info_test.dart`.
  static const version = '1.7.0';

  static const repositoryUrl = 'https://github.com/ElectWRT/raspisanie_app';

  /// Страница последнего релиза — её и отправляем друзьям: там APK
  /// и инструкция, а знать про Obtainium заранее не нужно.
  static const latestReleaseUrl = '$repositoryUrl/releases/latest';

  /// Новый issue с заготовкой текста и версией приложения — чтобы
  /// в сообщении об ошибке сразу было понятно, о какой сборке речь.
  static String get newIssueUrl => Uri.parse('$repositoryUrl/issues/new')
      .replace(queryParameters: {
        'body': '**Что случилось:**\n\n\n'
            '**Как повторить:**\n1. \n\n'
            '**Что ожидалось:**\n\n\n'
            '---\nВерсия приложения: $version',
      })
      .toString();

  /// Текст, который уходит через «Поделиться».
  static const shareText =
      '«Расписание» — расписание пар с автоматическими заменами, учётом '
      'пропусков и напоминаниями. Бесплатно, без рекламы и регистрации.\n'
      'Скачать: $latestReleaseUrl';

  /// Добавляет приложение в Obtainium — тот следит за релизами на GitHub
  /// и сам ставит обновления.
  ///
  /// Через страницу-редирект, а не напрямую `obtainium://`: браузеры не
  /// всегда открывают нестандартные схемы по ссылке, а редирект в таком
  /// случае показывает кнопку и предлагает скачать Obtainium, если его нет.
  static const obtainiumUrl =
      'https://apps.obtainium.imranr.dev/redirect?r=obtainium://add/'
      '$repositoryUrl';

  static const authorName = 'ElectWRT';
  static const authorUrl = 'https://github.com/ElectWRT';

  static const organizationName = 'TheSkippersTeam';
  static const organizationUrl = 'https://github.com/TheSkippersTeam';

  /// Короткая формулировка для экрана «О приложении». Полный текст —
  /// в файле LICENSE в репозитории.
  static const licenseNote =
      'Коммерческое использование запрещено. Приложение можно свободно '
      'использовать и распространять бесплатно, продавать его или брать '
      'плату за доступ нельзя.';
}
