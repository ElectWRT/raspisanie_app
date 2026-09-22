import 'package:dio/dio.dart';
import 'package:drift/drift.dart';
import 'package:flutter/widgets.dart';
import 'package:workmanager/workmanager.dart';

import '../../features/substitutions/data/datasources/docx_parser.dart';
import '../../features/substitutions/data/datasources/substitutions_remote_data_source.dart';
import '../../features/substitutions/data/repositories/substitutions_repository_impl.dart';
import '../database/database.dart';
import '../notifications/notification_service.dart';
import '../settings/app_settings.dart';
import '../utils/week_utils.dart';

/// Имя задачи, по которому WorkManager зовёт нас обратно.
const backgroundRefreshTask = 'refresh-substitutions';

const _uniqueName = 'raspisanie-substitutions-refresh';

/// Точка входа фонового изолята. Аннотация обязательна: без неё
/// tree shaking выбросит функцию из release-сборки.
@pragma('vm:entry-point')
void backgroundCallbackDispatcher() {
  Workmanager().executeTask((taskName, inputData) async {
    if (taskName != backgroundRefreshTask) return true;
    return runBackgroundRefresh();
  });
}

/// Проверяет сайт и, если замены изменились, показывает уведомление.
///
/// Выполняется в отдельном изоляте, где GetIt пуст, — зависимости
/// собираются здесь заново и закрываются в конце.
Future<bool> runBackgroundRefresh() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Базу открывает и UI-изолят, и этот. Предупреждение drift здесь
  // ожидаемо: SQLite сам разруливает блокировки между процессами.
  driftRuntimeOptions.dontWarnAboutMultipleDatabases = true;

  AppDatabase? database;
  try {
    final settings = await AppSettings.load();
    if (!settings.backgroundRefreshEnabled) return true;

    database = AppDatabase();
    final notifications = NotificationService.create();

    final repository = SubstitutionsRepositoryImpl(
      remoteDataSource: SubstitutionsRemoteDataSourceImpl(
        Dio(BaseOptions(
          connectTimeout: const Duration(seconds: 20),
          receiveTimeout: const Duration(seconds: 40),
          validateStatus: (status) => status != null && status < 400,
        )),
      ),
      parser: const DocxParser(),
      database: database,
      settings: settings,
    );

    // Слепки читаем до загрузки: она сама перепишет их на новые, и
    // сравнивать будет не с чем. В них учтено и то, что пользователь уже
    // обновил вручную, — о таком не уведомляем.
    final today = WeekUtils.dayKey(DateTime.now());
    final previous = <DateTime, String?>{};
    for (var offset = 0; offset < _lookaheadDays; offset++) {
      final date = today.add(Duration(days: offset));
      previous[date] = await database.getMeta(notifiedSignatureKey(date));
    }

    // Все документы с сегодняшнего дня, а не один ближайший: замены на
    // завтра выкладывают накануне, пока на странице ещё висит сегодняшний
    // документ, — и раньше фон качал только его, а о завтрашних молчал.
    final outcome = await repository.refreshUpcoming();

    // await обязателен. Без него return отдаёт незавершённый Future, finally
    // тут же закрывает базу, а ветка ниже ещё читает из неё — и падает уже
    // после того, как catch перестал что-либо ловить. Из-за этого фоновые
    // уведомления о заменах не показывались вообще.
    return await outcome.fold<Future<bool>>(
      // Сайт недоступен или замен ещё нет — это не сбой задачи,
      // повторим по расписанию. Возврат false заставил бы WorkManager
      // ретраить с нарастающей задержкой.
      (failure) async => true,
      (reports) async {
        for (final report in reports) {
          final date = WeekUtils.dayKey(report.date);
          if (date.isBefore(today)) continue;

          final signature = await database!.getMeta(notifiedSignatureKey(date));
          if (signature == previous[date]) continue;

          final count = await _countFor(
            database,
            date: date,
            group: settings.selectedGroup,
          );
          if (count == 0) continue;

          await notifications.showSubstitutionAlert(
            title: substitutionAlertTitle(date: date, today: today),
            body: substitutionAlertBody(
              date: date,
              count: count,
              group: settings.selectedGroup,
            ),
            payload: NotificationPayload.forSubstitutions(date),
            slot: daysBetween(today, date),
          );
        }
        return true;
      },
    );
  } catch (_) {
    // Фоновая задача не должна падать: молча ждём следующего запуска.
    return true;
  } finally {
    await database?.close();
  }
}

Future<int> _countFor(
  AppDatabase database, {
  required DateTime date,
  String? group,
}) async {
  final rows = await database.getSubstitutionsOnDate(date);
  if (group == null) return rows.length;
  return rows.where((r) => r.groupName == group).length;
}

/// Сколько дней вперёд смотрим. Дальше двух недель завуч замены
/// не выкладывает, а слепок на каждый день — отдельное чтение из базы.
const _lookaheadDays = 14;

/// Полных дней между двумя датами. Через UTC: при переводе часов местные
/// сутки короче, и разница в часах, делённая на 24, дала бы на день меньше.
int daysBetween(DateTime from, DateTime to) =>
    DateTime.utc(to.year, to.month, to.day)
        .difference(DateTime.utc(from.year, from.month, from.day))
        .inDays;

/// Заголовок уведомления: «на сегодня» и «на завтра» понятнее даты.
String substitutionAlertTitle({
  required DateTime date,
  required DateTime today,
}) =>
    switch (daysBetween(today, date)) {
      0 => 'Замены на сегодня',
      1 => 'Замены на завтра',
      _ => 'Новые замены',
    };

/// Текст уведомления о новых заменах.
String substitutionAlertBody({
  required DateTime date,
  required int count,
  String? group,
}) {
  final where = group == null ? '' : ' у $group';
  return 'На ${WeekUtils.formatFullDate(date)}$where — '
      '$count ${_changesWord(count)}. Откройте, чтобы посмотреть.';
}

String _changesWord(int count) {
  final mod10 = count % 10;
  final mod100 = count % 100;
  if (mod10 == 1 && mod100 != 11) return 'замена';
  if (mod10 >= 2 && mod10 <= 4 && (mod100 < 12 || mod100 > 14)) return 'замены';
  return 'замен';
}

/// Включает или выключает периодическую проверку по настройкам.
class BackgroundRefresh {
  const BackgroundRefresh._();

  /// Вызывается при старте и после смены настроек.
  static Future<void> apply(AppSettings settings) async {
    try {
      if (!settings.backgroundRefreshEnabled) {
        await Workmanager().cancelByUniqueName(_uniqueName);
        return;
      }

      await Workmanager().registerPeriodicTask(
        _uniqueName,
        backgroundRefreshTask,
        frequency: Duration(hours: settings.backgroundRefreshHours),
        // Без сети задача бессмысленна — пусть ждёт подключения.
        constraints: Constraints(networkType: NetworkType.connected),
        // update, а не keep: иначе смена интервала не подхватится.
        existingWorkPolicy: ExistingPeriodicWorkPolicy.update,
      );
    } catch (_) {
      // На устройствах без WorkManager приложение должно жить дальше.
    }
  }
}
