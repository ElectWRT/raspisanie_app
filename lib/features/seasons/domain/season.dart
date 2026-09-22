/// Время года — от него зависят фон главного экрана и то, что по нему летит.
enum Season { autumn, winter, spring, summer }

/// Что выбрал пользователь: следовать календарю, закрепить один сезон
/// или выключить оформление совсем.
enum SeasonMode { auto, autumn, winter, spring, summer, off }

extension SeasonModeLabel on SeasonMode {
  String get label => switch (this) {
        SeasonMode.auto => 'По календарю',
        SeasonMode.autumn => 'Осень',
        SeasonMode.winter => 'Зима',
        SeasonMode.spring => 'Весна',
        SeasonMode.summer => 'Лето',
        SeasonMode.off => 'Выключено',
      };
}

/// Сезон по календарю: осень — сентябрь–ноябрь, зима — декабрь–февраль,
/// весна — март–май, лето — июнь–август.
Season seasonFor(DateTime date) => switch (date.month) {
      12 || 1 || 2 => Season.winter,
      3 || 4 || 5 => Season.spring,
      6 || 7 || 8 => Season.summer,
      _ => Season.autumn,
    };

/// Новогодние каникулы — с 20 декабря по 10 января включительно.
bool isNewYearPeriod(DateTime date) =>
    (date.month == 12 && date.day >= 20) ||
    (date.month == 1 && date.day <= 10);

/// Итог: как оформить экран прямо сейчас.
class SeasonLook {
  const SeasonLook({required this.season, this.festive = false});

  final Season season;

  /// Новогодние каникулы: гирлянда, поздравление и снег погуще.
  final bool festive;

  @override
  bool operator ==(Object other) =>
      other is SeasonLook && other.season == season && other.festive == festive;

  @override
  int get hashCode => Object.hash(season, festive);
}

/// Оформление на [now] с учётом выбора пользователя. null — выключено.
///
/// Праздник бывает только в режиме «по календарю» или «зима»: закрепивший
/// осень человек гирлянду в январе явно не просил.
SeasonLook? resolveSeasonLook(DateTime now, SeasonMode mode) {
  final festive = isNewYearPeriod(now);
  return switch (mode) {
    SeasonMode.off => null,
    SeasonMode.auto => SeasonLook(season: seasonFor(now), festive: festive),
    SeasonMode.winter => SeasonLook(season: Season.winter, festive: festive),
    SeasonMode.autumn => const SeasonLook(season: Season.autumn),
    SeasonMode.spring => const SeasonLook(season: Season.spring),
    SeasonMode.summer => const SeasonLook(season: Season.summer),
  };
}

/// Текст поздравления в праздничный период.
String festiveGreeting(DateTime now) =>
    now.month == 12 ? 'С наступающим Новым годом!' : 'С Новым годом!';
