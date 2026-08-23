import 'package:equatable/equatable.dart';

/// Итог обновления замен — что скачали, за какое число и что не поняли.
class RefreshReport extends Equatable {
  /// Дата, на которую относятся замены.
  final DateTime date;

  /// Сколько строк записано в базу.
  final int importedCount;

  /// Откуда взяли документ (заголовок ссылки или «ручная ссылка»).
  final String source;

  /// Предупреждения парсера — строки, которые он не разобрал.
  final List<String> warnings;

  /// Текст документа для диагностики, если парсер ошибся.
  final String textPreview;

  /// Дата не нашлась в документе и была выбрана по ссылке/по умолчанию.
  final bool dateWasGuessed;

  const RefreshReport({
    required this.date,
    required this.importedCount,
    required this.source,
    this.warnings = const [],
    this.textPreview = '',
    this.dateWasGuessed = false,
  });

  @override
  List<Object?> get props =>
      [date, importedCount, source, warnings, textPreview, dateWasGuessed];
}
