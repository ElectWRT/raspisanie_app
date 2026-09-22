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

  /// Группы, расписание которых уже лежит в базе. По ним предпросмотр
  /// предупреждает, что импорт их перезапишет.
  final Set<String> existingGroups;

  const ImportState({
    this.status = ImportStatus.editing,
    this.markdown = '',
    this.result,
    this.error,
    this.existingGroups = const {},
  });

  /// Группа из файла заменит уже загруженное расписание.
  bool replacesExisting(String group) => existingGroups.contains(group);

  ImportState copyWith({
    ImportStatus? status,
    String? markdown,
    ScheduleImportResult? result,
    bool clearResult = false,
    String? error,
    bool clearError = false,
    Set<String>? existingGroups,
  }) {
    return ImportState(
      status: status ?? this.status,
      markdown: markdown ?? this.markdown,
      result: clearResult ? null : (result ?? this.result),
      error: clearError ? null : (error ?? this.error),
      existingGroups: existingGroups ?? this.existingGroups,
    );
  }

  @override
  List<Object?> get props => [status, markdown, result, error, existingGroups];
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

  Future<void> check() async {
    final outcome = repository.preview(state.markdown);
    final existing = await _existingGroups();
    if (isClosed) return;

    outcome.fold(
      (failure) => emit(state.copyWith(
        status: ImportStatus.error,
        error: failure.message,
        clearResult: true,
      )),
      (result) => emit(state.copyWith(
        status: ImportStatus.previewed,
        result: result,
        existingGroups: existing,
        clearError: true,
      )),
    );
  }

  /// Переименовывает группу в распознанном файле до сохранения.
  void renameGroup(String from, String to) {
    final result = state.result;
    if (result == null) return;
    emit(state.copyWith(result: result.renameGroup(from, to)));
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

  Future<Set<String>> _existingGroups() async {
    try {
      return (await repository.watchGroups().first).toSet();
    } catch (_) {
      // Без списка групп предпросмотр просто не предупредит о перезаписи —
      // это не повод не дать импортировать.
      return const {};
    }
  }
}
