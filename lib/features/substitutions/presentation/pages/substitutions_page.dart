import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/database/database.dart';
import '../../../../core/utils/week_utils.dart';
import '../../../../di.dart';
import '../../domain/repositories/substitutions_repository.dart';
import '../bloc/substitutions_cubit.dart';

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
          const _LastUpdatedLine(),
          Expanded(
            child: StreamBuilder<List<Substitution>>(
              stream: repository.watchOnDate(_date),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                final items = snapshot.data ?? const <Substitution>[];
                if (items.isEmpty) return const _EmptyView();
                return _GroupedList(items: items);
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
  const _GroupedList({required this.items});

  final List<Substitution> items;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
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
              Text(name, style: theme.textTheme.titleMedium),
              const SizedBox(height: 8),
              for (final row in rows) _SubstitutionRow(row: row),
            ],
          ),
        );
      },
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

class _LastUpdatedLine extends StatelessWidget {
  const _LastUpdatedLine();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SubstitutionsCubit, SubstitutionsState>(
      builder: (context, state) {
        final theme = Theme.of(context);
        final updated = state.lastUpdated;

        return Padding(
          padding: const EdgeInsets.fromLTRB(16, 4, 16, 0),
          child: Row(
            children: [
              if (state.status == RefreshStatus.loading)
                const SizedBox(
                  width: 12,
                  height: 12,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              else
                Icon(Icons.schedule,
                    size: 14, color: theme.colorScheme.onSurfaceVariant),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  updated == null
                      ? 'Замены ещё не загружались'
                      : 'Обновлено ${_formatTime(updated)}',
                  style: theme.textTheme.bodySmall
                      ?.copyWith(color: theme.colorScheme.onSurfaceVariant),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  static String _formatTime(DateTime value) {
    final now = DateTime.now();
    final time = '${value.hour.toString().padLeft(2, '0')}:'
        '${value.minute.toString().padLeft(2, '0')}';
    if (WeekUtils.dayKey(value) == WeekUtils.dayKey(now)) {
      return 'сегодня в $time';
    }
    return '${value.day} ${WeekUtils.monthsGenitive[value.month - 1]} в $time';
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
