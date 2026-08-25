import 'package:flutter/material.dart';

import '../../../../core/theme/app_theme.dart';

/// Заголовок раздела настроек.
class SectionHeader extends StatelessWidget {
  const SectionHeader(this.title, {super.key, this.icon});

  final String title;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 24, 16, 8),
      child: Row(
        children: [
          if (icon != null) ...[
            Icon(icon, size: 15, color: theme.colorScheme.primary),
            const SizedBox(width: 8),
          ],
          Text(
            title.toUpperCase(),
            style: theme.textTheme.labelSmall?.copyWith(
              color: theme.colorScheme.primary,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.8,
            ),
          ),
        ],
      ),
    );
  }
}

/// Ряд кружков с акцентными цветами.
class AccentPicker extends StatelessWidget {
  const AccentPicker({
    super.key,
    required this.selectedId,
    required this.onSelect,
    this.enabled = true,
  });

  final String selectedId;
  final ValueChanged<String> onSelect;

  /// Выключается, когда включён Material You — цвет берётся из обоев.
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: enabled ? 1 : 0.4,
      child: SizedBox(
        height: 60,
        child: ListView.separated(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          itemCount: AppAccents.options.length,
          separatorBuilder: (_, __) => const SizedBox(width: 12),
          itemBuilder: (context, index) {
            final option = AppAccents.options[index];
            final isSelected = option.id == selectedId;

            return Tooltip(
              message: option.label,
              child: GestureDetector(
                onTap: enabled ? () => onSelect(option.id) : null,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 160),
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: option.seed,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: isSelected
                          ? Theme.of(context).colorScheme.onSurface
                          : Colors.transparent,
                      width: 2.5,
                    ),
                  ),
                  child: isSelected
                      ? const Icon(Icons.check, color: Colors.white, size: 20)
                      : null,
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

/// Ползунок масштаба текста с живым примером.
class TextScaleTile extends StatelessWidget {
  const TextScaleTile({
    super.key,
    required this.value,
    required this.onChanged,
  });

  final double value;
  final ValueChanged<double> onChanged;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ListTile(
          leading: const Icon(Icons.format_size),
          title: const Text('Размер текста'),
          trailing: Text(
            '${(value * 100).round()}%',
            style: theme.textTheme.labelLarge
                ?.copyWith(color: theme.colorScheme.primary),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Slider(
            value: value,
            min: 0.85,
            max: 1.4,
            divisions: 11,
            label: '${(value * 100).round()}%',
            onChanged: onChanged,
          ),
        ),
      ],
    );
  }
}
