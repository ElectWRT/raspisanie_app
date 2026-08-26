import 'package:drift/drift.dart';

import '../../../../core/database/database.dart';
import '../../../../core/utils/week_utils.dart';
import '../../domain/repositories/homework_repository.dart';

class HomeworkRepositoryImpl implements HomeworkRepository {
  HomeworkRepositoryImpl(this.database);

  final AppDatabase database;

  @override
  Stream<List<Homework>> watch({
    required String groupName,
    bool includeDone = false,
  }) =>
      database.watchHomeworks(groupName: groupName, includeDone: includeDone);

  @override
  Stream<Map<String, int>> watchCountsBySubject(String groupName) =>
      database.watchHomeworkCountsBySubject(groupName);

  @override
  Future<List<Homework>> pending(String groupName) =>
      database.getPendingHomeworks(groupName);

  @override
  Future<void> add({
    required String groupName,
    required String subject,
    required String description,
    required DateTime dueDate,
    required HomeworkPriority priority,
  }) =>
      database.insertHomework(HomeworksCompanion.insert(
        groupName: groupName,
        subject: subject.trim(),
        description: description.trim(),
        dueDate: WeekUtils.dayKey(dueDate),
        priority: Value(priority),
      ));

  @override
  Future<void> save(Homework item) => database.updateHomework(
        item.copyWith(
          subject: item.subject.trim(),
          description: item.description.trim(),
          dueDate: WeekUtils.dayKey(item.dueDate),
        ),
      );

  @override
  Future<void> setDone(int id, bool done) => database.setHomeworkDone(id, done);

  @override
  Future<void> remove(int id) => database.deleteHomework(id);

  @override
  Future<void> purgeOld() => database.purgeOldHomeworks();
}
