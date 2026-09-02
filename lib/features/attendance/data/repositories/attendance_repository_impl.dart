import '../../../../core/database/database.dart';
import '../../../../core/utils/week_utils.dart';
import '../../domain/repositories/attendance_repository.dart';

/// Разделитель пунктов «что взять на пару» внутри одной текстовой колонки.
/// Перевод строки, а не запятая: в названии вещи запятая встречается
/// («ноутбук, заряженный»), а перенос строки — нет.
const _itemSeparator = '\n';

List<String> decodeProfileItems(String raw) => raw
    .split(_itemSeparator)
    .map((e) => e.trim())
    .where((e) => e.isNotEmpty)
    .toList();

String encodeProfileItems(List<String> items) => items
    .map((e) => e.trim())
    .where((e) => e.isNotEmpty)
    .join(_itemSeparator);

class AttendanceRepositoryImpl implements AttendanceRepository {
  AttendanceRepositoryImpl(this.database);

  final AppDatabase database;

  @override
  Stream<Map<String, Attendance>> watchDay({
    required String groupName,
    required DateTime date,
  }) =>
      database.watchAttendanceForDay(
        groupName: groupName,
        date: WeekUtils.dayKey(date),
      );

  @override
  Stream<List<Attendance>> watchAll(String groupName) =>
      database.watchAttendance(groupName);

  @override
  Future<List<Attendance>> all(String groupName) =>
      database.getAttendance(groupName);

  @override
  Future<void> mark({
    required DateTime date,
    required String groupName,
    required int pairNumber,
    String? subgroup,
    required String subject,
    required AttendanceStatus status,
  }) =>
      database.setAttendance(
        date: WeekUtils.dayKey(date),
        groupName: groupName,
        pairNumber: pairNumber,
        subgroup: subgroup,
        subject: subject.trim(),
        status: status,
      );

  @override
  Future<void> clear({
    required DateTime date,
    required String groupName,
    required int pairNumber,
    String? subgroup,
  }) =>
      database.clearAttendance(
        date: WeekUtils.dayKey(date),
        groupName: groupName,
        pairNumber: pairNumber,
        subgroup: subgroup,
      );

  @override
  Future<Set<String>> markedKeys({
    required String groupName,
    required DateTime date,
  }) =>
      database.markedKeysForDay(
        groupName: groupName,
        date: WeekUtils.dayKey(date),
      );

  @override
  Stream<List<SubjectProfile>> watchProfiles(String groupName) =>
      database.watchSubjectProfiles(groupName);

  @override
  Future<List<SubjectProfile>> profiles(String groupName) =>
      database.getSubjectProfiles(groupName);

  @override
  Future<void> saveProfile({
    required String groupName,
    required String subject,
    required bool isMajor,
    required List<String> items,
    String? note,
  }) =>
      database.upsertSubjectProfile(
        groupName: groupName,
        subject: subject,
        isMajor: isMajor,
        items: encodeProfileItems(items),
        note: (note == null || note.trim().isEmpty) ? null : note.trim(),
      );

  @override
  Future<void> removeProfile(int id) => database.deleteSubjectProfile(id);
}
