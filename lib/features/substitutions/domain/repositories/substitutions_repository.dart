import 'dart:typed_data';

import 'package:dartz/dartz.dart';

import '../../../../core/database/database.dart';
import '../../../../core/error/failures.dart';
import '../entities/substitution.dart';

abstract class SubstitutionsRepository {
  /// Ищет свежий документ замен на сайте (или по ручной ссылке из настроек),
  /// разбирает его и сохраняет в базу.
  Future<Either<Failure, RefreshReport>> refresh({DateTime? targetDate});

  /// Скачивает все документы с сегодняшнего дня и дальше, а не один.
  ///
  /// Нужен фоновой проверке: замены на завтра выкладывают накануне, пока
  /// на странице ещё висит сегодняшний документ. [refresh] без даты берёт
  /// ближайший — то есть сегодняшний, — и завтрашний так и не увидит.
  Future<Either<Failure, List<RefreshReport>>> refreshUpcoming();

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
