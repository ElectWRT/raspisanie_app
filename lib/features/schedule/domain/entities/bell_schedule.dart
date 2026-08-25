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

  const BellSchedule({
    required this.name,
    this.days = const {},
    this.times = const [],
  });

  bool get isDefault => days.isEmpty;

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
  }) {
    return BellSchedule(
      name: name ?? this.name,
      days: days ?? this.days,
      times: times ?? this.times,
    );
  }

  factory BellSchedule.fromJson(Map<String, dynamic> json) => BellSchedule(
        name: json['name'] as String? ?? 'Звонки',
        days: ((json['days'] as List?) ?? const [])
            .map((e) => (e as num).toInt())
            .toSet(),
        times: ((json['times'] as List?) ?? const [])
            .map((e) => BellTime.fromJson(e as Map<String, dynamic>))
            .toList(),
      );

  Map<String, dynamic> toJson() => {
        'name': name,
        'days': days.toList()..sort(),
        'times': times.map((t) => t.toJson()).toList(),
      };

  @override
  List<Object?> get props => [name, days, times];
}

/// Выбирает набор звонков для дня недели.
///
/// Сначала ищем набор, явно покрывающий этот день; если такого нет —
/// берём набор по умолчанию. Возвращает null, когда звонки не заданы вовсе.
BellSchedule? bellScheduleForWeekday(
  List<BellSchedule> schedules,
  int weekday,
) {
  for (final schedule in schedules) {
    if (schedule.days.contains(weekday)) return schedule;
  }
  for (final schedule in schedules) {
    if (schedule.isDefault) return schedule;
  }
  return null;
}
