import 'package:flutter/material.dart';

import '../../../../core/utils/week_utils.dart';
import '../../../../di.dart';
import '../../domain/entities/bell_schedule.dart';
import '../../domain/entities/schedule_slot.dart';
import '../../domain/repositories/schedule_repository.dart';

/// Список наборов звонков. Наборов может быть несколько — например,
/// будни и суббота, когда пары короче.
class BellsPage extends StatefulWidget {
  const BellsPage({super.key});

  @override
  State<BellsPage> createState() => _BellsPageState();
}

class _BellsPageState extends State<BellsPage> {
  final ScheduleRepository _repository = getIt<ScheduleRepository>();

  List<BellSchedule> _schedules = const [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final schedules = await _repository.getBellSchedules();
    if (!mounted) return;
    setState(() {
      _schedules = schedules;
      _loading = false;
    });
  }

  Future<void> _persist(List<BellSchedule> schedules) async {
    await _repository.saveBellSchedules(schedules);
    if (!mounted) return;
    setState(() => _schedules = schedules);
  }

  Future<void> _openEditor({BellSchedule? existing, int? index}) async {
    final result = await Navigator.of(context).push<BellSchedule>(
      MaterialPageRoute(
        builder: (_) => BellScheduleEditorPage(
          schedule: existing ??
              const BellSchedule(
                name: 'Новый набор',
                times: [BellTime(pairNumber: 1, start: '08:30', end: '10:00')],
              ),
        ),
      ),
    );
    if (result == null) return;

    final updated = [..._schedules];
    if (index == null) {
      updated.add(result);
    } else {
      updated[index] = result;
    }
    await _persist(updated);
  }

  Future<void> _delete(int index) async {
    final updated = [..._schedules]..removeAt(index);
    await _persist(updated);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Расписание звонков')),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _openEditor(),
        icon: const Icon(Icons.add),
        label: const Text('Набор'),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _schedules.isEmpty
              ? const _EmptyBells()
              : ListView.separated(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 96),
                  itemCount: _schedules.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 12),
                  itemBuilder: (context, index) => _ScheduleCard(
                    schedule: _schedules[index],
                    onEdit: () =>
                        _openEditor(existing: _schedules[index], index: index),
                    onDelete: () => _delete(index),
                  ),
                ),
    );
  }
}

class _ScheduleCard extends StatelessWidget {
  const _ScheduleCard({
    required this.schedule,
    required this.onEdit,
    required this.onDelete,
  });

  final BellSchedule schedule;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return Card(
      color: scheme.surfaceContainerLow,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: scheme.outlineVariant),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onEdit,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      schedule.name,
                      style: theme.textTheme.titleMedium
                          ?.copyWith(fontWeight: FontWeight.w600),
                    ),
                  ),
                  IconButton(
                    tooltip: 'Удалить набор',
                    icon: const Icon(Icons.delete_outline),
                    onPressed: onDelete,
                  ),
                ],
              ),
              const SizedBox(height: 2),
              Text(
                _daysCaption(schedule),
                style: theme.textTheme.bodySmall
                    ?.copyWith(color: scheme.onSurfaceVariant),
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 6,
                children: [
                  for (final time in schedule.times)
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 5),
                      decoration: BoxDecoration(
                        color: scheme.surfaceContainerHigh,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        '${time.pairNumber}.  ${time.start}–${time.end}',
                        style: theme.textTheme.labelMedium,
                      ),
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  static String _daysCaption(BellSchedule schedule) {
    if (schedule.isDefault) return 'По умолчанию — для всех остальных дней';
    final days = schedule.days.toList()..sort();
    return days.map(WeekUtils.dayNameShort).join(', ');
  }
}

class _EmptyBells extends StatelessWidget {
  const _EmptyBells();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.notifications_none,
                size: 56, color: theme.colorScheme.outline),
            const SizedBox(height: 16),
            Text('Звонки не заданы', style: theme.textTheme.titleMedium),
            const SizedBox(height: 8),
            Text(
              'Их можно указать в файле расписания или добавить здесь вручную. '
              'Без звонков не будет ни времени пар, ни напоминаний.',
              textAlign: TextAlign.center,
              style: theme.textTheme.bodySmall
                  ?.copyWith(color: theme.colorScheme.onSurfaceVariant),
            ),
          ],
        ),
      ),
    );
  }
}

/// Редактор одного набора: название, дни недели и времена пар.
class BellScheduleEditorPage extends StatefulWidget {
  const BellScheduleEditorPage({super.key, required this.schedule});

  final BellSchedule schedule;

  @override
  State<BellScheduleEditorPage> createState() => _BellScheduleEditorPageState();
}

class _BellScheduleEditorPageState extends State<BellScheduleEditorPage> {
  late final TextEditingController _nameController =
      TextEditingController(text: widget.schedule.name);
  late final Set<int> _days = {...widget.schedule.days};
  late List<BellTime> _times = [...widget.schedule.times];

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _pickTime(int index, {required bool isStart}) async {
    final current = isStart ? _times[index].start : _times[index].end;
    final parts = current.split(':');

    final picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay(
        hour: int.tryParse(parts.first) ?? 8,
        minute: int.tryParse(parts.last) ?? 0,
      ),
      builder: (context, child) => MediaQuery(
        // Принудительно 24-часовой формат — расписание всегда так пишут.
        data: MediaQuery.of(context).copyWith(alwaysUse24HourFormat: true),
        child: child!,
      ),
    );
    if (picked == null) return;

    final value = '${picked.hour.toString().padLeft(2, '0')}:'
        '${picked.minute.toString().padLeft(2, '0')}';

    setState(() {
      final time = _times[index];
      _times[index] = BellTime(
        pairNumber: time.pairNumber,
        start: isStart ? value : time.start,
        end: isStart ? time.end : value,
      );
    });
  }

  void _addPair() {
    final nextNumber = _times.isEmpty
        ? 1
        : _times.map((t) => t.pairNumber).reduce((a, b) => a > b ? a : b) + 1;
    setState(() {
      _times = [
        ..._times,
        BellTime(pairNumber: nextNumber, start: '08:30', end: '10:00'),
      ];
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Набор звонков'),
        actions: [
          TextButton(
            onPressed: _save,
            child: const Text('Готово'),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
        children: [
          TextField(
            controller: _nameController,
            decoration: const InputDecoration(labelText: 'Название'),
          ),
          const SizedBox(height: 20),
          Text('Дни недели', style: theme.textTheme.labelLarge),
          const SizedBox(height: 4),
          Text(
            'Если не выбрать ни одного — набор станет основным и будет '
            'применяться ко всем дням, для которых нет своего набора.',
            style: theme.textTheme.bodySmall
                ?.copyWith(color: theme.colorScheme.onSurfaceVariant),
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            children: [
              for (var day = 1; day <= 7; day++)
                FilterChip(
                  label: Text(WeekUtils.dayNameShort(day)),
                  selected: _days.contains(day),
                  onSelected: (selected) => setState(() {
                    selected ? _days.add(day) : _days.remove(day);
                  }),
                ),
            ],
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              Text('Пары', style: theme.textTheme.labelLarge),
              const Spacer(),
              TextButton.icon(
                onPressed: _addPair,
                icon: const Icon(Icons.add, size: 18),
                label: const Text('Добавить'),
              ),
            ],
          ),
          for (var i = 0; i < _times.length; i++) _pairRow(i),
        ],
      ),
    );
  }

  Widget _pairRow(int index) {
    final time = _times[index];

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          SizedBox(
            width: 36,
            child: Text(
              '${time.pairNumber}.',
              style: Theme.of(context).textTheme.titleSmall,
            ),
          ),
          Expanded(
            child: OutlinedButton(
              onPressed: () => _pickTime(index, isStart: true),
              child: Text(time.start),
            ),
          ),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 8),
            child: Text('–'),
          ),
          Expanded(
            child: OutlinedButton(
              onPressed: () => _pickTime(index, isStart: false),
              child: Text(time.end),
            ),
          ),
          IconButton(
            tooltip: 'Убрать пару',
            icon: const Icon(Icons.close),
            onPressed: () => setState(() => _times.removeAt(index)),
          ),
        ],
      ),
    );
  }

  void _save() {
    final name = _nameController.text.trim();
    final sorted = [..._times]
      ..sort((a, b) => a.pairNumber.compareTo(b.pairNumber));

    Navigator.of(context).pop(
      BellSchedule(
        name: name.isEmpty ? 'Звонки' : name,
        days: _days,
        times: sorted,
      ),
    );
  }
}
