import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../bloc/attendance_cubit.dart';

/// Часто нужные вещи — чтобы не набирать руками каждый раз.
const _suggestions = [
  'Ноутбук',
  'Планшет',
  'Наушники',
  'Тетрадь',
  'Калькулятор',
  'Линейка',
  'Спортивная форма',
  'Учебник',
];

/// Открывает редактор профиля предмета: профильный он или нет и что
/// брать на пару.
Future<void> showSubjectProfileSheet(
  BuildContext context, {
  required String subject,
}) {
  final cubit = context.read<AttendanceCubit>();
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    builder: (sheetContext) => BlocProvider.value(
      value: cubit,
      child: Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(sheetContext).viewInsets.bottom,
        ),
        child: _SubjectProfileSheet(subject: subject),
      ),
    ),
  );
}

class _SubjectProfileSheet extends StatefulWidget {
  const _SubjectProfileSheet({required this.subject});

  final String subject;

  @override
  State<_SubjectProfileSheet> createState() => _SubjectProfileSheetState();
}

class _SubjectProfileSheetState extends State<_SubjectProfileSheet> {
  late bool _isMajor;
  late List<String> _items;
  late TextEditingController _noteController;
  final _itemController = TextEditingController();

  @override
  void initState() {
    super.initState();
    final state = context.read<AttendanceCubit>().state;
    final profile = state.profileFor(widget.subject);

    _isMajor = profile?.isMajor ?? false;
    _items = List.of(state.itemsFor(widget.subject));
    _noteController = TextEditingController(text: profile?.note ?? '');
  }

  @override
  void dispose() {
    _noteController.dispose();
    _itemController.dispose();
    super.dispose();
  }

  void _addItem(String raw) {
    final value = raw.trim();
    if (value.isEmpty) return;
    // Без учёта регистра: «Ноутбук» и «ноутбук» — одна и та же вещь.
    final exists =
        _items.any((e) => e.toLowerCase() == value.toLowerCase());
    if (exists) return;
    setState(() => _items.add(value));
    _itemController.clear();
  }

  Future<void> _save() async {
    await context.read<AttendanceCubit>().saveProfile(
          subject: widget.subject,
          isMajor: _isMajor,
          items: _items,
          note: _noteController.text,
        );
    if (mounted) Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final unused = _suggestions
        .where((s) => !_items.any((e) => e.toLowerCase() == s.toLowerCase()))
        .toList();

    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(widget.subject, style: theme.textTheme.titleMedium),
            const SizedBox(height: 4),
            Text(
              'Профиль предмета',
              style: theme.textTheme.bodySmall
                  ?.copyWith(color: theme.colorScheme.onSurfaceVariant),
            ),
            const SizedBox(height: 16),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              value: _isMajor,
              onChanged: (value) => setState(() => _isMajor = value),
              title: const Text('Профильный предмет'),
              subtitle: const Text(
                'Пропуск считается по строгому лимиту, и день с такой парой '
                'не бывает «просто можно»',
              ),
            ),
            const SizedBox(height: 12),
            Text('Что взять на пару', style: theme.textTheme.titleSmall),
            const SizedBox(height: 8),
            if (_items.isNotEmpty)
              Wrap(
                spacing: 8,
                runSpacing: 4,
                children: [
                  for (final item in _items)
                    InputChip(
                      label: Text(item),
                      onDeleted: () => setState(() => _items.remove(item)),
                    ),
                ],
              ),
            if (_items.isNotEmpty) const SizedBox(height: 8),
            TextField(
              controller: _itemController,
              textInputAction: TextInputAction.done,
              decoration: InputDecoration(
                hintText: 'Добавить своё',
                border: const OutlineInputBorder(),
                isDense: true,
                suffixIcon: IconButton(
                  icon: const Icon(Icons.add),
                  onPressed: () => _addItem(_itemController.text),
                ),
              ),
              onSubmitted: _addItem,
            ),
            if (unused.isNotEmpty) ...[
              const SizedBox(height: 10),
              Wrap(
                spacing: 8,
                runSpacing: 4,
                children: [
                  for (final suggestion in unused)
                    ActionChip(
                      label: Text(suggestion),
                      onPressed: () => _addItem(suggestion),
                    ),
                ],
              ),
            ],
            const SizedBox(height: 16),
            TextField(
              controller: _noteController,
              maxLines: 2,
              decoration: const InputDecoration(
                labelText: 'Заметка',
                hintText: 'Например: преподаватель отмечает по журналу',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('Отмена'),
                ),
                const Spacer(),
                FilledButton(
                  onPressed: _save,
                  child: const Text('Сохранить'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
