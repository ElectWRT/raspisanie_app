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

/// Источник строк, загруженных по ручной ссылке из настроек.
const manualSourceKey = 'ссылка';

/// Источник строк из файла, выбранного на телефоне.
const fileSourceKey = 'файл';

/// Источник документа с сайта. Ключ — корпус, а не адрес ссылки: если
/// завуч перезальёт исправленный документ под другим именем, он должен
/// заменить прежний документ того же корпуса, а не лечь рядом с ним.
String sourceKeyFor(SourceLink link) =>
    link.building == null ? 'сайт' : 'корпус:${link.building}';

/// Какие документы качать при обновлении.
///
/// Все с сегодняшнего дня — по всем корпусам: замены на завтра выкладывают,
/// пока висит сегодняшний документ. Плюс документы на [targetDate], если
/// человек смотрит прошедший день. Если будущих нет — все документы самой
/// свежей даты. Если дат в ссылках нет совсем — первая ссылка на документ.
List<SourceLink> linksToRefresh(
  List<SourceLink> links, {
  DateTime? targetDate,
  required DateTime now,
}) {
  final today = WeekUtils.dayKey(now);
  final target = targetDate == null ? null : WeekUtils.dayKey(targetDate);

  final dated = links.where((l) => l.date != null).toList();
  final wanted = dated.where((l) {
    final day = WeekUtils.dayKey(l.date!);
    return !day.isBefore(today) || day == target;
  }).toList();

  if (wanted.isEmpty && dated.isNotEmpty) {
    final latest = dated
        .map((l) => WeekUtils.dayKey(l.date!))
        .reduce((a, b) => a.isAfter(b) ? a : b);
    wanted.addAll(dated.where((l) => WeekUtils.dayKey(l.date!) == latest));
  }

  if (wanted.isNotEmpty) {
    return wanted..sort((a, b) => a.date!.compareTo(b.date!));
  }

  return [
    links.firstWhere(
      (l) => l.isCloudMail || l.isDirectDocument,
      orElse: () => links.first,
    ),
  ];
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

  /// Обновление по кнопке, при запуске и свайпом вниз.
  ///
  /// Качает тот же набор документов, что и фоновая проверка, — все с
  /// сегодняшнего дня по всем корпусам, — плюс документы на [targetDate],
  /// если он в прошлом. Раньше каждый путь выбирал один документ по-своему,
  /// и «Обновить» на дне без документа перезаписывал сегодняшние замены
  /// документом другого корпуса. Возвращает отчёт за [targetDate], а если
  /// на него документа нет — за ближайший загруженный день.
  @override
  Future<Either<Failure, RefreshReport>> refresh({DateTime? targetDate}) async {
    final outcome = await _refreshDocuments(targetDate: targetDate);
    return outcome.map((reports) => _reportFor(reports, targetDate));
  }

  @override
  Future<Either<Failure, List<RefreshReport>>> refreshUpcoming() =>
      _refreshDocuments();

  Future<Either<Failure, List<RefreshReport>>> _refreshDocuments({
    DateTime? targetDate,
  }) async {
    try {
      // Ручная ссылка ведёт на один конкретный файл — выбирать не из чего.
      final manual = settings.manualLink;
      if (manual != null) {
        final bytes = await remoteDataSource.download(manual);
        return (await _store(
          bytes,
          source: 'ручная ссылка',
          sourceKey: manualSourceKey,
          fallbackDate: targetDate,
        ))
            .map((report) => [report]);
      }

      final links = _forMyBuilding(
        await remoteDataSource.findLinks(settings.sourcePageUrl),
      );
      if (links.isEmpty) {
        throw ParsingException('Ссылки на замены не найдены.');
      }
      return _downloadAll(
        linksToRefresh(links, targetDate: targetDate, now: DateTime.now()),
        fallbackDate: targetDate,
      );
    } on NetworkException catch (e) {
      return Left(ServerFailure(e.message));
    } on ParsingException catch (e) {
      return Left(ParsingFailure(e.message));
    } catch (e) {
      return Left(ServerFailure('Не удалось обновить замены: $e'));
    }
  }

  /// Качает документы по одному: сбой одного не отменяет остальные —
  /// завтрашние замены важнее, чем битый документ соседнего корпуса.
  Future<Either<Failure, List<RefreshReport>>> _downloadAll(
    List<SourceLink> links, {
    DateTime? fallbackDate,
  }) async {
    final reports = <RefreshReport>[];
    Failure? firstFailure;

    for (final link in links) {
      try {
        final bytes = await remoteDataSource.download(link.url);
        final stored = await _store(
          bytes,
          source: link.title.isEmpty ? link.url : link.title,
          sourceKey: sourceKeyFor(link),
          fallbackDate: link.date ?? fallbackDate,
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
  }

  @override
  Future<Either<Failure, RefreshReport>> importDocx(
    Uint8List bytes, {
    String source = 'файл с устройства',
    DateTime? fallbackDate,
  }) async {
    try {
      return _store(
        bytes,
        source: source,
        sourceKey: fileSourceKey,
        fallbackDate: fallbackDate,
      );
    } on ParsingException catch (e) {
      return Left(ParsingFailure(e.message));
    } catch (e) {
      return Left(ParsingFailure('Не удалось разобрать файл: $e'));
    }
  }

  Future<Either<Failure, RefreshReport>> _store(
    Uint8List bytes, {
    required String source,
    required String sourceKey,
    DateTime? fallbackDate,
  }) async {
    final parsed = parser.parseBytes(bytes);
    final guessed = parsed.date == null;
    final date = WeekUtils.dayKey(
      parsed.date ?? fallbackDate ?? DateTime.now(),
    );

    await database.replaceSubstitutionsFromSource(
      date,
      sourceKey,
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

  /// Отчёт для экрана: за [targetDate], иначе за ближайший день с
  /// сегодняшнего, иначе за первый загруженный. Документы разных корпусов
  /// за один день складываются в один отчёт.
  static RefreshReport _reportFor(
    List<RefreshReport> reports,
    DateTime? targetDate,
  ) {
    final byDate = <DateTime, List<RefreshReport>>{};
    for (final report in reports) {
      (byDate[WeekUtils.dayKey(report.date)] ??= []).add(report);
    }

    final today = WeekUtils.dayKey(DateTime.now());
    final dates = byDate.keys.toList()..sort();
    final wanted = targetDate == null ? null : WeekUtils.dayKey(targetDate);
    final chosen = byDate.containsKey(wanted)
        ? wanted!
        : dates.firstWhere((d) => !d.isBefore(today), orElse: () => dates.first);

    final same = byDate[chosen]!;
    if (same.length == 1) return same.single;
    return RefreshReport(
      date: chosen,
      importedCount: same.fold(0, (sum, r) => sum + r.importedCount),
      source: same.map((r) => r.source).join(' + '),
      warnings: [for (final r in same) ...r.warnings],
      textPreview: same.first.textPreview,
      dateWasGuessed: same.any((r) => r.dateWasGuessed),
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
