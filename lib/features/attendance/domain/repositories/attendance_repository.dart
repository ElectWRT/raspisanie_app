import '../../../../core/database/database.dart';

abstract class AttendanceRepository {
  /// Отметки за день. Ключ — [attendanceKey] пары.
  Stream<Map<String, Attendance>> watchDay({
    required String groupName,
    required DateTime date,
  });

  /// Все отметки группы — для статистики.
  Stream<List<Attendance>> watchAll(String groupName);

  Future<List<Attendance>> all(String groupName);

  Future<void> mark({
    required DateTime date,
    required String groupName,
    required int pairNumber,
    String? subgroup,
    required String subject,
    required AttendanceStatus status,
  });

  Future<void> clear({
    required DateTime date,
    required String groupName,
    required int pairNumber,
    String? subgroup,
  });

  /// Ключи пар, которые за день уже отмечены.
  Future<Set<String>> markedKeys({
    required String groupName,
    required DateTime date,
  });

  // ------------------------------------------------------- профили предметов

  Stream<List<SubjectProfile>> watchProfiles(String groupName);

  Future<List<SubjectProfile>> profiles(String groupName);

  Future<void> saveProfile({
    required String groupName,
    required String subject,
    required bool isMajor,
    required List<String> items,
    String? note,
  });

  Future<void> removeProfile(int id);
}
