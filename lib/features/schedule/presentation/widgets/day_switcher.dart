import 'package:flutter/material.dart';

import '../../../../core/utils/week_utils.dart';

/// Полоса с днями недели и переключением между неделями.
class DaySwitcher extends StatelessWidget {
  const DaySwitcher({super.key, required this.date, required this.onSelect});

  final DateTime date;
  final ValueChanged<DateTime> onSelect;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final weekStart = WeekUtils.startOfWeek(date);
    final today = WeekUtils.dayKey(DateTime.now());

    return Padding(
      padding: const EdgeInsets.fromLTRB(8, 0, 8, 8),
      child: Column(
        children: [
          Row(
            children: [
              IconButton(
                tooltip: 'Предыдущая неделя',
                icon: const Icon(Icons.chevron_left),
                onPressed: () =>
                    onSelect(date.subtract(const Duration(days: 7))),
              ),
              Expanded(
                child: Center(
                  child: TextButton(
                    onPressed: () => onSelect(today),
                    child: Text(
                      WeekUtils.formatFullDate(date),
                      style: theme.textTheme.labelLarge,
                    ),
                  ),
                ),
              ),
              IconButton(
                tooltip: 'Следующая неделя',
                icon: const Icon(Icons.chevron_right),
                onPressed: () => onSelect(date.add(const Duration(days: 7))),
              ),
            ],
          ),
          Row(
            children: [
              for (var i = 0; i < 7; i++)
                Expanded(
                  child: _DayChip(
                    day: weekStart.add(Duration(days: i)),
                    isSelected: WeekUtils.dayKey(date) ==
                        weekStart.add(Duration(days: i)),
                    isToday: today == weekStart.add(Duration(days: i)),
                    onTap: onSelect,
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

class _DayChip extends StatelessWidget {
  const _DayChip({
    required this.day,
    required this.isSelected,
    required this.isToday,
    required this.onTap,
  });

  final DateTime day;
  final bool isSelected;
  final bool isToday;
  final ValueChanged<DateTime> onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    final background = isSelected ? scheme.primary : Colors.transparent;
    final foreground = isSelected
        ? scheme.onPrimary
        : isToday
            ? scheme.primary
            : scheme.onSurface;

    return InkWell(
      borderRadius: BorderRadius.circular(12),
      onTap: () => onTap(day),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 2),
        padding: const EdgeInsets.symmetric(vertical: 6),
        decoration: BoxDecoration(
          color: background,
          borderRadius: BorderRadius.circular(12),
          border: isToday && !isSelected
              ? Border.all(color: scheme.primary.withValues(alpha: 0.5))
              : null,
        ),
        child: Column(
          children: [
            Text(
              WeekUtils.dayNameShort(day.weekday),
              style: theme.textTheme.labelSmall?.copyWith(
                color: foreground.withValues(alpha: 0.8),
              ),
            ),
            const SizedBox(height: 2),
            Text(
              '${day.day}',
              style: theme.textTheme.titleSmall?.copyWith(
                color: foreground,
                fontWeight: isSelected || isToday
                    ? FontWeight.w700
                    : FontWeight.w400,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
