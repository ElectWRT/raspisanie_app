import 'dart:convert';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../di.dart';
import '../../data/datasources/markdown_schedule_parser.dart';
import '../../domain/repositories/schedule_repository.dart';
import '../bloc/import_cubit.dart';
import 'schedule_format_page.dart';

class ImportSchedulePage extends StatelessWidget {
  const ImportSchedulePage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => ImportCubit(getIt<ScheduleRepository>()),
      child: const _ImportView(),
    );
  }
}

class _ImportView extends StatefulWidget {
  const _ImportView();

  @override
  State<_ImportView> createState() => _ImportViewState();
}

class _ImportViewState extends State<_ImportView> {
  final _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<ImportCubit, ImportState>(
      listenWhen: (previous, current) => previous.status != current.status,
      listener: (context, state) {
        if (state.status == ImportStatus.saved) {
          Navigator.of(context).pop(true);
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Импорт расписания'),
          actions: [
            IconButton(
              tooltip: 'Формат и промпт',
              icon: const Icon(Icons.help_outline),
              onPressed: () => Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const ScheduleFormatPage()),
              ),
            ),
          ],
        ),
        body: BlocBuilder<ImportCubit, ImportState>(
          builder: (context, state) {
            return ListView(
              padding: const EdgeInsets.all(16),
              children: [
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: _pickFile,
                        icon: const Icon(Icons.folder_open),
                        label: const Text('Выбрать .md'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: _pasteFromClipboard,
                        icon: const Icon(Icons.content_paste),
                        label: const Text('Вставить'),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: _controller,
                  maxLines: 14,
                  minLines: 8,
                  style: const TextStyle(fontFamily: 'monospace', fontSize: 13),
                  decoration: const InputDecoration(
                    labelText: 'Markdown с расписанием',
                    alignLabelWithHint: true,
                    hintText: '# СА-2124\n\n## Понедельник\n'
                        '1. Компьютерные сети | Иванов И.И. | 301',
                  ),
                  onChanged: context.read<ImportCubit>().setMarkdown,
                ),
                const SizedBox(height: 16),
                FilledButton.tonal(
                  onPressed: state.markdown.trim().isEmpty
                      ? null
                      : context.read<ImportCubit>().check,
                  child: const Text('Проверить'),
                ),
                if (state.error != null) ...[
                  const SizedBox(height: 16),
                  _ErrorBox(message: state.error!),
                ],
                if (state.result != null) ...[
                  const SizedBox(height: 16),
                  _PreviewBox(result: state.result!),
                  const SizedBox(height: 16),
                  FilledButton.icon(
                    onPressed: state.status == ImportStatus.saving
                        ? null
                        : context.read<ImportCubit>().save,
                    icon: const Icon(Icons.save_outlined),
                    label: Text(
                      state.status == ImportStatus.saving
                          ? 'Сохраняю…'
                          : 'Сохранить расписание',
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Пары перечисленных групп будут перезаписаны. '
                    'Расписание остальных групп не изменится.',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                  ),
                ],
              ],
            );
          },
        ),
      ),
    );
  }

  Future<void> _pickFile() async {
    final picked = await FilePicker.platform.pickFiles(
      type: FileType.any,
      withData: true,
    );
    if (picked == null || picked.files.isEmpty || !mounted) return;
    final file = picked.files.first;

    final bytes = file.bytes;
    if (bytes == null) {
      _snack('Не удалось прочитать файл.');
      return;
    }

    try {
      _apply(utf8.decode(bytes));
    } on FormatException {
      _snack('Файл не в кодировке UTF-8. Пересохраните его как UTF-8.');
    }
  }

  Future<void> _pasteFromClipboard() async {
    final data = await Clipboard.getData(Clipboard.kTextPlain);
    final text = data?.text;
    if (!mounted) return;
    if (text == null || text.trim().isEmpty) {
      _snack('В буфере обмена пусто.');
      return;
    }
    _apply(text);
  }

  void _apply(String text) {
    _controller.text = text;
    context.read<ImportCubit>().setMarkdown(text);
    context.read<ImportCubit>().check();
  }

  void _snack(String message) => ScaffoldMessenger.of(context)
      .showSnackBar(SnackBar(content: Text(message)));
}

class _PreviewBox extends StatelessWidget {
  const _PreviewBox({required this.result});

  final ScheduleImportResult result;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final warnings = result.warnings;
    final perGroup = result.lessonsPerGroup;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: scheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.check_circle_outline, color: scheme.primary, size: 20),
              const SizedBox(width: 8),
              Text('Распознано', style: theme.textTheme.titleSmall),
            ],
          ),
          const SizedBox(height: 12),
          for (final entry in perGroup.entries)
            Padding(
              padding: const EdgeInsets.only(bottom: 4),
              child: Text('${entry.key} — ${entry.value} пар'),
            ),
          for (final schedule in result.bellSchedules)
            Text('${schedule.name} — ${schedule.times.length} пар'),
          if (warnings.isNotEmpty) ...[
            const Divider(height: 24),
            Row(
              children: [
                Icon(Icons.warning_amber_outlined,
                    color: scheme.tertiary, size: 20),
                const SizedBox(width: 8),
                Text(
                  'Не разобрано строк: ${warnings.length}',
                  style: theme.textTheme.titleSmall,
                ),
              ],
            ),
            const SizedBox(height: 8),
            for (final warning in warnings.take(10))
              Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Text(
                  '• $warning',
                  style: theme.textTheme.bodySmall
                      ?.copyWith(color: scheme.onSurfaceVariant),
                ),
              ),
            if (warnings.length > 10)
              Text(
                '…и ещё ${warnings.length - 10}',
                style: theme.textTheme.bodySmall
                    ?.copyWith(color: scheme.onSurfaceVariant),
              ),
          ],
        ],
      ),
    );
  }
}

class _ErrorBox extends StatelessWidget {
  const _ErrorBox({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: scheme.errorContainer,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.error_outline, color: scheme.onErrorContainer, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              message,
              style: TextStyle(color: scheme.onErrorContainer),
            ),
          ),
        ],
      ),
    );
  }
}
