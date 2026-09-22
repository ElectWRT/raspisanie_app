/// Подбирает число частиц под конкретное устройство по тому, как быстро
/// оно на самом деле рисует кадры.
///
/// Угадывать по модели телефона, памяти или числу ядер ненадёжно: один и
/// тот же телефон тормозит по-разному в режиме экономии батареи, при
/// нагреве или со сторонним лаунчером. Поэтому меряем само приложение:
/// не успеваем — частиц сразу меньше, успеваем с запасом — понемногу больше.
class DensityGovernor {
  DensityGovernor({
    required this.maxCount,
    required int initial,
    this.windowSize = 60,
  }) : count = initial.clamp(0, maxCount);

  /// Потолок: больше частиц экран не просит, даже если устройство тянет.
  final int maxCount;

  /// Сколько кадров в одном окне замера — около секунды на 60 Гц.
  final int windowSize;

  /// Текущее число частиц.
  int count;

  final List<Duration> _window = [];
  int _fastWindows = 0;

  /// Сколько окон подряд с запасом нужно, чтобы добавить частиц.
  /// Прибавляем осторожно, убавляем сразу: рывок заметнее, чем
  /// пара лишних листьев.
  static const _windowsBeforeGrow = 3;

  /// Учитывает очередной кадр. [cost] — сколько он занял, [budget] —
  /// сколько отведено на кадр при частоте экрана. Возвращает true, когда
  /// число частиц поменялось.
  bool addFrame(Duration cost, Duration budget) {
    _window.add(cost);
    if (_window.length < windowSize) return false;

    final sorted = [..._window]..sort();
    _window.clear();
    // 90-й перцентиль, а не среднее: один тяжёлый кадр при открытии экрана
    // не должен срезать листья, а регулярные рывки — должны.
    final p90 = sorted[(sorted.length * 0.9).floor().clamp(0, sorted.length - 1)];
    final before = count;

    if (p90 > budget * 0.85) {
      _fastWindows = 0;
      count = (count * 0.7).floor();
    } else if (p90 < budget * 0.5) {
      _fastWindows++;
      if (_fastWindows >= _windowsBeforeGrow) {
        _fastWindows = 0;
        count = (count + 2).clamp(0, maxCount);
      }
    } else {
      _fastWindows = 0;
    }

    return count != before;
  }

  /// Потолок частиц для области экрана — чтобы на планшете их было
  /// больше, чем на маленьком телефоне, при той же густоте.
  static int maxForArea(double widthDp, double heightDp, {double factor = 1}) =>
      ((widthDp * heightDp / 12000) * factor).round().clamp(4, 45);
}
