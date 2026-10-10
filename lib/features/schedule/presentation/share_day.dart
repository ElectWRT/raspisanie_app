import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

import '../../../core/app_info.dart';

/// Не удалось превратить экран в картинку.
class ShareDayException implements Exception {
  const ShareDayException(this.message);

  final String message;
}

/// Отправляет день картинкой: снимает область под [boundaryKey] и отдаёт
/// её системному меню «Поделиться».
///
/// Одногруппникам без приложения так понятнее любого пересказа, а ссылка
/// в подписи заодно показывает, откуда картинка.
Future<void> shareDayAsImage({
  required GlobalKey boundaryKey,
  required String caption,
}) async {
  final boundary =
      boundaryKey.currentContext?.findRenderObject() as RenderRepaintBoundary?;
  if (boundary == null) {
    throw const ShareDayException('Экран ещё не готов — попробуйте ещё раз.');
  }

  // 2.5 — компромисс: текст читается на любом экране, а картинка не
  // раздувается до нескольких мегабайт, которые мессенджер потом сожмёт.
  final image = await boundary.toImage(pixelRatio: 2.5);
  final data = await image.toByteData(format: ui.ImageByteFormat.png);
  image.dispose();
  if (data == null) {
    throw const ShareDayException('Не удалось сохранить картинку.');
  }

  final directory = await getTemporaryDirectory();
  final file = File(
    '${directory.path}/raspisanie-${DateTime.now().millisecondsSinceEpoch}.png',
  );
  await file.writeAsBytes(data.buffer.asUint8List(), flush: true);

  await SharePlus.instance.share(
    ShareParams(
      files: [XFile(file.path, mimeType: 'image/png')],
      text: '$caption\n${AppInfo.latestReleaseUrl}',
      subject: caption,
    ),
  );
}
