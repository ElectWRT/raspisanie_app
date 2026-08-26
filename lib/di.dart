import 'dart:async';

import 'package:dio/dio.dart';
import 'package:get_it/get_it.dart';

import 'core/database/database.dart';
import 'core/notifications/notification_service.dart';
import 'core/notifications/reminder_scheduler.dart';
import 'core/settings/app_settings.dart';
import 'features/schedule/data/datasources/markdown_schedule_parser.dart';
import 'features/schedule/data/repositories/schedule_repository_impl.dart';
import 'features/schedule/domain/repositories/schedule_repository.dart';
import 'features/substitutions/data/datasources/docx_parser.dart';
import 'features/substitutions/data/datasources/substitutions_remote_data_source.dart';
import 'features/substitutions/data/repositories/substitutions_repository_impl.dart';
import 'features/substitutions/domain/repositories/substitutions_repository.dart';

final getIt = GetIt.instance;

Future<void> setupDependencies() async {
  final settings = await AppSettings.load();

  getIt
    ..registerSingleton<AppSettings>(settings)
    ..registerSingleton<AppDatabase>(AppDatabase())
    ..registerLazySingleton<Dio>(
      () => Dio(BaseOptions(
        connectTimeout: const Duration(seconds: 15),
        receiveTimeout: const Duration(seconds: 30),
        followRedirects: true,
        // Ошибки HTTP разбираем сами, чтобы показывать понятный текст.
        validateStatus: (status) => status != null && status < 400,
      )),
    )
    ..registerLazySingleton(() => const MarkdownScheduleParser())
    ..registerLazySingleton(() => const DocxParser())
    ..registerLazySingleton<SubstitutionsRemoteDataSource>(
      () => SubstitutionsRemoteDataSourceImpl(getIt<Dio>()),
    )
    ..registerLazySingleton<ScheduleRepository>(
      () => ScheduleRepositoryImpl(
        database: getIt<AppDatabase>(),
        parser: getIt<MarkdownScheduleParser>(),
      ),
    )
    ..registerLazySingleton<SubstitutionsRepository>(
      () => SubstitutionsRepositoryImpl(
        remoteDataSource: getIt<SubstitutionsRemoteDataSource>(),
        parser: getIt<DocxParser>(),
        database: getIt<AppDatabase>(),
        settings: getIt<AppSettings>(),
      ),
    )
    ..registerSingleton<NotificationService>(NotificationService.create())
    ..registerLazySingleton<ReminderScheduler>(
      () => ReminderScheduler(
        repository: getIt<ScheduleRepository>(),
        settings: getIt<AppSettings>(),
        notifications: getIt<NotificationService>(),
      ),
    );

  // Инициализацию уведомлений намеренно НЕ ждём: если плагин зависнет,
  // приложение всё равно должно открыться. Всё, что шлёт уведомления,
  // само вызывает init() и дождётся его.
  unawaited(getIt<NotificationService>().init());
}
