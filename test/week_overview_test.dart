import 'package:dio/dio.dart';
import 'package:drift/drift.dart' show DatabaseConnection, Value;
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:raspisanie_app/core/database/database.dart';
import 'package:raspisanie_app/core/notifications/notification_service.dart';
import 'package:raspisanie_app/core/notifications/reminder_scheduler.dart';
import 'package:raspisanie_app/core/settings/app_settings.dart';
import 'package:raspisanie_app/di.dart';
import 'package:raspisanie_app/features/attendance/data/repositories/attendance_repository_impl.dart';
import 'package:raspisanie_app/features/attendance/presentation/bloc/attendance_cubit.dart';
import 'package:raspisanie_app/features/homework/data/repositories/homework_repository_impl.dart';
import 'package:raspisanie_app/features/homework/presentation/bloc/homework_cubit.dart';
import 'package:raspisanie_app/features/schedule/data/datasources/markdown_schedule_parser.dart';
import 'package:raspisanie_app/features/schedule/data/repositories/schedule_repository_impl.dart';
import 'package:raspisanie_app/features/schedule/domain/entities/bell_schedule.dart';
import 'package:raspisanie_app/features/schedule/domain/entities/schedule_slot.dart';
import 'package:raspisanie_app/features/schedule/presentation/bloc/schedule_cubit.dart';
import 'package:raspisanie_app/features/schedule/presentation/pages/home_page.dart';
import 'package:raspisanie_app/features/seasons/domain/season.dart';
import 'package:raspisanie_app/features/substitutions/data/datasources/docx_parser.dart';
import 'package:raspisanie_app/features/substitutions/data/datasources/substitutions_remote_data_source.dart';
import 'package:raspisanie_app/features/substitutions/data/repositories/substitutions_repository_impl.dart';
import 'package:raspisanie_app/features/substitutions/presentation/bloc/substitutions_cubit.dart';
import 'package:shared_preferences/shared_preferences.dart';

class _Notifications extends NotificationService {
  _Notifications() : super(FlutterLocalNotificationsPlugin());

  @override
  Future<void> cancelAll() async {}
}

void main() {
  testWidgets('неделя учитывает снятую пару и открывает выбранный день',
      (tester) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(390, 844);
    addTearDown(tester.view.resetDevicePixelRatio);
    addTearDown(tester.view.resetPhysicalSize);
    final monday = DateTime(2026, 11, 23);
    final tuesday = DateTime(2026, 11, 24);
    final database = AppDatabase.forTesting(
      DatabaseConnection(NativeDatabase.memory(), closeStreamsSynchronously: true),
    );
    SharedPreferences.setMockInitialValues({});
    final settings = await AppSettings.load();
    await settings.setSelectedGroup('ИС-24');
    await settings.setSeasonMode(SeasonMode.off);
    await settings.setShowWeekends(false);
    getIt.registerSingleton<AppSettings>(settings);
    addTearDown(() => getIt.unregister<AppSettings>());

    final scheduleRepo = ScheduleRepositoryImpl(
      database: database,
      parser: const MarkdownScheduleParser(),
    );
    final homeworkRepo = HomeworkRepositoryImpl(database);
    final attendanceRepo = AttendanceRepositoryImpl(database);
    final reminders = ReminderScheduler(
      repository: scheduleRepo,
      homework: homeworkRepo,
      attendance: attendanceRepo,
      settings: settings,
      notifications: _Notifications(),
    );
    await database.replaceLessons([
      for (final (weekday, number, subject) in [
        (1, 1, 'Математика'),
        (1, 2, 'Физика'),
        (2, 1, 'Информатика'),
      ])
        LessonsCompanion.insert(
          groupName: 'ИС-24',
          dayOfWeek: weekday,
          pairNumber: number,
          subject: subject,
        ),
    ]);
    await database.replaceSubstitutionsForDate(monday, [
      SubstitutionsCompanion.insert(
        date: monday,
        groupName: 'ИС-24',
        pairNumber: 1,
        isCancelled: const Value(true),
      ),
    ]);
    await scheduleRepo.saveBellSchedules([
      const BellSchedule(name: 'Звонки', times: [
        BellTime(pairNumber: 1, start: '08:30', end: '10:00'),
        BellTime(pairNumber: 2, start: '10:10', end: '11:40'),
      ]),
      BellSchedule(name: 'Сокращённые', date: monday, times: const [
        BellTime(pairNumber: 1, start: '09:00', end: '10:00'),
        BellTime(pairNumber: 2, start: '10:20', end: '11:20'),
      ]),
    ]);
    final schedule = ScheduleCubit(
      repository: scheduleRepo,
      settings: settings,
      reminders: reminders,
    )..selectDate(monday);
    await schedule.init();
    await tester.pumpWidget(
      MultiBlocProvider(
        providers: [
          BlocProvider(create: (_) => schedule),
          BlocProvider(
            create: (_) => AttendanceCubit(
              repository: attendanceRepo,
              settings: settings,
            ),
          ),
          BlocProvider(
            create: (_) => HomeworkCubit(
              repository: homeworkRepo,
              settings: settings,
              reminders: reminders,
            ),
          ),
          BlocProvider(
            create: (_) => SubstitutionsCubit(
              SubstitutionsRepositoryImpl(
                remoteDataSource: SubstitutionsRemoteDataSourceImpl(Dio()),
                parser: const DocxParser(),
                database: database,
                settings: settings,
              ),
              reminders,
            ),
          ),
        ],
        child: const MaterialApp(home: HomePage()),
      ),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text('Неделя'));
    await tester.pumpAndSettle();

    final mondayTile = find.widgetWithText(ListTile, 'Понедельник, 23 ноября');
    expect(mondayTile, findsOneWidget);
    expect(
      find.descendant(of: mondayTile, matching: find.text('1 пара · с 10:20')),
      findsOneWidget,
    );
    expect(
      find.descendant(of: mondayTile, matching: find.text('Замен: 1')),
      findsOneWidget,
    );
    expect(find.text('Суббота, 28 ноября'), findsNothing);

    await tester.tap(find.byTooltip('Следующая неделя'));
    await tester.pumpAndSettle();
    expect(find.text('Понедельник, 30 ноября'), findsOneWidget);
    expect(find.text('Замен: 1'), findsNothing);
    await tester.tap(find.byTooltip('Предыдущая неделя'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Вторник, 24 ноября'));
    await tester.pumpAndSettle();
    expect(schedule.state.date, tuesday);
    expect(find.text('Информатика'), findsOneWidget);
    expect(mondayTile, findsNothing);

    await tester.pumpWidget(const SizedBox.shrink());
    await database.close();
  });
}
