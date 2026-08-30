import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/utils/week_utils.dart';
import '../bloc/substitutions_cubit.dart';

/// Строка «Обновлено N назад» — видна постоянно, а не только сразу
/// после нажатия «Обновить». Раньше это можно было узнать только
/// из снэкбара, который исчезает через несколько секунд.
class LastUpdatedLine extends StatelessWidget {
  const LastUpdatedLine({super.key, this.padding});

  final EdgeInsetsGeometry? padding;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SubstitutionsCubit, SubstitutionsState>(
      builder: (context, state) {
        final theme = Theme.of(context);
        final updated = state.lastUpdated;

        return Padding(
          padding: padding ?? const EdgeInsets.fromLTRB(16, 4, 16, 0),
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
