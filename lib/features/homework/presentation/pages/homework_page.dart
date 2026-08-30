import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/database/database.dart';
import '../../../../core/utils/week_utils.dart';
import '../../domain/homework_priority_ui.dart';
import '../bloc/homework_cubit.dart';
import '../widgets/homework_editor_sheet.dart';

class HomeworkPage extends StatelessWidget {
  const HomeworkPage({super.key, this.subjects = const [], this.highlightId});

  /// Предметы из расписания — подсказки в редакторе.
  final List<String> subjects;

  /// Задание, открытое по тапу на уведомление — подсвечивается в списке.
  final int? highlightId;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<HomeworkCubit, HomeworkState>(
      builder: (context, state) {
        final cubit = context.read<HomeworkCubit>();

        return Scaffold(
          appBar: AppBar(
            title: const Text('Домашние задания'),
            actions: [
              IconButton(
                tooltip: state.showDone ? 'Скрыть сделанные' : 'Показать сделанные',
                icon: Icon(state.showDone
                    ? Icons.visibility_off_outlined
                    : Icons.visibility_outlined),
                onPressed: cubit.toggleShowDone,
              ),
            ],
          ),
          floatingActionButton: FloatingActionButton.extended(
            onPressed: () => _openEditor(context),
            icon: const Icon(Icons.add),
            label: const Text('Задание'),
          ),
          body: switch (state) {
            HomeworkState(isLoading: true) =>
              const Center(child: CircularProgressIndicator()),
            HomeworkState(error: final String message) =>
              _ErrorView(message: message),
            HomeworkState(items: final items) when items.isEmpty =>
              const _EmptyView(),
            _ => _HomeworkList(
                state: state,
                subjects: subjects,
                highlightId: highlightId,
              ),
          },
        );
      },
    );
  }

  Future<void> _openEditor(BuildContext context, {Homework? existing}) async {
    final cubit = context.read<HomeworkCubit>();

    final draft = await showModalBottomSheet<HomeworkDraft>(
      context: context,
      isScrollControlled: true,
      builder: (_) => HomeworkEditorSheet(
        existing: existing,
        subjects: subjects,
      ),
    );
    if (draft == null) return;

    if (existing == null) {
      await cubit.add(
        subject: draft.subject,
        description: draft.description,
        dueDate: draft.dueDate,
        priority: draft.priority,
      );
    } else {
      await cubit.save(existing.copyWith(
        subject: draft.subject,
        description: draft.description,
        dueDate: draft.dueDate,
        priority: draft.priority,
      ));
    }
  }
}

class _HomeworkList extends StatelessWidget {
  const _HomeworkList({
    required this.state,
    required this.subjects,
    this.highlightId,
  });

  final HomeworkState state;
  final List<String> subjects;
  final int? highlightId;

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final groups = _groupByDue(state.items, now);

    // Сквозной счётчик для задержки анимации — так карточки появляются
    // по порядку сверху вниз, а не пачкой по группам.
    var cardIndex = 0;

    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 96),
      itemCount: groups.length,
      itemBuilder: (context, index) {
        final entry = groups[index];
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: EdgeInsets.only(top: index == 0 ? 0 : 20, bottom: 8),
              child: Text(
                entry.title,
                style: Theme.of(context).textTheme.labelLarge?.copyWith(
                      color: entry.isOverdue
                          ? Theme.of(context).colorScheme.error
                          : Theme.of(context).colorScheme.primary,
                      fontWeight: FontWeight.w700,
                    ),
              ),
            ),
            for (final item in entry.items)
              Padding(
                key: ValueKey('hw-${item.id}'),
                padding: const EdgeInsets.only(bottom: 10),
                child: _HomeworkCard(
                  item: item,
                  subjects: subjects,
                  now: now,
                  highlighted: item.id == highlightId,
                )
                    .animate(delay: Duration(milliseconds: 30 * cardIndex++))
                    .fadeIn(duration: 220.ms, curve: Curves.easeOut)
                    .slideY(
                      begin: 0.08,
                      end: 0,
                      duration: 220.ms,
                      curve: Curves.easeOut,
                    ),
              ),
          ],
        );
      },
    );
  }

  /// Группирует по сроку: просроченное, сегодня, завтра, дальше по датам.
  static List<_DueGroup> _groupByDue(List<Homework> items, DateTime now) {
    final today = WeekUtils.dayKey(now);
    final overdue = <Homework>[];
    final byDate = <DateTime, List<Homework>>{};

    for (final item in items) {
      final due = WeekUtils.dayKey(item.dueDate);
      if (!item.isDone && due.isBefore(today)) {
        overdue.add(item);
      } else {
        byDate.putIfAbsent(due, () => []).add(item);
      }
    }

    final dates = byDate.keys.toList()..sort();
    return [
      if (overdue.isNotEmpty)
        _DueGroup(title: 'ПРОСРОЧЕНО', items: overdue, isOverdue: true),
      for (final date in dates)
        _DueGroup(
          title: '${dueCaption(date, now).toUpperCase()} · '
              '${WeekUtils.formatFullDate(date)}',
          items: byDate[date]!,
        ),
    ];
  }
}

class _DueGroup {
  final String title;
  final List<Homework> items;
  final bool isOverdue;

  const _DueGroup({
    required this.title,
    required this.items,
    this.isOverdue = false,
  });
}

class _HomeworkCard extends StatelessWidget {
  const _HomeworkCard({
    required this.item,
    required this.subjects,
    required this.now,
    this.highlighted = false,
  });

  final Homework item;
  final List<String> subjects;
  final DateTime now;

  /// Открыто по тапу на уведомление — выделяем, чтобы сразу нашли глазами.
  final bool highlighted;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final accent = item.priority.color(scheme);

    return Card(
      color: highlighted
          ? scheme.primaryContainer.withValues(alpha: 0.45)
          : item.isDone
              ? scheme.surfaceContainerLowest
              : scheme.surfaceContainerLow,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: highlighted
              ? scheme.primary
              : item.isDone
                  ? scheme.outlineVariant
                  : accent.withValues(alpha: 0.45),
          width: highlighted ? 1.6 : 1,
        ),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () => _edit(context),
        onLongPress: () => _confirmDelete(context),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(8, 10, 14, 12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Checkbox(
                value: item.isDone,
                onChanged: (value) => context
                    .read<HomeworkCubit>()
                    .setDone(item, value ?? false),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            item.subject,
                            style: theme.textTheme.titleSmall?.copyWith(
                              fontWeight: FontWeight.w600,
                              decoration: item.isDone
                                  ? TextDecoration.lineThrough
                                  : null,
                              color: item.isDone ? scheme.outline : null,
                            ),
                          ),
                        ),
                        if (!item.isDone)
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: accent.withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              item.priority.shortLabel,
                              style: theme.textTheme.labelSmall?.copyWith(
                                color: accent,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      item.description,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: item.isDone
                            ? scheme.outline
                            : scheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _edit(BuildContext context) async {
    final cubit = context.read<HomeworkCubit>();

    final draft = await showModalBottomSheet<HomeworkDraft>(
      context: context,
      isScrollControlled: true,
      builder: (_) => HomeworkEditorSheet(existing: item, subjects: subjects),
    );
    if (draft == null) return;

    await cubit.save(item.copyWith(
      subject: draft.subject,
      description: draft.description,
      dueDate: draft.dueDate,
      priority: draft.priority,
    ));
  }

  Future<void> _confirmDelete(BuildContext context) async {
    final cubit = context.read<HomeworkCubit>();

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Удалить задание?'),
        content: Text('«${item.subject}» — ${item.description}'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text('Отмена'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(dialogContext).colorScheme.error,
            ),
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: const Text('Удалить'),
          ),
        ],
      ),
    );

    if (confirmed == true) await cubit.remove(item);
  }
}

class _EmptyView extends StatelessWidget {
  const _EmptyView();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.task_alt, size: 56, color: theme.colorScheme.outline),
            const SizedBox(height: 16),
            Text('Заданий нет', style: theme.textTheme.titleMedium),
            const SizedBox(height: 8),
            Text(
              'Добавьте задание — приложение напомнит о нём заранее, '
              'если приоритет выше «не критично».',
              textAlign: TextAlign.center,
              style: theme.textTheme.bodySmall
                  ?.copyWith(color: theme.colorScheme.onSurfaceVariant),
            ),
          ],
        ),
      ),
    );
  }
}

class _ErrorView extends StatelessWidget {
  const _ErrorView({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.error_outline, size: 48, color: theme.colorScheme.error),
            const SizedBox(height: 12),
            SelectableText(message, textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }
}
