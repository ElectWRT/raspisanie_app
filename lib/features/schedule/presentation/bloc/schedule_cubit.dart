import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/notifications/reminder_scheduler.dart';
import '../../../../core/settings/app_settings.dart';
import '../../../../core/utils/week_utils.dart';
import '../../domain/entities/bell_schedule.dart';
import '../../domain/entities/schedule_slot.dart';
import '../../domain/repositories/schedule_repository.dart';

class ScheduleState extends Equatable {
  final DateTime date;
  final String? group;
  final List<String> availableGroups;
  final DaySchedule? day;
  final List<BellSchedule> bellSchedules;

  /// Дни недели (1..7) видимой недели, на которые есть замены.
  final Set<int> substitutionWeekdays;

  /// Базовое расписание ещё не импортировано — показываем экран-подсказку.
  final bool needsImport;
  final bool isLoading;

  /// Сбой при чтении базы. Показываем текст, а не вечную крутилку.
  final String? error;

  const ScheduleState({
    required this.date,
    this.group,
    this.availableGroups = const [],
    this.day,
    this.bellSchedules = const [],
    this.substitutionWeekdays = const {},
    this.needsImport = false,
    this.isLoading = true,
    this.error,
  });

  ScheduleState copyWith({
    DateTime? date,
    String? group,
    bool clearGroup = false,
    List<String>? availableGroups,
    DaySchedule? day,
    bool clearDay = false,
    List<BellSchedule>? bellSchedules,
    Set<int>? substitutionWeekdays,
    bool? needsImport,
    bool? isLoading,
    String? error,
    bool clearError = false,
  }) {
    return ScheduleState(
      date: date ?? this.date,
      group: clearGroup ? null : (group ?? this.group),
      availableGroups: availableGroups ?? this.availableGroups,
      day: clearDay ? null : (day ?? this.day),
      bellSchedules: bellSchedules ?? this.bellSchedules,
      substitutionWeekdays: substitutionWeekdays ?? this.substitutionWeekdays,
      needsImport: needsImport ?? this.needsImport,
      isLoading: isLoading ?? this.isLoading,
      error: clearError ? null : (error ?? this.error),
    );
  }

  /// Набор звонков, действующий в выбранный день.
  BellSchedule? get activeBells =>
      bellScheduleForWeekday(bellSchedules, date.weekday);

  BellTime? bellFor(int pairNumber) => activeBells?.timeFor(pairNumber);

  @override
  List<Object?> get props => [
        date,
        group,
        availableGroups,
        day,
        bellSchedules,
        substitutionWeekdays,
        needsImport,
        isLoading,
        error,
      ];
}

class ScheduleCubit extends Cubit<ScheduleState> {
  ScheduleCubit({
    required this.repository,
    required this.settings,
    required this.reminders,
  }) : super(ScheduleState(date: WeekUtils.dayKey(DateTime.now())));

  final ScheduleRepository repository;
  final AppSettings settings;
  final ReminderScheduler reminders;

  StreamSubscription<DaySchedule>? _daySubscription;
  StreamSubscription<List<String>>? _groupsSubscription;
  StreamSubscription<Set<int>>? _weekSubscription;

  Future<void> init() async {
    _groupsSubscription = repository.watchGroups().listen((groups) async {
      final selected = settings.selectedGroup;
      // Группа из настроек могла исчезнуть после переимпорта расписания.
      final resolved = groups.contains(selected)
          ? selected
          : (groups.isEmpty ? null : groups.first);

      if (resolved != selected) {
        await settings.setSelectedGroup(resolved);
      }

      emit(state.copyWith(
        availableGroups: groups,
        group: resolved,
        clearGroup: resolved == null,
        needsImport: groups.isEmpty,
        isLoading: false,
      ));
      _resubscribe();
      unawaited(reminders.refresh());
    }, onError: _onStreamError);

    try {
      emit(state.copyWith(bellSchedules: await repository.getBellSchedules()));
    } catch (e) {
      _onStreamError(e);
    }
  }

  /// Любая ошибка чтения базы должна попасть на экран, а не подвесить его.
  void _onStreamError(Object error) {
    if (isClosed) return;
    emit(state.copyWith(isLoading: false, error: error.toString()));
  }

  /// Повторная попытка после ошибки.
  Future<void> retry() async {
    emit(state.copyWith(isLoading: true, clearError: true));
    await _groupsSubscription?.cancel();
    await init();
  }

  void selectDate(DateTime date) {
    emit(state.copyWith(date: WeekUtils.dayKey(date), clearDay: true));
    _resubscribe();
  }

  void shiftDay(int days) =>
      selectDate(state.date.add(Duration(days: days)));

  void goToToday() => selectDate(DateTime.now());

  Future<void> selectGroup(String group) async {
    await settings.setSelectedGroup(group);
    emit(state.copyWith(group: group, clearDay: true));
    _resubscribe();
    unawaited(reminders.refresh());
  }

  /// Вызывается после импорта расписания и после смены настроек.
  Future<void> reload() async {
    emit(state.copyWith(
      bellSchedules: await repository.getBellSchedules(),
      clearDay: true,
    ));
    _resubscribe();
    await reminders.refresh();
  }

  void _resubscribe() {
    _daySubscription?.cancel();
    final group = state.group;
    if (group == null) return;

    _daySubscription = repository
        .watchDay(
          groupName: group,
          date: state.date,
          subgroup: settings.subgroup,
          invertWeekParity: settings.invertWeekParity,
        )
        .listen(
          (day) => emit(state.copyWith(day: day, isLoading: false)),
          onError: _onStreamError,
        );

    _weekSubscription?.cancel();
    _weekSubscription = repository
        .watchSubstitutionWeekdays(
          groupName: group,
          weekStart: WeekUtils.startOfWeek(state.date),
        )
        .listen(
          (days) => emit(state.copyWith(substitutionWeekdays: days)),
          onError: _onStreamError,
        );
  }

  @override
  Future<void> close() {
    _daySubscription?.cancel();
    _groupsSubscription?.cancel();
    _weekSubscription?.cancel();
    return super.close();
  }
}
