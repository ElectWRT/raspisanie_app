import 'package:flutter_test/flutter_test.dart';
import 'package:raspisanie_app/core/database/database.dart';
import 'package:raspisanie_app/features/schedule/domain/entities/schedule_slot.dart';
import 'package:raspisanie_app/features/schedule/domain/schedule_merger.dart';

final _date = DateTime(2026, 9, 7); // понедельник

Lesson _lesson(
  int pair,
  String subject, {
  String? subgroup,
  String teacher = 'Иванов И.И.',
  String room = '301',
}) =>
    Lesson(
      id: pair,
      groupName: 'СА-2124',
      dayOfWeek: 1,
      pairNumber: pair,
      weekType: WeekType.every,
      subgroup: subgroup,
      subject: subject,
      teacher: teacher,
      room: room,
    );

Substitution _sub(
  int pair,
  String subject, {
  String? subgroup,
  bool cancelled = false,
  String teacher = 'Сидоров С.С.',
  String room = '210',
  String? note,
}) =>
    Substitution(
      id: 100 + pair,
      date: _date,
      groupName: 'СА-2124',
      pairNumber: pair,
      subgroup: subgroup,
      subject: subject,
      teacher: teacher,
      room: room,
      isCancelled: cancelled,
      note: note,
    );

DaySchedule _merge(
  List<Lesson> lessons,
  List<Substitution> subs, {
  String? filter,
}) =>
    mergeDaySchedule(
      date: _date,
      groupName: 'СА-2124',
      weekType: WeekType.numerator,
      lessons: lessons,
      substitutions: subs,
      subgroupFilter: filter,
    );

void main() {
  test('без замен возвращает базовое расписание', () {
    final day = _merge([_lesson(1, 'Сети'), _lesson(2, 'ОС')], const []);

    expect(day.slots, hasLength(2));
    expect(day.slots.every((s) => !s.isSubstitution), isTrue);
    expect(day.hasSubstitutions, isFalse);
  });

  test('замена перекрывает пару и сохраняет исходный предмет', () {
    final day = _merge(
      [_lesson(1, 'Сети'), _lesson(2, 'ОС')],
      [_sub(2, 'Философия', teacher: 'Орлов О.О.', room: '404')],
    );

    final second = day.slots[1];
    expect(second.isSubstitution, isTrue);
    expect(second.subject, 'Философия');
    expect(second.teacher, 'Орлов О.О.');
    expect(second.room, '404');
    expect(second.originalSubject, 'ОС');
    expect(second.isExtra, isFalse);
    expect(day.slots.first.isSubstitution, isFalse);
  });

  test('снятая пара помечается, предмет из базового расписания сохраняется', () {
    final day = _merge(
      [_lesson(3, 'Математика')],
      [_sub(3, '', cancelled: true, note: 'самостоятельно')],
    );

    final slot = day.slots.single;
    expect(slot.isCancelled, isTrue);
    expect(slot.subject, 'Математика');
    expect(slot.note, 'самостоятельно');
  });

  test('замена на пару, которой нет в расписании, добавляется как extra', () {
    final day = _merge([_lesson(1, 'Сети')], [_sub(5, 'Классный час')]);

    expect(day.slots, hasLength(2));
    expect(day.slots.last.pairNumber, 5);
    expect(day.slots.last.isExtra, isTrue);
    expect(day.slots.last.isSubstitution, isTrue);
  });

  test('замена без подгруппы перекрывает обе подгруппы', () {
    final day = _merge(
      [
        _lesson(3, 'Английский', subgroup: '1'),
        _lesson(3, 'Английский', subgroup: '2'),
      ],
      [_sub(3, 'Литература')],
    );

    expect(day.slots, hasLength(2));
    expect(day.slots.every((s) => s.subject == 'Литература'), isTrue);
    expect(day.slots.every((s) => s.isSubstitution), isTrue);
    expect(day.slots.any((s) => s.isExtra), isFalse);
  });

  test('замена с подгруппой трогает только свою подгруппу', () {
    final day = _merge(
      [
        _lesson(3, 'Английский', subgroup: '1'),
        _lesson(3, 'Английский', subgroup: '2'),
      ],
      [_sub(3, 'Литература', subgroup: '2')],
    );

    final first = day.slots.firstWhere((s) => s.subgroup == '1');
    final second = day.slots.firstWhere((s) => s.subgroup == '2');
    expect(first.isSubstitution, isFalse);
    expect(first.subject, 'Английский');
    expect(second.isSubstitution, isTrue);
    expect(second.subject, 'Литература');
  });

  test('точная замена подгруппы приоритетнее замены на всю пару', () {
    final day = _merge(
      [
        _lesson(3, 'Английский', subgroup: '1'),
        _lesson(3, 'Английский', subgroup: '2'),
      ],
      [_sub(3, 'Литература'), _sub(3, 'История', subgroup: '2')],
    );

    expect(day.slots.firstWhere((s) => s.subgroup == '1').subject, 'Литература');
    expect(day.slots.firstWhere((s) => s.subgroup == '2').subject, 'История');
    expect(day.slots.any((s) => s.isExtra), isFalse);
  });

  test('фильтр подгруппы прячет чужие пары, но оставляет общие', () {
    final day = _merge(
      [
        _lesson(1, 'Сети'),
        _lesson(3, 'Английский', subgroup: '1'),
        _lesson(3, 'Английский', subgroup: '2'),
      ],
      const [],
      filter: '1',
    );

    expect(day.slots, hasLength(2));
    expect(day.slots.map((s) => s.subgroup), [null, '1']);
  });

  test('пары отсортированы по номеру, потом по подгруппе', () {
    final day = _merge(
      [
        _lesson(4, 'Физика'),
        _lesson(2, 'Английский', subgroup: '2'),
        _lesson(2, 'Английский', subgroup: '1'),
      ],
      [_sub(1, 'Собрание')],
    );

    expect(day.slots.map((s) => s.pairNumber), [1, 2, 2, 4]);
    expect(day.slots[1].subgroup, '1');
    expect(day.slots[2].subgroup, '2');
  });
}
