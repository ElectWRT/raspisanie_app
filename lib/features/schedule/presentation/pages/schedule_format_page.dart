import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Справка по формату импорта: спецификация, пример и готовый промпт,
/// которым удобно превращать фото/таблицу расписания в нужный Markdown.
class ScheduleFormatPage extends StatelessWidget {
  const ScheduleFormatPage({super.key});

  static const String prompt = '''
Преобразуй расписание занятий в Markdown строго по формату ниже.
Ничего не придумывай: если данных нет — оставляй поле пустым.
В ответе верни только Markdown, без пояснений и без блока ```.

ФОРМАТ
- `# НАЗВАНИЕ-ГРУППЫ` — заголовок первого уровня начинает блок группы.
  В одном файле может быть несколько групп подряд.
- `## День недели` — Понедельник … Суббота.
- Строка пары: `НОМЕР. Предмет | Преподаватель | Аудитория`
  Разделитель — вертикальная черта. Преподавателя и аудиторию можно опустить.
- Если пара только на одной неделе, поставь маркер перед предметом:
  `(числ)` — числитель, `(знам)` — знаменатель.
- Если пара только для подгруппы, поставь `[1]` или `[2]` перед предметом.
- Маркеры можно совмещать: `2. (числ) [1] Английский | Смирнова О.П. | 208`
- Если в день пар нет — не пиши день вообще.
- Необязательный блок `# Звонки` со строками `НОМЕР. ЧЧ:ММ - ЧЧ:ММ`.

ПРИМЕР
# Звонки
1. 08:30 - 10:00
2. 10:10 - 11:40
3. 12:10 - 13:40

# СА-2124

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

  static const String _spec = '''
Приложение читает расписание из обычного текстового файла .md.
Формат выбран так, чтобы его было легко и написать руками, и получить от
нейросети по промпту (кнопка ниже).

Что понимает парсер:

• `# СА-2124` — название группы. Всё, что идёт ниже, относится к ней,
  пока не встретится следующий заголовок группы.
• `## Понедельник` — день недели. Понимаются и сокращения: Пн, Вт, Ср…
• `1. Предмет | Преподаватель | Аудитория` — пара. Номер обязателен,
  остальное — по желанию. Вместо точки можно ставить `)` или `-`.
• `(числ)` / `(знам)` перед предметом — пара только на числителе или
  знаменателе. Без маркера пара идёт каждую неделю.
• `[1]` / `[2]` перед предметом — пара только для этой подгруппы.
• `# Звонки` — блок со временем пар: `1. 08:30 - 10:00`.
• Строки Markdown-таблиц (`| 1 | Предмет | ... |`) тоже разбираются.

Импорт перезаписывает пары только тех групп, которые есть в файле.
''';

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Формат расписания')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(_spec, style: theme.textTheme.bodyMedium),
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
          FilledButton.tonalIcon(
            onPressed: () async {
              await Clipboard.setData(const ClipboardData(text: prompt));
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
            child: const SelectableText(
              prompt,
              style: TextStyle(fontFamily: 'monospace', fontSize: 12),
            ),
          ),
        ],
      ),
    );
  }
}
