import 'package:flutter/material.dart';
import 'package:rxdart/rxdart.dart';

import '../../../../core/utils/week_utils.dart';
import '../../domain/entities/bell_schedule.dart';
import '../../domain/entities/schedule_slot.dart';
import '../../domain/repositories/schedule_repository.dart';

class WeekOverview extends StatefulWidget {
  const WeekOverview({
    super.key,
    required this.repository,
    required this.weekStart,
    required this.group,
    required this.showWeekends,
    required this.subgroup,
    required this.invertWeekParity,
    required this.bellSchedules,
    required this.onSelect,
    required this.onRefresh,
  });

  final ScheduleRepository repository;
  final DateTime weekStart;
  final String group;
  final bool showWeekends;
  final String? subgroup;
  final bool invertWeekParity;
  final List<BellSchedule> bellSchedules;
  final ValueChanged<DateTime> onSelect;
  final Future<void> Function() onRefresh;

  @override
  State<WeekOverview> createState() => _WeekOverviewState();
}

class _WeekOverviewState extends State<WeekOverview> {
  late Stream<List<DaySchedule>> _week = _watchWeek();

  @override
  void didUpdateWidget(covariant WeekOverview oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.repository != oldWidget.repository ||
        widget.weekStart != oldWidget.weekStart ||
        widget.group != oldWidget.group ||
        widget.showWeekends != oldWidget.showWeekends ||
        widget.subgroup != oldWidget.subgroup ||
        widget.invertWeekParity != oldWidget.invertWeekParity) {
      _week = _watchWeek();
    }
  }

  Stream<List<DaySchedule>> _watchWeek() {
    final start = widget.weekStart;
    return Rx.combineLatestList([
      for (var i = 0; i < (widget.showWeekends ? 7 : 5); i++)
        widget.repository.watchDay(
          groupName: widget.group,
          date: DateTime(start.year, start.month, start.day + i),
          subgroup: widget.subgroup,
          invertWeekParity: widget.invertWeekParity,
        ),
    ]);
  }

  @override
  Widget build(BuildContext context) => StreamBuilder<List<DaySchedule>>(
        key: ObjectKey(_week),
        stream: _week,
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(
              child: FilledButton.tonalIcon(
                onPressed: () => setState(() => _week = _watchWeek()),
                icon: const Icon(Icons.refresh),
                label: const Text('Повторить загрузку недели'),
              ),
            );
          }
          final days = snapshot.data;
          if (days == null) {
            return const Center(child: CircularProgressIndicator());
          }
          final today = WeekUtils.dayKey(DateTime.now());
          return RefreshIndicator(
            onRefresh: widget.onRefresh,
            child: ListView.separated(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(16, 4, 16, 96),
              itemCount: days.length,
              separatorBuilder: (_, __) => const SizedBox(height: 8),
              itemBuilder: (context, index) {
                final day = days[index];
                return _WeekDayTile(
                  day: day,
                  bells: bellScheduleForDate(widget.bellSchedules, day.date),
                  isToday: day.date == today,
                  onTap: () => widget.onSelect(day.date),
                );
              },
            ),
          );
        },
      );
}

class _WeekDayTile extends StatelessWidget {
  const _WeekDayTile({
    required this.day,
    required this.bells,
    required this.isToday,
    required this.onTap,
  });

  final DaySchedule day;
  final BellSchedule? bells;
  final bool isToday;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final pairs = {
      for (final slot in day.slots)
        if (!slot.isCancelled) slot.pairNumber,
    };
    final firstPair =
        pairs.isEmpty ? null : pairs.reduce((a, b) => a < b ? a : b);
    final start = firstPair == null ? null : bells?.timeFor(firstPair)?.start;
    final summary = [
      pairs.isEmpty ? 'Нет занятий' : WeekUtils.formatPairCount(pairs.length),
      if (start != null) 'с $start',
    ].join(' · ');
    final date = day.date;
    final label = '${WeekUtils.dayName(date.weekday)}, '
        '${date.day} ${WeekUtils.monthsGenitive[date.month - 1]}';
    final shape =
        RoundedRectangleBorder(borderRadius: BorderRadius.circular(20));

    return Material(
      color: isToday ? scheme.primaryContainer : scheme.surfaceContainerLow,
      shape: shape,
      clipBehavior: Clip.antiAlias,
      child: ListTile(
        shape: shape,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        textColor: isToday ? scheme.onPrimaryContainer : scheme.onSurface,
        title: Text(
          label,
          style: const TextStyle(fontWeight: FontWeight.w700),
        ),
        subtitle: Wrap(
          spacing: 10,
          runSpacing: 4,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            Text(summary),
            if (day.substitutionCount > 0)
              DecoratedBox(
                decoration: BoxDecoration(
                  color: scheme.tertiaryContainer,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  child: Text(
                    'Замен: ${day.substitutionCount}',
                    style: theme.textTheme.labelMedium
                        ?.copyWith(color: scheme.onTertiaryContainer),
                  ),
                ),
              ),
          ],
        ),
        trailing: const Icon(Icons.chevron_right),
        onTap: onTap,
      ),
    );
  }
}
