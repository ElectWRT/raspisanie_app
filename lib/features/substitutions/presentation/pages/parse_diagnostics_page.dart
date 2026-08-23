import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/utils/week_utils.dart';
import '../bloc/substitutions_cubit.dart';

/// Показывает, что именно приложение прочитало в последнем документе.
/// Нужен, чтобы подстроить парсер под реальный формат документа завуча,
/// не гадая и не пересобирая приложение.
class ParseDiagnosticsPage extends StatelessWidget {
  const ParseDiagnosticsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Диагностика разбора')),
      body: BlocBuilder<SubstitutionsCubit, SubstitutionsState>(
        builder: (context, state) {
          final report = state.report;

          if (state.error != null && report == null) {
            return _Message(
              icon: Icons.error_outline,
              color: theme.colorScheme.error,
              text: state.error!,
            );
          }
          if (report == null) {
            return const _Message(
              icon: Icons.info_outline,
              text: 'Пока нечего показать — сначала обновите замены '
                  'или загрузите .docx вручную.',
            );
          }

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              _Field('Источник', report.source),
              _Field('Дата документа',
                  '${WeekUtils.formatFullDate(report.date)}'
                  '${report.dateWasGuessed ? '  (в документе не нашлась, '
                      'выбрана по ссылке)' : ''}'),
              _Field('Записано строк', '${report.importedCount}'),
              if (report.warnings.isNotEmpty) ...[
                const SizedBox(height: 16),
                Text(
                  'Не разобрано (${report.warnings.length})',
                  style: theme.textTheme.titleSmall,
                ),
                const SizedBox(height: 8),
                for (final warning in report.warnings)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 4),
                    child: Text('• $warning',
                        style: theme.textTheme.bodySmall),
                  ),
              ],
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: Text('Текст документа',
                        style: theme.textTheme.titleSmall),
                  ),
                  TextButton.icon(
                    onPressed: () async {
                      await Clipboard.setData(
                        ClipboardData(text: report.textPreview),
                      );
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Скопировано')),
                        );
                      }
                    },
                    icon: const Icon(Icons.copy, size: 18),
                    label: const Text('Копировать'),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: theme.colorScheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: SelectableText(
                  report.textPreview.isEmpty
                      ? '(пусто)'
                      : report.textPreview,
                  style: const TextStyle(fontFamily: 'monospace', fontSize: 12),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _Field extends StatelessWidget {
  const _Field(this.label, this.value);

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: theme.textTheme.labelSmall
                ?.copyWith(color: theme.colorScheme.onSurfaceVariant),
          ),
          Text(value, style: theme.textTheme.bodyMedium),
        ],
      ),
    );
  }
}

class _Message extends StatelessWidget {
  const _Message({required this.icon, required this.text, this.color});

  final IconData icon;
  final String text;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 48, color: color ?? theme.colorScheme.outline),
            const SizedBox(height: 12),
            Text(text, textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }
}
