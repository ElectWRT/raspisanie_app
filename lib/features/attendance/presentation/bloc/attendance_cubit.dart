import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/database/database.dart';
import '../../../../core/settings/app_settings.dart';
import '../../../../core/utils/week_utils.dart';
import '../../../schedule/domain/entities/schedule_slot.dart';
import '../../data/repositories/attendance_repository_impl.dart';
import '../../domain/attendance_stats.dart';
import '../../domain/repositories/attendance_repository.dart';
import '../../domain/skip_advice.dart';

class AttendanceState extends Equatable {
  const AttendanceState({
    this.date,
    this.group,
    this.dayMarks = const {},
    this.stats = const AttendanceStats(),
    this.profiles = const [],
    this.isLoading = true,
  });

  final DateTime? date;
  final String? group;

  /// Отметки выбранного дня по [attendanceKey].
  final Map<String, Attendance> dayMarks;

  final AttendanceStats stats;
  final List<SubjectProfile> profiles;
  final bool isLoading;

  AttendanceState copyWith({
    DateTime? date,
    String? group,
    bool clearGroup = false,
    Map<String, Attendance>? dayMarks,
    AttendanceStats? stats,
    List<SubjectProfile>? profiles,
    bool? isLoading,
  }) {
    return AttendanceState(
      date: date ?? this.date,
      group: clearGroup ? null : (group ?? this.group),
      dayMarks: dayMarks ?? this.dayMarks,
      stats: stats ?? this.stats,
      profiles: profiles ?? this.profiles,
      isLoading: isLoading ?? this.isLoading,
    );
  }

  /// Профиль предмета, если он заведён.
  SubjectProfile? profileFor(String subject) {
    final key = subject.toLowerCase().trim();
    for (final profile in profiles) {
      if (profile.subjectKey == key) return profile;
    }
    return null;
  }

  /// Что взять на пару по этому предмету.
  List<String> itemsFor(String subject) {
    final profile = profileFor(subject);
    return profile == null ? const [] : decodeProfileItems(profile.items);
  }

  bool isMajor(String subject) => profileFor(subject)?.isMajor ?? false;

  Attendance? markFor(ScheduleSlot slot) =>
      dayMarks[attendanceKey(slot.pairNumber, slot.subgroup)];

  /// Сколько пар дня ещё не отмечено. Снятые не в счёт — отмечать нечего.
  int unmarkedCount(List<ScheduleSlot> slots) => slots
      .where((s) => !s.isCancelled)
      .where((s) => markFor(s) == null)
      .length;

  @override
  List<Object?> get props =>
      [date, group, dayMarks, stats, profiles, isLoading];
}

class AttendanceCubit extends Cubit<AttendanceState> {
  AttendanceCubit({required this.repository, required this.settings})
      : super(const AttendanceState());

  final AttendanceRepository repository;
  final AppSettings settings;

  StreamSubscription<Map<String, Attendance>>? _daySubscription;
  StreamSubscription<List<Attendance>>? _allSubscription;
  StreamSubscription<List<SubjectProfile>>? _profilesSubscription;

  /// Вызывается, когда на главном экране сменились группа или дата.
  Future<void> setContext({String? group, required DateTime date}) async {
    final day = WeekUtils.dayKey(date);
    final sameGroup = group == state.group;
    final sameDate = state.date != null && state.date == day;
    if (sameGroup && sameDate) return;

    // Сюда доходим только когда группа или день сменились, поэтому старые
    // отметки сбрасываем всегда — иначе на новом дне на мгновение видны
    // чужие галочки.
    emit(state.copyWith(
      date: day,
      group: group,
      clearGroup: group == null,
      isLoading: group != null,
      dayMarks: const {},
    ));

    await _resubscribe(groupChanged: !sameGroup);
  }

  Future<void> _resubscribe({required bool groupChanged}) async {
    // Отписываемся до подписки: иначе старый поток успевает отдать
    // последнее событие уже после смены дня и перетирает отметки чужими.
    await _daySubscription?.cancel();
    _daySubscription = null;

    final group = state.group;
    final date = state.date;
    if (group == null || date == null) {
      emit(state.copyWith(isLoading: false));
      return;
    }

    _daySubscription = repository
        .watchDay(groupName: group, date: date)
        .listen((marks) => emit(state.copyWith(dayMarks: marks, isLoading: false)));

    if (!groupChanged && _allSubscription != null) return;

    await _allSubscription?.cancel();
    await _profilesSubscription?.cancel();

    _allSubscription = repository.watchAll(group).listen((rows) {
      _rows = rows;
      emit(state.copyWith(stats: _buildStats()));
    });

    _profilesSubscription = repository.watchProfiles(group).listen((profiles) {
      _profiles = profiles;
      emit(state.copyWith(profiles: profiles, stats: _buildStats()));
    });
  }

  // Отметки и профили приходят двумя независимыми потоками, а статистика
  // нужна из обоих сразу: профили решают, какой предмет профильный.
  List<Attendance> _rows = const [];
  List<SubjectProfile> _profiles = const [];

  AttendanceStats _buildStats() => buildAttendanceStats(
        rows: _rows,
        majorSubjects: {
          for (final profile in _profiles)
            if (profile.isMajor) profile.subjectKey,
        },
      );

  Future<void> mark(ScheduleSlot slot, AttendanceStatus status) async {
    final group = state.group;
    final date = state.date;
    if (group == null || date == null) return;

    await repository.mark(
      date: date,
      groupName: group,
      pairNumber: slot.pairNumber,
      subgroup: slot.subgroup,
      subject: slot.subject,
      status: status,
    );
  }

  Future<void> clearMark(ScheduleSlot slot) async {
    final group = state.group;
    final date = state.date;
    if (group == null || date == null) return;

    await repository.clear(
      date: date,
      groupName: group,
      pairNumber: slot.pairNumber,
      subgroup: slot.subgroup,
    );
  }

  /// Переключает отметку по кругу: не отмечено → был → пропустил →
  /// уважительная → не отмечено.
  Future<void> cycle(ScheduleSlot slot) async {
    final current = state.markFor(slot)?.status;
    switch (current) {
      case null:
        await mark(slot, AttendanceStatus.present);
      case AttendanceStatus.present:
        await mark(slot, AttendanceStatus.absent);
      case AttendanceStatus.absent:
        await mark(slot, AttendanceStatus.excused);
      case AttendanceStatus.excused:
        await clearMark(slot);
    }
  }

  Future<void> saveProfile({
    required String subject,
    required bool isMajor,
    required List<String> items,
    String? note,
  }) async {
    final group = state.group;
    if (group == null) return;
    await repository.saveProfile(
      groupName: group,
      subject: subject,
      isMajor: isMajor,
      items: items,
      note: note,
    );
  }

  Future<void> removeProfile(int id) => repository.removeProfile(id);

  /// Стоит ли пропускать этот день.
  ///
  /// Считается по парам уже с наложенными заменами: снятая пара выпадает,
  /// а заменённая идёт со своим новым предметом.
  SkipAdvice adviceFor(List<ScheduleSlot> slots) {
    return adviseSkip(
      pairs: slots
          .map((slot) => SkipPair(
                pairNumber: slot.pairNumber,
                subject: slot.subject,
                isMajor: state.isMajor(slot.subject),
                isCancelled: slot.isCancelled,
                missedBefore: state.stats.missedFor(slot.subject),
              ))
          .toList(),
      limits: SkipLimits(
        perSubject: settings.skipLimitPerSubject,
        perMajorSubject: settings.skipLimitPerMajorSubject,
      ),
    );
  }

  @override
  Future<void> close() {
    _daySubscription?.cancel();
    _allSubscription?.cancel();
    _profilesSubscription?.cancel();
    return super.close();
  }
}
