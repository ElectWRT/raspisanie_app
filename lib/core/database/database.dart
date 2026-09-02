import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

import 'tables.dart';

export 'tables.dart';

part 'database.g.dart';

@DriftDatabase(tables: [
  Lessons,
  Substitutions,
  AppMeta,
  Homeworks,
  Attendances,
  SubjectProfiles,
])
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  /// Конструктор для тестов — база в памяти.
  AppDatabase.forTesting(super.e);

  @override
  int get schemaVersion => 3;

  @override
  MigrationStrategy get migration => MigrationStrategy(
        onCreate: (m) => m.createAll(),
        onUpgrade: (m, from, to) async {
          // v2: домашние задания. У существующих установок база уже с
          // расписанием — создаём только новую таблицу, ничего не трогая.
          if (from < 2) {
            await m.createTable(homeworks);
          }
          // v3: учёт пропусков и профили предметов. Так же — только новые
          // таблицы, расписание и замены не трогаем.
          if (from < 3) {
            await m.createTable(attendances);
            await m.createTable(subjectProfiles);
          }
        },
      );

  // ---------------------------------------------------------------- Lessons

  /// Пары базового расписания на конкретный день недели.
  /// Возвращает пары, помеченные [WeekType.every], и пары нужной чётности.
  Stream<List<Lesson>> watchLessons({
    required String groupName,
    required int dayOfWeek,
    required WeekType weekType,
  }) {
    final query = select(lessons)
      ..where((t) =>
          t.groupName.equals(groupName) &
          t.dayOfWeek.equals(dayOfWeek) &
          (t.weekType.equalsValue(WeekType.every) |
              t.weekType.equalsValue(weekType)))
      ..orderBy([
        (t) => OrderingTerm(expression: t.pairNumber),
        (t) => OrderingTerm(expression: t.subgroup),
      ]);
    return query.watch();
  }

  /// Все группы, для которых загружено базовое расписание.
  Future<List<String>> getGroupNames() async {
    final query = selectOnly(lessons, distinct: true)
      ..addColumns([lessons.groupName])
      ..orderBy([OrderingTerm(expression: lessons.groupName)]);
    final rows = await query.get();
    return rows.map((r) => r.read(lessons.groupName)!).toList();
  }

  Stream<List<String>> watchGroupNames() {
    final query = selectOnly(lessons, distinct: true)
      ..addColumns([lessons.groupName])
      ..orderBy([OrderingTerm(expression: lessons.groupName)]);
    return query.watch().map(
          (rows) => rows.map((r) => r.read(lessons.groupName)!).toList(),
        );
  }

  /// Названия предметов группы — подсказки при добавлении домашки.
  Future<List<String>> getSubjectNames(String groupName) async {
    final query = selectOnly(lessons, distinct: true)
      ..addColumns([lessons.subject])
      ..where(lessons.groupName.equals(groupName))
      ..orderBy([OrderingTerm(expression: lessons.subject)]);
    final rows = await query.get();
    return rows.map((r) => r.read(lessons.subject)!).toList();
  }

  Future<int> countLessons() async {
    final query = selectOnly(lessons)..addColumns([lessons.id.count()]);
    final row = await query.getSingle();
    return row.read(lessons.id.count()) ?? 0;
  }

  /// Полностью заменяет базовое расписание для перечисленных групп.
  /// Пары групп, которых нет в [items], не трогаются — это позволяет
  /// импортировать файлы по одной группе, не стирая остальные.
  Future<void> replaceLessons(List<LessonsCompanion> items) async {
    final groups = items.map((e) => e.groupName.value).toSet();
    await transaction(() async {
      for (final group in groups) {
        await (delete(lessons)..where((t) => t.groupName.equals(group))).go();
      }
      await batch((batch) => batch.insertAll(lessons, items));
    });
  }

  Future<void> clearLessons() => delete(lessons).go();

  // ---------------------------------------------------------- Substitutions

  Stream<List<Substitution>> watchSubstitutionsFor({
    required String groupName,
    required DateTime date,
  }) {
    final day = DateTime(date.year, date.month, date.day);
    final query = select(substitutions)
      ..where((t) => t.groupName.equals(groupName) & t.date.equals(day))
      ..orderBy([(t) => OrderingTerm(expression: t.pairNumber)]);
    return query.watch();
  }

  /// Все замены на дату — для экрана «замены по всем группам».
  Stream<List<Substitution>> watchSubstitutionsOnDate(DateTime date) {
    final day = DateTime(date.year, date.month, date.day);
    final query = select(substitutions)
      ..where((t) => t.date.equals(day))
      ..orderBy([
        (t) => OrderingTerm(expression: t.groupName),
        (t) => OrderingTerm(expression: t.pairNumber),
      ]);
    return query.watch();
  }

  /// Даты в промежутке, на которые у группы есть замены.
  /// Нужны, чтобы помечать дни в переключателе недели.
  Stream<Set<DateTime>> watchSubstitutionDatesBetween({
    required String groupName,
    required DateTime from,
    required DateTime to,
  }) {
    final query = selectOnly(substitutions, distinct: true)
      ..addColumns([substitutions.date])
      ..where(substitutions.groupName.equals(groupName) &
          substitutions.date.isBiggerOrEqualValue(from) &
          substitutions.date.isSmallerOrEqualValue(to));

    return query.watch().map(
          (rows) => rows.map((r) => r.read(substitutions.date)!).toSet(),
        );
  }

  Future<List<Substitution>> getSubstitutionsOnDate(DateTime date) {
    final day = DateTime(date.year, date.month, date.day);
    return (select(substitutions)..where((t) => t.date.equals(day))).get();
  }

  /// Перезаписывает замены на конкретную дату — старые за этот день удаляются.
  /// Замены за другие дни сохраняются (история + расписание на завтра).
  Future<void> replaceSubstitutionsForDate(
    DateTime date,
    List<SubstitutionsCompanion> items,
  ) async {
    final day = DateTime(date.year, date.month, date.day);
    await transaction(() async {
      await (delete(substitutions)..where((t) => t.date.equals(day))).go();
      await batch(
        (batch) => batch.insertAll(
          substitutions,
          items,
          mode: InsertMode.insertOrReplace,
        ),
      );
    });
  }

  /// Удаляет замены старше [days] дней, чтобы база не росла бесконечно.
  Future<int> purgeOldSubstitutions({int days = 30}) {
    final cutoff = DateTime.now().subtract(Duration(days: days));
    final day = DateTime(cutoff.year, cutoff.month, cutoff.day);
    return (delete(substitutions)..where((t) => t.date.isSmallerThanValue(day)))
        .go();
  }

  Future<void> clearSubstitutions() => delete(substitutions).go();

  // -------------------------------------------------------------- Homeworks

  /// Незакрытые задания группы, ближайшие по сроку — первыми.
  Stream<List<Homework>> watchHomeworks({
    required String groupName,
    bool includeDone = false,
  }) {
    final query = select(homeworks)
      ..where((t) => includeDone
          ? t.groupName.equals(groupName)
          : t.groupName.equals(groupName) & t.isDone.equals(false))
      ..orderBy([
        (t) => OrderingTerm(expression: t.dueDate),
        (t) => OrderingTerm(expression: t.priority, mode: OrderingMode.desc),
      ]);
    return query.watch();
  }

  /// Задания, по которым ещё нужно напомнить.
  Future<List<Homework>> getPendingHomeworks(String groupName) {
    return (select(homeworks)
          ..where((t) => t.groupName.equals(groupName) & t.isDone.equals(false)))
        .get();
  }

  /// Сколько незакрытых заданий по предмету на ближайшие дни —
  /// для значка на карточке пары.
  Stream<Map<String, int>> watchHomeworkCountsBySubject(String groupName) {
    final query = select(homeworks)
      ..where((t) => t.groupName.equals(groupName) & t.isDone.equals(false));

    return query.watch().map((rows) {
      final counts = <String, int>{};
      for (final row in rows) {
        final key = row.subject.toLowerCase();
        counts[key] = (counts[key] ?? 0) + 1;
      }
      return counts;
    });
  }

  Future<int> insertHomework(HomeworksCompanion item) =>
      into(homeworks).insert(item);

  Future<bool> updateHomework(Homework item) =>
      update(homeworks).replace(item);

  Future<void> setHomeworkDone(int id, bool done) =>
      (update(homeworks)..where((t) => t.id.equals(id)))
          .write(HomeworksCompanion(isDone: Value(done)));

  Future<int> deleteHomework(int id) =>
      (delete(homeworks)..where((t) => t.id.equals(id))).go();

  /// Убирает выполненные задания, у которых срок давно прошёл.
  Future<int> purgeOldHomeworks({int days = 30}) {
    final cutoff = DateTime.now().subtract(Duration(days: days));
    return (delete(homeworks)
          ..where((t) =>
              t.isDone.equals(true) &
              t.dueDate.isSmallerThanValue(
                DateTime(cutoff.year, cutoff.month, cutoff.day),
              )))
        .go();
  }

  // ------------------------------------------------------------ Attendances

  /// Отметки за день. Ключ — «номер пары:подгруппа», как в [attendanceKey].
  Stream<Map<String, Attendance>> watchAttendanceForDay({
    required String groupName,
    required DateTime date,
  }) {
    final query = select(attendances)
      ..where((t) => t.groupName.equals(groupName) & t.date.equals(date));
    return query.watch().map((rows) => {
          for (final row in rows)
            attendanceKey(row.pairNumber, row.subgroup): row,
        });
  }

  /// Все отметки группы — основа статистики.
  Stream<List<Attendance>> watchAttendance(String groupName) =>
      (select(attendances)
            ..where((t) => t.groupName.equals(groupName))
            ..orderBy([(t) => OrderingTerm(expression: t.date)]))
          .watch();

  Future<List<Attendance>> getAttendance(String groupName) =>
      (select(attendances)..where((t) => t.groupName.equals(groupName))).get();

  /// Ставит или переставляет отметку. Повторный вызов с тем же ключом
  /// перезаписывает статус, а не плодит строки.
  Future<void> setAttendance({
    required DateTime date,
    required String groupName,
    required int pairNumber,
    String? subgroup,
    required String subject,
    required AttendanceStatus status,
  }) =>
      into(attendances).insert(
        AttendancesCompanion.insert(
          date: date,
          groupName: groupName,
          pairNumber: pairNumber,
          subgroup: Value(subgroup ?? ''),
          subject: subject,
          status: status,
          markedAt: Value(DateTime.now()),
        ),
        // Цель конфликта задаём явно: по умолчанию drift целится
        // в первичный ключ, то есть в автоинкрементный id, и повторная
        // отметка той же пары падала бы на уникальном ключе.
        onConflict: DoUpdate(
          (_) => AttendancesCompanion(
            subject: Value(subject),
            status: Value(status),
            markedAt: Value(DateTime.now()),
          ),
          target: [
            attendances.date,
            attendances.groupName,
            attendances.pairNumber,
            attendances.subgroup,
          ],
        ),
      );

  /// Снимает отметку — пара снова считается неотмеченной.
  Future<int> clearAttendance({
    required DateTime date,
    required String groupName,
    required int pairNumber,
    String? subgroup,
  }) {
    return (delete(attendances)
          ..where((t) =>
              t.date.equals(date) &
              t.groupName.equals(groupName) &
              t.pairNumber.equals(pairNumber) &
              t.subgroup.equals(subgroup ?? '')))
        .go();
  }

  /// Номера пар, отмеченных за день, — чтобы понять, что осталось.
  Future<Set<String>> markedKeysForDay({
    required String groupName,
    required DateTime date,
  }) async {
    final rows = await (select(attendances)
          ..where((t) => t.groupName.equals(groupName) & t.date.equals(date)))
        .get();
    return {
      for (final row in rows) attendanceKey(row.pairNumber, row.subgroup),
    };
  }

  // -------------------------------------------------------- SubjectProfiles

  Stream<List<SubjectProfile>> watchSubjectProfiles(String groupName) =>
      (select(subjectProfiles)
            ..where((t) => t.groupName.equals(groupName))
            ..orderBy([(t) => OrderingTerm(expression: t.subject)]))
          .watch();

  Future<List<SubjectProfile>> getSubjectProfiles(String groupName) =>
      (select(subjectProfiles)..where((t) => t.groupName.equals(groupName)))
          .get();

  Future<void> upsertSubjectProfile({
    required String groupName,
    required String subject,
    required bool isMajor,
    required String items,
    String? note,
  }) =>
      into(subjectProfiles).insert(
        SubjectProfilesCompanion.insert(
          groupName: groupName,
          subjectKey: subject.toLowerCase().trim(),
          subject: subject.trim(),
          isMajor: Value(isMajor),
          items: Value(items),
          note: Value(note),
        ),
        onConflict: DoUpdate(
          (_) => SubjectProfilesCompanion(
            subject: Value(subject.trim()),
            isMajor: Value(isMajor),
            items: Value(items),
            note: Value(note),
          ),
          target: [subjectProfiles.groupName, subjectProfiles.subjectKey],
        ),
      );

  Future<int> deleteSubjectProfile(int id) =>
      (delete(subjectProfiles)..where((t) => t.id.equals(id))).go();

  // ---------------------------------------------------------------- Backup

  /// Всё, что относится к расписанию: базовые пары, замены, домашка и
  /// служебные записи (в том числе звонки — они лежат в AppMeta). Настройки
  /// (SharedPreferences) сюда не входят — их добавляет BackupService.
  Future<Map<String, dynamic>> exportAllTables() async {
    final lessonRows = await select(lessons).get();
    final substitutionRows = await select(substitutions).get();
    final homeworkRows = await select(homeworks).get();
    final metaRows = await select(appMeta).get();
    final attendanceRows = await select(attendances).get();
    final profileRows = await select(subjectProfiles).get();

    return {
      'lessons': lessonRows.map((r) => r.toJson()).toList(),
      'substitutions': substitutionRows.map((r) => r.toJson()).toList(),
      'homeworks': homeworkRows.map((r) => r.toJson()).toList(),
      'appMeta': metaRows.map((r) => r.toJson()).toList(),
      'attendances': attendanceRows.map((r) => r.toJson()).toList(),
      'subjectProfiles': profileRows.map((r) => r.toJson()).toList(),
    };
  }

  /// Заменяет все данные на те, что в резервной копии. Текущие пары,
  /// замены, домашка и звонки стираются безвозвратно.
  Future<void> importAllTables(Map<String, dynamic> data) async {
    await transaction(() async {
      await delete(lessons).go();
      await delete(substitutions).go();
      await delete(homeworks).go();
      await delete(appMeta).go();
      await delete(attendances).go();
      await delete(subjectProfiles).go();

      final lessonRows = _decodeList(data['lessons'], Lesson.fromJson);
      if (lessonRows.isNotEmpty) {
        await batch((b) => b.insertAll(
              lessons,
              lessonRows.map((r) => r.toCompanion(true)),
            ));
      }

      final substitutionRows =
          _decodeList(data['substitutions'], Substitution.fromJson);
      if (substitutionRows.isNotEmpty) {
        await batch((b) => b.insertAll(
              substitutions,
              substitutionRows.map((r) => r.toCompanion(true)),
            ));
      }

      final homeworkRows = _decodeList(data['homeworks'], Homework.fromJson);
      if (homeworkRows.isNotEmpty) {
        await batch((b) => b.insertAll(
              homeworks,
              homeworkRows.map((r) => r.toCompanion(true)),
            ));
      }

      final metaRows = _decodeList(data['appMeta'], AppMetaData.fromJson);
      if (metaRows.isNotEmpty) {
        await batch((b) => b.insertAll(
              appMeta,
              metaRows.map((r) => r.toCompanion(true)),
            ));
      }

      // Копии, снятые до появления учёта пропусков, этих ключей не имеют —
      // _decodeList вернёт пустой список, и таблицы просто останутся пустыми.
      final attendanceRows =
          _decodeList(data['attendances'], Attendance.fromJson);
      if (attendanceRows.isNotEmpty) {
        await batch((b) => b.insertAll(
              attendances,
              attendanceRows.map((r) => r.toCompanion(true)),
            ));
      }

      final profileRows =
          _decodeList(data['subjectProfiles'], SubjectProfile.fromJson);
      if (profileRows.isNotEmpty) {
        await batch((b) => b.insertAll(
              subjectProfiles,
              profileRows.map((r) => r.toCompanion(true)),
            ));
      }
    });
  }

  static List<T> _decodeList<T>(
    dynamic raw,
    T Function(Map<String, dynamic>) fromJson,
  ) {
    final list = raw as List?;
    if (list == null) return const [];
    return list
        .map((e) => fromJson(Map<String, dynamic>.from(e as Map)))
        .toList();
  }

  // ---------------------------------------------------------------- AppMeta

  Future<String?> getMeta(String key) async {
    final row = await (select(appMeta)..where((t) => t.key.equals(key)))
        .getSingleOrNull();
    return row?.value;
  }

  Future<void> setMeta(String key, String value) => into(appMeta).insertOnConflictUpdate(
        AppMetaCompanion.insert(key: key, value: value),
      );

  Stream<String?> watchMeta(String key) =>
      (select(appMeta)..where((t) => t.key.equals(key)))
          .watchSingleOrNull()
          .map((row) => row?.value);
}

LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    final dbFolder = await getApplicationDocumentsDirectory();
    final file = File(p.join(dbFolder.path, 'raspisanie.sqlite'));

    // Намеренно НЕ createInBackground: на части устройств фоновый изолят
    // drift не поднимается — база молча не открывается, приложение висит
    // на экране загрузки без единого исключения. Объёмы здесь крошечные
    // (сотни строк), так что выигрыш от отдельного изолята не стоит риска.
    return NativeDatabase(file);
  });
}
