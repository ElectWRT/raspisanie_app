import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/backup/backup_service.dart';
import '../../../core/notifications/reminder_scheduler.dart';
import '../../../core/utils/week_utils.dart';
import '../../../di.dart';
import '../../schedule/presentation/bloc/schedule_cubit.dart';

class BackupPage extends StatefulWidget {
  const BackupPage({super.key});

  @override
  State<BackupPage> createState() => _BackupPageState();
}

class _BackupPageState extends State<BackupPage> {
  final BackupService _backup = getIt<BackupService>();
  bool _busy = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Резервная копия')),
      body: AbsorbPointer(
        absorbing: _busy,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Text(
              'В копию попадает расписание, звонки, домашние задания и '
              'настройки приложения. Файл можно сохранить куда угодно — '
              'в облако, на карту памяти, отправить себе.',
              style: theme.textTheme.bodyMedium
                  ?.copyWith(color: theme.colorScheme.onSurfaceVariant),
            ),
            const SizedBox(height: 20),
            Card(
              color: theme.colorScheme.surfaceContainerLow,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
                side: BorderSide(color: theme.colorScheme.outlineVariant),
              ),
              child: ListTile(
                leading: const Icon(Icons.save_alt_outlined),
                title: const Text('Сохранить резервную копию'),
                subtitle: const Text('Создаёт файл .json'),
                trailing: _busy ? null : const Icon(Icons.chevron_right),
                onTap: _busy ? null : _export,
              ),
            ),
            const SizedBox(height: 12),
            Card(
              color: theme.colorScheme.surfaceContainerLow,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
                side: BorderSide(color: theme.colorScheme.outlineVariant),
              ),
              child: ListTile(
                leading: const Icon(Icons.restore_outlined),
                title: const Text('Восстановить из файла'),
                subtitle: const Text('Текущие данные будут заменены'),
                trailing: _busy ? null : const Icon(Icons.chevron_right),
                onTap: _busy ? null : _pickAndRestore,
              ),
            ),
            if (_busy) ...[
              const SizedBox(height: 24),
              const Center(child: CircularProgressIndicator()),
            ],
          ],
        ),
      ),
    );
  }

  Future<void> _export() async {
    final messenger = ScaffoldMessenger.of(context);
    setState(() => _busy = true);

    try {
      final path = await _backup.exportToFile();
      if (!mounted) return;
      messenger.showSnackBar(SnackBar(
        content: Text(
          path == null ? 'Сохранение отменено' : 'Копия сохранена',
        ),
      ));
    } catch (e) {
      if (!mounted) return;
      messenger.showSnackBar(
        SnackBar(content: Text('Не удалось сохранить копию: $e')),
      );
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _pickAndRestore() async {
    final picked = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: const ['json'],
      withData: true,
    );
    if (!mounted || picked == null || picked.files.isEmpty) return;

    final bytes = picked.files.first.bytes;
    if (bytes == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Не удалось прочитать файл.')),
      );
      return;
    }

    final BackupPreview preview;
    try {
      preview = _backup.inspect(bytes);
    } on BackupFormatException catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(e.message)));
      return;
    }

    if (!mounted) return;
    final messenger = ScaffoldMessenger.of(context);
    final scheduleCubit = context.read<ScheduleCubit>();

    final confirmed = await _confirmRestore(preview);
    if (confirmed != true) return;

    setState(() => _busy = true);

    try {
      await _backup.restore(bytes);
      await scheduleCubit.reload();
      await getIt<ReminderScheduler>().refresh();
      if (!mounted) return;
      messenger.showSnackBar(
        const SnackBar(content: Text('Данные восстановлены')),
      );
    } catch (e) {
      if (!mounted) return;
      messenger.showSnackBar(
        SnackBar(content: Text('Не удалось восстановить копию: $e')),
      );
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<bool?> _confirmRestore(BackupPreview preview) {
    final theme = Theme.of(context);
    final summary = preview.summary;

    return showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Восстановить из копии?'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Текущее расписание, замены, домашка и настройки будут '
              'заменены содержимым файла. Отменить это будет нельзя.',
            ),
            const SizedBox(height: 12),
            Text(
              'В файле: ${summary.lessons} пар, '
              '${summary.substitutions} замен, '
              '${summary.homeworks} заданий.',
              style: theme.textTheme.bodySmall,
            ),
            if (preview.createdAt != null)
              Text(
                'Создан: ${WeekUtils.formatFullDate(preview.createdAt!)}',
                style: theme.textTheme.bodySmall
                    ?.copyWith(color: theme.colorScheme.onSurfaceVariant),
              ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text('Отмена'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: theme.colorScheme.error,
            ),
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: const Text('Восстановить'),
          ),
        ],
      ),
    );
  }
}
