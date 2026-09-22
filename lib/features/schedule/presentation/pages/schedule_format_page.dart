import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Справка по формату импорта: спецификация, пример и готовый промпт,
/// которым удобно превращать фото/таблицу расписания в нужный Markdown.
class ScheduleFormatPage extends StatefulWidget {
  const ScheduleFormatPage({super.key});

  /// Промпт для нейросети.
  ///
  /// В примере намеренно нет настоящего названия группы: раньше там стояло
  /// «СА-2124», нейросеть переносила его в ответ как есть, и расписание
  /// любой другой группы импортировалось под этим именем — поверх первой.
  /// Если [group] задан, промпт прямо велит использовать это название.
  static String buildPrompt({String? group}) {
    final name = group?.trim() ?? '';
    final groupRule = name.isEmpty
        ? '- Название группы возьми из исходных данных, как там написано.\n'
            '  Если его там нет — оставь `# НАЗВАНИЕ-ГРУППЫ`, название '
            'поправят при импорте.'
        : '- Группа называется «$name». Заголовок группы — ровно `# $name`,\n'
            '  даже если в исходных данных название написано иначе.';

    return '''
Преобразуй расписание занятий в Markdown строго по формату ниже.
Ничего не придумывай: если данных нет — оставляй поле пустым.
В ответе верни только Markdown, без пояснений и без блока ```.

ФОРМАТ
- `# НАЗВАНИЕ-ГРУППЫ` — заголовок первого уровня начинает блок группы.
  В одном файле может быть несколько групп подряд.
$groupRule
- `## День недели` — Понедельник … Суббота.
- Строка пары: `НОМЕР. Предмет | Преподаватель | Аудитория`
  Разделитель — вертикальная черта. Преподавателя и аудиторию можно опустить.
- Если пара только на одной неделе, поставь маркер перед предметом:
  `(числ)` — числитель, `(знам)` — знаменатель.
- Если пара только для подгруппы, поставь `[1]` или `[2]` перед предметом.
- Маркеры можно совмещать: `2. (числ) [1] Английский | Смирнова О.П. | 208`
- Если в день пар нет — не пиши день вообще.
- Блок звонков: `# Звонки` и строки `НОМЕР. ЧЧ:ММ - ЧЧ:ММ`.
  Если в разные дни звонки разные, сделай несколько блоков и укажи дни
  в скобках: `# Звонки (пн-пт)`, `# Звонки (сб)`.
  Блок без указания дней считается основным.

ПРИМЕР
Пример показывает только формат. Не переноси из него ни название группы,
ни предметы, ни преподавателей — всё бери из исходных данных.

# Звонки (пн-пт)
1. 08:30 - 10:00
2. 10:10 - 11:40
3. 12:10 - 13:40

# Звонки (сб)
1. 08:30 - 09:30
2. 09:40 - 10:40

# НАЗВАНИЕ-ГРУППЫ

## Понедельник
1. Компьютерные сети | Иванов И.И. | 301
2. (числ) Математика | Петрова А.А. | 210
2. (знам) Физика | Кузнецов В.В. | 112
3. [1] Английский язык | Смирнова О.П. | 208
3. [2] Английский язык | Волкова Н.С. | 209

## Вторник
1. Операционные системы | Петров П.П. | 305

ИСХОДНЫЕ ДАННЫЕ
<вставь сюда таблицу, текст или фото расписания>
''';
  }

  static const String _spec = '''
Приложение читает расписание из обычного текстового файла .md.
Формат выбран так, чтобы его было легко и написать руками, и получить от
нейросети по промпту (кнопка ниже).

Что понимает парсер:

• `# НАЗВАНИЕ-ГРУППЫ` — название группы, например `# ИС-2301`. Всё, что
  идёт ниже, относится к ней, пока не встретится следующий заголовок группы.
• `## Понедельник` — день недели. Понимаются и сокращения: Пн, Вт, Ср…
• `1. Предмет | Преподаватель | Аудитория` — пара. Номер обязателен,
  остальное — по желанию. Вместо точки можно ставить `)` или `-`.
• `(числ)` / `(знам)` перед предметом — пара только на числителе или
  знаменателе. Без маркера пара идёт каждую неделю.
• `[1]` / `[2]` перед предметом — пара только для этой подгруппы.
• `# Звонки` — блок со временем пар: `1. 08:30 - 10:00`.
  Наборов может быть несколько: `# Звонки (пн-пт)` и `# Звонки (сб)`.
  Набор без дней в заголовке применяется ко всем остальным дням.
• Строки Markdown-таблиц (`| 1 | Предмет | ... |`) тоже разбираются.

Импорт перезаписывает пары только тех групп, которые есть в файле, —
расписание остальных групп остаётся. Чтобы добавить ещё одну группу,
импортируйте её файл так же. Если название группы распознано не так,
его можно поправить на экране импорта перед сохранением.
''';

  @override
  State<ScheduleFormatPage> createState() => _ScheduleFormatPageState();
}

class _ScheduleFormatPageState extends State<ScheduleFormatPage> {
  final _groupController = TextEditingController();

  @override
  void dispose() {
    _groupController.dispose();
    super.dispose();
  }

  String get _prompt =>
      ScheduleFormatPage.buildPrompt(group: _groupController.text);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Формат расписания')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(ScheduleFormatPage._spec, style: theme.textTheme.bodyMedium),
          const SizedBox(height: 24),
          Text('Промпт для нейросети', style: theme.textTheme.titleMedium),
          const SizedBox(height: 8),
          Text(
            'Скопируйте промпт, добавьте в конец фото или текст расписания '
            'и отправьте любой нейросети. Ответ вставьте на экране импорта.',
            style: theme.textTheme.bodySmall
                ?.copyWith(color: theme.colorScheme.onSurfaceVariant),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _groupController,
            textCapitalization: TextCapitalization.characters,
            decoration: const InputDecoration(
              labelText: 'Название группы',
              hintText: 'Например, ИС-2301',
              helperText: 'Необязательно. Если указать — нейросеть подпишет '
                  'расписание именно так.',
              border: OutlineInputBorder(),
            ),
            onChanged: (_) => setState(() {}),
          ),
          const SizedBox(height: 12),
          FilledButton.tonalIcon(
            onPressed: () async {
              await Clipboard.setData(ClipboardData(text: _prompt));
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Промпт скопирован')),
                );
              }
            },
            icon: const Icon(Icons.copy_all_outlined),
            label: const Text('Скопировать промпт'),
          ),
          const SizedBox(height: 16),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: theme.colorScheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(12),
            ),
            child: SelectableText(
              _prompt,
              style: const TextStyle(fontFamily: 'monospace', fontSize: 12),
            ),
          ),
        ],
      ),
    );
  }
}
