import 'package:flutter/material.dart';

import '../../../../core/database/tables.dart';
import '../../../../core/utils/week_utils.dart';
import '../../domain/entities/schedule_slot.dart';

/// Карточка одной пары. Замена подсвечивается цветом и показывает,
/// что стояло в расписании раньше.
class LessonCard extends StatelessWidget {
  const LessonCard({super.key, required this.slot, this.bell});

  final ScheduleSlot slot;
  final BellTime? bell;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    final accent = slot.isCancelled
        ? scheme.error
        : slot.isSubstitution
            ? scheme.tertiary
            : scheme.primary;

    return Card(
      color: slot.isSubstitution
          ? accent.withValues(alpha: 0.06)
          : scheme.surfaceContainerLow,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: slot.isSubstitution
              ? accent.withValues(alpha: 0.4)
              : scheme.outlineVariant,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _PairNumber(number: slot.pairNumber, bell: bell, accent: accent),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (slot.isSubstitution) _badge(context, accent),
                  Text(
                    slot.isCancelled ? 'Пара снята' : slot.subject,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                      decoration:
                          slot.isCancelled ? TextDecoration.lineThrough : null,
                      color: slot.isCancelled ? scheme.error : null,
                    ),
                  ),
                  if (slot.isSubstitution &&
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
                    const SizedBox(height: 8),
                    _MetaRow(teacher: slot.teacher, room: slot.room),
                  ],
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
  }

  Widget _badge(BuildContext context, Color accent) {
    final labels = <String>[
      if (slot.isCancelled) 'ПАРА СНЯТА' else 'ЗАМЕНА',
      if (slot.isExtra) 'ДОБАВЛЕНА',
      if (slot.subgroup != null) '${slot.subgroup} подгруппа',
    ];

    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Wrap(
        spacing: 6,
        children: [
          for (final label in labels)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: accent.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                label,
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      color: accent,
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
    this.bell,
  });

  final int number;
  final Color accent;
  final BellTime? bell;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return SizedBox(
      width: 52,
      child: Column(
        children: [
          Container(
            width: 32,
            height: 32,
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
            const SizedBox(height: 6),
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
  const _MetaRow({required this.teacher, required this.room});

  final String teacher;
  final String room;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final muted = theme.colorScheme.onSurfaceVariant;

    if (teacher.isEmpty && room.isEmpty) return const SizedBox.shrink();

    return Row(
      children: [
        if (teacher.isNotEmpty) ...[
          Icon(Icons.person_outline, size: 16, color: muted),
          const SizedBox(width: 4),
          Expanded(
            child: Text(
              teacher,
              style: theme.textTheme.bodyMedium?.copyWith(color: muted),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ] else
          const Spacer(),
        if (room.isNotEmpty) ...[
          const SizedBox(width: 8),
          Icon(Icons.meeting_room_outlined, size: 16, color: muted),
          const SizedBox(width: 4),
          Text(
            room,
            style: theme.textTheme.bodyMedium
                ?.copyWith(fontWeight: FontWeight.w600),
          ),
        ],
      ],
    );
  }
}

/// Подпись «числитель/знаменатель» для шапки дня.
String weekTypeCaption(WeekType type) => WeekUtils.weekTypeLabel(type);
