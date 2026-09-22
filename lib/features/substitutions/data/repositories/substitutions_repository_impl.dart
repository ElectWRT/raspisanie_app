import 'dart:typed_data';

import 'package:crypto/crypto.dart';
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

/// Ключ в AppMeta: слепок замен на [date], которые пользователь уже видел —
/// сам в приложении или в уведомлении о них.
///
/// Отдельный на каждую дату: фоновая проверка качает и сегодняшний, и
/// завтрашний документ, и с одним общим ключом они затирали бы слепки
/// друг друга — уведомление приходило бы при каждой проверке.
String notifiedSignatureKey(DateTime date) {
  final day = WeekUtils.dayKey(date);
  return 'notified_substitutions_signature:'
      '${day.year.toString().padLeft(4, '0')}-'
      '${day.month.toString().padLeft(2, '0')}-'
      '${day.day.toString().padLeft(2, '0')}';
}

/// Слепок замен на дату. Меняется, если поменялась хоть одна строка.
///
/// Порядок строк не влияет: список сортируется перед свёрткой, иначе
/// уведомление приходило бы после каждой загрузки.
String substitutionsSignature({
  required List<Substitution> rows,
  required DateTime date,
  String? group,
}) {
  final mine = group == null
      ? rows
      : rows.where((r) => r.groupName == group).toList();

  final parts = mine
      .map((r) => '${r.groupName}|${r.pairNumber}|${r.subgroup ?? ''}|'
          '${r.subject}|${r.teacher}|${r.room}|${r.isCancelled}')
      .toList()
    ..sort();

  final payload = '${WeekUtils.dayKey(date).toIso8601String()}::'
      '${parts.join(';')}';
  return md5.convert(payload.codeUnits).toString();
}

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
  Future<Either<Failure, List<RefreshReport>>> refreshUpcoming() async {
    // Ручная ссылка ведёт на один конкретный файл — выбирать не из чего.
    if (settings.manualLink != null) {
      return (await refresh()).map((report) => [report]);
    }

    try {
      final links = _forMyBuilding(
        await remoteDataSource.findLinks(settings.sourcePageUrl),
      );
      if (links.isEmpty) {
        throw ParsingException('Ссылки на замены не найдены.');
      }

      final today = WeekUtils.dayKey(DateTime.now());
      final upcoming = links
          .where((l) => l.date != null && !l.date!.isBefore(today))
          .toList()
        ..sort((a, b) => a.date!.compareTo(b.date!));

      // Дат в ссылках нет или все документы в прошлом — ведём себя
      // как обычное обновление: берём один, самый подходящий.
      if (upcoming.isEmpty) {
        return (await refresh()).map((report) => [report]);
      }

      final reports = <RefreshReport>[];
      Failure? firstFailure;

      // Документы качаем по одному: сбой одного не должен отменять
      // остальные — завтрашние замены важнее, чем битый сегодняшний файл.
      for (final link in upcoming) {
        try {
          final bytes = await remoteDataSource.download(link.url);
          final stored = await _store(
            bytes,
            source: link.title.isEmpty ? link.url : link.title,
            fallbackDate: link.date,
          );
          stored.fold(
            (failure) => firstFailure ??= failure,
            (report) {
              reports.add(report);
              return null;
            },
          );
        } on NetworkException catch (e) {
          firstFailure ??= ServerFailure(e.message);
        } on ParsingException catch (e) {
          firstFailure ??= ParsingFailure(e.message);
        }
      }

      if (reports.isEmpty) {
        return Left(firstFailure ?? const ServerFailure('Замены не загружены.'));
      }
      return Right(reports);
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

    // Слепок пишет любой путь обновления, а не только фоновый. Иначе после
    // обновления вручную фоновая задача сравнила бы новые замены с давно
    // устаревшим слепком и прислала уведомление о том, что пользователь
    // уже прочитал в приложении.
    await database.setMeta(
      notifiedSignatureKey(date),
      substitutionsSignature(
        rows: await database.getSubstitutionsOnDate(date),
        date: date,
        group: settings.selectedGroup,
      ),
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

  /// Замены выкладывают отдельным файлом на каждый корпус. Если корпус
  /// выбран в настройках — берём только его, иначе попадём в чужой.
  /// Ссылки без указания корпуса оставляем: они относятся ко всем.
  List<SourceLink> _forMyBuilding(List<SourceLink> links) {
    final building = settings.preferredBuilding;
    if (building == null) return links;
    final mine = links
        .where((l) => l.building == null || l.building == building)
        .toList();
    return mine.isNotEmpty ? mine : links;
  }

  /// Выбирает подходящую ссылку: точное совпадение с нужной датой, иначе
  /// ближайшую будущую, иначе самую свежую из найденных.
  SourceLink _pickLink(List<SourceLink> allLinks, DateTime? targetDate) {
    if (allLinks.isEmpty) {
      throw ParsingException('Ссылки на замены не найдены.');
    }

    final links = _forMyBuilding(allLinks);

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
