import '../../schedule/domain/entities/bell_schedule.dart';
import '../../schedule/domain/entities/schedule_slot.dart';

/// Что замены сделали с началом учебного дня.
enum DayStartShift {
  /// Начало не сдвинулось.
  none,

  /// Первые пары сняли — приходить позже.
  later,

  /// Пару добавили перед первой — приходить раньше.
  earlier,

  /// Сняли весь день.
  freeDay,
}

/// Во сколько теперь начинается день и куда он сдвинулся.
class DayStartChange {
  const DayStartChange({required this.shift, this.firstPair, this.startsAt});

  final DayStartShift shift;

  /// Номер первой пары, которая осталась.
  final int? firstPair;

  /// Время звонка на неё, «10:10». null — звонки на этот номер не заданы.
  final String? startsAt;

  bool get isEmpty => shift == DayStartShift.none;

  /// Короткая строка для уведомления. null — говорить не о чем.
  String? get message => switch (shift) {
        DayStartShift.none => null,
        DayStartShift.freeDay => 'Занятий нет — весь день сняли.',
        DayStartShift.later => startsAt == null
            ? 'Первых пар не будет — начало ${_fromPair(firstPair)}.'
            : 'Первых пар не будет — к $startsAt.',
        DayStartShift.earlier => startsAt == null
            ? 'Добавили пару в начало — начало ${_fromPair(firstPair)}.'
            : 'Добавили пару в начало — к $startsAt.',
      };

  /// «со 2-й», но «с 3-й»: перед второй предлог удлиняется.
  static String _fromPair(int? pair) => pair == 2 ? 'со 2-й' : 'с $pair-й';
}

/// Сравнивает, с какой пары день должен был начаться и с какой начнётся.
///
/// Считает по дню, уже слитому с заменами: снятая пара остаётся в списке
/// с пометкой, а добавленная заменой помечена отдельно. Это и есть самое
/// ценное в заменах — узнать вечером, что завтра можно не вставать к первой.
DayStartChange describeDayStart(
  List<ScheduleSlot> slots, {
  BellSchedule? bells,
}) {
  if (slots.isEmpty) return const DayStartChange(shift: DayStartShift.none);

  int? minPair(Iterable<ScheduleSlot> items) => items.isEmpty
      ? null
      : items.map((s) => s.pairNumber).reduce((a, b) => a < b ? a : b);

  // По расписанию день начинался с первой пары, которую не добавляли заменой.
  final scheduled = minPair(slots.where((s) => !s.isExtra)) ?? minPair(slots);
  final actual = minPair(slots.where((s) => !s.isCancelled));

  if (actual == null) {
    return const DayStartChange(shift: DayStartShift.freeDay);
  }
  if (scheduled == null || actual == scheduled) {
    return const DayStartChange(shift: DayStartShift.none);
  }

  return DayStartChange(
    shift: actual > scheduled ? DayStartShift.later : DayStartShift.earlier,
    firstPair: actual,
    startsAt: bells?.timeFor(actual)?.start,
  );
}
