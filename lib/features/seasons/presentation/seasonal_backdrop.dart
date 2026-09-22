import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

import '../domain/density_governor.dart';
import '../domain/season.dart';

/// Сезонный фон главного экрана: подкрашенная подложка и летящие по ней
/// листья, снег, лепестки или блики. Лежит под содержимым — частицы
/// проходят за карточками и не мешают читать и нажимать.
class SeasonalBackdrop extends StatefulWidget {
  const SeasonalBackdrop({
    super.key,
    required this.look,
    required this.motion,
    required this.child,
    this.plainBackground = false,
    this.initialCount,
    this.onCountLearned,
  });

  /// Какой сезон рисовать. null — оформление выключено.
  final SeasonLook? look;

  /// Движущиеся объекты включены в настройках.
  final bool motion;

  /// Не подкрашивать фон — для AMOLED-темы, где фон должен остаться чёрным.
  final bool plainBackground;

  /// Сколько частиц устройство тянуло в прошлый раз — старт без рывков.
  final int? initialCount;

  /// Регулятор подобрал новое число частиц — его стоит запомнить.
  final ValueChanged<int>? onCountLearned;

  final Widget child;

  @override
  State<SeasonalBackdrop> createState() => _SeasonalBackdropState();
}

class _SeasonalBackdropState extends State<SeasonalBackdrop>
    with SingleTickerProviderStateMixin {
  late final Ticker _ticker = createTicker(_onTick);
  final _repaint = ValueNotifier<int>(0);
  final _random = math.Random();
  final List<_Particle> _particles = [];

  DensityGovernor? _governor;
  Size _size = Size.zero;
  Duration _lastElapsed = Duration.zero;
  DateTime? _measureFrom;
  bool _timingsAttached = false;

  /// Первые секунды после запуска анимации не меряем: открытие экрана и
  /// переходы дают тяжёлые кадры, к частицам отношения не имеющие.
  static const _warmUp = Duration(seconds: 2);

  bool get _running =>
      widget.look != null &&
      widget.motion &&
      !MediaQuery.disableAnimationsOf(context);

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _syncTicker();
  }

  @override
  void didUpdateWidget(covariant SeasonalBackdrop oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.look != widget.look) {
      _governor = null;
      _particles.clear();
    }
    _syncTicker();
  }

  void _syncTicker() {
    if (_running) {
      if (!_ticker.isActive) {
        _lastElapsed = Duration.zero;
        _measureFrom = DateTime.now().add(_warmUp);
        _ticker.start();
      }
      if (!_timingsAttached) {
        SchedulerBinding.instance.addTimingsCallback(_onTimings);
        _timingsAttached = true;
      }
    } else {
      if (_ticker.isActive) _ticker.stop();
      _detachTimings();
      _particles.clear();
      _repaint.value++;
    }
  }

  void _detachTimings() {
    if (!_timingsAttached) return;
    SchedulerBinding.instance.removeTimingsCallback(_onTimings);
    _timingsAttached = false;
  }

  @override
  void dispose() {
    _ticker.dispose();
    _detachTimings();
    _repaint.dispose();
    super.dispose();
  }

  /// Время на кадр при частоте этого экрана: 16,7 мс на 60 Гц, 8,3 на 120.
  Duration get _frameBudget {
    final rate = View.maybeOf(context)?.display.refreshRate ?? 60;
    final hz = rate.isFinite && rate > 1 ? rate : 60;
    return Duration(microseconds: (1000000 / hz).round());
  }

  void _onTimings(List<FrameTiming> timings) {
    final governor = _governor;
    final from = _measureFrom;
    if (governor == null || from == null || DateTime.now().isBefore(from)) {
      return;
    }
    final budget = _frameBudget;
    for (final timing in timings) {
      // Сборка и отрисовка идут параллельно в разных потоках — кадр
      // упирается в более медленный из них.
      final cost = timing.buildDuration > timing.rasterDuration
          ? timing.buildDuration
          : timing.rasterDuration;
      if (governor.addFrame(cost, budget)) {
        widget.onCountLearned?.call(governor.count);
      }
    }
  }

  void _ensureGovernor(Size size) {
    final look = widget.look;
    if (look == null || size.isEmpty) return;
    if (_governor != null && _size == size) return;

    _size = size;
    final max = DensityGovernor.maxForArea(
      size.width,
      size.height,
      factor: _style(look).densityFactor,
    );
    _governor = DensityGovernor(
      maxCount: max,
      initial: widget.initialCount ?? (max * 0.6).round(),
    );
  }

  void _onTick(Duration elapsed) {
    final look = widget.look;
    final governor = _governor;
    if (look == null || governor == null || _size.isEmpty) return;

    final dt = ((elapsed - _lastElapsed).inMicroseconds / 1e6).clamp(0.0, 0.05);
    _lastElapsed = elapsed;
    final style = _style(look);

    // Первое заполнение — по всему экрану сразу. Иначе все частицы
    // рождались бы над краем: экран несколько секунд пустой, а потом
    // сверху накатывает сплошная волна. Добавленные позже — как обычно,
    // из-за края.
    final initialFill = _particles.isEmpty;
    while (_particles.length < governor.count) {
      _particles.add(_spawn(style, anywhere: initialFill));
    }
    if (_particles.length > governor.count) {
      _particles.removeRange(governor.count, _particles.length);
    }

    for (var i = 0; i < _particles.length; i++) {
      final p = _particles[i]..t += dt;
      p.y += (style.rises ? -p.speed : p.speed) * dt;
      p.rotation += p.spin * dt;
      final gone = style.rises ? p.y < -30 : p.y > _size.height + 30;
      if (gone) _particles[i] = _spawn(style, anywhere: false);
    }
    _repaint.value++;
  }

  _Particle _spawn(_SeasonStyle style, {required bool anywhere}) {
    double between(double a, double b) => a + _random.nextDouble() * (b - a);
    final spawnY = style.rises ? _size.height + between(5, 30) : between(-40, -10);
    final festiveFlake =
        style.shape == _Shape.snow && style.fancyFlakes && _random.nextDouble() < 0.3;

    return _Particle(
      x: between(0, _size.width),
      y: anywhere ? between(0, _size.height) : spawnY,
      size: festiveFlake ? between(5, 8) : between(style.size.$1, style.size.$2),
      speed: between(style.speed.$1, style.speed.$2),
      sway: between(10, 30),
      frequency: between(0.4, 1.2),
      phase: between(0, math.pi * 2),
      rotation: between(0, math.pi * 2),
      spin: between(-1.5, 1.5),
      color: style.colors[_random.nextInt(style.colors.length)],
      variant: festiveFlake ? 2 : _random.nextInt(2),
    );
  }

  @override
  Widget build(BuildContext context) {
    final look = widget.look;
    if (look == null) return widget.child;

    final style = _style(look);
    final dark = Theme.of(context).brightness == Brightness.dark;
    final tint = widget.plainBackground
        ? null
        : dark
            ? style.hue.withValues(alpha: 0.08)
            : style.lightTint.withValues(alpha: 0.6);

    return LayoutBuilder(
      builder: (context, constraints) {
        _ensureGovernor(constraints.biggest);
        return Stack(
          children: [
            Positioned.fill(
              child: IgnorePointer(
                child: RepaintBoundary(
                  child: CustomPaint(
                    painter: _BackdropPainter(
                      repaint: _repaint,
                      particles: _particles,
                      style: style,
                      tint: tint,
                      outlineSnow: !dark,
                    ),
                  ),
                ),
              ),
            ),
            widget.child,
          ],
        );
      },
    );
  }
}

// ---------------------------------------------------------------- стиль

enum _Shape { leaf, snow, petal, sparkle }

class _SeasonStyle {
  const _SeasonStyle({
    required this.shape,
    required this.colors,
    required this.lightTint,
    required this.hue,
    required this.size,
    required this.speed,
    this.rises = false,
    this.densityFactor = 1,
    this.fancyFlakes = false,
  });

  final _Shape shape;
  final List<Color> colors;

  /// Подложка в светлой теме.
  final Color lightTint;

  /// Цвет сезона — им слегка подкрашивается тёмная тема.
  final Color hue;
  final (double, double) size;

  /// Скорость, логических пикселей в секунду.
  final (double, double) speed;

  /// Летит вверх, а не падает — летние блики.
  final bool rises;
  final double densityFactor;

  /// Узорчатые снежинки вперемешку с простыми — под Новый год.
  final bool fancyFlakes;
}

_SeasonStyle _style(SeasonLook look) => switch (look.season) {
      Season.autumn => const _SeasonStyle(
          shape: _Shape.leaf,
          colors: [
            Color(0xFFD2551A),
            Color(0xFFE8871E),
            Color(0xFFF2B233),
            Color(0xFFB8431A),
          ],
          lightTint: Color(0xFFFCECD1),
          hue: Color(0xFFE8871E),
          size: (9, 16),
          speed: (28, 55),
        ),
      Season.winter => _SeasonStyle(
          shape: _Shape.snow,
          colors: const [Color(0xFFFFFFFF), Color(0xFFEAF3FB)],
          // Насыщеннее прочих сезонов: белый снег на бледном фоне теряется.
          lightTint: const Color(0xFFD3E4F4),
          hue: const Color(0xFF6FA8DC),
          size: (2.5, 5),
          speed: (18, 40),
          // Под Новый год снега погуще и снежинки узорчатые.
          densityFactor: look.festive ? 1.6 : 1,
          fancyFlakes: look.festive,
        ),
      Season.spring => const _SeasonStyle(
          shape: _Shape.petal,
          colors: [Color(0xFFF4B6C8), Color(0xFFEE93B1), Color(0xFFFAD3DE)],
          lightTint: Color(0xFFFDF0F3),
          hue: Color(0xFFEE93B1),
          size: (8, 13),
          speed: (20, 42),
        ),
      Season.summer => const _SeasonStyle(
          shape: _Shape.sparkle,
          colors: [Color(0xFFF6C453), Color(0xFFFBD98A)],
          lightTint: Color(0xFFFFF6DE),
          hue: Color(0xFFF6C453),
          size: (2, 4),
          speed: (8, 18),
          rises: true,
          densityFactor: 0.8,
        ),
    };

// ------------------------------------------------------------- частицы

class _Particle {
  _Particle({
    required this.x,
    required this.y,
    required this.size,
    required this.speed,
    required this.sway,
    required this.frequency,
    required this.phase,
    required this.rotation,
    required this.spin,
    required this.color,
    required this.variant,
  });

  final double x;
  double y;
  final double size;
  final double speed;
  final double sway;
  final double frequency;
  final double phase;
  double rotation;
  final double spin;
  final Color color;

  /// Вариант формы: клён или овальный лист, простая или узорчатая снежинка.
  final int variant;
  double t = 0;
}

class _BackdropPainter extends CustomPainter {
  _BackdropPainter({
    required Listenable repaint,
    required this.particles,
    required this.style,
    required this.tint,
    required this.outlineSnow,
  }) : super(repaint: repaint);

  final List<_Particle> particles;
  final _SeasonStyle style;
  final Color? tint;

  /// На светлом фоне белый снег не виден без тонкого контура.
  final bool outlineSnow;

  static final _fill = Paint()..isAntiAlias = true;
  static final _stroke = Paint()
    ..isAntiAlias = true
    ..style = PaintingStyle.stroke;

  /// Кленовый лист единичного размера — строится один раз.
  static final Path _maple = () {
    final path = Path()..moveTo(0, -1);
    for (var i = 0; i < 5; i++) {
      final a = -math.pi / 2 + i * 2 * math.pi / 5;
      final b = a + math.pi / 5;
      path
        ..lineTo(math.cos(a), math.sin(a))
        ..lineTo(math.cos(b) * 0.45, math.sin(b) * 0.45);
    }
    return path..close();
  }();

  static final Path _oval = Path()
    ..addOval(Rect.fromCenter(center: Offset.zero, width: 1, height: 2));

  @override
  void paint(Canvas canvas, Size size) {
    final tint = this.tint;
    if (tint != null) {
      canvas.drawRect(Offset.zero & size, _fill..color = tint);
    }

    for (final p in particles) {
      final dx = p.x + math.sin(p.t * p.frequency + p.phase) * p.sway;
      canvas.save();
      canvas.translate(dx, p.y);
      switch (style.shape) {
        case _Shape.leaf:
          _paintLeaf(canvas, p);
        case _Shape.petal:
          _paintPetal(canvas, p);
        case _Shape.snow:
          _paintSnow(canvas, p);
        case _Shape.sparkle:
          _paintSparkle(canvas, p);
      }
      canvas.restore();
    }
  }

  /// Лист «переворачивается» в полёте: его сжимают по одной оси синусом.
  void _flip(Canvas canvas, _Particle p) {
    canvas.rotate(p.rotation);
    canvas.scale(math.cos(p.t * p.frequency * 1.6 + p.phase), 1);
  }

  void _paintLeaf(Canvas canvas, _Particle p) {
    _flip(canvas, p);
    canvas.scale(p.size, p.size);
    canvas.drawPath(p.variant == 0 ? _maple : _oval, _fill..color = p.color);
    canvas.drawLine(
      const Offset(0, -0.8),
      const Offset(0, 0.9),
      _stroke
        ..color = const Color(0x595A280A)
        ..strokeWidth = 1 / p.size,
    );
  }

  void _paintPetal(Canvas canvas, _Particle p) {
    _flip(canvas, p);
    canvas.drawOval(
      Rect.fromCenter(center: Offset.zero, width: p.size * 0.9, height: p.size * 1.6),
      _fill..color = p.color,
    );
  }

  void _paintSnow(Canvas canvas, _Particle p) {
    if (p.variant == 2) {
      // Узорчатая снежинка: шесть лучей с веточками.
      canvas.rotate(p.rotation);
      _stroke
        ..color = outlineSnow ? const Color(0xFF9CC0E0) : p.color
        ..strokeWidth = 1.2
        ..strokeCap = StrokeCap.round;
      for (var i = 0; i < 6; i++) {
        canvas.drawLine(Offset.zero, Offset(0, -p.size), _stroke);
        canvas.drawLine(Offset(0, -p.size * 0.55),
            Offset(p.size * 0.25, -p.size * 0.8), _stroke);
        canvas.drawLine(Offset(0, -p.size * 0.55),
            Offset(-p.size * 0.25, -p.size * 0.8), _stroke);
        canvas.rotate(math.pi / 3);
      }
      return;
    }
    canvas.drawCircle(Offset.zero, p.size, _fill..color = p.color);
    if (outlineSnow) {
      canvas.drawCircle(
        Offset.zero,
        p.size,
        _stroke
          ..color = const Color(0xFF8FB4DA)
          ..strokeWidth = 1,
      );
    }
  }

  void _paintSparkle(Canvas canvas, _Particle p) {
    final pulse = 0.55 + 0.35 * math.sin(p.t * 2 + p.phase);
    canvas.drawCircle(
      Offset.zero,
      p.size,
      _fill..color = p.color.withValues(alpha: pulse.clamp(0.0, 1.0)),
    );
  }

  @override
  bool shouldRepaint(covariant _BackdropPainter old) =>
      old.style != style || old.tint != tint || old.outlineSnow != outlineSnow;
}

/// Для тестов: цвет подложки сезона в светлой теме.
@visibleForTesting
Color seasonLightTint(SeasonLook look) => _style(look).lightTint;

/// Для тестов: во сколько раз гуще частицы этого сезона.
@visibleForTesting
double seasonDensityFactor(SeasonLook look) => _style(look).densityFactor;
