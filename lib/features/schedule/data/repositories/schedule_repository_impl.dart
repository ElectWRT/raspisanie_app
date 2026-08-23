import 'dart:convert';

import 'package:dartz/dartz.dart';
import 'package:rxdart/rxdart.dart';

import '../../../../core/database/database.dart';
import '../../../../core/error/exceptions.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/utils/week_utils.dart';
import '../../domain/entities/schedule_slot.dart';
import '../../domain/repositories/schedule_repository.dart';
import '../../domain/schedule_merger.dart';
import '../datasources/markdown_schedule_parser.dart';

class ScheduleRepositoryImpl implements ScheduleRepository {
  ScheduleRepositoryImpl({required this.database, required this.parser});

  final AppDatabase database;
  final MarkdownScheduleParser parser;

  static const _bellsKey = 'bells';

  @override
  Stream<DaySchedule> watchDay({
    required String groupName,
    required DateTime date,
    String? subgroup,
    bool invertWeekParity = false,
  }) {
    final day = WeekUtils.dayKey(date);
    final weekType = WeekUtils.weekTypeFor(day, invert: invertWeekParity);

    return Rx.combineLatest2(
      database.watchLessons(
        groupName: groupName,
        dayOfWeek: day.weekday,
        weekType: weekType,
      ),
      database.watchSubstitutionsFor(groupName: groupName, date: day),
      (List<Lesson> lessons, List<Substitution> subs) => mergeDaySchedule(
        date: day,
        groupName: groupName,
        weekType: weekType,
        lessons: lessons,
        substitutions: subs,
        subgroupFilter: subgroup,
      ),
    );
  }

  @override
  Stream<List<String>> watchGroups() => database.watchGroupNames();

  @override
  Future<bool> get hasSchedule async => (await database.countLessons()) > 0;

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
      if (result.bells.isNotEmpty) {
        await database.setMeta(
          _bellsKey,
          jsonEncode(result.bells.map((b) => b.toJson()).toList()),
        );
      }
      return const Right(unit);
    } catch (e) {
      return Left(CacheFailure('Не удалось сохранить расписание: $e'));
    }
  }

  @override
  Future<List<BellTime>> getBells() async {
    final raw = await database.getMeta(_bellsKey);
    if (raw == null) return const [];
    try {
      final list = jsonDecode(raw) as List<dynamic>;
      return list
          .map((e) => BellTime.fromJson(e as Map<String, dynamic>))
          .toList();
    } catch (_) {
      return const [];
    }
  }

  @override
  Future<void> clearSchedule() => database.clearLessons();
}
