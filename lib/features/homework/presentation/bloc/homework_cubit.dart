import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/database/database.dart';
import '../../../../core/notifications/reminder_scheduler.dart';
import '../../../../core/settings/app_settings.dart';
import '../../domain/repositories/homework_repository.dart';

class HomeworkState extends Equatable {
  final List<Homework> items;
  final bool showDone;
  final bool isLoading;
  final String? error;

  const HomeworkState({
    this.items = const [],
    this.showDone = false,
    this.isLoading = true,
    this.error,
  });

  /// Задания, срок которых уже прошёл, а галочки нет.
  List<Homework> get overdue {
    final today = DateTime.now();
    final todayKey = DateTime(today.year, today.month, today.day);
    return items
        .where((h) => !h.isDone && h.dueDate.isBefore(todayKey))
        .toList();
  }

  HomeworkState copyWith({
    List<Homework>? items,
    bool? showDone,
    bool? isLoading,
    String? error,
    bool clearError = false,
  }) {
    return HomeworkState(
      items: items ?? this.items,
      showDone: showDone ?? this.showDone,
      isLoading: isLoading ?? this.isLoading,
      error: clearError ? null : (error ?? this.error),
    );
  }

  @override
  List<Object?> get props => [items, showDone, isLoading, error];
}

class HomeworkCubit extends Cubit<HomeworkState> {
  HomeworkCubit({
    required this.repository,
    required this.settings,
    required this.reminders,
  }) : super(const HomeworkState());

  final HomeworkRepository repository;
  final AppSettings settings;
  final ReminderScheduler reminders;

  StreamSubscription<List<Homework>>? _subscription;

  void load() {
    final group = settings.selectedGroup;
    if (group == null) {
      emit(state.copyWith(items: const [], isLoading: false));
      return;
    }

    _subscription?.cancel();
    _subscription = repository
        .watch(groupName: group, includeDone: state.showDone)
        .listen(
          (items) => emit(state.copyWith(items: items, isLoading: false)),
          onError: (Object e) => emit(
            state.copyWith(isLoading: false, error: e.toString()),
          ),
        );
  }

  void toggleShowDone() {
    emit(state.copyWith(showDone: !state.showDone, isLoading: true));
    load();
  }

  Future<void> add({
    required String subject,
    required String description,
    required DateTime dueDate,
    required HomeworkPriority priority,
  }) async {
    final group = settings.selectedGroup;
    if (group == null) return;

    await repository.add(
      groupName: group,
      subject: subject,
      description: description,
      dueDate: dueDate,
      priority: priority,
    );
    await reminders.refresh();
  }

  Future<void> save(Homework item) async {
    await repository.save(item);
    await reminders.refresh();
  }

  Future<void> setDone(Homework item, bool done) async {
    await repository.setDone(item.id, done);
    // Сделанное задание больше не должно напоминать о себе.
    await reminders.refresh();
  }

  Future<void> remove(Homework item) async {
    await repository.remove(item.id);
    await reminders.refresh();
  }

  @override
  Future<void> close() {
    _subscription?.cancel();
    return super.close();
  }
}
