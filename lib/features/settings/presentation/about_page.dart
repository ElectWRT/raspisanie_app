import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../core/app_info.dart';

class AboutPage extends StatelessWidget {
  const AboutPage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(title: const Text('О приложении')),
      body: ListView(
        children: [
          const SizedBox(height: 24),
          Center(
            child: Container(
              width: 84,
              height: 84,
              decoration: BoxDecoration(
                color: scheme.primaryContainer,
                borderRadius: BorderRadius.circular(24),
              ),
              child: Icon(
                Icons.calendar_month_outlined,
                size: 44,
                color: scheme.onPrimaryContainer,
              ),
            ),
          ),
          const SizedBox(height: 16),
          Center(
            child: Text('Расписание', style: theme.textTheme.titleLarge),
          ),
          const SizedBox(height: 4),
          Center(
            child: Text(
              'версия ${AppInfo.version}',
              style: theme.textTheme.bodySmall
                  ?.copyWith(color: scheme.onSurfaceVariant),
            ),
          ),
          const SizedBox(height: 28),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Text(
              'Расписание занятий с автоматической подстановкой замен. '
              'Всё работает на устройстве: данные никуда не отправляются, '
              'сервера у приложения нет.',
              style: theme.textTheme.bodyMedium
                  ?.copyWith(color: scheme.onSurfaceVariant),
            ),
          ),
          const SizedBox(height: 20),
          const _LinkTile(
            icon: Icons.person_outline,
            title: 'Разработчик',
            subtitle: AppInfo.authorName,
            url: AppInfo.authorUrl,
          ),
          const _LinkTile(
            icon: Icons.groups_outlined,
            title: 'Организация на GitHub',
            subtitle: AppInfo.organizationName,
            url: AppInfo.organizationUrl,
          ),
          const _LinkTile(
            icon: Icons.code,
            title: 'Исходный код',
            subtitle: AppInfo.repositoryUrl,
            url: AppInfo.repositoryUrl,
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
            child: Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: scheme.errorContainer.withValues(alpha: 0.4),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: scheme.error.withValues(alpha: 0.3),
                ),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.block_outlined, size: 20, color: scheme.error),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      AppInfo.licenseNote,
                      style: theme.textTheme.bodySmall
                          ?.copyWith(color: scheme.onSurface),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),
          const Divider(),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
            child: Text(
              'Разбор документов с заменами настроен по предполагаемому '
              'формату. Если замены разбираются неправильно, откройте '
              '«Диагностика разбора» — там видно, что именно приложение '
              'прочитало в файле.',
              style: theme.textTheme.bodySmall
                  ?.copyWith(color: scheme.onSurfaceVariant),
            ),
          ),
        ],
      ),
    );
  }
}

/// Строка с внешней ссылкой: тап открывает её в браузере, иконка
/// справа — копирует адрес в буфер (пригодится, если браузера под рукой
/// нет — например, чтобы переслать ссылку в мессенджер).
class _LinkTile extends StatelessWidget {
  const _LinkTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.url,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final String url;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon),
      title: Text(title),
      subtitle: Text(subtitle),
      trailing: IconButton(
        tooltip: 'Скопировать ссылку',
        icon: const Icon(Icons.copy, size: 18),
        onPressed: () => _copy(context),
      ),
      onTap: () => _open(context),
    );
  }

  Future<void> _open(BuildContext context) async {
    final messenger = ScaffoldMessenger.of(context);
    final uri = Uri.parse(url);
    final opened = await launchUrl(uri, mode: LaunchMode.externalApplication);
    if (!opened && context.mounted) {
      messenger.showSnackBar(
        const SnackBar(content: Text('Не удалось открыть ссылку')),
      );
    }
  }

  Future<void> _copy(BuildContext context) async {
    final messenger = ScaffoldMessenger.of(context);
    await Clipboard.setData(ClipboardData(text: url));
    if (context.mounted) {
      messenger.showSnackBar(
        const SnackBar(content: Text('Ссылка скопирована')),
      );
    }
  }
}
