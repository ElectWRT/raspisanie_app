import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../core/app_info.dart';

/// Окно «спасибо, что пользуетесь»: изредка при запуске предлагает
/// сообщить об ошибке, поделиться приложением или поставить звезду.
Future<void> showThanksDialog(BuildContext context) {
  return showDialog<void>(
    context: context,
    builder: (dialogContext) => const _ThanksDialog(),
  );
}

class _ThanksDialog extends StatelessWidget {
  const _ThanksDialog();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return AlertDialog(
      icon: Icon(Icons.favorite_outline, color: theme.colorScheme.primary),
      title: const Text('Спасибо, что пользуетесь приложением!'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Если нашли ошибку — оставьте issue на GitHub. А если приложение '
            'нравится, поделитесь им с друзьями и знакомыми.',
            style: theme.textTheme.bodyMedium,
          ),
          const SizedBox(height: 20),
          _ActionButton(
            icon: Icons.bug_report_outlined,
            label: 'Нашёл ошибку',
            onPressed: () => _openUrl(context, AppInfo.newIssueUrl),
          ),
          const SizedBox(height: 8),
          _ActionButton(
            icon: Icons.share_outlined,
            label: 'Поделиться',
            onPressed: () => _share(context),
          ),
          const SizedBox(height: 8),
          _ActionButton(
            icon: Icons.star_outline,
            label: 'Оставить звезду на GitHub',
            onPressed: () => _openUrl(context, AppInfo.repositoryUrl),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Закрыть'),
        ),
      ],
    );
  }

  /// Сначала закрываем окно, потом уходим в браузер: иначе, вернувшись
  /// в приложение, человек снова упрётся в то же окно.
  Future<void> _openUrl(BuildContext context, String url) async {
    final messenger = ScaffoldMessenger.of(context);
    Navigator.of(context).pop();

    final opened = await launchUrl(
      Uri.parse(url),
      mode: LaunchMode.externalApplication,
    );
    if (!opened) {
      messenger.showSnackBar(
        const SnackBar(content: Text('Не удалось открыть браузер')),
      );
    }
  }

  /// Системное меню «Поделиться»: мессенджеры, почта, копирование ссылки —
  /// что стоит на телефоне. Окно закрываем до него, чтобы не висело сзади.
  Future<void> _share(BuildContext context) async {
    Navigator.of(context).pop();
    await SharePlus.instance.share(
      ShareParams(
        text: AppInfo.shareText,
        subject: 'Приложение «Расписание»',
        title: 'Поделиться приложением',
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  const _ActionButton({
    required this.icon,
    required this.label,
    required this.onPressed,
  });

  final IconData icon;
  final String label;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return FilledButton.tonalIcon(
      onPressed: onPressed,
      icon: Icon(icon),
      label: Text(label),
      style: FilledButton.styleFrom(
        alignment: Alignment.centerLeft,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      ),
    );
  }
}
