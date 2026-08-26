import '../../../../core/database/database.dart';

abstract class HomeworkRepository {
  /// Задания группы. По умолчанию только невыполненные.
  Stream<List<Homework>> watch({
    required String groupName,
    bool includeDone = false,
  });

  /// Сколько незакрытых заданий по каждому предмету — ключ в нижнем регистре.
  Stream<Map<String, int>> watchCountsBySubject(String groupName);

  /// Невыполненные задания — для планирования напоминаний.
  Future<List<Homework>> pending(String groupName);

  Future<void> add({
    required String groupName,
    required String subject,
    required String description,
    required DateTime dueDate,
    required HomeworkPriority priority,
  });

  Future<void> save(Homework item);

  Future<void> setDone(int id, bool done);

  Future<void> remove(int id);

  /// Чистит давно сданные задания, чтобы список не разрастался.
  Future<void> purgeOld();
}
