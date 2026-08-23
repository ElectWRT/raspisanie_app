import 'package:collection/collection.dart';

import '../../../core/database/database.dart';
import 'entities/schedule_slot.dart';

/// Накладывает замены на базовое расписание одного дня.
///
/// Правила:
/// * замена без подгруппы перекрывает пару целиком (все подгруппы);
/// * замена с подгруппой перекрывает только эту подгруппу;
/// * замена на номер пары, которого нет в базовом расписании, добавляется
///   в конец как дополнительная;
/// * [subgroupFilter] скрывает пары чужой подгруппы.
DaySchedule mergeDaySchedule({
  required DateTime date,
  required String groupName,
  required WeekType weekType,
  required List<Lesson> lessons,
  required List<Substitution> substitutions,
  String? subgroupFilter,
}) {
  final unusedSubgroupSubs =
      substitutions.where((s) => s.subgroup != null).toList();
  final wholePairSubs = substitutions.where((s) => s.subgroup == null).toList();
  final usedWholePair = <int>{};
  final slots = <ScheduleSlot>[];

  for (final lesson in lessons) {
    // Точное совпадение по подгруппе приоритетнее замены на всю пару.
    final match = unusedSubgroupSubs.firstWhereOrNull((s) =>
            s.pairNumber == lesson.pairNumber &&
            s.subgroup == lesson.subgroup) ??
        wholePairSubs
            .firstWhereOrNull((s) => s.pairNumber == lesson.pairNumber);

    if (match == null) {
      slots.add(ScheduleSlot(
        pairNumber: lesson.pairNumber,
        subgroup: lesson.subgroup,
        subject: lesson.subject,
        teacher: lesson.teacher,
        room: lesson.room,
        weekType: lesson.weekType,
      ));
      continue;
    }

    if (match.subgroup != null) {
      unusedSubgroupSubs.remove(match);
    } else {
      usedWholePair.add(match.pairNumber);
    }

    slots.add(ScheduleSlot(
      pairNumber: lesson.pairNumber,
      subgroup: lesson.subgroup ?? match.subgroup,
      subject: match.isCancelled ? lesson.subject : match.subject,
      teacher: match.teacher,
      room: match.room,
      isSubstitution: true,
      isCancelled: match.isCancelled,
      note: match.note,
      originalSubject: lesson.subject,
      originalTeacher: lesson.teacher,
      originalRoom: lesson.room,
      weekType: lesson.weekType,
    ));
  }

  // Замены, которым не нашлось пары в базовом расписании.
  final extras = [
    ...unusedSubgroupSubs,
    ...wholePairSubs.where((s) => !usedWholePair.contains(s.pairNumber)),
  ];
  for (final sub in extras) {
    slots.add(ScheduleSlot(
      pairNumber: sub.pairNumber,
      subgroup: sub.subgroup,
      subject: sub.subject,
      teacher: sub.teacher,
      room: sub.room,
      isSubstitution: true,
      isCancelled: sub.isCancelled,
      isExtra: true,
      note: sub.note,
    ));
  }

  final visible = subgroupFilter == null
      ? slots
      : slots
          .where((s) => s.subgroup == null || s.subgroup == subgroupFilter)
          .toList();

  visible.sort((a, b) {
    final byPair = a.pairNumber.compareTo(b.pairNumber);
    if (byPair != 0) return byPair;
    return (a.subgroup ?? '').compareTo(b.subgroup ?? '');
  });

  return DaySchedule(
    date: date,
    groupName: groupName,
    weekType: weekType,
    slots: visible,
    hasSubstitutions: substitutions.isNotEmpty,
  );
}
