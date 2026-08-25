import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

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
          ListTile(
            leading: const Icon(Icons.code),
            title: const Text('Исходный код'),
            subtitle: const Text(AppInfo.repositoryUrl),
            trailing: const Icon(Icons.copy, size: 18),
            onTap: () async {
              await Clipboard.setData(
                const ClipboardData(text: AppInfo.repositoryUrl),
              );
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Ссылка скопирована')),
                );
              }
            },
          ),
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
