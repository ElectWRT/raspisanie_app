import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../data/datasources/markdown_schedule_parser.dart';
import '../../domain/repositories/schedule_repository.dart';

enum ImportStatus { editing, previewed, saving, saved, error }

class ImportState extends Equatable {
  final ImportStatus status;
  final String markdown;

  /// Что нашёл парсер. Заполняется после «Проверить».
  final ScheduleImportResult? result;
  final String? error;

  const ImportState({
    this.status = ImportStatus.editing,
    this.markdown = '',
    this.result,
    this.error,
  });

  ImportState copyWith({
    ImportStatus? status,
    String? markdown,
    ScheduleImportResult? result,
    bool clearResult = false,
    String? error,
    bool clearError = false,
  }) {
    return ImportState(
      status: status ?? this.status,
      markdown: markdown ?? this.markdown,
      result: clearResult ? null : (result ?? this.result),
      error: clearError ? null : (error ?? this.error),
    );
  }

  @override
  List<Object?> get props => [status, markdown, result, error];
}

class ImportCubit extends Cubit<ImportState> {
  ImportCubit(this.repository) : super(const ImportState());

  final ScheduleRepository repository;

  void setMarkdown(String value) => emit(state.copyWith(
        markdown: value,
        status: ImportStatus.editing,
        clearResult: true,
        clearError: true,
      ));

  void check() {
    final outcome = repository.preview(state.markdown);
    outcome.fold(
      (failure) => emit(state.copyWith(
        status: ImportStatus.error,
        error: failure.message,
        clearResult: true,
      )),
      (result) => emit(state.copyWith(
        status: ImportStatus.previewed,
        result: result,
        clearError: true,
      )),
    );
  }

  Future<void> save() async {
    final result = state.result;
    if (result == null) return;

    emit(state.copyWith(status: ImportStatus.saving, clearError: true));
    final outcome = await repository.commitImport(result);
    outcome.fold(
      (failure) => emit(state.copyWith(
        status: ImportStatus.error,
        error: failure.message,
      )),
      (_) => emit(state.copyWith(status: ImportStatus.saved)),
    );
  }
}
