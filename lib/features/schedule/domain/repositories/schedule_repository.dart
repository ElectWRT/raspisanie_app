import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../../data/datasources/markdown_schedule_parser.dart';
import '../entities/schedule_slot.dart';

abstract class ScheduleRepository {
  /// Расписание на день с уже наложенными заменами.
  Stream<DaySchedule> watchDay({
    required String groupName,
    required DateTime date,
    String? subgroup,
    bool invertWeekParity,
  });

  /// Список групп, для которых загружено базовое расписание.
  Stream<List<String>> watchGroups();

  Future<bool> get hasSchedule;

  /// Разбирает Markdown, но ничего не сохраняет — для экрана предпросмотра.
  Either<Failure, ScheduleImportResult> preview(String markdown);

  /// Сохраняет разобранное расписание, заменяя пары указанных групп.
  Future<Either<Failure, Unit>> commitImport(ScheduleImportResult result);

  Future<List<BellTime>> getBells();

  Future<void> clearSchedule();
}
