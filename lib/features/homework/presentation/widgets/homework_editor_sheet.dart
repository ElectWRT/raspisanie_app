import 'package:flutter/material.dart';

import '../../../../core/database/database.dart';
import '../../../../core/utils/week_utils.dart';
import '../../domain/homework_priority_ui.dart';

/// Что вернул редактор: новое или отредактированное задание.
class HomeworkDraft {
  final String subject;
  final String description;
  final DateTime dueDate;
  final HomeworkPriority priority;

  const HomeworkDraft({
    required this.subject,
    required this.description,
    required this.dueDate,
    required this.priority,
  });
}

/// Лист создания и правки задания.
///
/// [subjects] — предметы из расписания группы, чтобы не набирать вручную.
class HomeworkEditorSheet extends StatefulWidget {
  const HomeworkEditorSheet({
    super.key,
    this.existing,
    this.subjects = const [],
    this.initialSubject,
  });

  final Homework? existing;
  final List<String> subjects;
  final String? initialSubject;

  @override
  State<HomeworkEditorSheet> createState() => _HomeworkEditorSheetState();
}

class _HomeworkEditorSheetState extends State<HomeworkEditorSheet> {
  late final TextEditingController _subjectController = TextEditingController(
    text: widget.existing?.subject ?? widget.initialSubject ?? '',
  );
  late final TextEditingController _descriptionController =
      TextEditingController(text: widget.existing?.description ?? '');

  late DateTime _dueDate = widget.existing?.dueDate ??
      WeekUtils.dayKey(DateTime.now().add(const Duration(days: 1)));
  late HomeworkPriority _priority =
      widget.existing?.priority ?? HomeworkPriority.normal;

  String? _error;

  @override
  void dispose() {
    _subjectController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _dueDate,
      firstDate: DateTime(now.year - 1),
      lastDate: DateTime(now.year + 2),
      helpText: 'Когда сдавать',
    );
    if (picked != null) setState(() => _dueDate = WeekUtils.dayKey(picked));
  }

  void _submit() {
    final subject = _subjectController.text.trim();
    final description = _descriptionController.text.trim();

    if (subject.isEmpty) {
      setState(() => _error = 'Укажите предмет');
      return;
    }
    if (description.isEmpty) {
      setState(() => _error = 'Напишите, что задали');
      return;
    }

    Navigator.of(context).pop(HomeworkDraft(
      subject: subject,
      description: description,
      dueDate: _dueDate,
      priority: _priority,
    ));
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final insets = MediaQuery.of(context).viewInsets;

    return Padding(
      padding: EdgeInsets.only(bottom: insets.bottom),
      child: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                widget.existing == null ? 'Новое задание' : 'Правка задания',
                style: theme.textTheme.titleLarge,
              ),
              const SizedBox(height: 20),
              _subjectField(scheme),
              const SizedBox(height: 14),
              TextField(
                controller: _descriptionController,
                maxLines: 4,
                minLines: 2,
                textCapitalization: TextCapitalization.sentences,
                decoration: const InputDecoration(
                  labelText: 'Что задали',
                  alignLabelWithHint: true,
                ),
              ),
              const SizedBox(height: 18),
              Text('Когда сдавать', style: theme.textTheme.labelLarge),
              const SizedBox(height: 8),
              OutlinedButton.icon(
                onPressed: _pickDate,
                icon: const Icon(Icons.event_outlined, size: 18),
                label: Text(
                  '${WeekUtils.formatFullDate(_dueDate)}'
                  '  ·  ${dueCaption(_dueDate, DateTime.now())}',
                ),
              ),
              const SizedBox(height: 18),
              Text('Насколько обязательно', style: theme.textTheme.labelLarge),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                children: [
                  for (final option in HomeworkPriority.values)
                    ChoiceChip(
                      label: Text(option.label),
                      avatar: Icon(
                        option.icon,
                        size: 16,
                        color: _priority == option
                            ? option.color(scheme)
                            : scheme.onSurfaceVariant,
                      ),
                      selected: _priority == option,
                      onSelected: (_) => setState(() => _priority = option),
                    ),
                ],
              ),
              if (_priority == HomeworkPriority.optional)
                Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Text(
                    'О необязательных заданиях уведомления не приходят.',
                    style: theme.textTheme.bodySmall
                        ?.copyWith(color: scheme.onSurfaceVariant),
                  ),
                ),
              if (_error != null)
                Padding(
                  padding: const EdgeInsets.only(top: 12),
                  child: Text(
                    _error!,
                    style: theme.textTheme.bodySmall
                        ?.copyWith(color: scheme.error),
                  ),
                ),
              const SizedBox(height: 22),
              Row(
                children: [
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text('Отмена'),
                  ),
                  const Spacer(),
                  FilledButton(
                    onPressed: _submit,
                    child: Text(
                      widget.existing == null ? 'Добавить' : 'Сохранить',
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Поле предмета с подсказками из расписания — печатать целиком не нужно.
  Widget _subjectField(ColorScheme scheme) {
    if (widget.subjects.isEmpty) {
      return TextField(
        controller: _subjectController,
        textCapitalization: TextCapitalization.sentences,
        decoration: const InputDecoration(labelText: 'Предмет'),
      );
    }

    return Autocomplete<String>(
      initialValue: TextEditingValue(text: _subjectController.text),
      optionsBuilder: (value) {
        final query = value.text.trim().toLowerCase();
        if (query.isEmpty) return widget.subjects;
        return widget.subjects
            .where((s) => s.toLowerCase().contains(query))
            .toList();
      },
      onSelected: (value) => _subjectController.text = value,
      fieldViewBuilder: (context, controller, focusNode, onSubmitted) {
        // Autocomplete держит свой контроллер — синхронизируем с нашим.
        controller.addListener(() => _subjectController.text = controller.text);
        return TextField(
          controller: controller,
          focusNode: focusNode,
          textCapitalization: TextCapitalization.sentences,
          decoration: const InputDecoration(
            labelText: 'Предмет',
            helperText: 'Начните печатать — подставится из расписания',
          ),
        );
      },
    );
  }
}
