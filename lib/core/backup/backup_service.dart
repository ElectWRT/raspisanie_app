import 'dart:convert';
import 'dart:typed_data';

import 'package:file_picker/file_picker.dart';

import '../app_info.dart';
import '../database/database.dart';
import '../settings/app_settings.dart';

/// Формат файла резервной копии не совпадает с внутренней схемой базы —
/// это отдельный контракт, который должен пережить смену таблиц.
const _backupFormatVersion = 1;

class BackupSummary {
  final int lessons;
  final int substitutions;
  final int homeworks;

  const BackupSummary({
    required this.lessons,
    required this.substitutions,
    required this.homeworks,
  });
}

/// Что показать перед восстановлением — пользователь должен понимать,
/// что он сейчас заменит, до необратимого шага.
class BackupPreview {
  final DateTime? createdAt;
  final String? appVersion;
  final BackupSummary summary;

  const BackupPreview({
    required this.createdAt,
    required this.appVersion,
    required this.summary,
  });
}

class BackupFormatException implements Exception {
  final String message;
  const BackupFormatException(this.message);

  @override
  String toString() => message;
}

/// Резервное копирование расписания, звонков, домашки и настроек в один
/// JSON-файл. Замены и служебные записи попадают в копию как есть —
/// это цена простоты, зато после восстановления не нужно ничего докачивать.
class BackupService {
  BackupService({required this.database, required this.settings});

  final AppDatabase database;
  final AppSettings settings;

  Future<Map<String, dynamic>> _buildPayload() async {
    final tables = await database.exportAllTables();
    return {
      'backupFormatVersion': _backupFormatVersion,
      'appVersion': AppInfo.version,
      'createdAt': DateTime.now().toIso8601String(),
      'settings': settings.exportForBackup(),
      ...tables,
    };
  }

  /// Строит файл и открывает системный выбор места сохранения.
  /// Возвращает путь, если пользователь его выбрал, иначе null.
  Future<String?> exportToFile() async {
    final payload = await _buildPayload();
    final bytes = Uint8List.fromList(
      utf8.encode(const JsonEncoder.withIndent('  ').convert(payload)),
    );

    final stamp = DateTime.now();
    final fileName = 'raspisanie-backup-'
        '${stamp.year}${_pad(stamp.month)}${_pad(stamp.day)}-'
        '${_pad(stamp.hour)}${_pad(stamp.minute)}.json';

    return FilePicker.platform.saveFile(
      dialogTitle: 'Сохранить резервную копию',
      fileName: fileName,
      type: FileType.custom,
      allowedExtensions: const ['json'],
      bytes: bytes,
    );
  }

  /// Разбирает файл и считает, что в нём есть, не трогая базу.
  /// Показывается пользователю перед подтверждением восстановления.
  BackupPreview inspect(Uint8List bytes) {
    final data = _decode(bytes);

    final lessons = (data['lessons'] as List?)?.length ?? 0;
    final substitutions = (data['substitutions'] as List?)?.length ?? 0;
    final homeworks = (data['homeworks'] as List?)?.length ?? 0;

    return BackupPreview(
      createdAt: DateTime.tryParse(data['createdAt'] as String? ?? ''),
      appVersion: data['appVersion'] as String?,
      summary: BackupSummary(
        lessons: lessons,
        substitutions: substitutions,
        homeworks: homeworks,
      ),
    );
  }

  /// Заменяет текущие данные содержимым файла. Необратимо — вызывающая
  /// сторона обязана подтвердить это с пользователем заранее.
  Future<void> restore(Uint8List bytes) async {
    final data = _decode(bytes);

    await database.importAllTables(data);

    final rawSettings = data['settings'];
    if (rawSettings is Map) {
      await settings.importFromBackup(Map<String, dynamic>.from(rawSettings));
    }
  }

  Map<String, dynamic> _decode(Uint8List bytes) {
    final Map<String, dynamic> data;
    try {
      data = jsonDecode(utf8.decode(bytes)) as Map<String, dynamic>;
    } catch (e) {
      throw const BackupFormatException(
        'Файл повреждён или это не резервная копия расписания.',
      );
    }

    final version = data['backupFormatVersion'];
    if (version is! int || version > _backupFormatVersion) {
      throw const BackupFormatException(
        'Эта копия сделана более новой версией приложения. Обновите '
        'приложение и попробуйте снова.',
      );
    }

    return data;
  }

  static String _pad(int value) => value.toString().padLeft(2, '0');
}
