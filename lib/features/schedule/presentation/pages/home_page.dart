import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/utils/week_utils.dart';
import '../../../settings/presentation/settings_page.dart';
import '../../../substitutions/presentation/bloc/substitutions_cubit.dart';
import '../../../substitutions/presentation/pages/substitutions_page.dart';
import '../bloc/schedule_cubit.dart';
import '../widgets/day_switcher.dart';
import '../widgets/lesson_card.dart';
import 'import_schedule_page.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocListener<SubstitutionsCubit, SubstitutionsState>(
      listenWhen: (previous, current) => previous.status != current.status,
      listener: _onRefreshStatusChanged,
      child: BlocBuilder<ScheduleCubit, ScheduleState>(
        builder: (context, state) {
          if (state.isLoading && state.day == null && !state.needsImport) {
            return const Scaffold(
              body: Center(child: CircularProgressIndicator()),
            );
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
                IconButton(
                  tooltip: 'Настройки',
                  icon: const Icon(Icons.settings_outlined),
                  onPressed: () => _openSettings(context),
                ),
              ],
            ),
            body: Column(
              children: [
                DaySwitcher(
                  date: state.date,
                  onSelect: context.read<ScheduleCubit>().selectDate,
                ),
                const _RefreshBanner(),
                Expanded(child: _DayBody(state: state)),
              ],
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
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 6),
      ));
    }
  }

  static Future<void> _openSettings(BuildContext context) async {
    final scheduleCubit = context.read<ScheduleCubit>();
    await Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const SettingsPage()),
    );
    await scheduleCubit.reload();
  }
}

class _DayBody extends StatelessWidget {
  const _DayBody({required this.state});

  final ScheduleState state;

  @override
  Widget build(BuildContext context) {
    final day = state.day;
    if (day == null) {
      return const Center(child: CircularProgressIndicator());
    }
    if (day.isEmpty) return _EmptyDayView(date: day.date);

    return RefreshIndicator(
      onRefresh: () =>
          context.read<SubstitutionsCubit>().refresh(targetDate: state.date),
      child: ListView.separated(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 96),
        itemCount: day.slots.length,
        separatorBuilder: (_, __) => const SizedBox(height: 10),
        itemBuilder: (context, index) {
          final slot = day.slots[index];
          return LessonCard(slot: slot, bell: state.bellFor(slot.pairNumber));
        },
      ),
    );
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
                    state.day?.weekType ??
                        WeekUtils.weekTypeFor(state.date),
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

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              isWeekend ? Icons.weekend_outlined : Icons.event_available_outlined,
              size: 56,
              color: theme.colorScheme.outline,
            ),
            const SizedBox(height: 16),
            Text(
              isWeekend ? 'Выходной' : 'В этот день пар нет',
              style: theme.textTheme.titleMedium,
            ),
            const SizedBox(height: 4),
            Text(
              WeekUtils.formatFullDate(date),
              style: theme.textTheme.bodySmall
                  ?.copyWith(color: theme.colorScheme.onSurfaceVariant),
            ),
          ],
        ),
      ),
    );
  }
}

class _NoScheduleView extends StatelessWidget {
  const _NoScheduleView();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Расписание')),
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
                  style: theme.textTheme.titleLarge, textAlign: TextAlign.center),
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
}
