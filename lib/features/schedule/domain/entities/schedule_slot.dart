import 'package:equatable/equatable.dart';

import '../../../../core/database/tables.dart';

/// Одна строка расписания на конкретный день — уже с наложенной заменой.
class ScheduleSlot extends Equatable {
  final int pairNumber;
  final String? subgroup;
  final String subject;
  final String teacher;
  final String room;

  /// Пара пришла из документа замен.
  final bool isSubstitution;

  /// Пара снята («группа гуляет»).
  final bool isCancelled;

  /// Пары не было в базовом расписании — её добавили заменой.
  final bool isExtra;

  /// Что стояло в базовом расписании до замены.
  final String? originalSubject;
  final String? originalTeacher;
  final String? originalRoom;

  final String? note;
  final WeekType weekType;

  const ScheduleSlot({
    required this.pairNumber,
    required this.subject,
    this.subgroup,
    this.teacher = '',
    this.room = '',
    this.isSubstitution = false,
    this.isCancelled = false,
    this.isExtra = false,
    this.originalSubject,
    this.originalTeacher,
    this.originalRoom,
    this.note,
    this.weekType = WeekType.every,
  });

  @override
  List<Object?> get props => [
        pairNumber,
        subgroup,
        subject,
        teacher,
        room,
        isSubstitution,
        isCancelled,
        isExtra,
        originalSubject,
        originalTeacher,
        originalRoom,
        note,
        weekType,
      ];
}

/// Расписание на один день.
class DaySchedule extends Equatable {
  final DateTime date;
  final String groupName;
  final WeekType weekType;
  final List<ScheduleSlot> slots;

  /// Есть ли на этот день загруженный документ замен.
  final bool hasSubstitutions;

  const DaySchedule({
    required this.date,
    required this.groupName,
    required this.weekType,
    required this.slots,
    this.hasSubstitutions = false,
  });

  bool get isEmpty => slots.isEmpty;

  int get substitutionCount => slots.where((s) => s.isSubstitution).length;

  @override
  List<Object?> get props => [date, groupName, weekType, slots, hasSubstitutions];
}

/// Время начала и конца пары.
class BellTime extends Equatable {
  final int pairNumber;
  final String start;
  final String end;

  const BellTime({
    required this.pairNumber,
    required this.start,
    required this.end,
  });

  factory BellTime.fromJson(Map<String, dynamic> json) => BellTime(
        pairNumber: json['pair'] as int,
        start: json['start'] as String,
        end: json['end'] as String,
      );

  Map<String, dynamic> toJson() => {
        'pair': pairNumber,
        'start': start,
        'end': end,
      };

  @override
  List<Object?> get props => [pairNumber, start, end];
}
