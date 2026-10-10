import 'package:equatable/equatable.dart';

import 'schedule_slot.dart';

/// Набор звонков, привязанный к дням недели.
///
/// В большинстве заведений звонки в субботу отличаются от будних, а иногда
/// заводят отдельный «сокращённый» день. Поэтому наборов может быть несколько.
class BellSchedule extends Equatable {
  final String name;

  /// Дни недели 1..7, для которых действует набор.
  /// Пустое множество — набор по умолчанию, используется для всех
  /// дней, которые не покрыты другими наборами.
  final Set<int> days;

  final List<BellTime> times;

  /// Разовый набор на конкретную дату: сокращённые пары перед праздником,
  /// актовый час. Действует только в этот день и сильнее любого набора
  /// по дням недели. null — обычный набор.
  final DateTime? date;

  const BellSchedule({
    required this.name,
    this.days = const {},
    this.times = const [],
    this.date,
  });

  /// Набор на один день, а не на день недели.
  bool get isOneOff => date != null;

  bool get isDefault => days.isEmpty && date == null;

  BellTime? timeFor(int pairNumber) {
    for (final time in times) {
      if (time.pairNumber == pairNumber) return time;
    }
    return null;
  }

  BellSchedule copyWith({
    String? name,
    Set<int>? days,
    List<BellTime>? times,
    DateTime? date,
  }) {
    return BellSchedule(
      name: name ?? this.name,
      days: days ?? this.days,
      times: times ?? this.times,
      date: date ?? this.date,
    );
  }

  factory BellSchedule.fromJson(Map<String, dynamic> json) {
    final raw = json['date'];
    return BellSchedule(
      name: json['name'] as String? ?? 'Звонки',
      days: ((json['days'] as List?) ?? const [])
          .map((e) => (e as num).toInt())
          .toSet(),
      times: ((json['times'] as List?) ?? const [])
          .map((e) => BellTime.fromJson(e as Map<String, dynamic>))
          .toList(),
      date: raw is String ? DateTime.tryParse(raw) : null,
    );
  }

  Map<String, dynamic> toJson() => {
        'name': name,
        'days': days.toList()..sort(),
        'times': times.map((t) => t.toJson()).toList(),
        // Только у разовых: в наборах по дням недели ключа не будет,
        // и старые сохранённые звонки читаются как раньше.
        if (date != null)
          'date': DateTime(date!.year, date!.month, date!.day)
              .toIso8601String(),
      };

  @override
  List<Object?> get props => [name, days, times, date];
}

/// Выбирает набор звонков для дня недели.
///
/// Сначала ищем набор, явно покрывающий этот день; если такого нет —
/// берём набор по умолчанию. Разовые наборы здесь не участвуют: они
/// привязаны к дате, а не к дню недели.
/// Возвращает null, когда звонки не заданы вовсе.
BellSchedule? bellScheduleForWeekday(
  List<BellSchedule> schedules,
  int weekday,
) {
  for (final schedule in schedules) {
    if (!schedule.isOneOff && schedule.days.contains(weekday)) return schedule;
  }
  for (final schedule in schedules) {
    if (schedule.isDefault) return schedule;
  }
  return null;
}

/// Выбирает набор звонков на конкретный день.
///
/// Разовый набор на эту дату сильнее всего: если завтра сокращённые пары,
/// то и напоминания, и время на карточках должны идти по ним.
BellSchedule? bellScheduleForDate(
  List<BellSchedule> schedules,
  DateTime date,
) {
  final day = DateTime(date.year, date.month, date.day);
  for (final schedule in schedules) {
    final own = schedule.date;
    if (own != null && DateTime(own.year, own.month, own.day) == day) {
      return schedule;
    }
  }
  return bellScheduleForWeekday(schedules, date.weekday);
}
