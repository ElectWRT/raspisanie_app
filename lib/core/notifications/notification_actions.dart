import 'package:drift/drift.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

import '../../features/attendance/data/mark_day_present.dart';
import '../database/database.dart';
import '../settings/app_settings.dart';
import 'notification_service.dart';

/// Нажатие кнопки в шторке. Выполняется в отдельном изоляте, где нет ни
/// интерфейса, ни собранных зависимостей, — всё открываем заново и
/// закрываем за собой.
///
/// Аннотация обязательна: без неё tree shaking выбросит функцию из
/// release-сборки, и кнопка молча перестанет работать.
@pragma('vm:entry-point')
void handleBackgroundNotificationAction(NotificationResponse response) {
  runNotificationAction(response);
}

/// Отдельно от точки входа, чтобы можно было дождаться в тесте.
Future<void> runNotificationAction(NotificationResponse response) async {
  if (response.actionId != markAllPresentActionId) return;

  final date = NotificationPayload.dateOf(response.payload);
  if (date == null) return;

  WidgetsFlutterBinding.ensureInitialized();
  // Базу уже держит открытой UI-изолят: предупреждение drift здесь
  // ожидаемо, блокировки разруливает сам SQLite.
  driftRuntimeOptions.dontWarnAboutMultipleDatabases = true;

  AppDatabase? database;
  try {
    final settings = await AppSettings.load();
    database = AppDatabase();
    await markDayPresent(
      database: database,
      settings: settings,
      date: date,
    );
  } catch (_) {
    // Нажатие кнопки не должно ронять процесс: в худшем случае человек
    // отметит пары руками.
  } finally {
    await database?.close();
  }
}
