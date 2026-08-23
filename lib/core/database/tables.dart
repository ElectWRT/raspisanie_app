import 'package:drift/drift.dart';

/// Чётность недели, к которой привязана пара базового расписания.
enum WeekType {
  /// Каждую неделю.
  every,

  /// Только числитель (верхняя неделя).
  numerator,

  /// Только знаменатель (нижняя неделя).
  denominator,
}

/// Базовое (постоянное) расписание. Заполняется импортом Markdown-файла.
class Lessons extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get groupName => text()();

  /// 1 = понедельник ... 7 = воскресенье (как в [DateTime.weekday]).
  IntColumn get dayOfWeek => integer()();
  IntColumn get pairNumber => integer()();
  IntColumn get weekType => intEnum<WeekType>().withDefault(const Constant(0))();

  /// Номер подгруппы ("1", "2"). null — пара для всей группы.
  TextColumn get subgroup => text().nullable()();
  TextColumn get subject => text()();
  TextColumn get teacher => text().withDefault(const Constant(''))();
  TextColumn get room => text().withDefault(const Constant(''))();
}

/// Замены на конкретную дату. Перекрывают [Lessons] на эту дату.
class Substitutions extends Table {
  IntColumn get id => integer().autoIncrement()();

  /// Всегда полночь локального времени — ключ дня.
  DateTimeColumn get date => dateTime()();
  TextColumn get groupName => text()();
  IntColumn get pairNumber => integer()();
  TextColumn get subgroup => text().nullable()();
  TextColumn get subject => text().withDefault(const Constant(''))();
  TextColumn get teacher => text().withDefault(const Constant(''))();
  TextColumn get room => text().withDefault(const Constant(''))();

  /// true — пара снята («группа гуляет»), предмет показывать не нужно.
  BoolColumn get isCancelled => boolean().withDefault(const Constant(false))();

  /// Произвольная приписка из документа («самостоятельно», «дист.» и т.п.).
  TextColumn get note => text().nullable()();

  @override
  List<Set<Column>> get uniqueKeys => [
        {date, groupName, pairNumber, subgroup},
      ];
}

/// Key-value хранилище для служебных данных: время последнего обновления,
/// хеш последнего разобранного документа, расписание звонков.
class AppMeta extends Table {
  TextColumn get key => text()();
  TextColumn get value => text()();

  @override
  Set<Column> get primaryKey => {key};
}
