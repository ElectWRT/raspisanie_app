import 'package:dynamic_color/dynamic_color.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'core/notifications/reminder_scheduler.dart';
import 'core/settings/app_settings.dart';
import 'core/theme/app_theme.dart';
import 'di.dart';
import 'features/schedule/domain/repositories/schedule_repository.dart';
import 'features/schedule/presentation/bloc/schedule_cubit.dart';
import 'features/schedule/presentation/pages/home_page.dart';
import 'features/substitutions/domain/repositories/substitutions_repository.dart';
import 'features/substitutions/presentation/bloc/substitutions_cubit.dart';

class RaspisanieApp extends StatelessWidget {
  const RaspisanieApp({super.key});

  @override
  Widget build(BuildContext context) {
    final settings = getIt<AppSettings>();

    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (_) => ScheduleCubit(
            repository: getIt<ScheduleRepository>(),
            settings: settings,
            reminders: getIt<ReminderScheduler>(),
          )..init(),
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
