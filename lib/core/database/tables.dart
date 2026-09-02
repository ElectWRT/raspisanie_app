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

/// Насколько обязательно сделать задание.
enum HomeworkPriority {
  /// Не критично — можно и пропустить.
  optional,

  /// Желательно сделать.
  normal,

  /// Обязательно: спросят, влияет на оценку.
  required,
}

/// Был ли студент на паре.
enum AttendanceStatus {
  /// Был.
  present,

  /// Пропустил.
  absent,

  /// Пропустил по уважительной причине — в лимит пропусков не идёт.
  excused,
}

/// Ключ пары внутри дня: номер и подгруппа. У одной пары бывает две
/// записи — по одной на подгруппу, — поэтому номера мало.
String attendanceKey(int pairNumber, String? subgroup) =>
    '$pairNumber:${subgroup ?? ''}';

/// Отметки посещения по парам.
///
/// Предмет хранится строкой рядом с отметкой, а не ссылкой на [Lessons]:
/// расписание переимпортируют целиком, и статистика за прошлые месяцы
/// не должна от этого рассыпаться.
class Attendances extends Table {
  IntColumn get id => integer().autoIncrement()();

  /// Всегда полночь локального времени — ключ дня.
  DateTimeColumn get date => dateTime()();
  TextColumn get groupName => text()();
  IntColumn get pairNumber => integer()();

  /// Подгруппа: «1», «2» или пустая строка для пары всей группы.
  ///
  /// Пустая строка, а не NULL: колонка входит в уникальный ключ, а SQLite
  /// считает любые два NULL разными значениями — с nullable-колонкой
  /// повторная отметка пары без подгруппы не находила бы конфликт
  /// и создавала вторую строку вместо перезаписи первой.
  TextColumn get subgroup => text().withDefault(const Constant(''))();

  /// Предмет на момент отметки — уже с учётом замены, если она была.
  TextColumn get subject => text()();
  IntColumn get status => intEnum<AttendanceStatus>()();
  DateTimeColumn get markedAt => dateTime().withDefault(currentDateAndTime)();

  @override
  List<Set<Column>> get uniqueKeys => [
        {date, groupName, pairNumber, subgroup},
      ];
}

/// Профиль предмета: насколько дорого его пропускать и что брать на пару.
class SubjectProfiles extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get groupName => text()();

  /// Название в нижнем регистре — в расписании и заменах предмет пишут
  /// по-разному, а профиль должен находиться в обоих случаях.
  TextColumn get subjectKey => text()();

  /// Название так, как его показывать.
  TextColumn get subject => text()();

  /// Профильный предмет: пропуск считается строже.
  BoolColumn get isMajor => boolean().withDefault(const Constant(false))();

  /// Что взять на пару — по одному пункту в строке.
  TextColumn get items => text().withDefault(const Constant(''))();
  TextColumn get note => text().nullable()();

  @override
  List<Set<Column>> get uniqueKeys => [
        {groupName, subjectKey},
      ];
}

/// Домашние задания. Привязаны к предмету и дате сдачи, а не к конкретной
/// паре: пару могут перенести заменой, а сдавать всё равно к этому дню.
class Homeworks extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get groupName => text()();
  TextColumn get subject => text()();

  /// Что задали.
  TextColumn get description => text()();

  /// День сдачи — всегда полночь.
  DateTimeColumn get dueDate => dateTime()();
  IntColumn get priority =>
      intEnum<HomeworkPriority>().withDefault(const Constant(1))();
  BoolColumn get isDone => boolean().withDefault(const Constant(false))();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
}
