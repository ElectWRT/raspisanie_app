import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/settings/app_settings.dart';
import '../../../../core/utils/week_utils.dart';
import '../../../attendance/presentation/bloc/attendance_cubit.dart';
import '../../../attendance/presentation/widgets/skip_advice_chip.dart';
import '../../../../di.dart';
import '../../../homework/presentation/bloc/homework_cubit.dart';
import '../../../seasons/domain/season.dart';
import '../../../seasons/presentation/festive_garland.dart';
import '../../../seasons/presentation/seasonal_backdrop.dart';
import '../../../homework/presentation/pages/homework_page.dart';
import '../../../settings/presentation/backup_page.dart';
import '../../../settings/presentation/settings_page.dart';
import '../../../substitutions/presentation/bloc/substitutions_cubit.dart';
import '../../../substitutions/presentation/pages/substitutions_page.dart';
import '../../../substitutions/presentation/widgets/last_updated_line.dart';
import '../../domain/entities/bell_schedule.dart';
import '../../domain/repositories/schedule_repository.dart';
import '../../domain/entities/schedule_slot.dart';
import '../bloc/schedule_cubit.dart';
import '../widgets/day_switcher.dart';
import '../widgets/lesson_card.dart';
import 'import_schedule_page.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final settings = getIt<AppSettings>();

    return BlocListener<SubstitutionsCubit, SubstitutionsState>(
      listenWhen: (previous, current) => previous.status != current.status,
      listener: _onRefreshStatusChanged,
      child: BlocBuilder<ScheduleCubit, ScheduleState>(
        builder: (context, state) {
          if (state.error != null) {
            return _StartupErrorView(message: state.error!);
          }
          if (state.isLoading && state.day == null && !state.needsImport) {
            return const _StartupLoadingView();
          }
          if (state.needsImport) return const _NoScheduleView();

          return Scaffold(
            appBar: AppBar(
              title: _GroupPicker(state: state),
              actions: [
                IconButton(
                  tooltip: 'Все замены на день',
                  icon: const Icon(Icons.swap_horiz),
                  onPressed: () => Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => SubstitutionsPage(date: state.date),
                    ),
                  ),
                ),
                _HomeworkButton(group: state.group),
                IconButton(
                  tooltip: 'Настройки',
                  icon: const Icon(Icons.settings_outlined),
                  onPressed: () => _openSettings(context),
                ),
              ],
            ),
            // Сезонное оформление слушает настройки само: смена сезона или
            // выключателя движения видна сразу, без перезагрузки экрана.
            body: ListenableBuilder(
              listenable: settings,
              builder: (context, _) {
                final now = DateTime.now();
                final look = resolveSeasonLook(now, settings.seasonMode);
                final dark = Theme.of(context).brightness == Brightness.dark;

                return SeasonalBackdrop(
                  look: look,
                  motion: settings.seasonalMotion,
                  plainBackground: dark && settings.amoledDark,
                  initialCount: settings.seasonalParticleCount,
                  onCountLearned: settings.setSeasonalParticleCount,
                  child: Column(
                    children: [
                      if (look?.festive ?? false)
                        FestiveGarland(
                          greeting: festiveGreeting(now),
                          motion: settings.seasonalMotion,
                        ),
                      DaySwitcher(
                        date: state.date,
                        onSelect: context.read<ScheduleCubit>().selectDate,
                        showWeekends: settings.showWeekends,
                        substitutionDays: state.substitutionWeekdays,
                      ),
                      const _RefreshBanner(),
                      const LastUpdatedLine(
                        padding: EdgeInsets.fromLTRB(16, 0, 16, 8),
                      ),
                      Expanded(
                        child: _DayBody(state: state, settings: settings),
                      ),
                    ],
                  ),
                );
              },
            ),
            floatingActionButton: const _RefreshButton(),
          );
        },
      ),
    );
  }

  static void _onRefreshStatusChanged(
    BuildContext context,
    SubstitutionsState state,
  ) {
    final messenger = ScaffoldMessenger.of(context);
    if (state.status == RefreshStatus.success && state.report != null) {
      final report = state.report!;
      messenger.showSnackBar(SnackBar(
        content: Text(
          'Замены на ${WeekUtils.formatFullDate(report.date)}: '
          '${report.importedCount} шт.',
        ),
        // Снэкбар с кнопкой Flutter по умолчанию не закрывает сам
        // (persist = action != null) — сообщение висело до ручного свайпа.
        persist: false,
        duration: const Duration(seconds: 4),
        action: SnackBarAction(
          label: 'Открыть',
          onPressed: () => Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => SubstitutionsPage(date: report.date),
            ),
          ),
        ),
      ));
    } else if (state.status == RefreshStatus.failure && state.error != null) {
      messenger.showSnackBar(SnackBar(
        content: Text(state.error!),
        duration: const Duration(seconds: 6),
      ));
    }
  }

  static Future<void> _openSettings(BuildContext context) => openSettings(context);
}

/// Открывает настройки и перечитывает расписание после возврата.
///
/// Общая точка входа: до импорта расписания настройки доступны только
/// отсюда — без этого добраться до резервной копии для восстановления
/// было бы нечем, кроме как сначала вслепую импортировать файл.
Future<void> openSettings(BuildContext context) async {
  final scheduleCubit = context.read<ScheduleCubit>();
  await Navigator.of(context).push(
    MaterialPageRoute(builder: (_) => const SettingsPage()),
  );
  await scheduleCubit.reload();
}

/// Список пар на день. Держит таймер, чтобы отметка «сейчас» не устаревала.
class _DayBody extends StatefulWidget {
  const _DayBody({required this.state, required this.settings});

  final ScheduleState state;
  final AppSettings settings;

  @override
  State<_DayBody> createState() => _DayBodyState();
}

class _DayBodyState extends State<_DayBody> {
  Timer? _ticker;
  DateTime _now = DateTime.now();

  @override
  void initState() {
    super.initState();
    _ticker = Timer.periodic(
      const Duration(seconds: 30),
      (_) => setState(() => _now = DateTime.now()),
    );
    _syncAttendance();
  }

  @override
  void dispose() {
    _ticker?.cancel();
    super.dispose();
  }

  @override
  void didUpdateWidget(covariant _DayBody oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.state.date == widget.state.date &&
        oldWidget.state.group == widget.state.group) {
      return;
    }
    _syncAttendance();
  }

  /// Учёт посещений живёт своим кубитом, но смотрит на ту же группу и день,
  /// что и расписание. Синхронизируем здесь, а не в ScheduleCubit, чтобы
  /// расписание ничего не знало про отметки.
  ///
  /// Всегда после кадра: и initState, и didUpdateWidget выполняются внутри
  /// сборки, а setContext синхронно эмитит новое состояние — подписчики
  /// начали бы перестраиваться посреди уже идущей сборки.
  void _syncAttendance() {
    final state = widget.state;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      context
          .read<AttendanceCubit>()
          .setContext(group: state.group, date: state.date);
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = widget.state;
    final settings = widget.settings;
    final day = state.day;

    if (day == null) {
      return const Center(child: CircularProgressIndicator());
    }

    final content = day.isEmpty
        ? _EmptyDayView(date: day.date)
        : _buildList(day, settings);

    // Горизонтальный свайп листает дни — вертикальная прокрутка не мешает.
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onHorizontalDragEnd: (details) {
        final velocity = details.primaryVelocity ?? 0;
        if (velocity.abs() < 200) return;
        context.read<ScheduleCubit>().shiftDay(velocity < 0 ? 1 : -1);
      },
      child: RefreshIndicator(
        onRefresh: () =>
            context.read<SubstitutionsCubit>().refresh(targetDate: state.date),
        child: content,
      ),
    );
  }

  Widget _buildList(DaySchedule day, AppSettings settings) {
    final isToday = WeekUtils.dayKey(_now) == day.date;
    final compact = settings.compactCards;

    // Отметки, профили предметов и «что взять» — из учёта посещений.
    final attendance = context.watch<AttendanceCubit>().state;

    // Незакрытые задания по предметам — значок на карточке пары.
    final homework = context.watch<HomeworkCubit>().state;
    final counts = <String, int>{};
    for (final task in homework.items) {
      if (task.isDone) continue;
      final key = task.subject.toLowerCase();
      counts[key] = (counts[key] ?? 0) + 1;
    }

    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 96),
      itemCount: day.slots.length + 1,
      separatorBuilder: (_, __) => SizedBox(height: compact ? 8 : 10),
      itemBuilder: (context, index) {
        if (index == 0) {
          return _DaySummary(
            key: ValueKey('summary-${day.date}'),
            day: day,
            bells: widget.state.activeBells,
            showAdvice: settings.showSkipAdvice,
          ).animate().fadeIn(duration: 200.ms);
        }

        final slot = day.slots[index - 1];
        final bell = widget.state.bellFor(slot.pairNumber);
        final highlight = settings.highlightCurrentLesson && isToday;

        return LessonCard(
          key: ValueKey('${day.date}-${slot.pairNumber}-${slot.subgroup}'),
          slot: slot,
          bell: bell,
          compact: compact,
          isNow: highlight && (bell?.isNow(_now, day.date) ?? false),
          isPast: highlight && (bell?.isPast(_now, day.date) ?? false),
          homeworkCount: counts[slot.subject.toLowerCase()] ?? 0,
          entranceIndex: index - 1,
          attendance: attendance.markFor(slot)?.status,
          onAttendanceTap: () =>
              context.read<AttendanceCubit>().cycle(slot),
          requiredItems: attendance.itemsFor(slot.subject),
          isMajorSubject: attendance.isMajor(slot.subject),
        );
      },
    );
  }
}

/// Строка-сводка над списком: сколько пар, во сколько начало и конец,
/// а справа — вердикт, во что обойдётся пропуск этого дня.
class _DaySummary extends StatelessWidget {
  const _DaySummary({
    super.key,
    required this.day,
    required this.bells,
    this.showAdvice = true,
  });

  final DaySchedule day;
  final BellSchedule? bells;
  final bool showAdvice;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    final numbers = day.slots.map((s) => s.pairNumber).toSet().toList()..sort();
    final first = bells?.timeFor(numbers.first);
    final last = bells?.timeFor(numbers.last);

    final parts = <String>[
      _plural(numbers.length),
      if (first != null && last != null) '${first.start} – ${last.end}',
      if (day.substitutionCount > 0) 'замен: ${day.substitutionCount}',
    ];

    // Вердикт считается по парам с уже наложенными заменами: снятая пара
    // в него не идёт, а заменённая идёт со своим новым предметом.
    final attendance = context.watch<AttendanceCubit>();
    final advice = showAdvice ? attendance.adviceFor(day.slots) : null;

    return Padding(
      padding: const EdgeInsets.only(bottom: 10, left: 2),
      child: Row(
        children: [
          Icon(Icons.schedule_outlined, size: 15, color: scheme.onSurfaceVariant),
          const SizedBox(width: 6),
          Expanded(
            child: Text(
              parts.join('  ·  '),
              style: theme.textTheme.labelMedium
                  ?.copyWith(color: scheme.onSurfaceVariant),
            ),
          ),
          if (day.substitutionCount > 0)
            Padding(
              padding: const EdgeInsets.only(right: 6),
              child: Icon(Icons.swap_horiz, size: 15, color: scheme.tertiary),
            ),
          if (advice != null && !advice.isEmpty)
            SkipAdviceChip(advice: advice),
        ],
      ),
    );
  }

  static String _plural(int count) {
    final mod10 = count % 10;
    final mod100 = count % 100;
    if (mod10 == 1 && mod100 != 11) return '$count пара';
    if (mod10 >= 2 && mod10 <= 4 && (mod100 < 12 || mod100 > 14)) {
      return '$count пары';
    }
    return '$count пар';
  }
}

class _GroupPicker extends StatelessWidget {
  const _GroupPicker({required this.state});

  final ScheduleState state;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final group = state.group ?? '—';

    return InkWell(
      borderRadius: BorderRadius.circular(8),
      onTap: state.availableGroups.length < 2
          ? null
          : () => _showGroupSheet(context),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 4),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(group, style: theme.textTheme.titleMedium),
                Text(
                  WeekUtils.weekTypeLabel(
                    state.day?.weekType ?? WeekUtils.weekTypeFor(state.date),
                  ),
                  style: theme.textTheme.labelSmall
                      ?.copyWith(color: theme.colorScheme.onSurfaceVariant),
                ),
              ],
            ),
            if (state.availableGroups.length > 1)
              const Icon(Icons.expand_more, size: 20),
          ],
        ),
      ),
    );
  }

  void _showGroupSheet(BuildContext context) {
    final cubit = context.read<ScheduleCubit>();
    showModalBottomSheet<void>(
      context: context,
      builder: (sheetContext) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 18, 20, 8),
              child: Row(
                children: [
                  const Icon(Icons.groups_outlined, size: 20),
                  const SizedBox(width: 10),
                  Text(
                    'Группа',
                    style: Theme.of(sheetContext).textTheme.titleMedium,
                  ),
                ],
              ),
            ),
            Flexible(
              child: RadioGroup<String>(
                groupValue: state.group,
                onChanged: (value) {
                  if (value != null) cubit.selectGroup(value);
                  Navigator.of(sheetContext).pop();
                },
                child: ListView(
                  shrinkWrap: true,
                  children: [
                    for (final group in state.availableGroups)
                      RadioListTile<String>(value: group, title: Text(group)),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }
}

class _RefreshBanner extends StatelessWidget {
  const _RefreshBanner();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SubstitutionsCubit, SubstitutionsState>(
      builder: (context, state) {
        if (state.status != RefreshStatus.loading) {
          return const SizedBox.shrink();
        }
        return const LinearProgressIndicator(minHeight: 2);
      },
    );
  }
}

class _RefreshButton extends StatelessWidget {
  const _RefreshButton();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SubstitutionsCubit, SubstitutionsState>(
      builder: (context, state) {
        final loading = state.status == RefreshStatus.loading;
        return FloatingActionButton.extended(
          onPressed: loading
              ? null
              : () => context.read<SubstitutionsCubit>().refresh(
                    targetDate: context.read<ScheduleCubit>().state.date,
                  ),
          icon: loading
              ? const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Icon(Icons.cloud_download_outlined),
          label: Text(loading ? 'Загружаю…' : 'Обновить замены'),
        );
      },
    );
  }
}

class _EmptyDayView extends StatelessWidget {
  const _EmptyDayView({required this.date});

  final DateTime date;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isWeekend = date.weekday >= 6;

    // ListView, а не Center — иначе RefreshIndicator не сработает.
    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 64),
      children: [
        Icon(
          key: ValueKey('empty-icon-$date'),
          isWeekend ? Icons.weekend_outlined : Icons.event_available_outlined,
          size: 56,
          color: theme.colorScheme.outline,
        ).animate().fadeIn(duration: 260.ms).scale(
              begin: const Offset(0.85, 0.85),
              end: const Offset(1, 1),
              duration: 260.ms,
              curve: Curves.easeOut,
            ),
        const SizedBox(height: 16),
        Text(
          isWeekend ? 'Выходной' : 'В этот день пар нет',
          textAlign: TextAlign.center,
          style: theme.textTheme.titleMedium,
        ),
        const SizedBox(height: 4),
        Text(
          WeekUtils.formatFullDate(date),
          textAlign: TextAlign.center,
          style: theme.textTheme.bodySmall
              ?.copyWith(color: theme.colorScheme.onSurfaceVariant),
        ),
      ],
    );
  }
}

class _NoScheduleView extends StatelessWidget {
  const _NoScheduleView();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Расписание'),
        actions: [
          IconButton(
            tooltip: 'Настройки',
            icon: const Icon(Icons.settings_outlined),
            onPressed: () => openSettings(context),
          ),
        ],
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.upload_file_outlined,
                  size: 64, color: theme.colorScheme.primary),
              const SizedBox(height: 20),
              Text('Расписание ещё не загружено',
                  style: theme.textTheme.titleLarge,
                  textAlign: TextAlign.center),
              const SizedBox(height: 8),
              Text(
                'Импортируйте основное расписание в формате Markdown — '
                'после этого замены будут накладываться на него автоматически.',
                textAlign: TextAlign.center,
                style: theme.textTheme.bodyMedium
                    ?.copyWith(color: theme.colorScheme.onSurfaceVariant),
              ),
              const SizedBox(height: 24),
              FilledButton.icon(
                onPressed: () => _openImport(context),
                icon: const Icon(Icons.add),
                label: const Text('Импортировать расписание'),
              ),
              const SizedBox(height: 12),
              TextButton.icon(
                onPressed: () => _openBackup(context),
                icon: const Icon(Icons.restore_outlined, size: 18),
                label: const Text('Восстановить из резервной копии'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _openImport(BuildContext context) async {
    final cubit = context.read<ScheduleCubit>();
    await Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const ImportSchedulePage()),
    );
    await cubit.reload();
  }

  Future<void> _openBackup(BuildContext context) async {
    final cubit = context.read<ScheduleCubit>();
    await Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const BackupPage()),
    );
    await cubit.reload();
  }
}

/// Загрузка при старте. Если она затянулась, показываем подсказку —
/// молчаливая крутилка навсегда была бы худшим из вариантов.
class _StartupLoadingView extends StatefulWidget {
  const _StartupLoadingView();

  @override
  State<_StartupLoadingView> createState() => _StartupLoadingViewState();
}

class _StartupLoadingViewState extends State<_StartupLoadingView> {
  Timer? _watchdog;
  bool _slow = false;

  @override
  void initState() {
    super.initState();
    _watchdog = Timer(const Duration(seconds: 6), () {
      if (mounted) setState(() => _slow = true);
    });
  }

  @override
  void dispose() {
    _watchdog?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const CircularProgressIndicator(),
              if (_slow) ...[
                const SizedBox(height: 24),
                Text(
                  'Что-то долго',
                  style: theme.textTheme.titleMedium,
                ),
                const SizedBox(height: 8),
                Text(
                  'База данных не отвечает. Попробуйте перезапустить '
                  'приложение. Если не поможет — переустановите его: '
                  'загруженное расписание придётся импортировать заново.',
                  textAlign: TextAlign.center,
                  style: theme.textTheme.bodySmall
                      ?.copyWith(color: theme.colorScheme.onSurfaceVariant),
                ),
                const SizedBox(height: 20),
                FilledButton.tonal(
                  onPressed: () => context.read<ScheduleCubit>().retry(),
                  child: const Text('Попробовать снова'),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

/// Показывает текст сбоя вместо бесконечной загрузки.
class _StartupErrorView extends StatelessWidget {
  const _StartupErrorView({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Не удалось запуститься')),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          Icon(Icons.error_outline, size: 56, color: theme.colorScheme.error),
          const SizedBox(height: 16),
          Text(
            'Ошибка при чтении данных',
            textAlign: TextAlign.center,
            style: theme.textTheme.titleMedium,
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: theme.colorScheme.surfaceContainerHigh,
              borderRadius: BorderRadius.circular(12),
            ),
            child: SelectableText(
              message,
              style: theme.textTheme.bodySmall
                  ?.copyWith(fontFamily: 'monospace'),
            ),
          ),
          const SizedBox(height: 20),
          FilledButton(
            onPressed: () => context.read<ScheduleCubit>().retry(),
            child: const Text('Попробовать снова'),
          ),
          const SizedBox(height: 8),
          TextButton.icon(
            onPressed: () async {
              await Clipboard.setData(ClipboardData(text: message));
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Текст ошибки скопирован')),
                );
              }
            },
            icon: const Icon(Icons.copy, size: 18),
            label: const Text('Скопировать ошибку'),
          ),
        ],
      ),
    );
  }
}

/// Кнопка домашки в шапке. На ней — счётчик незакрытых заданий.
class _HomeworkButton extends StatelessWidget {
  const _HomeworkButton({required this.group});

  final String? group;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<HomeworkCubit, HomeworkState>(
      builder: (context, state) {
        final pending = state.items.where((h) => !h.isDone).length;
        final overdue = state.overdue.isNotEmpty;

        return IconButton(
          tooltip: 'Домашние задания',
          onPressed: () => _open(context),
          icon: Badge(
            isLabelVisible: pending > 0,
            label: Text('$pending'),
            backgroundColor: overdue
                ? Theme.of(context).colorScheme.error
                : Theme.of(context).colorScheme.secondary,
            child: const Icon(Icons.assignment_outlined),
          ),
        );
      },
    );
  }

  Future<void> _open(BuildContext context) async {
    final homeworkCubit = context.read<HomeworkCubit>();
    final navigator = Navigator.of(context);

    // Предметы группы подставляются подсказками в редакторе задания.
    final subjects = group == null
        ? <String>[]
        : await getIt<ScheduleRepository>().subjects(group!);

    await navigator.push(
      MaterialPageRoute(
        builder: (_) => BlocProvider.value(
          value: homeworkCubit,
          child: HomeworkPage(subjects: subjects),
        ),
      ),
    );
  }
}
