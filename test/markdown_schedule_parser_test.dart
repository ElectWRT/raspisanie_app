import 'package:flutter_test/flutter_test.dart';
import 'package:raspisanie_app/core/database/database.dart';
import 'package:raspisanie_app/core/error/exceptions.dart';
import 'package:raspisanie_app/features/schedule/data/datasources/markdown_schedule_parser.dart';

void main() {
  const parser = MarkdownScheduleParser();

  test('разбирает группу, дни и пары', () {
    final result = parser.parse('''
# СА-2124

## Понедельник
1. Компьютерные сети | Иванов И.И. | 301
2. ОС и среды | Петров П.П. | 305

## Вторник
1. Математика | Петрова А.А. | 210
''');

    expect(result.lessons, hasLength(3));
    expect(result.lessonsPerGroup, {'СА-2124': 3});
    expect(result.warnings, isEmpty);

    final first = result.lessons.first;
    expect(first.groupName.value, 'СА-2124');
    expect(first.dayOfWeek.value, 1);
    expect(first.pairNumber.value, 1);
    expect(first.subject.value, 'Компьютерные сети');
    expect(first.teacher.value, 'Иванов И.И.');
    expect(first.room.value, '301');
    expect(first.weekType.value, WeekType.every);

    expect(result.lessons.last.dayOfWeek.value, 2);
  });

  test('понимает числитель, знаменатель и подгруппы в любом порядке', () {
    final result = parser.parse('''
# ИС-21
## Среда
1. (числ) Физика | Кузнецов В.В. | 112
2. (знам) Химия
3. [1] Английский | Смирнова О.П. | 208
4. (числ) [2] Английский | Волкова Н.С. | 209
5. [1] (знам) История
''');

    final lessons = result.lessons;
    expect(lessons[0].weekType.value, WeekType.numerator);
    expect(lessons[1].weekType.value, WeekType.denominator);
    expect(lessons[1].teacher.value, '');
    expect(lessons[2].subgroup.value, '1');
    expect(lessons[2].weekType.value, WeekType.every);
    expect(lessons[3].weekType.value, WeekType.numerator);
    expect(lessons[3].subgroup.value, '2');
    expect(lessons[4].weekType.value, WeekType.denominator);
    expect(lessons[4].subgroup.value, '1');
  });

  test('поддерживает несколько групп в одном файле', () {
    final result = parser.parse('''
# СА-2124
## Пн
1. Сети

# СА-2125
## Пн
1. Базы данных
2. Философия
''');

    expect(result.lessonsPerGroup, {'СА-2124': 1, 'СА-2125': 2});
    expect(result.groups, ['СА-2124', 'СА-2125']);
  });

  test('разбирает блок звонков', () {
    final result = parser.parse('''
# Звонки
1. 8:30 - 10:00
2. 10.10 — 11.40

# СА-2124
## Пн
1. Сети
''');

    expect(result.bellSchedules, hasLength(1));
    final times = result.bellSchedules.single.times;
    expect(times, hasLength(2));
    expect(times.first.start, '08:30');
    expect(times.first.end, '10:00');
    expect(times.last.start, '10:10');
    expect(times.last.end, '11:40');
    expect(result.bellSchedules.single.isDefault, isTrue,
        reason: 'без указания дней набор считается основным');
  });

  test('несколько наборов звонков с привязкой к дням', () {
    final result = parser.parse('''
# Звонки (пн-пт)
1. 08:30 - 10:00
2. 10:10 - 11:40

# Звонки (сб)
1. 08:30 - 09:30
2. 09:40 - 10:40

# СА-2124
## Пн
1. Сети
''');

    expect(result.bellSchedules, hasLength(2));

    final weekdays = result.bellSchedules.first;
    expect(weekdays.days, {1, 2, 3, 4, 5});
    expect(weekdays.times.first.start, '08:30');

    final saturday = result.bellSchedules.last;
    expect(saturday.days, {6});
    expect(saturday.times.last.end, '10:40');
  });

  test('день недели в заголовке звонков пишется и словом', () {
    final result = parser.parse('''
# Расписание звонков на субботу
1. 08:30 - 09:30

# СА-2124
## Пн
1. Сети
''');

    expect(result.bellSchedules.single.days, {6});
  });

  test('строки Markdown-таблицы тоже разбираются', () {
    final result = parser.parse('''
# СА-2124
## Пн
| № | Предмет | Преподаватель | Ауд. |
|---|---------|---------------|------|
| 1 | Сети | Иванов И.И. | 301 |
''');

    // Строка-заголовок таблицы не содержит номера пары и уходит в warnings.
    expect(result.lessons, hasLength(1));
    expect(result.lessons.single.subject.value, 'Сети');
    expect(result.lessons.single.room.value, '301');
  });

  test('«выходной» и пустые дни не ломают разбор', () {
    final result = parser.parse('''
# СА-2124
## Пн
1. Сети
## Сб
нет пар
''');

    expect(result.lessons, hasLength(1));
    expect(result.warnings, isEmpty);
  });

  test('строки без группы попадают в предупреждения, а не теряются молча', () {
    final result = parser.parse('''
## Понедельник
1. Сети

# СА-2124
## Вторник
1. Базы данных
''');

    expect(result.lessons, hasLength(1));
    expect(result.warnings, isNotEmpty);
    expect(result.warnings.first, contains('Понедельник'));
  });

  test('бросает понятную ошибку, если распознать нечего', () {
    expect(
      () => parser.parse('какой-то текст без структуры'),
      throwsA(isA<ParsingException>()),
    );
    expect(() => parser.parse('   '), throwsA(isA<ParsingException>()));
  });

  test('игнорирует содержимое блоков кода', () {
    final result = parser.parse('''
# СА-2124
## Пн
1. Сети
```
2. Это пример, а не пара
```
''');

    expect(result.lessons, hasLength(1));
  });
}
