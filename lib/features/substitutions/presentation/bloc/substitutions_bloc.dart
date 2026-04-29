import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../domain/entities/substitution.dart';
import '../../domain/repositories/substitutions_repository.dart';

// Events
abstract class SubstitutionsEvent extends Equatable {
  const SubstitutionsEvent();
  @override
  List<Object?> get props => [];
}

class RefreshSubstitutions extends SubstitutionsEvent {
  final String? date;
  const RefreshSubstitutions({this.date});
}

class WatchSubstitutions extends SubstitutionsEvent {
  const WatchSubstitutions();
}

// States
abstract class SubstitutionsState extends Equatable {
  const SubstitutionsState();
  @override
  List<Object?> get props => [];
}

class SubstitutionsInitial extends SubstitutionsState {}
class SubstitutionsLoading extends SubstitutionsState {}
class SubstitutionsLoaded extends SubstitutionsState {
  final List<SubstitutionEntity> items;
  const SubstitutionsLoaded(this.items);
  @override
  List<Object?> get props => [items];
}
class SubstitutionsError extends SubstitutionsState {
  final String message;
  const SubstitutionsError(this.message);
  @override
  List<Object?> get props => [message];
}

// Bloc
class SubstitutionsBloc extends Bloc<SubstitutionsEvent, SubstitutionsState> {
  final SubstitutionsRepository repository;

  SubstitutionsBloc(this.repository) : super(SubstitutionsInitial()) {
    on<WatchSubstitutions>((event, emit) async {
      await emit.forEach(
        repository.watchSubstitutions(),
        onData: (items) => SubstitutionsLoaded(items),
      );
    });

    on<RefreshSubstitutions>((event, emit) async {
      emit(SubstitutionsLoading());
      final result = await repository.refreshSubstitutions(date: event.date);
      result.fold(
        (failure) => emit(SubstitutionsError(failure.message)),
        (_) => null, // Data is updated via watch stream
      );
    });
  }
}
