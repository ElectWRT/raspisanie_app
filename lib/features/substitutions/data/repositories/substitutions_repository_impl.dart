import 'dart:typed_data';

import 'package:dartz/dartz.dart';

import '../../../../core/database/database.dart';
import '../../../../core/error/exceptions.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/settings/app_settings.dart';
import '../../../../core/utils/week_utils.dart';
import '../../domain/entities/substitution.dart';
import '../../domain/repositories/substitutions_repository.dart';
import '../datasources/docx_parser.dart';
import '../datasources/substitutions_remote_data_source.dart';

class SubstitutionsRepositoryImpl implements SubstitutionsRepository {
  SubstitutionsRepositoryImpl({
    required this.remoteDataSource,
    required this.parser,
    required this.database,
    required this.settings,
  });

  final SubstitutionsRemoteDataSource remoteDataSource;
  final DocxParser parser;
  final AppDatabase database;
  final AppSettings settings;

  static const _lastUpdatedKey = 'substitutions_last_updated';

  @override
  Future<Either<Failure, RefreshReport>> refresh({DateTime? targetDate}) async {
    try {
      final manual = settings.manualLink;
      final Uint8List bytes;
      final String source;
      DateTime? linkDate;

      if (manual != null) {
        bytes = await remoteDataSource.download(manual);
        source = 'ручная ссылка';
      } else {
        final links = await remoteDataSource.findLinks(settings.sourcePageUrl);
        final best = _pickLink(links, targetDate);
        linkDate = best.date;
        source = best.title.isEmpty ? best.url : best.title;
        bytes = await remoteDataSource.download(best.url);
      }

      return _store(
        bytes,
        source: source,
        fallbackDate: targetDate ?? linkDate,
      );
    } on NetworkException catch (e) {
      return Left(ServerFailure(e.message));
    } on ParsingException catch (e) {
      return Left(ParsingFailure(e.message));
    } catch (e) {
      return Left(ServerFailure('Не удалось обновить замены: $e'));
    }
  }

  @override
  Future<Either<Failure, RefreshReport>> importDocx(
    Uint8List bytes, {
    String source = 'файл с устройства',
    DateTime? fallbackDate,
  }) async {
    try {
      return _store(bytes, source: source, fallbackDate: fallbackDate);
    } on ParsingException catch (e) {
      return Left(ParsingFailure(e.message));
    } catch (e) {
      return Left(ParsingFailure('Не удалось разобрать файл: $e'));
    }
  }

  Future<Either<Failure, RefreshReport>> _store(
    Uint8List bytes, {
    required String source,
    DateTime? fallbackDate,
  }) async {
    final parsed = parser.parseBytes(bytes);
    final guessed = parsed.date == null;
    final date = WeekUtils.dayKey(
      parsed.date ?? fallbackDate ?? DateTime.now(),
    );

    await database.replaceSubstitutionsForDate(
      date,
      parsed.items.map((item) => item.toCompanion(date)).toList(),
    );
    await database.setMeta(
      _lastUpdatedKey,
      DateTime.now().toIso8601String(),
    );
    await database.purgeOldSubstitutions();

    return Right(RefreshReport(
      date: date,
      importedCount: parsed.items.length,
      source: source,
      warnings: parsed.warnings,
      textPreview: parsed.textPreview,
      dateWasGuessed: guessed,
    ));
  }

  /// Выбирает подходящую ссылку: точное совпадение с нужной датой, иначе
  /// ближайшую будущую, иначе самую свежую из найденных.
  SourceLink _pickLink(List<SourceLink> allLinks, DateTime? targetDate) {
    if (allLinks.isEmpty) {
      throw ParsingException('Ссылки на замены не найдены.');
    }

    // Замены выкладывают отдельным файлом на каждый корпус. Если корпус
    // выбран в настройках — берём только его, иначе попадём в чужой.
    // Ссылки без указания корпуса оставляем: они относятся ко всем.
    final building = settings.preferredBuilding;
    var links = allLinks;
    if (building != null) {
      final mine = allLinks
          .where((l) => l.building == null || l.building == building)
          .toList();
      if (mine.isNotEmpty) links = mine;
    }

    if (targetDate != null) {
      final day = WeekUtils.dayKey(targetDate);
      final exact = links.where(
        (l) => l.date != null && WeekUtils.dayKey(l.date!) == day,
      );
      if (exact.isNotEmpty) return exact.first;
    }

    final today = WeekUtils.dayKey(DateTime.now());
    final dated = links.where((l) => l.date != null).toList()
      ..sort((a, b) => b.date!.compareTo(a.date!));

    if (dated.isNotEmpty) {
      final upcoming = dated.where((l) => !l.date!.isBefore(today)).toList();
      // Ближайшая будущая дата, иначе самый свежий из прошлых документов.
      if (upcoming.isNotEmpty) return upcoming.last;
      return dated.first;
    }

    // Даты в тексте нет — берём первую ссылку, которая ведёт на документ.
    return links.firstWhere(
      (l) => l.isCloudMail || l.isDirectDocument,
      orElse: () => links.first,
    );
  }

  @override
  Stream<List<Substitution>> watchOnDate(DateTime date) =>
      database.watchSubstitutionsOnDate(date);

  @override
  Future<void> clearAll() => database.clearSubstitutions();

  @override
  Stream<DateTime?> watchLastUpdated() => database
      .watchMeta(_lastUpdatedKey)
      .map((raw) => raw == null ? null : DateTime.tryParse(raw));
}
