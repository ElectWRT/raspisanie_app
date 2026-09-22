import 'dart:async';

import 'package:dynamic_color/dynamic_color.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'core/notifications/notification_router.dart';
import 'core/notifications/notification_service.dart';
import 'core/notifications/reminder_scheduler.dart';
import 'core/settings/app_settings.dart';
import 'core/theme/app_theme.dart';
import 'di.dart';
import 'features/attendance/domain/repositories/attendance_repository.dart';
import 'features/attendance/presentation/bloc/attendance_cubit.dart';
import 'features/homework/domain/repositories/homework_repository.dart';
import 'features/homework/presentation/bloc/homework_cubit.dart';
import 'features/schedule/domain/repositories/schedule_repository.dart';
import 'features/schedule/presentation/bloc/schedule_cubit.dart';
import 'features/schedule/presentation/pages/home_page.dart';
import 'features/settings/domain/thanks_prompt.dart';
import 'features/settings/presentation/widgets/thanks_dialog.dart';
import 'features/substitutions/domain/repositories/substitutions_repository.dart';
import 'features/substitutions/presentation/bloc/substitutions_cubit.dart';

class RaspisanieApp extends StatefulWidget {
  const RaspisanieApp({super.key});

  @override
  State<RaspisanieApp> createState() => _RaspisanieAppState();
}

class _RaspisanieAppState extends State<RaspisanieApp>
    with WidgetsBindingObserver {
  ScheduleCubit? _scheduleCubit;
  final _navigatorKey = GlobalKey<NavigatorState>();
  StreamSubscription<String>? _tapSubscription;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);

    final notifications = getIt<NotificationService>();
    _tapSubscription = notifications.onNotificationTap.listen(_handlePayload);

    // Приложение могло быть полностью убито и запущено именно тапом по
    // уведомлению — такой payload стрим тапов не увидит, у него отдельный
    // путь. Проверяем один раз, как только появится Navigator.
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final settings = getIt<AppSettings>();
      await settings.recordLaunch();

      final payload = await notifications.consumeLaunchPayload();
      if (payload != null) {
        // Открыли тапом по уведомлению — человек пришёл за конкретным
        // делом, благодарность подождёт до обычного запуска.
        _handlePayload(payload);
        return;
      }
      await _maybeThank(settings);
    });
  }

  /// Изредка показывает окно «спасибо, что пользуетесь».
  Future<void> _maybeThank(AppSettings settings) async {
    final due = shouldShowThanks(
      launchCount: settings.launchCount,
      lastShown: settings.thanksShownAt,
      now: DateTime.now(),
    );
    if (!due) return;

    // Пока расписание не импортировано, благодарить не за что — человек
    // ещё на экране первой настройки.
    if (!await getIt<ScheduleRepository>().hasSchedule) return;

    // Даём главному экрану открыться, чтобы окно не выскочило поверх
    // заставки загрузки.
    await Future<void>.delayed(const Duration(seconds: 2));
    final context = _navigatorKey.currentContext;
    if (!mounted || context == null || !context.mounted) return;

    // Отмечаем до показа: если приложение закроют с открытым окном,
    // на следующем запуске оно не выскочит снова.
    await settings.setThanksShownAt(DateTime.now());
    if (!context.mounted) return;
    await showThanksDialog(context);
  }

  void _handlePayload(String payload) {
    final context = _navigatorKey.currentContext;
    if (context == null) return;
    NotificationRouter.handle(context, payload);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _tapSubscription?.cancel();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // Фоновая задача пишет в базу из другого изолята, и потоки drift
    // в UI-изоляте об этом не узнают. Поэтому перечитываем при возврате.
    if (state == AppLifecycleState.resumed) {
      _scheduleCubit?.reload();
    }
  }

  @override
  Widget build(BuildContext context) {
    final settings = getIt<AppSettings>();

    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (_) {
            final cubit = ScheduleCubit(
              repository: getIt<ScheduleRepository>(),
              settings: settings,
              reminders: getIt<ReminderScheduler>(),
            )..init();
            _scheduleCubit = cubit;
            return cubit;
          },
        ),
        BlocProvider(
          create: (_) => HomeworkCubit(
            repository: getIt<HomeworkRepository>(),
            settings: settings,
            reminders: getIt<ReminderScheduler>(),
          )..load(),
        ),
        BlocProvider(
          create: (_) {
            final cubit = SubstitutionsCubit(
              getIt<SubstitutionsRepository>(),
              getIt<ReminderScheduler>(),
            );
            if (settings.autoRefreshOnLaunch) cubit.refresh();
            return cubit;
          },
        ),
        BlocProvider(
          create: (_) => AttendanceCubit(
            repository: getIt<AttendanceRepository>(),
            settings: settings,
          ),
        ),
      ],
      // Настройки — ChangeNotifier, поэтому смена темы перестраивает
      // MaterialApp без перезапуска приложения.
      child: AnimatedBuilder(
        animation: settings,
        builder: (context, _) => DynamicColorBuilder(
          builder: (lightDynamic, darkDynamic) {
            final accent = AppAccents.byId(settings.accentId);
            final useDynamic = settings.useDynamicColor;

            return MaterialApp(
              navigatorKey: _navigatorKey,
              title: 'Расписание',
              debugShowCheckedModeBanner: false,
              themeMode: settings.themeMode,
              theme: AppTheme.build(
                brightness: Brightness.light,
                seed: accent.seed,
                dynamicScheme: useDynamic ? lightDynamic?.harmonized() : null,
              ),
              darkTheme: AppTheme.build(
                brightness: Brightness.dark,
                seed: accent.seed,
                dynamicScheme: useDynamic ? darkDynamic?.harmonized() : null,
                amoled: settings.amoledDark,
              ),
              builder: (context, child) {
                final media = MediaQuery.of(context);
                // Системный масштаб умножаем на пользовательский, чтобы не
                // ломать доступность тем, кто уже увеличил шрифт в ОС.
                final systemScale = media.textScaler.scale(100) / 100;
                final combined =
                    (systemScale * settings.textScale).clamp(0.8, 1.8);

                return MediaQuery(
                  data: media.copyWith(
                    textScaler: TextScaler.linear(combined),
                  ),
                  child: child ?? const SizedBox.shrink(),
                );
              },
              home: const HomePage(),
            );
          },
        ),
      ),
    );
  }
}
