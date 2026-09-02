import 'package:equatable/equatable.dart';

import '../../../core/database/database.dart';

/// Сводка по одному предмету.
class SubjectAttendance extends Equatable {
  const SubjectAttendance({
    required this.subject,
    this.present = 0,
    this.absent = 0,
    this.excused = 0,
    this.isMajor = false,
  });

  final String subject;
  final int present;

  /// Пропуски без уважительной причины — только они идут в лимит.
  final int absent;
  final int excused;
  final bool isMajor;

  int get marked => present + absent + excused;

  /// Доля посещённых пар среди отмеченных. Уважительные считаются
  /// пропущенными: студент на паре не был, материал всё равно мимо.
  double get rate => marked == 0 ? 1 : present / marked;

  int get percent => (rate * 100).round();

  @override
  List<Object?> get props => [subject, present, absent, excused, isMajor];
}

/// Общая сводка: по предметам и итог.
class AttendanceStats extends Equatable {
  const AttendanceStats({this.subjects = const []});

  /// Предметы, отсортированы: сначала где хуже посещаемость.
  final List<SubjectAttendance> subjects;

  bool get isEmpty => subjects.isEmpty;

  int get present => subjects.fold(0, (sum, s) => sum + s.present);
  int get absent => subjects.fold(0, (sum, s) => sum + s.absent);
  int get excused => subjects.fold(0, (sum, s) => sum + s.excused);
  int get marked => present + absent + excused;

  double get rate => marked == 0 ? 1 : present / marked;
  int get percent => (rate * 100).round();

  /// Сколько пропущено по предмету без уважительной причины.
  int missedFor(String subject) {
    final key = subject.toLowerCase().trim();
    for (final item in subjects) {
      if (item.subject.toLowerCase().trim() == key) return item.absent;
    }
    return 0;
  }

  @override
  List<Object?> get props => [subjects];
}

/// Собирает статистику из отметок.
///
/// Предметы сводятся по названию в нижнем регистре: в расписании и в
/// документе с заменами один и тот же предмет пишут по-разному, и без
/// этого одна пара разъехалась бы на две строки статистики.
AttendanceStats buildAttendanceStats({
  required List<Attendance> rows,
  Set<String> majorSubjects = const {},
}) {
  final byKey = <String, SubjectAttendance>{};

  for (final row in rows) {
    final name = row.subject.trim();
    if (name.isEmpty) continue;
    final key = name.toLowerCase();

    final current = byKey[key] ??
        SubjectAttendance(subject: name, isMajor: majorSubjects.contains(key));

    byKey[key] = SubjectAttendance(
      subject: current.subject,
      isMajor: current.isMajor,
      present: current.present + (row.status == AttendanceStatus.present ? 1 : 0),
      absent: current.absent + (row.status == AttendanceStatus.absent ? 1 : 0),
      excused: current.excused + (row.status == AttendanceStatus.excused ? 1 : 0),
    );
  }

  final subjects = byKey.values.toList()
    ..sort((a, b) {
      // Сначала то, где хуже: именно это и нужно видеть первым.
      final byRate = a.rate.compareTo(b.rate);
      if (byRate != 0) return byRate;
      return a.subject.toLowerCase().compareTo(b.subject.toLowerCase());
    });

  return AttendanceStats(subjects: subjects);
}
