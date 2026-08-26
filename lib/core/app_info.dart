/// Сведения о приложении, показываемые на экране «О приложении».
class AppInfo {
  const AppInfo._();

  /// Должна совпадать с `version:` в pubspec.yaml.
  /// За этим следит тест `test/app_info_test.dart`.
  static const version = '1.1.1';

  static const repositoryUrl = 'https://github.com/ElectWRT/raspisanie_app';
}
