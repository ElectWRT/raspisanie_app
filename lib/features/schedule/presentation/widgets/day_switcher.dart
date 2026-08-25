import 'package:flutter/material.dart';

import '../../../../core/utils/week_utils.dart';

/// Полоса с днями недели и переключением между неделями.
class DaySwitcher extends StatelessWidget {
  const DaySwitcher({
    super.key,
    required this.date,
    required this.onSelect,
    this.showWeekends = true,
    this.substitutionDays = const {},
  });

  final DateTime date;
  final ValueChanged<DateTime> onSelect;

  /// Показывать субботу и воскресенье.
  final bool showWeekends;

  /// Дни недели (1..7), на которые есть замены — помечаем точкой.
  final Set<int> substitutionDays;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final weekStart = WeekUtils.startOfWeek(date);
    final today = WeekUtils.dayKey(DateTime.now());
    final dayCount = showWeekends ? 7 : 5;

    return Padding(
      padding: const EdgeInsets.fromLTRB(8, 0, 8, 10),
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
                  child: TextButton.icon(
                    onPressed: () => onSelect(today),
                    icon: Icon(
                      Icons.today_outlined,
                      size: 16,
                      color: WeekUtils.dayKey(date) == today
                          ? theme.colorScheme.primary
                          : theme.colorScheme.onSurfaceVariant,
                    ),
                    label: Text(
                      _caption(date, today),
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
              for (var i = 0; i < dayCount; i++)
                Expanded(
                  child: _DayChip(
                    day: weekStart.add(Duration(days: i)),
                    isSelected: WeekUtils.dayKey(date) ==
                        weekStart.add(Duration(days: i)),
                    isToday: today == weekStart.add(Duration(days: i)),
                    hasSubstitutions: substitutionDays.contains(i + 1),
                    onTap: onSelect,
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }

  /// «Сегодня», «Завтра» или полная дата — так быстрее считывается.
  static String _caption(DateTime date, DateTime today) {
    final day = WeekUtils.dayKey(date);
    final diff = day.difference(today).inDays;
    return switch (diff) {
      0 => 'Сегодня, ${WeekUtils.formatFullDate(date)}',
      1 => 'Завтра, ${WeekUtils.formatFullDate(date)}',
      -1 => 'Вчера, ${WeekUtils.formatFullDate(date)}',
      _ => WeekUtils.formatFullDate(date),
    };
  }
}

class _DayChip extends StatelessWidget {
  const _DayChip({
    required this.day,
    required this.isSelected,
    required this.isToday,
    required this.hasSubstitutions,
    required this.onTap,
  });

  final DateTime day;
  final bool isSelected;
  final bool isToday;
  final bool hasSubstitutions;
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
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        curve: Curves.easeOut,
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
                fontWeight:
                    isSelected || isToday ? FontWeight.w700 : FontWeight.w400,
              ),
            ),
            const SizedBox(height: 3),
            // Точка-индикатор: в этот день есть замены.
            Container(
              width: 4,
              height: 4,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: hasSubstitutions
                    ? (isSelected ? scheme.onPrimary : scheme.tertiary)
                    : Colors.transparent,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
