import 'package:flutter_test/flutter_test.dart';
import 'package:raspisanie_app/core/database/database.dart';
import 'package:raspisanie_app/features/schedule/domain/entities/schedule_slot.dart';
import 'package:raspisanie_app/features/schedule/domain/joint_classes.dart';
import 'package:raspisanie_app/features/schedule/domain/teacher_name.dart';

void main() {
  final date = DateTime(2026, 9, 15);

  Lesson lesson({
    required String group,
    required int pair,
    required String teacher,
    String subject = 'Сети',
  }) =>
      Lesson(
        id: pair * 100 + group.hashCode % 90,
        groupName: group,
        dayOfWeek: date.weekday,
        pairNumber: pair,
        weekType: WeekType.every,
        subject: subject,
        teacher: teacher,
        room: '',
      );

  Substitution sub({
    required String group,
    required int pair,
    required String teacher,
    bool cancelled = false,
  }) =>
      Substitution(
        id: pair * 1000 + group.hashCode % 900,
        date: date,
        groupName: group,
        pairNumber: pair,
        subject: cancelled ? '' : 'Сети',
        teacher: teacher,
        room: '',
        isCancelled: cancelled,
      );

  group('разбор ФИО', () {
    test('фамилия и инициалы вытаскиваются из разных написаний', () {
      final variants = [
        'Иванов И.И.',
        'Иванов И. И.',
        'иванов и.и.',
        'Иванов Иван Иванович',
        'ИВАНОВ И.И.',
      ].map(TeacherName.parse).toList();

      expect(variants.every((v) => v != null), isTrue);
      for (final variant in variants) {
        expect(variant!.matches(variants.first!), isTrue,
            reason: 'все написания — один человек');
      }
    });

    test('ё и е не различаются', () {
      expect(
        TeacherName.parse('Королёв С.П.')!
            .matches(TeacherName.parse('Королев С.П.')!),
        isTrue,
      );
    });

    test('разные фамилии не совпадают', () {
      expect(
        TeacherName.parse('Иванов И.И.')!
            .matches(TeacherName.parse('Иванова И.И.')!),
        isFalse,
      );
    });

    test('разные инициалы не совпадают', () {
      expect(
        TeacherName.parse('Иванов И.И.')!
            .matches(TeacherName.parse('Иванов И.П.')!),
        isFalse,
      );
    });

    test('одна фамилия без инициалов совпадает с полной записью', () {
      expect(
        TeacherName.parse('Иванов')!
            .matches(TeacherName.parse('Иванов И.И.')!),
        isTrue,
        reason: 'больше информации в документе всё равно нет',
      );
    });

    test('мусор не разбирается', () {
      expect(TeacherName.parse(''), isNull);
      expect(TeacherName.parse('   '), isNull);
      expect(TeacherName.parse('—'), isNull);
      expect(TeacherName.parse('И.'), isNull, reason: 'одна буква — не фамилия');
    });
  });

  group('поиск совмещённых пар', () {
    test('один преподаватель на одной паре у двух групп', () {
      final joint = findJointGroups(
        ownSlots: const [
          ScheduleSlot(pairNumber: 2, subject: 'Сети', teacher: 'Иванов И.И.'),
        ],
        foreign: foreignPairsFor(
          ownGroup: 'СА-2124',
          lessons: [],
          substitutions: [
            sub(group: 'СА-2125', pair: 2, teacher: 'Иванов И. И.'),
          ],
        ),
      );

      expect(joint[2], {'СА-2125'});
    });

    test('разные пары одного преподавателя — не совмещёнка', () {
      final joint = findJointGroups(
        ownSlots: const [
          ScheduleSlot(pairNumber: 1, subject: 'Сети', teacher: 'Иванов И.И.'),
        ],
        foreign: foreignPairsFor(
          ownGroup: 'СА-2124',
          lessons: [],
          substitutions: [
            sub(group: 'СА-2125', pair: 3, teacher: 'Иванов И.И.'),
          ],
        ),
      );

      expect(joint, isEmpty);
    });

    test('своя группа сама с собой не совмещается', () {
      final joint = findJointGroups(
        ownSlots: const [
          ScheduleSlot(pairNumber: 1, subject: 'Сети', teacher: 'Иванов И.И.'),
        ],
        foreign: foreignPairsFor(
          ownGroup: 'СА-2124',
          lessons: [lesson(group: 'СА-2124', pair: 1, teacher: 'Иванов И.И.')],
          substitutions: [],
        ),
      );

      expect(joint, isEmpty);
    });

    test('замена чужой группы перекрывает её базовую пару', () {
      // По расписанию у СА-2125 ведёт Иванов, но пару заменили на Петрова.
      // Совмещёнки с нами больше нет.
      final foreign = foreignPairsFor(
        ownGroup: 'СА-2124',
        lessons: [lesson(group: 'СА-2125', pair: 1, teacher: 'Иванов И.И.')],
        substitutions: [sub(group: 'СА-2125', pair: 1, teacher: 'Петров П.П.')],
      );

      final joint = findJointGroups(
        ownSlots: const [
          ScheduleSlot(pairNumber: 1, subject: 'Сети', teacher: 'Иванов И.И.'),
        ],
        foreign: foreign,
      );

      expect(joint, isEmpty);
    });

    test('снятая у соседей пара совмещёнкой не считается', () {
      final joint = findJointGroups(
        ownSlots: const [
          ScheduleSlot(pairNumber: 1, subject: 'Сети', teacher: 'Иванов И.И.'),
        ],
        foreign: foreignPairsFor(
          ownGroup: 'СА-2124',
          lessons: [],
          substitutions: [
            sub(group: 'СА-2125', pair: 1, teacher: 'Иванов И.И.', cancelled: true),
          ],
        ),
      );

      expect(joint, isEmpty);
    });

    test('наша снятая пара тоже не совмещёнка', () {
      final joint = findJointGroups(
        ownSlots: const [
          ScheduleSlot(
            pairNumber: 1,
            subject: '',
            teacher: 'Иванов И.И.',
            isCancelled: true,
          ),
        ],
        foreign: foreignPairsFor(
          ownGroup: 'СА-2124',
          lessons: [],
          substitutions: [sub(group: 'СА-2125', pair: 1, teacher: 'Иванов И.И.')],
        ),
      );

      expect(joint, isEmpty);
    });

    test('пустой преподаватель не сводит группы', () {
      final joint = findJointGroups(
        ownSlots: const [
          ScheduleSlot(pairNumber: 1, subject: 'Сети', teacher: ''),
        ],
        foreign: foreignPairsFor(
          ownGroup: 'СА-2124',
          lessons: [],
          substitutions: [sub(group: 'СА-2125', pair: 1, teacher: '')],
        ),
      );

      expect(joint, isEmpty);
    });

    test('несколько групп на одной паре собираются вместе', () {
      final joint = findJointGroups(
        ownSlots: const [
          ScheduleSlot(pairNumber: 1, subject: 'Сети', teacher: 'Иванов И.И.'),
        ],
        foreign: foreignPairsFor(
          ownGroup: 'СА-2124',
          lessons: [],
          substitutions: [
            sub(group: 'СА-2126', pair: 1, teacher: 'Иванов И.И.'),
            sub(group: 'СА-2125', pair: 1, teacher: 'Иванов Иван Иванович'),
          ],
        ),
      );

      expect(joint[1], {'СА-2125', 'СА-2126'});
    });
  });

  group('простановка в расписание дня', () {
    DaySchedule dayWith(List<ScheduleSlot> slots) => DaySchedule(
          date: date,
          groupName: 'СА-2124',
          weekType: WeekType.every,
          slots: slots,
        );

    test('группы попадают в слот и сортируются', () {
      final result = applyJointClasses(
        dayWith(const [
          ScheduleSlot(pairNumber: 1, subject: 'Сети', teacher: 'Иванов И.И.'),
          ScheduleSlot(pairNumber: 2, subject: 'ОС', teacher: 'Петров П.П.'),
        ]),
        lessons: [],
        substitutions: [
          sub(group: 'СА-2126', pair: 1, teacher: 'Иванов И.И.'),
          sub(group: 'СА-2125', pair: 1, teacher: 'Иванов И.И.'),
        ],
      );

      expect(result.slots.first.jointGroups, ['СА-2125', 'СА-2126']);
      expect(result.slots.last.jointGroups, isEmpty);
    });

    test('без чужих данных расписание возвращается как есть', () {
      final day = dayWith(const [
        ScheduleSlot(pairNumber: 1, subject: 'Сети', teacher: 'Иванов И.И.'),
      ]);

      expect(
        applyJointClasses(day, lessons: [], substitutions: []),
        same(day),
      );
    });
  });
}
