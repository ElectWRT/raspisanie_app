import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/attendance_stats.dart';
import '../bloc/attendance_cubit.dart';
import '../widgets/subject_profile_sheet.dart';

/// Статистика пропусков по предметам.
///
/// Отмечают посещение прямо в списке пар на главном экране — здесь только
/// итог: где запас исчерпан и по каким предметам.
class AttendancePage extends StatelessWidget {
  const AttendancePage({super.key, this.subjects = const []});

  /// Предметы из расписания — чтобы завести профиль предмету, по которому
  /// отметок ещё нет.
  final List<String> subjects;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AttendanceCubit, AttendanceState>(
      builder: (context, state) {
        final stats = state.stats;

        return Scaffold(
          appBar: AppBar(
            title: const Text('Посещаемость'),
            actions: [
              IconButton(
                tooltip: 'Профили предметов',
                icon: const Icon(Icons.tune),
                onPressed: () => _openProfiles(context, state),
              ),
            ],
          ),
          body: stats.isEmpty
              ? const _EmptyStats()
              : ListView(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 32),
                  children: [
                    _TotalCard(stats: stats),
                    const SizedBox(height: 18),
                    Text(
                      'По предметам',
                      style: Theme.of(context).textTheme.titleSmall,
                    ),
                    const SizedBox(height: 8),
                    for (final subject in stats.subjects)
                      _SubjectTile(
                        item: subject,
                        onTap: () => showSubjectProfileSheet(
                          context,
                          subject: subject.subject,
                        ),
                      ),
                  ],
                ),
        );
      },
    );
  }

  void _openProfiles(BuildContext context, AttendanceState state) {
    final known = <String>{
      ...subjects,
      ...state.stats.subjects.map((s) => s.subject),
      ...state.profiles.map((p) => p.subject),
    }.toList()
      ..sort((a, b) => a.toLowerCase().compareTo(b.toLowerCase()));

    Navigator.of(context).push(MaterialPageRoute(
      builder: (_) => BlocProvider.value(
        value: context.read<AttendanceCubit>(),
        child: _SubjectProfilesPage(subjects: known),
      ),
    ));
  }
}

class _TotalCard extends StatelessWidget {
  const _TotalCard({required this.stats});

  final AttendanceStats stats;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: scheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: scheme.outlineVariant),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text('${stats.percent}%',
                  style: theme.textTheme.displaySmall
                      ?.copyWith(fontWeight: FontWeight.w600)),
              const SizedBox(width: 10),
              Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Text('посещено',
                    style: theme.textTheme.bodyMedium
                        ?.copyWith(color: scheme.onSurfaceVariant)),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: stats.rate,
              minHeight: 7,
              backgroundColor: scheme.surfaceContainerHighest,
            ),
          ),
          const SizedBox(height: 14),
          Wrap(
            spacing: 18,
            runSpacing: 8,
            children: [
              _Counter(label: 'был', value: stats.present, color: scheme.primary),
              _Counter(
                  label: 'пропустил', value: stats.absent, color: scheme.error),
              _Counter(
                  label: 'по уважительной',
                  value: stats.excused,
                  color: scheme.tertiary),
            ],
          ),
        ],
      ),
    );
  }
}

class _Counter extends StatelessWidget {
  const _Counter({
    required this.label,
    required this.value,
    required this.color,
  });

  final String label;
  final int value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 6),
        Text('$value',
            style: theme.textTheme.titleSmall
                ?.copyWith(fontWeight: FontWeight.w600)),
        const SizedBox(width: 4),
        Text(label,
            style: theme.textTheme.bodySmall
                ?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
      ],
    );
  }
}

class _SubjectTile extends StatelessWidget {
  const _SubjectTile({required this.item, required this.onTap});

  final SubjectAttendance item;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return Card(
      elevation: 0,
      margin: const EdgeInsets.only(bottom: 8),
      color: scheme.surfaceContainerLow,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: BorderSide(color: scheme.outlineVariant),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      item.subject,
                      style: theme.textTheme.titleSmall
                          ?.copyWith(fontWeight: FontWeight.w600),
                    ),
                  ),
                  if (item.isMajor)
                    Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: Icon(Icons.star, size: 15, color: scheme.secondary),
                    ),
                  Text('${item.percent}%',
                      style: theme.textTheme.titleSmall?.copyWith(
                        color: item.absent > 0 ? scheme.error : scheme.primary,
                      )),
                ],
              ),
              const SizedBox(height: 8),
              ClipRRect(
                borderRadius: BorderRadius.circular(3),
                child: LinearProgressIndicator(
                  value: item.rate,
                  minHeight: 5,
                  backgroundColor: scheme.surfaceContainerHighest,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'был ${item.present} · пропустил ${item.absent}'
                '${item.excused > 0 ? " · по уважительной ${item.excused}" : ""}',
                style: theme.textTheme.bodySmall
                    ?.copyWith(color: scheme.onSurfaceVariant),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _EmptyStats extends StatelessWidget {
  const _EmptyStats();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.how_to_reg_outlined,
                size: 56, color: theme.colorScheme.onSurfaceVariant),
            const SizedBox(height: 16),
            Text('Отметок пока нет', style: theme.textTheme.titleMedium),
            const SizedBox(height: 8),
            Text(
              'Отмечайте пары кружком справа на карточке: '
              'был, пропустил или по уважительной причине.',
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyMedium
                  ?.copyWith(color: theme.colorScheme.onSurfaceVariant),
            ),
          ],
        ),
      ),
    );
  }
}

/// Список предметов с их профилями: профильность и что брать на пару.
class _SubjectProfilesPage extends StatelessWidget {
  const _SubjectProfilesPage({required this.subjects});

  final List<String> subjects;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AttendanceCubit, AttendanceState>(
      builder: (context, state) {
        return Scaffold(
          appBar: AppBar(title: const Text('Профили предметов')),
          body: subjects.isEmpty
              ? const Center(
                  child: Padding(
                    padding: EdgeInsets.all(32),
                    child: Text(
                      'Предметы появятся после импорта расписания.',
                      textAlign: TextAlign.center,
                    ),
                  ),
                )
              : ListView.separated(
                  itemCount: subjects.length,
                  separatorBuilder: (_, __) => const Divider(height: 1),
                  itemBuilder: (context, index) {
                    final subject = subjects[index];
                    final isMajor = state.isMajor(subject);
                    final items = state.itemsFor(subject);

                    final details = [
                      if (isMajor) 'профильный',
                      if (items.isNotEmpty) 'взять: ${items.join(', ')}',
                    ].join(' · ');

                    return ListTile(
                      title: Text(subject),
                      subtitle: Text(
                        details.isEmpty ? 'профиль не задан' : details,
                      ),
                      trailing: Icon(
                        isMajor ? Icons.star : Icons.chevron_right,
                        color: isMajor
                            ? Theme.of(context).colorScheme.secondary
                            : null,
                      ),
                      onTap: () =>
                          showSubjectProfileSheet(context, subject: subject),
                    );
                  },
                ),
        );
      },
    );
  }
}
