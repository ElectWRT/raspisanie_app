import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:dio/dio.dart';
import 'package:google_fonts/google_fonts.dart';

import 'core/database/app_database.dart';
import 'features/substitutions/data/datasources/substitutions_remote_data_source.dart';
import 'features/substitutions/data/datasources/docx_parser.dart';
import 'features/substitutions/data/repositories/substitutions_repository_impl.dart';
import 'features/substitutions/presentation/bloc/substitutions_bloc.dart';
import 'features/substitutions/presentation/pages/substitutions_page.dart';

final getIt = GetIt.instance;

void setupDependencyInjection() {
  final dio = Dio();
  final database = AppDatabase();
  final parser = DocxParser();
  
  final remoteDataSource = SubstitutionsRemoteDataSourceImpl(dio);
  
  getIt.registerLazySingleton(() => database);
  getIt.registerLazySingleton<SubstitutionsRemoteDataSource>(() => remoteDataSource);
  getIt.registerLazySingleton(() => parser);
  
  getIt.registerLazySingleton<SubstitutionsRepositoryImpl>(() => SubstitutionsRepositoryImpl(
    remoteDataSource: getIt(),
    parser: getIt(),
    database: getIt(),
  ));
}

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  setupDependencyInjection();
  
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Автодор Замены',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF2196F3),
          brightness: Brightness.light,
        ),
        textTheme: GoogleFonts.interTextTheme(),
      ),
      home: BlocProvider(
        create: (context) => SubstitutionsBloc(getIt<SubstitutionsRepositoryImpl>())
          ..add(const WatchSubstitutions())
          ..add(const RefreshSubstitutions()),
        child: const SubstitutionsPage(),
      ),
    );
  }
}
