import 'package:flutter/material.dart';

import '../../domain/entities/schedule_slot.dart';

/// Карточка одной пары. Замена подсвечивается цветом и показывает,
/// что стояло в расписании раньше.
class LessonCard extends StatelessWidget {
  const LessonCard({
    super.key,
    required this.slot,
    this.bell,
    this.compact = false,
    this.isNow = false,
    this.isPast = false,
    this.homeworkCount = 0,
  });

  final ScheduleSlot slot;
  final BellTime? bell;

  /// Плотная вёрстка — меньше отступов, скрыта строка «было».
  final bool compact;

  /// Пара идёт прямо сейчас.
  final bool isNow;

  /// Пара уже закончилась — гасим её, чтобы взгляд цеплялся за актуальное.
  final bool isPast;

  /// Сколько незакрытых заданий по этому предмету.
  final int homeworkCount;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    final accent = slot.isCancelled
        ? scheme.error
        : slot.isSubstitution
            ? scheme.tertiary
            : scheme.primary;

    final padding = compact ? 11.0 : 14.0;

    final card = Card(
      color: isNow
          ? scheme.primaryContainer.withValues(alpha: 0.55)
          : slot.isSubstitution
              ? accent.withValues(alpha: 0.06)
              : scheme.surfaceContainerLow,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: isNow
              ? scheme.primary
              : slot.isSubstitution
                  ? accent.withValues(alpha: 0.4)
                  : scheme.outlineVariant,
          width: isNow ? 1.6 : 1,
        ),
      ),
      child: Padding(
        padding: EdgeInsets.all(padding),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _PairNumber(
              number: slot.pairNumber,
              bell: bell,
              accent: accent,
              compact: compact,
            ),
            SizedBox(width: compact ? 11 : 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (slot.isSubstitution || isNow)
                    _Badges(slot: slot, accent: accent, isNow: isNow),
                  Text(
                    slot.isCancelled ? 'Пара снята' : slot.subject,
                    style: (compact
                            ? theme.textTheme.titleSmall
                            : theme.textTheme.titleMedium)
                        ?.copyWith(
                      fontWeight: FontWeight.w600,
                      decoration:
                          slot.isCancelled ? TextDecoration.lineThrough : null,
                      color: slot.isCancelled ? scheme.error : null,
                    ),
                  ),
                  if (!compact &&
                      slot.isSubstitution &&
                      slot.originalSubject != null &&
                      slot.originalSubject != slot.subject)
                    Padding(
                      padding: const EdgeInsets.only(top: 2),
                      child: Text(
                        'Было: ${slot.originalSubject}',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: scheme.onSurfaceVariant,
                          decoration: TextDecoration.lineThrough,
                        ),
                      ),
                    ),
                  if (!slot.isCancelled) ...[
                    SizedBox(height: compact ? 5 : 8),
                    _MetaRow(
                      teacher: slot.teacher,
                      room: slot.room,
                      compact: compact,
                    ),
                  ],
                  if (homeworkCount > 0)
                    Padding(
                      padding: const EdgeInsets.only(top: 6),
                      child: Row(
                        children: [
                          Icon(Icons.assignment_outlined,
                              size: 14, color: scheme.secondary),
                          const SizedBox(width: 4),
                          Text(
                            homeworkCount == 1
                                ? 'есть домашка'
                                : 'домашки: $homeworkCount',
                            style: theme.textTheme.labelSmall
                                ?.copyWith(color: scheme.secondary),
                          ),
                        ],
                      ),
                    ),
                  if (slot.note != null && slot.note!.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(top: 6),
                      child: Text(
                        slot.note!,
                        style: theme.textTheme.bodySmall
                            ?.copyWith(color: scheme.onSurfaceVariant),
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );

    if (!isPast) return card;
    return Opacity(opacity: 0.45, child: card);
  }
}

class _Badges extends StatelessWidget {
  const _Badges({
    required this.slot,
    required this.accent,
    required this.isNow,
  });

  final ScheduleSlot slot;
  final Color accent;
  final bool isNow;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    final badges = <(String, Color)>[
      if (isNow) ('СЕЙЧАС', scheme.primary),
      if (slot.isSubstitution)
        (slot.isCancelled ? 'ПАРА СНЯТА' : 'ЗАМЕНА', accent),
      if (slot.isExtra) ('ДОБАВЛЕНА', accent),
      if (slot.subgroup != null) ('${slot.subgroup} подгруппа', accent),
    ];

    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Wrap(
        spacing: 6,
        runSpacing: 4,
        children: [
          for (final (label, color) in badges)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                label,
                style: theme.textTheme.labelSmall?.copyWith(
                  color: color,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.4,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _PairNumber extends StatelessWidget {
  const _PairNumber({
    required this.number,
    required this.accent,
    required this.compact,
    this.bell,
  });

  final int number;
  final Color accent;
  final bool compact;
  final BellTime? bell;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final size = compact ? 28.0 : 32.0;

    return SizedBox(
      width: compact ? 46 : 52,
      child: Column(
        children: [
          Container(
            width: size,
            height: size,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: accent.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(
              '$number',
              style: theme.textTheme.titleSmall?.copyWith(
                color: accent,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          if (bell != null) ...[
            SizedBox(height: compact ? 4 : 6),
            Text(
              bell!.start,
              style: theme.textTheme.labelSmall
                  ?.copyWith(color: theme.colorScheme.onSurfaceVariant),
            ),
            Text(
              bell!.end,
              style: theme.textTheme.labelSmall
                  ?.copyWith(color: theme.colorScheme.outline),
            ),
          ],
        ],
      ),
    );
  }
}

class _MetaRow extends StatelessWidget {
  const _MetaRow({
    required this.teacher,
    required this.room,
    required this.compact,
  });

  final String teacher;
  final String room;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final muted = theme.colorScheme.onSurfaceVariant;
    final iconSize = compact ? 14.0 : 16.0;
    final style = compact ? theme.textTheme.bodySmall : theme.textTheme.bodyMedium;

    if (teacher.isEmpty && room.isEmpty) return const SizedBox.shrink();

    return Row(
      children: [
        if (teacher.isNotEmpty) ...[
          Icon(Icons.person_outline, size: iconSize, color: muted),
          const SizedBox(width: 4),
          Expanded(
            child: Text(
              teacher,
              style: style?.copyWith(color: muted),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ] else
          const Spacer(),
        if (room.isNotEmpty) ...[
          const SizedBox(width: 8),
          Icon(Icons.meeting_room_outlined, size: iconSize, color: muted),
          const SizedBox(width: 4),
          Text(
            room,
            style: style?.copyWith(fontWeight: FontWeight.w600),
          ),
        ],
      ],
    );
  }
}
