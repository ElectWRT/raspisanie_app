import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/background/background_refresh.dart';
import '../../../core/notifications/notification_service.dart';
import '../../../core/notifications/reminder_scheduler.dart';
import '../../../core/settings/app_settings.dart';
import '../../../core/utils/week_utils.dart';
import '../../../di.dart';
import '../../attendance/presentation/pages/attendance_page.dart';
import '../../seasons/domain/season.dart';
import '../../schedule/domain/repositories/schedule_repository.dart';
import '../../schedule/presentation/bloc/schedule_cubit.dart';
import '../../schedule/presentation/pages/bells_page.dart';
import '../../schedule/presentation/pages/import_schedule_page.dart';
import '../../schedule/presentation/pages/schedule_format_page.dart';
import '../../substitutions/domain/repositories/substitutions_repository.dart';
import '../../substitutions/presentation/bloc/substitutions_cubit.dart';
import '../../substitutions/presentation/pages/parse_diagnostics_page.dart';
import 'about_page.dart';
import 'backup_page.dart';
import 'widgets/settings_widgets.dart';

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

  /// Перерисовывает настройки и главный экран после смены значения.
  Future<void> _applyAndReload(Future<void> Function() change) async {
    final scheduleCubit = context.read<ScheduleCubit>();
    await change();
    if (mounted) setState(() {});
    await scheduleCubit.reload();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Настройки')),
      body: ListView(
        padding: const EdgeInsets.only(bottom: 32),
        children: [
          ..._scheduleSection(),
          ..._notificationsSection(),
          ..._attendanceSection(),
          ..._appearanceSection(),
          ..._sourceSection(),
          ..._dataSection(),
        ],
      ),
    );
  }

  // ------------------------------------------------------------ расписание

  List<Widget> _scheduleSection() {
    final scheduleState = context.watch<ScheduleCubit>().state;
    final currentWeek = WeekUtils.weekTypeFor(
      DateTime.now(),
      invert: _settings.invertWeekParity,
    );

    return [
      const SectionHeader('Расписание', icon: Icons.calendar_today_outlined),
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
          onSelectionChanged: (selection) => _applyAndReload(() {
            final value = selection.first;
            return _settings.setSubgroup(value.isEmpty ? null : value);
          }),
        ),
      ),
      SwitchListTile(
        secondary: const Icon(Icons.swap_vert),
        title: const Text('Поменять числитель и знаменатель'),
        subtitle: Text(
          'Сейчас эта неделя — '
          '${WeekUtils.weekTypeLabel(currentWeek).toLowerCase()}',
        ),
        value: _settings.invertWeekParity,
        onChanged: (value) =>
            _applyAndReload(() => _settings.setInvertWeekParity(value)),
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
        leading: const Icon(Icons.schedule),
        title: const Text('Расписание звонков'),
        subtitle: const Text('Разные наборы для будней и субботы'),
        trailing: const Icon(Icons.chevron_right),
        onTap: () async {
          final cubit = context.read<ScheduleCubit>();
          await Navigator.of(context).push(
            MaterialPageRoute(builder: (_) => const BellsPage()),
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
    ];
  }

  // --------------------------------------------------------- уведомления

  List<Widget> _notificationsSection() {
    final enabled = _settings.notificationsEnabled;

    return [
      const SectionHeader('Уведомления', icon: Icons.notifications_outlined),
      SwitchListTile(
        secondary: const Icon(Icons.notifications_active_outlined),
        title: const Text('Напоминать о парах'),
        subtitle: const Text('Уведомление незадолго до звонка'),
        value: enabled,
        onChanged: _toggleNotifications,
      ),
      if (enabled) ...[
        ListTile(
          leading: const Icon(Icons.timer_outlined),
          title: const Text('За сколько предупреждать'),
          subtitle: SegmentedButton<int>(
            showSelectedIcon: false,
            segments: const [
              ButtonSegment(value: 5, label: Text('5 мин')),
              ButtonSegment(value: 10, label: Text('10')),
              ButtonSegment(value: 15, label: Text('15')),
              ButtonSegment(value: 30, label: Text('30')),
            ],
            selected: {_settings.reminderMinutes},
            onSelectionChanged: (selection) async {
              await _settings.setReminderMinutes(selection.first);
              if (mounted) setState(() {});
              await getIt<ReminderScheduler>().refresh();
            },
          ),
          isThreeLine: true,
        ),
        SwitchListTile(
          secondary: const Icon(Icons.alarm_on_outlined),
          title: const Text('Точное время'),
          subtitle: const Text(
            'Без него Android может задержать уведомление на несколько минут. '
            'Потребует отдельного разрешения.',
          ),
          isThreeLine: true,
          value: _settings.exactAlarms,
          onChanged: _toggleExactAlarms,
        ),
        const Divider(indent: 16, endIndent: 16),
        SwitchListTile(
          secondary: const Icon(Icons.assignment_outlined),
          title: const Text('Напоминать о домашке'),
          subtitle: const Text('Кроме заданий с приоритетом «не критично»'),
          value: _settings.homeworkReminders,
          onChanged: (value) async {
            await _settings.setHomeworkReminders(value);
            if (mounted) setState(() {});
            await getIt<ReminderScheduler>().refresh();
          },
        ),
        if (_settings.homeworkReminders) ...[
          ListTile(
            leading: const Icon(Icons.event_available_outlined),
            title: const Text('За сколько дней до сдачи'),
            subtitle: SegmentedButton<int>(
              showSelectedIcon: false,
              segments: const [
                ButtonSegment(value: 1, label: Text('1')),
                ButtonSegment(value: 2, label: Text('2')),
                ButtonSegment(value: 3, label: Text('3')),
                ButtonSegment(value: 7, label: Text('7')),
              ],
              selected: {_settings.homeworkDaysBefore},
              onSelectionChanged: (selection) async {
                await _settings.setHomeworkDaysBefore(selection.first);
                if (mounted) setState(() {});
                await getIt<ReminderScheduler>().refresh();
              },
            ),
            isThreeLine: true,
          ),
          ListTile(
            leading: const Icon(Icons.schedule_outlined),
            title: const Text('Во сколько напоминать'),
            subtitle: const Text('Час, когда придёт уведомление о домашке'),
            trailing: Text(
              '${_settings.homeworkReminderHour.toString().padLeft(2, '0')}:00',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            onTap: _pickHomeworkHour,
          ),
        ],
        const Divider(indent: 16, endIndent: 16),
        SwitchListTile(
          secondary: const Icon(Icons.how_to_reg_outlined),
          title: const Text('Напоминать отметить пропуски'),
          subtitle: const Text(
            'Через 20 минут после последней пары, если что-то не отмечено',
          ),
          isThreeLine: true,
          value: _settings.attendanceRemindersEnabled,
          onChanged: (value) async {
            await _settings.setAttendanceRemindersEnabled(value);
            if (mounted) setState(() {});
            await getIt<ReminderScheduler>().refresh();
          },
        ),
        const Divider(indent: 16, endIndent: 16),
        ListTile(
          leading: const Icon(Icons.fact_check_outlined),
          title: const Text('Проверить напоминания'),
          subtitle: const Text('Показать, сколько уже запланировано'),
          onTap: _checkPending,
        ),
      ],
    ];
  }

  // ---------------------------------------------------------- посещаемость

  List<Widget> _attendanceSection() {
    return [
      const SectionHeader('Посещаемость', icon: Icons.how_to_reg_outlined),
      ListTile(
        leading: const Icon(Icons.insights_outlined),
        title: const Text('Статистика пропусков'),
        subtitle: const Text('Сколько пропущено по каждому предмету'),
        trailing: const Icon(Icons.chevron_right),
        onTap: _openAttendance,
      ),
      SwitchListTile(
        secondary: const Icon(Icons.help_outline),
        title: const Text('Показывать вердикт над расписанием'),
        subtitle: const Text(
          'Можно ли пропустить этот день — справа в строке со временем',
        ),
        isThreeLine: true,
        value: _settings.showSkipAdvice,
        onChanged: (value) async {
          await _settings.setShowSkipAdvice(value);
          if (mounted) setState(() {});
        },
      ),
      if (_settings.showSkipAdvice) ...[
        ListTile(
          leading: const Icon(Icons.numbers_outlined),
          title: const Text('Лимит пропусков по предмету'),
          subtitle: SegmentedButton<int>(
            showSelectedIcon: false,
            segments: const [
              ButtonSegment(value: 2, label: Text('2')),
              ButtonSegment(value: 4, label: Text('4')),
              ButtonSegment(value: 6, label: Text('6')),
              ButtonSegment(value: 8, label: Text('8')),
            ],
            selected: {_nearest(_settings.skipLimitPerSubject, const [2, 4, 6, 8])},
            onSelectionChanged: (selection) async {
              await _settings.setSkipLimitPerSubject(selection.first);
              if (mounted) setState(() {});
            },
          ),
          isThreeLine: true,
        ),
        ListTile(
          leading: const Icon(Icons.star_outline),
          title: const Text('Лимит по профильному предмету'),
          subtitle: SegmentedButton<int>(
            showSelectedIcon: false,
            segments: const [
              ButtonSegment(value: 1, label: Text('1')),
              ButtonSegment(value: 2, label: Text('2')),
              ButtonSegment(value: 3, label: Text('3')),
              ButtonSegment(value: 4, label: Text('4')),
            ],
            selected: {
              _nearest(_settings.skipLimitPerMajorSubject, const [1, 2, 3, 4])
            },
            onSelectionChanged: (selection) async {
              await _settings.setSkipLimitPerMajorSubject(selection.first);
              if (mounted) setState(() {});
            },
          ),
          isThreeLine: true,
        ),
      ],
    ];
  }

  /// SegmentedButton падает, если выбранного значения нет среди сегментов,
  /// а в настройках может лежать что угодно из восстановленной копии.
  static int _nearest(int value, List<int> options) {
    var best = options.first;
    for (final option in options) {
      if ((option - value).abs() < (best - value).abs()) best = option;
    }
    return best;
  }

  Future<void> _openAttendance() async {
    final group = _settings.selectedGroup;
    final subjects =
        group == null ? <String>[] : await getIt<ScheduleRepository>().subjects(group);
    if (!mounted) return;

    await Navigator.of(context).push(MaterialPageRoute(
      builder: (_) => AttendancePage(subjects: subjects),
    ));
  }

  Future<void> _pickHomeworkHour() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay(hour: _settings.homeworkReminderHour, minute: 0),
      helpText: 'Когда напоминать о домашке',
      builder: (context, child) => MediaQuery(
        data: MediaQuery.of(context).copyWith(alwaysUse24HourFormat: true),
        child: child!,
      ),
    );
    if (picked == null) return;

    await _settings.setHomeworkReminderHour(picked.hour);
    if (mounted) setState(() {});
    await getIt<ReminderScheduler>().refresh();
  }

  Future<void> _toggleNotifications(bool value) async {
    final messenger = ScaffoldMessenger.of(context);

    if (value) {
      final granted = await getIt<NotificationService>().requestPermission();
      if (!granted) {
        messenger.showSnackBar(const SnackBar(
          content: Text(
            'Android не дал разрешение на уведомления. '
            'Включите его в настройках телефона.',
          ),
        ));
        return;
      }
    }

    await _settings.setNotificationsEnabled(value);
    if (mounted) setState(() {});

    final count = await getIt<ReminderScheduler>().refresh();
    if (!value) return;
    messenger.showSnackBar(SnackBar(
      content: Text(
        count == 0
            ? 'Напоминаний нет: проверьте, что заданы звонки и выбрана группа.'
            : 'Запланировано напоминаний: $count',
      ),
    ));
  }

  Future<void> _toggleExactAlarms(bool value) async {
    final messenger = ScaffoldMessenger.of(context);

    if (value) {
      final granted =
          await getIt<NotificationService>().requestExactAlarmPermission();
      if (!granted) {
        messenger.showSnackBar(const SnackBar(
          content: Text('Разрешение на точные будильники не выдано.'),
        ));
        return;
      }
    }

    await _settings.setExactAlarms(value);
    if (mounted) setState(() {});
    await getIt<ReminderScheduler>().refresh();
  }

  Future<void> _checkPending() async {
    final messenger = ScaffoldMessenger.of(context);
    final pending = await getIt<NotificationService>().pending();
    messenger.showSnackBar(SnackBar(
      content: Text('Запланировано напоминаний: ${pending.length}'),
    ));
  }

  // -------------------------------------------------------- внешний вид

  List<Widget> _appearanceSection() {
    final dynamicOn = _settings.useDynamicColor;

    return [
      const SectionHeader('Внешний вид', icon: Icons.palette_outlined),
      ListTile(
        leading: const Icon(Icons.brightness_6_outlined),
        title: const Text('Тема'),
        subtitle: SegmentedButton<ThemeMode>(
          showSelectedIcon: false,
          segments: const [
            ButtonSegment(
              value: ThemeMode.system,
              label: Text('Как в ОС'),
              icon: Icon(Icons.phone_android, size: 16),
            ),
            ButtonSegment(
              value: ThemeMode.light,
              label: Text('Светлая'),
              icon: Icon(Icons.light_mode_outlined, size: 16),
            ),
            ButtonSegment(
              value: ThemeMode.dark,
              label: Text('Тёмная'),
              icon: Icon(Icons.dark_mode_outlined, size: 16),
            ),
          ],
          selected: {_settings.themeMode},
          onSelectionChanged: (selection) async {
            await _settings.setThemeMode(selection.first);
            if (mounted) setState(() {});
          },
        ),
        isThreeLine: true,
      ),
      SwitchListTile(
        secondary: const Icon(Icons.auto_awesome_outlined),
        title: const Text('Цвета из обоев'),
        subtitle: const Text('Material You, Android 12 и новее'),
        value: dynamicOn,
        onChanged: (value) async {
          await _settings.setUseDynamicColor(value);
          if (mounted) setState(() {});
        },
      ),
      Padding(
        padding: const EdgeInsets.only(left: 16, top: 8, bottom: 4),
        child: Text(
          dynamicOn ? 'Акцент задаётся обоями' : 'Акцент',
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
        ),
      ),
      AccentPicker(
        selectedId: _settings.accentId,
        enabled: !dynamicOn,
        onSelect: (id) async {
          await _settings.setAccentId(id);
          if (mounted) setState(() {});
        },
      ),
      SwitchListTile(
        secondary: const Icon(Icons.contrast),
        title: const Text('Чёрный фон в тёмной теме'),
        subtitle: const Text('Экономит батарею на OLED-экранах'),
        value: _settings.amoledDark,
        onChanged: (value) async {
          await _settings.setAmoledDark(value);
          if (mounted) setState(() {});
        },
      ),
      TextScaleTile(
        value: _settings.textScale,
        onChanged: (value) async {
          await _settings.setTextScale(value);
          if (mounted) setState(() {});
        },
      ),
      SwitchListTile(
        secondary: const Icon(Icons.density_small),
        title: const Text('Компактные карточки'),
        subtitle: const Text('На экран помещается больше пар'),
        value: _settings.compactCards,
        onChanged: (value) async {
          await _settings.setCompactCards(value);
          if (mounted) setState(() {});
        },
      ),
      SwitchListTile(
        secondary: const Icon(Icons.weekend_outlined),
        title: const Text('Показывать выходные'),
        subtitle: const Text('Суббота и воскресенье в полосе дней'),
        value: _settings.showWeekends,
        onChanged: (value) async {
          await _settings.setShowWeekends(value);
          if (mounted) setState(() {});
        },
      ),
      SwitchListTile(
        secondary: const Icon(Icons.play_circle_outline),
        title: const Text('Выделять текущую пару'),
        subtitle: const Text('Прошедшие пары приглушаются'),
        value: _settings.highlightCurrentLesson,
        onChanged: (value) async {
          await _settings.setHighlightCurrentLesson(value);
          if (mounted) setState(() {});
        },
      ),
      ListTile(
        leading: const Icon(Icons.eco_outlined),
        title: const Text('Оформление по сезону'),
        subtitle: Text(_settings.seasonMode.label),
        trailing: const Icon(Icons.chevron_right),
        onTap: _pickSeasonMode,
      ),
      if (_settings.seasonMode != SeasonMode.off)
        SwitchListTile(
          secondary: const Icon(Icons.air),
          title: const Text('Движущиеся объекты'),
          subtitle: const Text(
            'Падающие листья, снег, лепестки. Отключаются сами, если в '
            'Android включено «Удалить анимации». Число подбирается под '
            'телефон, чтобы не было рывков',
          ),
          isThreeLine: true,
          value: _settings.seasonalMotion,
          onChanged: (value) async {
            await _settings.setSeasonalMotion(value);
            if (mounted) setState(() {});
          },
        ),
      ListTile(
        leading: const Icon(Icons.restart_alt),
        title: const Text('Сбросить внешний вид'),
        subtitle: const Text('Расписание и настройки замен не затрагиваются'),
        onTap: () async {
          await _settings.resetAppearance();
          if (mounted) setState(() {});
        },
      ),
    ];
  }

  Future<void> _pickSeasonMode() async {
    final picked = await showDialog<SeasonMode>(
      context: context,
      builder: (dialogContext) => SimpleDialog(
        title: const Text('Оформление по сезону'),
        children: [
          RadioGroup<SeasonMode>(
            groupValue: _settings.seasonMode,
            onChanged: (value) => Navigator.of(dialogContext).pop(value),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                for (final mode in SeasonMode.values)
                  RadioListTile<SeasonMode>(
                    value: mode,
                    title: Text(mode.label),
                    subtitle: mode == SeasonMode.auto
                        ? const Text('Сезон по дате, под Новый год — гирлянда')
                        : null,
                  ),
              ],
            ),
          ),
        ],
      ),
    );
    if (picked == null) return;
    await _settings.setSeasonMode(picked);
    if (mounted) setState(() {});
  }

  // ------------------------------------------------------- источник замен

  List<Widget> _sourceSection() {
    return [
      const SectionHeader('Источник замен', icon: Icons.cloud_outlined),
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
      ListTile(
        leading: const Icon(Icons.apartment_outlined),
        title: const Text('Корпус'),
        subtitle: const Text(
          'Замены на каждый корпус выкладывают отдельным файлом',
        ),
        trailing: SegmentedButton<int>(
          showSelectedIcon: false,
          segments: const [
            ButtonSegment(value: 0, label: Text('Любой')),
            ButtonSegment(value: 1, label: Text('1')),
            ButtonSegment(value: 2, label: Text('2')),
          ],
          selected: {_settings.preferredBuilding ?? 0},
          onSelectionChanged: (selection) async {
            final value = selection.first;
            await _settings.setPreferredBuilding(value == 0 ? null : value);
            if (mounted) setState(() {});
          },
        ),
        isThreeLine: true,
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
      SwitchListTile(
        secondary: const Icon(Icons.cloud_sync_outlined),
        title: const Text('Проверять в фоне'),
        subtitle: const Text(
          'Приложение само сходит на сайт и пришлёт уведомление, '
          'когда появятся новые замены',
        ),
        isThreeLine: true,
        value: _settings.backgroundRefreshEnabled,
        onChanged: (value) async {
          final messenger = ScaffoldMessenger.of(context);

          if (value && !_settings.notificationsEnabled) {
            // Без разрешения на уведомления фоновая проверка бессмысленна:
            // приложение узнает о заменах, а сказать не сможет.
            final granted = await getIt<NotificationService>()
                .requestPermission();
            if (!granted) {
              messenger.showSnackBar(const SnackBar(
                content: Text(
                  'Без разрешения на уведомления сообщить о заменах не выйдет',
                ),
              ));
              return;
            }
          }

          await _settings.setBackgroundRefreshEnabled(value);
          await BackgroundRefresh.apply(_settings);
          if (mounted) setState(() {});
        },
      ),
      if (_settings.backgroundRefreshEnabled)
        ListTile(
          leading: const Icon(Icons.timelapse_outlined),
          title: const Text('Как часто проверять'),
          subtitle: SegmentedButton<int>(
            showSelectedIcon: false,
            segments: const [
              ButtonSegment(value: 1, label: Text('1 ч')),
              ButtonSegment(value: 3, label: Text('3 ч')),
              ButtonSegment(value: 6, label: Text('6 ч')),
              ButtonSegment(value: 12, label: Text('12 ч')),
            ],
            selected: {_settings.backgroundRefreshHours},
            onSelectionChanged: (selection) async {
              await _settings.setBackgroundRefreshHours(selection.first);
              await BackgroundRefresh.apply(_settings);
              if (mounted) setState(() {});
            },
          ),
          isThreeLine: true,
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
    ];
  }

  // -------------------------------------------------------------- данные

  List<Widget> _dataSection() {
    return [
      const SectionHeader('Данные', icon: Icons.storage_outlined),
      ListTile(
        leading: const Icon(Icons.backup_outlined),
        title: const Text('Резервная копия'),
        subtitle: const Text('Сохранить или восстановить всё сразу'),
        trailing: const Icon(Icons.chevron_right),
        onTap: () => Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => const BackupPage()),
        ),
      ),
      ListTile(
        leading: const Icon(Icons.delete_sweep_outlined),
        title: const Text('Удалить загруженные замены'),
        subtitle: const Text('Основное расписание останется'),
        onTap: () => _confirmAndRun(
          title: 'Удалить замены?',
          message: 'Все загруженные замены будут стёрты. '
              'Основное расписание останется на месте.',
          action: () => getIt<SubstitutionsRepository>().clearAll(),
          doneMessage: 'Замены удалены',
        ),
      ),
      ListTile(
        leading: Icon(Icons.delete_forever_outlined,
            color: Theme.of(context).colorScheme.error),
        title: const Text('Удалить расписание'),
        subtitle: const Text('Придётся импортировать .md заново'),
        onTap: () => _confirmAndRun(
          title: 'Удалить расписание?',
          message: 'Будут удалены все импортированные пары. '
              'Чтобы вернуть их, понадобится снова импортировать файл.',
          action: () => getIt<ScheduleRepository>().clearSchedule(),
          doneMessage: 'Расписание удалено',
          destructive: true,
        ),
      ),
      ListTile(
        leading: const Icon(Icons.info_outline),
        title: const Text('О приложении'),
        trailing: const Icon(Icons.chevron_right),
        onTap: () => Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => const AboutPage()),
        ),
      ),
    ];
  }

  Future<void> _confirmAndRun({
    required String title,
    required String message,
    required Future<void> Function() action,
    required String doneMessage,
    bool destructive = false,
  }) async {
    final scheduleCubit = context.read<ScheduleCubit>();
    final messenger = ScaffoldMessenger.of(context);

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text('Отмена'),
          ),
          FilledButton(
            style: destructive
                ? FilledButton.styleFrom(
                    backgroundColor: Theme.of(dialogContext).colorScheme.error,
                  )
                : null,
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: const Text('Удалить'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    await action();
    await scheduleCubit.reload();
    messenger.showSnackBar(SnackBar(content: Text(doneMessage)));
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
