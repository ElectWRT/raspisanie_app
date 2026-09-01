import 'package:flutter_test/flutter_test.dart';
import 'package:raspisanie_app/core/background/background_refresh.dart';
import 'package:raspisanie_app/core/database/database.dart';
import 'package:raspisanie_app/features/substitutions/data/repositories/substitutions_repository_impl.dart';

void main() {
  final date = DateTime(2026, 9, 15);

  Substitution row({
    String group = 'СА-2124',
    int pair = 1,
    String subject = 'Математика',
    String teacher = 'Иванов И.И.',
    String room = '301',
    bool cancelled = false,
    int id = 1,
  }) {
    return Substitution(
      id: id,
      date: date,
      groupName: group,
      pairNumber: pair,
      subject: subject,
      teacher: teacher,
      room: room,
      isCancelled: cancelled,
    );
  }

  group('слепок замен', () {
    test('порядок строк не влияет', () {
      final a = substitutionsSignature(
        rows: [row(id: 1, pair: 1), row(id: 2, pair: 2)],
        date: date,
      );
      final b = substitutionsSignature(
        rows: [row(id: 2, pair: 2), row(id: 1, pair: 1)],
        date: date,
      );

      expect(a, b, reason: 'иначе уведомление приходило бы после каждой загрузки');
    });

    test('изменение предмета меняет слепок', () {
      final before = substitutionsSignature(rows: [row()], date: date);
      final after = substitutionsSignature(
        rows: [row(subject: 'Физика')],
        date: date,
      );

      expect(before, isNot(after));
    });

    test('снятие пары меняет слепок', () {
      final before = substitutionsSignature(rows: [row()], date: date);
      final after = substitutionsSignature(
        rows: [row(cancelled: true)],
        date: date,
      );

      expect(before, isNot(after));
    });

    test('идентификатор строки в слепок не входит', () {
      // После перезагрузки документа id меняются, а содержимое — нет.
      final before = substitutionsSignature(rows: [row(id: 1)], date: date);
      final after = substitutionsSignature(rows: [row(id: 99)], date: date);

      expect(before, after);
    });

    test('другая дата — другой слепок', () {
      final a = substitutionsSignature(rows: [row()], date: date);
      final b = substitutionsSignature(
        rows: [row()],
        date: DateTime(2026, 9, 16),
      );

      expect(a, isNot(b));
    });

    test('время в дате не учитывается', () {
      final a = substitutionsSignature(rows: [row()], date: date);
      final b = substitutionsSignature(
        rows: [row()],
        date: DateTime(2026, 9, 15, 23, 59),
      );

      expect(a, b);
    });

    test('фильтр по группе отбрасывает чужие замены', () {
      final mineOnly = substitutionsSignature(
        rows: [row(group: 'СА-2124')],
        date: date,
        group: 'СА-2124',
      );
      final withStranger = substitutionsSignature(
        rows: [row(group: 'СА-2124'), row(id: 2, group: 'СА-2125')],
        date: date,
        group: 'СА-2124',
      );

      expect(mineOnly, withStranger,
          reason: 'чужие замены не должны дёргать уведомление');
    });

    test('без фильтра чужая замена учитывается', () {
      final a = substitutionsSignature(rows: [row()], date: date);
      final b = substitutionsSignature(
        rows: [row(), row(id: 2, group: 'СА-2125')],
        date: date,
      );

      expect(a, isNot(b));
    });
  });

  group('текст уведомления', () {
    test('склонение слова «замена»', () {
      expect(
        substitutionAlertBody(date: date, count: 1),
        contains('1 замена'),
      );
      expect(
        substitutionAlertBody(date: date, count: 3),
        contains('3 замены'),
      );
      expect(
        substitutionAlertBody(date: date, count: 5),
        contains('5 замен'),
      );
      expect(
        substitutionAlertBody(date: date, count: 11),
        contains('11 замен'),
      );
    });

    test('называет группу, если она выбрана', () {
      expect(
        substitutionAlertBody(date: date, count: 2, group: 'СА-2124'),
        contains('у СА-2124'),
      );
    });

    test('без группы про неё не пишет', () {
      expect(
        substitutionAlertBody(date: date, count: 2),
        isNot(contains(' у ')),
      );
    });

    test('называет дату по-русски', () {
      expect(
        substitutionAlertBody(date: date, count: 1),
        contains('15 сентября'),
      );
    });
  });
}
