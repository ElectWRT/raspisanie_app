import 'dart:convert';

import 'package:dartz/dartz.dart';
import 'package:rxdart/rxdart.dart';

import '../../../../core/database/database.dart';
import '../../../../core/error/exceptions.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/utils/week_utils.dart';
import '../../domain/entities/bell_schedule.dart';
import '../../domain/entities/schedule_slot.dart';
import '../../domain/repositories/schedule_repository.dart';
import '../../domain/joint_classes.dart';
import '../../domain/schedule_merger.dart';
import '../datasources/markdown_schedule_parser.dart';

class ScheduleRepositoryImpl implements ScheduleRepository {
  ScheduleRepositoryImpl({required this.database, required this.parser});

  final AppDatabase database;
  final MarkdownScheduleParser parser;

  static const _bellsKey = 'bell_schedules';

  /// Ключ из первой версии — один общий набор звонков.
  static const _legacyBellsKey = 'bells';

  @override
  Stream<DaySchedule> watchDay({
    required String groupName,
    required DateTime date,
    String? subgroup,
    bool invertWeekParity = false,
  }) {
    final day = WeekUtils.dayKey(date);
    final weekType = WeekUtils.weekTypeFor(day, invert: invertWeekParity);

    return Rx.combineLatest4(
      database.watchLessons(
        groupName: groupName,
        dayOfWeek: day.weekday,
        weekType: weekType,
      ),
      database.watchSubstitutionsFor(groupName: groupName, date: day),
      // Чужие пары — для поиска совмещённых. Замены приходят по всем
      // группам сразу: документ у завуча один на всех.
      database.watchLessonsForAllGroups(
        dayOfWeek: day.weekday,
        weekType: weekType,
      ),
      database.watchSubstitutionsOnDate(day),
      (
        List<Lesson> lessons,
        List<Substitution> subs,
        List<Lesson> allLessons,
        List<Substitution> allSubs,
      ) =>
          applyJointClasses(
        mergeDaySchedule(
          date: day,
          groupName: groupName,
          weekType: weekType,
          lessons: lessons,
          substitutions: subs,
          subgroupFilter: subgroup,
        ),
        lessons: allLessons,
        substitutions: allSubs,
      ),
    );
  }

  @override
  Stream<List<String>> watchGroups() => database.watchGroupNames();

  @override
  Stream<Set<int>> watchSubstitutionWeekdays({
    required String groupName,
    required DateTime weekStart,
  }) {
    final start = WeekUtils.dayKey(weekStart);
    return database
        .watchSubstitutionDatesBetween(
          groupName: groupName,
          from: start,
          to: start.add(const Duration(days: 6)),
        )
        .map((dates) => dates.map((d) => d.weekday).toSet());
  }

  @override
  Future<bool> get hasSchedule async => (await database.countLessons()) > 0;

  @override
  Future<List<String>> subjects(String groupName) =>
      database.getSubjectNames(groupName);

  @override
  Either<Failure, ScheduleImportResult> preview(String markdown) {
    try {
      return Right(parser.parse(markdown));
    } on ParsingException catch (e) {
      return Left(ParsingFailure(e.message));
    } catch (e) {
      return Left(ParsingFailure('Не удалось разобрать файл: $e'));
    }
  }

  @override
  Future<Either<Failure, Unit>> commitImport(ScheduleImportResult result) async {
    try {
      await database.replaceLessons(result.lessons);
      if (result.bellSchedules.isNotEmpty) {
        await saveBellSchedules(result.bellSchedules);
      }
      return const Right(unit);
    } catch (e) {
      return Left(CacheFailure('Не удалось сохранить расписание: $e'));
    }
  }

  @override
  Future<List<BellSchedule>> getBellSchedules() async {
    final raw = await database.getMeta(_bellsKey);
    if (raw != null) {
      try {
        final list = jsonDecode(raw) as List<dynamic>;
        return list
            .map((e) => BellSchedule.fromJson(e as Map<String, dynamic>))
            .toList();
      } catch (_) {
        return const [];
      }
    }
    return _migrateLegacyBells();
  }

  /// Переносит звонки из старого формата (один общий список) в новый.
  Future<List<BellSchedule>> _migrateLegacyBells() async {
    final raw = await database.getMeta(_legacyBellsKey);
    if (raw == null) return const [];

    try {
      final times = (jsonDecode(raw) as List<dynamic>)
          .map((e) => BellTime.fromJson(e as Map<String, dynamic>))
          .toList();
      if (times.isEmpty) return const [];

      final migrated = [BellSchedule(name: 'Основные', times: times)];
      await saveBellSchedules(migrated);
      return migrated;
    } catch (_) {
      return const [];
    }
  }

  @override
  Future<void> saveBellSchedules(List<BellSchedule> schedules) => database
      .setMeta(_bellsKey, jsonEncode(schedules.map((s) => s.toJson()).toList()));

  @override
  Future<void> clearSchedule() => database.clearLessons();
}
