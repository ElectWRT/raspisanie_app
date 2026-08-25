import 'dart:async';
import 'dart:typed_data';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/notifications/reminder_scheduler.dart';
import '../../domain/entities/substitution.dart';
import '../../domain/repositories/substitutions_repository.dart';

enum RefreshStatus { idle, loading, success, failure }

class SubstitutionsState extends Equatable {
  final RefreshStatus status;

  /// Отчёт последнего успешного обновления.
  final RefreshReport? report;
  final String? error;
  final DateTime? lastUpdated;

  const SubstitutionsState({
    this.status = RefreshStatus.idle,
    this.report,
    this.error,
    this.lastUpdated,
  });

  SubstitutionsState copyWith({
    RefreshStatus? status,
    RefreshReport? report,
    String? error,
    bool clearError = false,
    DateTime? lastUpdated,
  }) {
    return SubstitutionsState(
      status: status ?? this.status,
      report: report ?? this.report,
      error: clearError ? null : (error ?? this.error),
      lastUpdated: lastUpdated ?? this.lastUpdated,
    );
  }

  @override
  List<Object?> get props => [status, report, error, lastUpdated];
}

class SubstitutionsCubit extends Cubit<SubstitutionsState> {
  SubstitutionsCubit(this.repository, this.reminders)
      : super(const SubstitutionsState()) {
    _lastUpdatedSubscription = repository.watchLastUpdated().listen(
          (value) => emit(state.copyWith(lastUpdated: value)),
        );
  }

  final SubstitutionsRepository repository;
  final ReminderScheduler reminders;
  StreamSubscription<DateTime?>? _lastUpdatedSubscription;

  Future<void> refresh({DateTime? targetDate}) async {
    if (state.status == RefreshStatus.loading) return;
    emit(state.copyWith(status: RefreshStatus.loading, clearError: true));

    final outcome = await repository.refresh(targetDate: targetDate);
    // Замены могли сдвинуть пары — перепланируем напоминания.
    if (outcome.isRight()) await reminders.refresh();
    outcome.fold(
      (failure) => emit(state.copyWith(
        status: RefreshStatus.failure,
        error: failure.message,
      )),
      (report) => emit(state.copyWith(
        status: RefreshStatus.success,
        report: report,
        clearError: true,
      )),
    );
  }

  Future<void> importDocx(Uint8List bytes, {required String source}) async {
    emit(state.copyWith(status: RefreshStatus.loading, clearError: true));

    final outcome = await repository.importDocx(bytes, source: source);
    if (outcome.isRight()) await reminders.refresh();
    outcome.fold(
      (failure) => emit(state.copyWith(
        status: RefreshStatus.failure,
        error: failure.message,
      )),
      (report) => emit(state.copyWith(
        status: RefreshStatus.success,
        report: report,
        clearError: true,
      )),
    );
  }

  @override
  Future<void> close() {
    _lastUpdatedSubscription?.cancel();
    return super.close();
  }
}
