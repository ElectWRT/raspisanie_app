import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';

import 'core/settings/app_settings.dart';
import 'di.dart';
import 'features/schedule/domain/repositories/schedule_repository.dart';
import 'features/schedule/presentation/bloc/schedule_cubit.dart';
import 'features/schedule/presentation/pages/home_page.dart';
import 'features/substitutions/domain/repositories/substitutions_repository.dart';
import 'features/substitutions/presentation/bloc/substitutions_cubit.dart';

const _seedColor = Color(0xFF2F6BFF);

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
          )..init(),
        ),
        BlocProvider(
          create: (_) {
            final cubit = SubstitutionsCubit(getIt<SubstitutionsRepository>());
            if (settings.autoRefreshOnLaunch) cubit.refresh();
            return cubit;
          },
        ),
      ],
      child: AnimatedBuilder(
        animation: settings,
        builder: (context, _) => MaterialApp(
          title: 'Расписание',
          debugShowCheckedModeBanner: false,
          themeMode: settings.themeMode,
          theme: _buildTheme(Brightness.light),
          darkTheme: _buildTheme(Brightness.dark),
          home: const HomePage(),
        ),
      ),
    );
  }

  ThemeData _buildTheme(Brightness brightness) {
    final scheme = ColorScheme.fromSeed(
      seedColor: _seedColor,
      brightness: brightness,
    );
    final base = ThemeData(colorScheme: scheme, useMaterial3: true);

    return base.copyWith(
      textTheme: GoogleFonts.interTextTheme(base.textTheme),
      appBarTheme: AppBarTheme(
        backgroundColor: scheme.surface,
        surfaceTintColor: Colors.transparent,
        centerTitle: false,
        elevation: 0,
      ),
      cardTheme: CardThemeData(
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
      listTileTheme: const ListTileThemeData(
        contentPadding: EdgeInsets.symmetric(horizontal: 16),
      ),
      inputDecorationTheme: const InputDecorationTheme(
        border: OutlineInputBorder(),
        isDense: true,
      ),
    );
  }
}
