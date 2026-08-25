import 'dart:typed_data';

import 'package:dartz/dartz.dart';

import '../../../../core/database/database.dart';
import '../../../../core/error/failures.dart';
import '../entities/substitution.dart';

abstract class SubstitutionsRepository {
  /// Ищет свежий документ замен на сайте (или по ручной ссылке из настроек),
  /// разбирает его и сохраняет в базу.
  Future<Either<Failure, RefreshReport>> refresh({DateTime? targetDate});

  /// Разбирает .docx, выбранный пользователем вручную. Нужен, когда сайт
  /// недоступен или разметка поменялась.
  Future<Either<Failure, RefreshReport>> importDocx(
    Uint8List bytes, {
    String source = 'файл с устройства',
    DateTime? fallbackDate,
  });

  Stream<List<Substitution>> watchOnDate(DateTime date);

  /// Когда замены обновлялись в последний раз.
  Stream<DateTime?> watchLastUpdated();

  /// Удаляет все загруженные замены.
  Future<void> clearAll();
}
