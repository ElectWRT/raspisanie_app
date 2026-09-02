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

  /// Группы, с которыми пара идёт совмещённо — тот же преподаватель
  /// в то же время. Пустой список — пара только для своей группы.
  final List<String> jointGroups;

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
    this.jointGroups = const [],
  });

  ScheduleSlot withJointGroups(List<String> groups) => ScheduleSlot(
        pairNumber: pairNumber,
        subject: subject,
        subgroup: subgroup,
        teacher: teacher,
        room: room,
        isSubstitution: isSubstitution,
        isCancelled: isCancelled,
        isExtra: isExtra,
        originalSubject: originalSubject,
        originalTeacher: originalTeacher,
        originalRoom: originalRoom,
        note: note,
        weekType: weekType,
        jointGroups: groups,
      );

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
        jointGroups,
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

  /// Превращает "08:30" в момент времени того же дня, что и [day].
  DateTime? _moment(DateTime day, String hhmm) {
    final parts = hhmm.split(':');
    if (parts.length != 2) return null;
    final hour = int.tryParse(parts[0]);
    final minute = int.tryParse(parts[1]);
    if (hour == null || minute == null) return null;
    return DateTime(day.year, day.month, day.day, hour, minute);
  }

  /// Идёт ли пара прямо сейчас. [day] — день, к которому относится пара.
  bool isNow(DateTime now, DateTime day) {
    final from = _moment(day, start);
    final to = _moment(day, end);
    if (from == null || to == null) return false;
    return !now.isBefore(from) && now.isBefore(to);
  }

  /// Пара уже закончилась.
  bool isPast(DateTime now, DateTime day) {
    final to = _moment(day, end);
    return to != null && now.isAfter(to);
  }

  @override
  List<Object?> get props => [pairNumber, start, end];
}
