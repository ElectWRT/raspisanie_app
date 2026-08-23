import 'package:drift/drift.dart';
import 'package:equatable/equatable.dart';

import '../../../../core/database/database.dart';

/// Одна строка замены, вытащенная из документа. Ещё не привязана к дате —
/// дату определяет репозиторий (из документа или из выбранного дня).
class SubstitutionModel extends Equatable {
  final String groupName;
  final int pairNumber;
  final String? subgroup;
  final String subject;
  final String teacher;
  final String room;
  final bool isCancelled;
  final String? note;

  const SubstitutionModel({
    required this.groupName,
    required this.pairNumber,
    this.subgroup,
    this.subject = '',
    this.teacher = '',
    this.room = '',
    this.isCancelled = false,
    this.note,
  });

  SubstitutionsCompanion toCompanion(DateTime date) =>
      SubstitutionsCompanion.insert(
        date: DateTime(date.year, date.month, date.day),
        groupName: groupName,
        pairNumber: pairNumber,
        subgroup: Value(subgroup),
        subject: Value(subject),
        teacher: Value(teacher),
        room: Value(room),
        isCancelled: Value(isCancelled),
        note: Value(note),
      );

  @override
  List<Object?> get props =>
      [groupName, pairNumber, subgroup, subject, teacher, room, isCancelled, note];
}
