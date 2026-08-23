import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/settings/app_settings.dart';
import '../../../core/utils/week_utils.dart';
import '../../../di.dart';
import '../../schedule/presentation/bloc/schedule_cubit.dart';
import '../../schedule/presentation/pages/import_schedule_page.dart';
import '../../schedule/presentation/pages/schedule_format_page.dart';
import '../../substitutions/presentation/bloc/substitutions_cubit.dart';
import '../../substitutions/presentation/pages/parse_diagnostics_page.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  final AppSettings _settings = getIt<AppSettings>();
  late final TextEditingController _pageUrlController =
      TextEditingController(text: _settings.sourcePageUrl);
  late final TextEditingController _manualLinkController =
      TextEditingController(text: _settings.manualLink ?? '');

  @override
  void dispose() {
    _pageUrlController.dispose();
    _manualLinkController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final scheduleState = context.watch<ScheduleCubit>().state;
    final currentWeek = WeekUtils.weekTypeFor(
      DateTime.now(),
      invert: _settings.invertWeekParity,
    );

    return Scaffold(
      appBar: AppBar(title: const Text('Настройки')),
      body: ListView(
        children: [
          const _SectionHeader('Расписание'),
          if (scheduleState.availableGroups.isNotEmpty)
            ListTile(
              leading: const Icon(Icons.groups_outlined),
              title: const Text('Группа'),
              subtitle: Text(scheduleState.group ?? 'не выбрана'),
              trailing: DropdownButton<String>(
                value: scheduleState.group,
                underline: const SizedBox.shrink(),
                items: [
                  for (final group in scheduleState.availableGroups)
                    DropdownMenuItem(value: group, child: Text(group)),
                ],
                onChanged: (value) {
                  if (value != null) {
                    context.read<ScheduleCubit>().selectGroup(value);
                  }
                },
              ),
            ),
          ListTile(
            leading: const Icon(Icons.call_split),
            title: const Text('Подгруппа'),
            subtitle: const Text('Пары чужой подгруппы будут скрыты'),
            trailing: SegmentedButton<String>(
              showSelectedIcon: false,
              segments: const [
                ButtonSegment(value: '', label: Text('Все')),
                ButtonSegment(value: '1', label: Text('1')),
                ButtonSegment(value: '2', label: Text('2')),
              ],
              selected: {_settings.subgroup ?? ''},
              onSelectionChanged: (selection) async {
                final scheduleCubit = context.read<ScheduleCubit>();
                final value = selection.first;
                await _settings.setSubgroup(value.isEmpty ? null : value);
                if (mounted) setState(() {});
                await scheduleCubit.reload();
              },
            ),
          ),
          SwitchListTile(
            secondary: const Icon(Icons.swap_vert),
            title: const Text('Поменять числитель и знаменатель'),
            subtitle: Text(
              'Сейчас эта неделя — ${WeekUtils.weekTypeLabel(currentWeek).toLowerCase()}',
            ),
            value: _settings.invertWeekParity,
            onChanged: (value) async {
              final scheduleCubit = context.read<ScheduleCubit>();
              await _settings.setInvertWeekParity(value);
              if (mounted) setState(() {});
              await scheduleCubit.reload();
            },
          ),
          ListTile(
            leading: const Icon(Icons.upload_file_outlined),
            title: const Text('Импортировать расписание (.md)'),
            subtitle: const Text('Перезапишет пары групп из файла'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () async {
              final cubit = context.read<ScheduleCubit>();
              await Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const ImportSchedulePage()),
              );
              await cubit.reload();
            },
          ),
          ListTile(
            leading: const Icon(Icons.help_outline),
            title: const Text('Формат файла и промпт'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const ScheduleFormatPage()),
            ),
          ),

          const _SectionHeader('Источник замен'),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
            child: TextField(
              controller: _pageUrlController,
              decoration: const InputDecoration(
                labelText: 'Страница с заменами',
                helperText: 'Здесь приложение ищет ссылки со словом «замены»',
                helperMaxLines: 2,
              ),
              onSubmitted: _settings.setSourcePageUrl,
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
            child: TextField(
              controller: _manualLinkController,
              decoration: const InputDecoration(
                labelText: 'Прямая ссылка (необязательно)',
                helperText: 'Если заполнено — сайт не разбирается, файл '
                    'качается сразу по этой ссылке',
                helperMaxLines: 3,
              ),
              onSubmitted: _settings.setManualLink,
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 4, 16, 8),
            child: Align(
              alignment: Alignment.centerLeft,
              child: FilledButton.tonal(
                onPressed: () async {
                  final messenger = ScaffoldMessenger.of(context);
                  await _settings.setSourcePageUrl(_pageUrlController.text);
                  await _settings.setManualLink(_manualLinkController.text);
                  messenger.showSnackBar(
                    const SnackBar(content: Text('Сохранено')),
                  );
                },
                child: const Text('Сохранить адреса'),
              ),
            ),
          ),
          SwitchListTile(
            secondary: const Icon(Icons.refresh),
            title: const Text('Обновлять замены при запуске'),
            value: _settings.autoRefreshOnLaunch,
            onChanged: (value) async {
              await _settings.setAutoRefreshOnLaunch(value);
              if (mounted) setState(() {});
            },
          ),
          ListTile(
            leading: const Icon(Icons.description_outlined),
            title: const Text('Загрузить .docx вручную'),
            subtitle: const Text('Когда сайт недоступен'),
            trailing: const Icon(Icons.chevron_right),
            onTap: _pickDocx,
          ),
          ListTile(
            leading: const Icon(Icons.bug_report_outlined),
            title: const Text('Диагностика разбора'),
            subtitle: const Text('Что приложение прочитало в документе'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => BlocProvider.value(
                  value: context.read<SubstitutionsCubit>(),
                  child: const ParseDiagnosticsPage(),
                ),
              ),
            ),
          ),

          const _SectionHeader('Внешний вид'),
          ListTile(
            leading: const Icon(Icons.brightness_6_outlined),
            title: const Text('Тема'),
            trailing: SegmentedButton<ThemeMode>(
              showSelectedIcon: false,
              segments: const [
                ButtonSegment(value: ThemeMode.system, label: Text('Как в ОС')),
                ButtonSegment(value: ThemeMode.light, label: Text('Светлая')),
                ButtonSegment(value: ThemeMode.dark, label: Text('Тёмная')),
              ],
              selected: {_settings.themeMode},
              onSelectionChanged: (selection) async {
                await _settings.setThemeMode(selection.first);
                if (mounted) setState(() {});
              },
            ),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Future<void> _pickDocx() async {
    final picked = await FilePicker.platform.pickFiles(
      type: FileType.any,
      withData: true,
    );
    if (!mounted || picked == null || picked.files.isEmpty) return;

    final file = picked.files.first;
    final bytes = file.bytes;
    if (bytes == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Не удалось прочитать файл.')),
      );
      return;
    }

    await context
        .read<SubstitutionsCubit>()
        .importDocx(bytes, source: file.name);
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader(this.title);

  final String title;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 8),
      child: Text(
        title.toUpperCase(),
        style: theme.textTheme.labelSmall?.copyWith(
          color: theme.colorScheme.primary,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.8,
        ),
      ),
    );
  }
}
