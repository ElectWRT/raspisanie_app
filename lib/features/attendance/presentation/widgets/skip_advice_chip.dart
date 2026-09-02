import 'package:flutter/material.dart';

import '../../domain/skip_advice.dart';

/// Вердикт «во что обойдётся пропуск» — компактной плашкой справа
/// в строке-сводке дня. По тапу разворачивает объяснение: голое
/// «Критично» без причины бесполезно.
class SkipAdviceChip extends StatelessWidget {
  const SkipAdviceChip({super.key, required this.advice});

  final SkipAdvice advice;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = _colorsFor(advice.verdict, theme.colorScheme);

    return InkWell(
      borderRadius: BorderRadius.circular(20),
      onTap: () => _showDetails(context),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: BoxDecoration(
          color: colors.background,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(_iconFor(advice.verdict), size: 13, color: colors.foreground),
            const SizedBox(width: 5),
            Text(
              advice.verdict.label,
              style: theme.textTheme.labelSmall?.copyWith(
                color: colors.foreground,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showDetails(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      builder: (sheetContext) {
        final theme = Theme.of(sheetContext);
        final colors = _colorsFor(advice.verdict, theme.colorScheme);

        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(_iconFor(advice.verdict),
                        size: 20, color: colors.foreground),
                    const SizedBox(width: 10),
                    Text(
                      'Пропустить день: ${advice.verdict.label.toLowerCase()}',
                      style: theme.textTheme.titleMedium,
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                if (advice.reasons.isEmpty)
                  Text(
                    'Запас по пропускам есть, профильных пар сегодня нет.',
                    style: theme.textTheme.bodyMedium,
                  )
                else
                  ...advice.reasons.map(
                    (reason) => Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(top: 6, right: 10),
                            child: Container(
                              width: 5,
                              height: 5,
                              decoration: BoxDecoration(
                                color: colors.foreground,
                                shape: BoxShape.circle,
                              ),
                            ),
                          ),
                          Expanded(
                            child: Text(reason,
                                style: theme.textTheme.bodyMedium),
                          ),
                        ],
                      ),
                    ),
                  ),
                const SizedBox(height: 12),
                Text(
                  'Считается по вашим отметкам и лимитам из настроек. '
                  'Снятые заменой пары не учитываются.',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  static IconData _iconFor(SkipVerdict verdict) => switch (verdict) {
        SkipVerdict.allowed => Icons.check_circle_outline,
        SkipVerdict.notAdvised => Icons.info_outline,
        SkipVerdict.critical => Icons.warning_amber_rounded,
      };

  static _AdviceColors _colorsFor(SkipVerdict verdict, ColorScheme scheme) =>
      switch (verdict) {
        SkipVerdict.allowed => _AdviceColors(
            background: scheme.secondaryContainer,
            foreground: scheme.onSecondaryContainer,
          ),
        SkipVerdict.notAdvised => _AdviceColors(
            background: scheme.tertiaryContainer,
            foreground: scheme.onTertiaryContainer,
          ),
        SkipVerdict.critical => _AdviceColors(
            background: scheme.errorContainer,
            foreground: scheme.onErrorContainer,
          ),
      };
}

class _AdviceColors {
  const _AdviceColors({required this.background, required this.foreground});

  final Color background;
  final Color foreground;
}
