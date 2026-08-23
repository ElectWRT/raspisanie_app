import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/settings/app_settings.dart';
import '../../../../core/utils/week_utils.dart';
import '../../domain/entities/schedule_slot.dart';
import '../../domain/repositories/schedule_repository.dart';

class ScheduleState extends Equatable {
  final DateTime date;
  final String? group;
  final List<String> availableGroups;
  final DaySchedule? day;
  final List<BellTime> bells;

  /// Базовое расписание ещё не импортировано — показываем экран-подсказку.
  final bool needsImport;
  final bool isLoading;

  const ScheduleState({
    required this.date,
    this.group,
    this.availableGroups = const [],
    this.day,
    this.bells = const [],
    this.needsImport = false,
    this.isLoading = true,
  });

  ScheduleState copyWith({
    DateTime? date,
    String? group,
    bool clearGroup = false,
    List<String>? availableGroups,
    DaySchedule? day,
    bool clearDay = false,
    List<BellTime>? bells,
    bool? needsImport,
    bool? isLoading,
  }) {
    return ScheduleState(
      date: date ?? this.date,
      group: clearGroup ? null : (group ?? this.group),
      availableGroups: availableGroups ?? this.availableGroups,
      day: clearDay ? null : (day ?? this.day),
      bells: bells ?? this.bells,
      needsImport: needsImport ?? this.needsImport,
      isLoading: isLoading ?? this.isLoading,
    );
  }

  BellTime? bellFor(int pairNumber) =>
      bells.where((b) => b.pairNumber == pairNumber).firstOrNull;

  @override
  List<Object?> get props =>
      [date, group, availableGroups, day, bells, needsImport, isLoading];
}

extension _FirstOrNull<T> on Iterable<T> {
  T? get firstOrNull => isEmpty ? null : first;
}

class ScheduleCubit extends Cubit<ScheduleState> {
  ScheduleCubit({required this.repository, required this.settings})
      : super(ScheduleState(date: WeekUtils.dayKey(DateTime.now())));

  final ScheduleRepository repository;
  final AppSettings settings;

  StreamSubscription<DaySchedule>? _daySubscription;
  StreamSubscription<List<String>>? _groupsSubscription;

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
    });

    emit(state.copyWith(bells: await repository.getBells()));
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
  }

  /// Вызывается после импорта расписания и после смены настроек.
  Future<void> reload() async {
    emit(state.copyWith(bells: await repository.getBells(), clearDay: true));
    _resubscribe();
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
        .listen((day) => emit(state.copyWith(day: day, isLoading: false)));
  }

  @override
  Future<void> close() {
    _daySubscription?.cancel();
    _groupsSubscription?.cancel();
    return super.close();
  }
}
