import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:raspisanie_app/core/database/database.dart';
import 'package:raspisanie_app/features/attendance/data/repositories/attendance_repository_impl.dart';
import 'package:raspisanie_app/features/attendance/domain/attendance_stats.dart';

void main() {
  late AppDatabase database;
  late AttendanceRepositoryImpl repository;

  final day = DateTime(2026, 9, 15);
  const groupName = 'СА-2124';

  setUp(() {
    database = AppDatabase.forTesting(NativeDatabase.memory());
    repository = AttendanceRepositoryImpl(database);
  });

  tearDown(() => database.close());

  group('отметки', () {
    test('отметка сохраняется и читается за день', () async {
      await repository.mark(
        date: day,
        groupName: groupName,
        pairNumber: 2,
        subject: 'Математика',
        status: AttendanceStatus.absent,
      );

      final marks = await repository.watchDay(groupName: groupName, date: day).first;

      expect(marks, hasLength(1));
      expect(marks[attendanceKey(2, null)]?.status, AttendanceStatus.absent);
      expect(marks[attendanceKey(2, null)]?.subject, 'Математика');
    });

    test('повторная отметка той же пары переписывает статус, а не плодит строки',
        () async {
      for (final status in [
        AttendanceStatus.present,
        AttendanceStatus.absent,
        AttendanceStatus.excused,
      ]) {
        await repository.mark(
          date: day,
          groupName: groupName,
          pairNumber: 1,
          subject: 'Сети',
          status: status,
        );
      }

      final rows = await repository.all(groupName);

      expect(rows, hasLength(1));
      expect(rows.single.status, AttendanceStatus.excused);
    });

    test('подгруппы отмечаются независимо', () async {
      await repository.mark(
        date: day,
        groupName: groupName,
        pairNumber: 3,
        subgroup: '1',
        subject: 'Английский',
        status: AttendanceStatus.present,
      );
      await repository.mark(
        date: day,
        groupName: groupName,
        pairNumber: 3,
        subgroup: '2',
        subject: 'Английский',
        status: AttendanceStatus.absent,
      );

      final marks = await repository.watchDay(groupName: groupName, date: day).first;

      expect(marks[attendanceKey(3, '1')]?.status, AttendanceStatus.present);
      expect(marks[attendanceKey(3, '2')]?.status, AttendanceStatus.absent);
    });

    test('снятая отметка исчезает из дня', () async {
      await repository.mark(
        date: day,
        groupName: groupName,
        pairNumber: 1,
        subject: 'Сети',
        status: AttendanceStatus.present,
      );
      await repository.clear(date: day, groupName: groupName, pairNumber: 1);

      final marks = await repository.watchDay(groupName: groupName, date: day).first;
      expect(marks, isEmpty);
    });

    test('markedKeys отдаёт ключи отмеченных пар', () async {
      await repository.mark(
        date: day,
        groupName: groupName,
        pairNumber: 1,
        subject: 'Сети',
        status: AttendanceStatus.present,
      );

      final keys = await repository.markedKeys(groupName: groupName, date: day);

      expect(keys, {attendanceKey(1, null)});
    });

    test('время в дате отбрасывается — отметка ложится на день', () async {
      await repository.mark(
        date: DateTime(2026, 9, 15, 14, 37),
        groupName: groupName,
        pairNumber: 1,
        subject: 'Сети',
        status: AttendanceStatus.present,
      );

      final marks = await repository.watchDay(groupName: groupName, date: day).first;
      expect(marks, hasLength(1));
    });
  });

  group('профили предметов', () {
    test('профиль сохраняется и перезаписывается по имени предмета', () async {
      await repository.saveProfile(
        groupName: groupName,
        subject: 'Базы данных',
        isMajor: true,
        items: ['Ноутбук', 'Тетрадь'],
      );
      // Тот же предмет в другом регистре — это тот же предмет.
      await repository.saveProfile(
        groupName: groupName,
        subject: 'базы данных',
        isMajor: true,
        items: ['Ноутбук'],
      );

      final profiles = await repository.profiles(groupName);

      expect(profiles, hasLength(1));
      expect(decodeProfileItems(profiles.single.items), ['Ноутбук']);
      expect(profiles.single.isMajor, isTrue);
    });

    test('пустые пункты в списке вещей отбрасываются', () async {
      await repository.saveProfile(
        groupName: groupName,
        subject: 'Физкультура',
        isMajor: false,
        items: ['Форма', '   ', ''],
      );

      final profiles = await repository.profiles(groupName);
      expect(decodeProfileItems(profiles.single.items), ['Форма']);
    });
  });

  group('статистика', () {
    test('сводит предмет независимо от регистра', () {
      final stats = buildAttendanceStats(rows: [
        _row(1, 'Математика', AttendanceStatus.present),
        _row(2, 'математика', AttendanceStatus.absent),
      ]);

      expect(stats.subjects, hasLength(1));
      expect(stats.subjects.single.present, 1);
      expect(stats.subjects.single.absent, 1);
      expect(stats.subjects.single.percent, 50);
    });

    test('missedFor считает только неуважительные пропуски', () {
      final stats = buildAttendanceStats(rows: [
        _row(1, 'Сети', AttendanceStatus.absent),
        _row(2, 'Сети', AttendanceStatus.absent),
        _row(3, 'Сети', AttendanceStatus.excused),
      ]);

      expect(stats.missedFor('сети'), 2);
    });

    test('предметы с худшей посещаемостью идут первыми', () {
      final stats = buildAttendanceStats(rows: [
        _row(1, 'Хорошо', AttendanceStatus.present),
        _row(2, 'Плохо', AttendanceStatus.absent),
      ]);

      expect(stats.subjects.first.subject, 'Плохо');
    });

    test('профильность приходит из профилей', () {
      final stats = buildAttendanceStats(
        rows: [_row(1, 'Базы данных', AttendanceStatus.present)],
        majorSubjects: {'базы данных'},
      );

      expect(stats.subjects.single.isMajor, isTrue);
    });

    test('на пустых отметках статистика пуста, а не делит на ноль', () {
      final stats = buildAttendanceStats(rows: const []);

      expect(stats.isEmpty, isTrue);
      expect(stats.percent, 100);
      expect(stats.missedFor('что угодно'), 0);
    });
  });
}

Attendance _row(int id, String subject, AttendanceStatus status) => Attendance(
      id: id,
      date: DateTime(2026, 9, 15),
      groupName: 'СА-2124',
      pairNumber: id,
      subgroup: '',
      subject: subject,
      status: status,
      markedAt: DateTime(2026, 9, 15, 20),
    );
