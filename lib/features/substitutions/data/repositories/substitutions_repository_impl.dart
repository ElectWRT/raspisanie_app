import 'dart:io';
import 'package:dartz/dartz.dart';
import 'package:drift/drift.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/error/exceptions.dart';
import '../../../../core/database/database.dart';
import '../datasources/substitutions_remote_data_source.dart';
import '../datasources/docx_parser.dart';
import '../../domain/repositories/substitutions_repository.dart';
import '../../domain/entities/substitution.dart';

class SubstitutionsRepositoryImpl implements SubstitutionsRepository {
  final SubstitutionsRemoteDataSource remoteDataSource;
  final DocxParser parser;
  final AppDatabase database;

  SubstitutionsRepositoryImpl({
    required this.remoteDataSource,
    required this.parser,
    required this.database,
  });

  @override
  Future<Either<Failure, Unit>> refreshSubstitutions({String? date}) async {
    File? tempFile;
    try {
      final publicUrl = await remoteDataSource.getMailRuLink();
      final directLink = await remoteDataSource.getDirectLink(publicUrl);
      tempFile = await remoteDataSource.downloadFile(directLink);
      final models = parser.parse(tempFile);
      
      final now = DateTime.now();
      final startOfDay = DateTime(now.year, now.month, now.day);

      await database.clearAllSubstitutions();
      await database.insertSubstitutions(
        models.map((m) => SubstitutionsCompanion.insert(
          date: startOfDay,
          groupName: m.groupName,
          pairNumber: m.lessonNumber,
          subject: m.subject,
          teacher: m.teacher,
          room: m.room,
        )).toList(),
      );
      
      return Right(unit);
    } on NetworkException catch (e) {
      return Left(ServerFailure(e.message));
    } on ParsingException catch (e) {
      return Left(ParsingFailure(e.message));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    } finally {
      // 6. Delete temp file ALWAYS
      if (tempFile != null && tempFile.existsSync()) {
        try {
          await tempFile.delete();
          print('--- DEBUG: Временный файл успешно удален ---');
        } catch (e) {
          print('--- DEBUG: Ошибка удаления файла: $e ---');
        }
      }
    }
  }

  @override
  Future<Either<Failure, List<SubstitutionEntity>>> getLocalSubstitutions() async {
    try {
      final results = await database.getAllSubstitutions();
      return Right(results.map((r) => SubstitutionEntity(
        id: r.id,
        groupName: r.groupName,
        period: r.pairNumber.toString(),
        subject: r.subject,
        teacher: r.teacher,
        room: r.room,
      )).toList());
    } catch (e) {
      return Left(CacheFailure(e.toString()));
    }
  }

  @override
  Stream<List<SubstitutionEntity>> watchSubstitutions() {
    return database.watchAllSubstitutions().map((list) => list.map((r) => SubstitutionEntity(
      id: r.id,
      groupName: r.groupName,
      period: r.pairNumber.toString(),
      subject: r.subject,
      teacher: r.teacher,
      room: r.room,
    )).toList());
  }
}
