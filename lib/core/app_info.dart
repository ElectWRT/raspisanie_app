/// Сведения о приложении, показываемые на экране «О приложении».
class AppInfo {
  const AppInfo._();

  /// Должна совпадать с `version:` в pubspec.yaml.
  /// За этим следит тест `test/app_info_test.dart`.
  static const version = '1.5.0';

  static const repositoryUrl = 'https://github.com/ElectWRT/raspisanie_app';

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
