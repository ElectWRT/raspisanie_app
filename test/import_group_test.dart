import 'package:flutter_test/flutter_test.dart';
import 'package:raspisanie_app/features/schedule/data/datasources/markdown_schedule_parser.dart';
import 'package:raspisanie_app/features/schedule/presentation/pages/schedule_format_page.dart';

void main() {
  const parser = MarkdownScheduleParser();

  group('промпт для нейросети', () {
    test('не содержит конкретной группы, которую можно скопировать', () {
      // Из-за «СА-2124» в примере нейросеть подписывала этим именем
      // расписание любой группы, и второй импорт затирал первый.
      final prompt = ScheduleFormatPage.buildPrompt();

      expect(prompt, isNot(contains('СА-2124')));
      expect(prompt, contains('возьми из исходных данных'));
    });

    test('с названием группы велит использовать именно его', () {
      final prompt = ScheduleFormatPage.buildPrompt(group: ' ИС-2301 ');

      expect(prompt, contains('`# ИС-2301`'));
    });

    test('пустое название — как без него', () {
      expect(
        ScheduleFormatPage.buildPrompt(group: '   '),
        ScheduleFormatPage.buildPrompt(),
      );
    });
  });

  group('название группы в заголовке', () {
    test('«Группа ИС-2301» — префикс срезается', () {
      final result = parser.parse('# Группа ИС-2301\n## Пн\n1. Сети');
      expect(result.groups, ['ИС-2301']);
    });

    test('голое «Группа» не превращается в пустое название', () {
      final result = parser.parse('# Группа\n## Пн\n1. Сети');
      expect(result.groups, ['Группа']);
    });

    test('заглушка из промпта сохраняется как есть, чтобы её переименовать', () {
      final result = parser.parse('# НАЗВАНИЕ-ГРУППЫ\n## Пн\n1. Сети');
      expect(result.groups, ['НАЗВАНИЕ-ГРУППЫ']);
    });
  });

  group('переименование группы при импорте', () {
    const markdown = '''
# НАЗВАНИЕ-ГРУППЫ
## Понедельник
1. Сети | Иванов И.И. | 301
2. ОС | Петров П.П. | 305
''';

    test('пары и счётчик переезжают на новое название', () {
      final result =
          parser.parse(markdown).renameGroup('НАЗВАНИЕ-ГРУППЫ', 'ИС-2301');

      expect(result.lessonsPerGroup, {'ИС-2301': 2});
      expect(
        result.lessons.map((l) => l.groupName.value).toSet(),
        {'ИС-2301'},
      );
    });

    test('если такая группа уже есть в файле — сливаются', () {
      final result = parser.parse('''
# А
## Понедельник
1. Сети
# Б
## Вторник
1. ОС
''').renameGroup('Б', 'А');

      expect(result.lessonsPerGroup, {'А': 2});
      expect(result.lessons, hasLength(2));
    });

    test('пустое или то же самое название ничего не меняет', () {
      final original = parser.parse(markdown);

      expect(original.renameGroup('НАЗВАНИЕ-ГРУППЫ', '  '), same(original));
      expect(original.renameGroup('НАЗВАНИЕ-ГРУППЫ', 'НАЗВАНИЕ-ГРУППЫ'), same(original));
    });

    test('звонки и предупреждения не теряются', () {
      final original = parser.parse('''
# Звонки
1. 08:30 - 10:00
$markdown''');
      final renamed = original.renameGroup('НАЗВАНИЕ-ГРУППЫ', 'ИС-2301');

      expect(renamed.bellSchedules, original.bellSchedules);
      expect(renamed.warnings, original.warnings);
    });
  });
}
