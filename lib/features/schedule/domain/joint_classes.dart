import '../../../core/database/database.dart';
import 'entities/schedule_slot.dart';
import 'teacher_name.dart';

/// Пара чужой группы на тот же день — уже с учётом её замен.
class ForeignPair {
  const ForeignPair({
    required this.groupName,
    required this.pairNumber,
    required this.teacher,
  });

  final String groupName;
  final int pairNumber;
  final String teacher;
}

/// Собирает пары остальных групп на день.
///
/// Замена перекрывает базовую пару той же группы, снятая пара выпадает
/// совсем: если у соседей пару сняли, сидеть с ними не с кем.
///
/// [lessons] — базовые пары всех групп на этот день недели, [substitutions] —
/// замены всех групп на эту дату. Базовое расписание чужой группы есть
/// только если её импортировали; замены — всегда, документ общий.
List<ForeignPair> foreignPairsFor({
  required String ownGroup,
  required List<Lesson> lessons,
  required List<Substitution> substitutions,
}) {
  final own = ownGroup.toLowerCase().trim();
  final result = <ForeignPair>[];

  // Ключ «группа:пара» — по нему базовая пара уступает место замене.
  final replaced = <String>{};

  for (final sub in substitutions) {
    final group = sub.groupName.trim();
    if (group.toLowerCase() == own) continue;
    replaced.add('${group.toLowerCase()}:${sub.pairNumber}');
    if (sub.isCancelled) continue;
    if (sub.teacher.trim().isEmpty) continue;

    result.add(ForeignPair(
      groupName: group,
      pairNumber: sub.pairNumber,
      teacher: sub.teacher,
    ));
  }

  for (final lesson in lessons) {
    final group = lesson.groupName.trim();
    if (group.toLowerCase() == own) continue;
    if (replaced.contains('${group.toLowerCase()}:${lesson.pairNumber}')) {
      continue;
    }
    if (lesson.teacher.trim().isEmpty) continue;

    result.add(ForeignPair(
      groupName: group,
      pairNumber: lesson.pairNumber,
      teacher: lesson.teacher,
    ));
  }

  return result;
}

/// Группы, с которыми пара идёт совмещённо, по номеру пары.
///
/// Признак — один преподаватель у двух групп на одной паре в один день:
/// физически он не может вести две пары одновременно, значит группы сидят
/// вместе. Снятые пары и пары без указанного преподавателя пропускаем.
Map<int, Set<String>> findJointGroups({
  required List<ScheduleSlot> ownSlots,
  required List<ForeignPair> foreign,
}) {
  if (foreign.isEmpty) return const {};

  // Чужие пары разложены по номеру: сравнивать нужно только внутри пары.
  final byPair = <int, List<(String, TeacherName)>>{};
  for (final pair in foreign) {
    final name = TeacherName.parse(pair.teacher);
    if (name == null) continue;
    (byPair[pair.pairNumber] ??= []).add((pair.groupName, name));
  }

  final joint = <int, Set<String>>{};

  for (final slot in ownSlots) {
    if (slot.isCancelled) continue;
    final mine = TeacherName.parse(slot.teacher);
    if (mine == null) continue;

    final candidates = byPair[slot.pairNumber];
    if (candidates == null) continue;

    for (final (group, theirs) in candidates) {
      if (!mine.matches(theirs)) continue;
      (joint[slot.pairNumber] ??= <String>{}).add(group);
    }
  }

  return joint;
}

/// Проставляет в расписание дня группы, с которыми пары идут совмещённо.
DaySchedule applyJointClasses(
  DaySchedule day, {
  required List<Lesson> lessons,
  required List<Substitution> substitutions,
}) {
  final joint = findJointGroups(
    ownSlots: day.slots,
    foreign: foreignPairsFor(
      ownGroup: day.groupName,
      lessons: lessons,
      substitutions: substitutions,
    ),
  );
  if (joint.isEmpty) return day;

  return DaySchedule(
    date: day.date,
    groupName: day.groupName,
    weekType: day.weekType,
    hasSubstitutions: day.hasSubstitutions,
    slots: [
      for (final slot in day.slots)
        joint[slot.pairNumber] == null
            ? slot
            : slot.withJointGroups(
                (joint[slot.pairNumber]!.toList()..sort()),
              ),
    ],
  );
}
