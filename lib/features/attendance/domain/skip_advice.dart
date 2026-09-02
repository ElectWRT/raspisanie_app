import 'package:equatable/equatable.dart';

/// Насколько дорого обойдётся пропуск.
enum SkipVerdict {
  /// Можно — запас по пропускам есть, профильных пар нет.
  allowed,

  /// Не стоит — либо профильная пара, либо это последний пропуск до лимита.
  notAdvised,

  /// Критично — лимит по предмету уже выбран.
  critical,
}

extension SkipVerdictLabel on SkipVerdict {
  String get label => switch (this) {
        SkipVerdict.allowed => 'Можно',
        SkipVerdict.notAdvised => 'Не стоит',
        SkipVerdict.critical => 'Критично',
      };

  /// Чем больше, тем серьёзнее. Нужен, чтобы взять худшую пару за день.
  int get severity => switch (this) {
        SkipVerdict.allowed => 0,
        SkipVerdict.notAdvised => 1,
        SkipVerdict.critical => 2,
      };
}

/// Пара глазами анализа — уже после наложения замен.
class SkipPair extends Equatable {
  const SkipPair({
    required this.pairNumber,
    required this.subject,
    this.isMajor = false,
    this.isCancelled = false,
    this.missedBefore = 0,
  });

  final int pairNumber;

  /// Предмет с учётом замены: если пару заменили, здесь новый предмет.
  final String subject;

  /// Профильный предмет — пропуск считается строже.
  final bool isMajor;

  /// Пара снята заменой: пропускать нечего, в анализ не идёт.
  final bool isCancelled;

  /// Сколько пар по этому предмету уже пропущено без уважительной причины.
  final int missedBefore;

  @override
  List<Object?> get props =>
      [pairNumber, subject, isMajor, isCancelled, missedBefore];
}

/// Пороги, после которых пропуск перестаёт быть безобидным.
///
/// Значения настраиваемые: в разных заведениях считают по-разному, а
/// осмысленного общего стандарта нет.
class SkipLimits extends Equatable {
  const SkipLimits({this.perSubject = 4, this.perMajorSubject = 2});

  /// Допустимо пропусков по обычному предмету.
  final int perSubject;

  /// Допустимо пропусков по профильному.
  final int perMajorSubject;

  int limitFor({required bool isMajor}) =>
      isMajor ? perMajorSubject : perSubject;

  @override
  List<Object?> get props => [perSubject, perMajorSubject];
}

/// Итог анализа: вердикт и человеческое объяснение, почему именно такой.
class SkipAdvice extends Equatable {
  const SkipAdvice({
    required this.verdict,
    this.reasons = const [],
    this.consideredPairs = 0,
  });

  final SkipVerdict verdict;

  /// Короткие фразы для подсказки: «Базы данных — профильный, 2 из 2».
  final List<String> reasons;

  /// Сколько пар реально участвовало в анализе (снятые не считаются).
  final int consideredPairs;

  bool get isEmpty => consideredPairs == 0;

  @override
  List<Object?> get props => [verdict, reasons, consideredPairs];
}

/// Считает, чем обернётся пропуск всего дня.
///
/// Вердикт дня — худший из вердиктов по парам: одна критичная пара делает
/// критичным весь день, потому что пропускают обычно день целиком.
///
/// Снятые заменой пары выбрасываются: их и так не будет, и портить ими
/// статистику нельзя — иначе «группа гуляет» выглядело бы как прогул.
SkipAdvice adviseSkip({
  required List<SkipPair> pairs,
  SkipLimits limits = const SkipLimits(),
}) {
  final considered = pairs.where((p) => !p.isCancelled).toList();
  if (considered.isEmpty) {
    return const SkipAdvice(verdict: SkipVerdict.allowed);
  }

  var worst = SkipVerdict.allowed;
  final reasons = <String>[];

  for (final pair in considered) {
    final limit = limits.limitFor(isMajor: pair.isMajor);
    final after = pair.missedBefore + 1;
    final verdict = _verdictFor(pair: pair, after: after, limit: limit);

    if (verdict.severity > worst.severity) worst = verdict;
    if (verdict != SkipVerdict.allowed) {
      reasons.add(_reasonFor(pair: pair, after: after, limit: limit));
    }
  }

  return SkipAdvice(
    verdict: worst,
    reasons: reasons,
    consideredPairs: considered.length,
  );
}

SkipVerdict _verdictFor({
  required SkipPair pair,
  required int after,
  required int limit,
}) {
  if (after > limit) return SkipVerdict.critical;
  if (after == limit) return SkipVerdict.notAdvised;
  // Профильный предмет не бывает «просто можно», даже с запасом.
  return pair.isMajor ? SkipVerdict.notAdvised : SkipVerdict.allowed;
}

String _reasonFor({
  required SkipPair pair,
  required int after,
  required int limit,
}) {
  final subject = pair.subject.trim().isEmpty ? 'Пара' : pair.subject.trim();
  final major = pair.isMajor ? 'профильный, ' : '';
  if (after > limit) {
    return '$subject — $major'
        'пропусков будет $after при лимите $limit';
  }
  return '$subject — $major$after из $limit';
}
