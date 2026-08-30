import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/database/database.dart';
import '../../../../core/settings/app_settings.dart';
import '../../../../core/utils/week_utils.dart';
import '../../../../di.dart';
import '../../../schedule/domain/entities/schedule_slot.dart';
import '../../../schedule/domain/repositories/schedule_repository.dart';
import '../../domain/repositories/substitutions_repository.dart';
import '../bloc/substitutions_cubit.dart';
import '../widgets/last_updated_line.dart';

/// Все замены на выбранную дату — по всем группам.
class SubstitutionsPage extends StatefulWidget {
  const SubstitutionsPage({super.key, required this.date});

  final DateTime date;

  @override
  State<SubstitutionsPage> createState() => _SubstitutionsPageState();
}

class _SubstitutionsPageState extends State<SubstitutionsPage> {
  late DateTime _date = WeekUtils.dayKey(widget.date);

  @override
  Widget build(BuildContext context) {
    final repository = getIt<SubstitutionsRepository>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Замены'),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(48),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              IconButton(
                icon: const Icon(Icons.chevron_left),
                onPressed: () => setState(
                  () => _date = _date.subtract(const Duration(days: 1)),
                ),
              ),
              Text(WeekUtils.formatFullDate(_date)),
              IconButton(
                icon: const Icon(Icons.chevron_right),
                onPressed: () => setState(
                  () => _date = _date.add(const Duration(days: 1)),
                ),
              ),
            ],
          ),
        ),
      ),
      body: Column(
        children: [
          const LastUpdatedLine(),
          Expanded(
            child: StreamBuilder<List<Substitution>>(
              stream: repository.watchOnDate(_date),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                final items = snapshot.data ?? const <Substitution>[];
                if (items.isEmpty) return const _EmptyView();
                return _GroupedList(items: items, date: _date);
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        tooltip: 'Загрузить замены на этот день',
        onPressed: () =>
            context.read<SubstitutionsCubit>().refresh(targetDate: _date),
        child: const Icon(Icons.cloud_download_outlined),
      ),
    );
  }
}

class _GroupedList extends StatelessWidget {
  const _GroupedList({required this.items, required this.date});

  final List<Substitution> items;
  final DateTime date;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final myGroup = getIt<AppSettings>().selectedGroup;

    final groups = <String, List<Substitution>>{};
    for (final item in items) {
      groups.putIfAbsent(item.groupName, () => []).add(item);
    }
    final names = groups.keys.toList()..sort();

    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 88),
      itemCount: names.length,
      itemBuilder: (context, index) {
        final name = names[index];
        final rows = groups[name]!
          ..sort((a, b) => a.pairNumber.compareTo(b.pairNumber));

        return Padding(
          padding: const EdgeInsets.only(bottom: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(name, style: theme.textTheme.titleMedium),
                  if (name == myGroup) ...[
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 6, vertical: 1),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.primaryContainer,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        'моя',
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: theme.colorScheme.onPrimaryContainer,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
              const SizedBox(height: 8),
              // Для своей группы известно базовое расписание — можно
              // показать «было → стало». У чужих групп его нет: их
              // schedule никто не импортировал на этом телефоне.
              if (name == myGroup)
                _MyGroupChanges(date: date, groupName: name)
              else
                for (final row in rows) _SubstitutionRow(row: row),
            ],
          ),
        );
      },
    );
  }
}

/// «Было → стало» для группы пользователя — переиспользует тот же
/// merge, что и главный экран, только без фильтра по подгруппе.
class _MyGroupChanges extends StatelessWidget {
  const _MyGroupChanges({required this.date, required this.groupName});

  final DateTime date;
  final String groupName;

  @override
  Widget build(BuildContext context) {
    final settings = getIt<AppSettings>();

    return StreamBuilder<DaySchedule>(
      stream: getIt<ScheduleRepository>().watchDay(
        groupName: groupName,
        date: date,
        invertWeekParity: settings.invertWeekParity,
      ),
      builder: (context, snapshot) {
        final day = snapshot.data;
        if (day == null) {
          return const Padding(
            padding: EdgeInsets.symmetric(vertical: 12),
            child: Center(
              child: SizedBox(
                width: 18,
                height: 18,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            ),
          );
        }

        final changes = day.slots.where((s) => s.isSubstitution).toList();
        if (changes.isEmpty) return const SizedBox.shrink();

        return Column(
          children: [
            for (final slot in changes) _ChangeRow(slot: slot),
          ],
        );
      },
    );
  }
}

class _ChangeRow extends StatelessWidget {
  const _ChangeRow({required this.slot});

  final ScheduleSlot slot;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final accent = slot.isCancelled ? scheme.error : scheme.tertiary;

    final hadOriginal =
        !slot.isExtra && slot.originalSubject != null && !slot.isCancelled;

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: accent.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: accent.withValues(alpha: 0.3)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 28,
            height: 28,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: accent.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              '${slot.pairNumber}',
              style: theme.textTheme.labelLarge
                  ?.copyWith(color: accent, fontWeight: FontWeight.w700),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (slot.isCancelled)
                  Text('Пара снята',
                      style: theme.textTheme.bodyLarge?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: scheme.error,
                      ))
                else if (hadOriginal && slot.originalSubject != slot.subject)
                  Text.rich(
                    TextSpan(children: [
                      TextSpan(
                        text: slot.originalSubject,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: scheme.onSurfaceVariant,
                          decoration: TextDecoration.lineThrough,
                        ),
                      ),
                      const TextSpan(text: '  →  '),
                      TextSpan(
                        text: slot.subject,
                        style: theme.textTheme.bodyLarge
                            ?.copyWith(fontWeight: FontWeight.w600),
                      ),
                    ]),
                  )
                else
                  Text(
                    slot.subject,
                    style: theme.textTheme.bodyLarge
                        ?.copyWith(fontWeight: FontWeight.w600),
                  ),
                if (!slot.isCancelled) ...[
                  const SizedBox(height: 2),
                  Text(
                    [
                      if (slot.teacher.isNotEmpty) slot.teacher,
                      if (slot.room.isNotEmpty) 'ауд. ${slot.room}',
                    ].join(' · '),
                    style: theme.textTheme.bodySmall
                        ?.copyWith(color: scheme.onSurfaceVariant),
                  ),
                ],
                if (slot.isExtra)
                  Text('добавлена',
                      style: theme.textTheme.labelSmall
                          ?.copyWith(color: accent)),
                if (slot.note != null && slot.note!.isNotEmpty)
                  Text(slot.note!,
                      style: theme.textTheme.bodySmall
                          ?.copyWith(color: scheme.onSurfaceVariant)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SubstitutionRow extends StatelessWidget {
  const _SubstitutionRow({required this.row});

  final Substitution row;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final accent = row.isCancelled ? scheme.error : scheme.tertiary;

    final details = [
      if (row.teacher.isNotEmpty) row.teacher,
      if (row.room.isNotEmpty) 'ауд. ${row.room}',
      if (row.note != null && row.note!.isNotEmpty) row.note!,
    ].join(' · ');

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: accent.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: accent.withValues(alpha: 0.3)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 28,
            height: 28,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: accent.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              '${row.pairNumber}',
              style: theme.textTheme.labelLarge
                  ?.copyWith(color: accent, fontWeight: FontWeight.w700),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  row.isCancelled ? 'Пара снята' : row.subject,
                  style: theme.textTheme.bodyLarge?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: row.isCancelled ? scheme.error : null,
                  ),
                ),
                if (details.isNotEmpty)
                  Text(
                    details,
                    style: theme.textTheme.bodySmall
                        ?.copyWith(color: scheme.onSurfaceVariant),
                  ),
                if (row.subgroup != null)
                  Text(
                    '${row.subgroup} подгруппа',
                    style: theme.textTheme.labelSmall?.copyWith(color: accent),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
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
            Icon(Icons.inbox_outlined,
                size: 48, color: theme.colorScheme.outline),
            const SizedBox(height: 12),
            Text('На этот день замен нет',
                style: theme.textTheme.titleMedium),
            const SizedBox(height: 4),
            Text(
              'Либо документ ещё не выложили, либо он не загружен.',
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
