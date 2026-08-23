import '../database/tables.dart';

/// Утилиты для работы с учебной неделей.
class WeekUtils {
  const WeekUtils._();

  static const List<String> dayNames = [
    'Понедельник',
    'Вторник',
    'Среда',
    'Четверг',
    'Пятница',
    'Суббота',
    'Воскресенье',
  ];

  static const List<String> dayNamesShort = [
    'Пн',
    'Вт',
    'Ср',
    'Чт',
    'Пт',
    'Сб',
    'Вс',
  ];

  static const List<String> monthsGenitive = [
    'января',
    'февраля',
    'марта',
    'апреля',
    'мая',
    'июня',
    'июля',
    'августа',
    'сентября',
    'октября',
    'ноября',
    'декабря',
  ];

  /// Название дня недели по номеру 1..7.
  static String dayName(int dayOfWeek) => dayNames[(dayOfWeek - 1) % 7];

  static String dayNameShort(int dayOfWeek) => dayNamesShort[(dayOfWeek - 1) % 7];

  /// «5 сентября, пятница»
  static String formatFullDate(DateTime date) =>
      '${date.day} ${monthsGenitive[date.month - 1]}, '
      '${dayName(date.weekday).toLowerCase()}';

  /// Полночь переданной даты — канонический ключ дня в базе.
  static DateTime dayKey(DateTime date) =>
      DateTime(date.year, date.month, date.day);

  /// Номер ISO-недели (1..53).
  static int isoWeekNumber(DateTime date) {
    final day = DateTime.utc(date.year, date.month, date.day);
    // Четверг той же недели однозначно определяет год недели.
    final thursday = day.add(Duration(days: 4 - day.weekday));
    final firstJanuary = DateTime.utc(thursday.year, 1, 1);
    final diff = thursday.difference(firstJanuary).inDays;
    return (diff / 7).floor() + 1;
  }

  /// Числитель или знаменатель для даты.
  ///
  /// [invert] переключает, какая неделя считается числителем — в разных
  /// заведениях отсчёт разный, поэтому это настройка, а не константа.
  static WeekType weekTypeFor(DateTime date, {bool invert = false}) {
    final isOdd = isoWeekNumber(date).isOdd;
    final numerator = invert ? !isOdd : isOdd;
    return numerator ? WeekType.numerator : WeekType.denominator;
  }

  static String weekTypeLabel(WeekType type) => switch (type) {
        WeekType.every => 'Каждую неделю',
        WeekType.numerator => 'Числитель',
        WeekType.denominator => 'Знаменатель',
      };

  static String weekTypeLabelShort(WeekType type) => switch (type) {
        WeekType.every => '',
        WeekType.numerator => 'числ.',
        WeekType.denominator => 'знам.',
      };

  /// Понедельник недели, содержащей [date].
  static DateTime startOfWeek(DateTime date) {
    final day = dayKey(date);
    return day.subtract(Duration(days: day.weekday - 1));
  }
}
