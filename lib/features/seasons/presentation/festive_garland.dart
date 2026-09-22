import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

/// Новогодняя гирлянда над расписанием и поздравление под ней.
///
/// Лампочки мигают, только если включены движущиеся объекты и система не
/// просит убрать анимации. Иначе горят ровно — праздник остаётся, а
/// мельтешения нет.
class FestiveGarland extends StatefulWidget {
  const FestiveGarland({
    super.key,
    required this.greeting,
    required this.motion,
  });

  final String greeting;
  final bool motion;

  static const height = 46.0;

  @override
  State<FestiveGarland> createState() => _FestiveGarlandState();
}

class _FestiveGarlandState extends State<FestiveGarland>
    with SingleTickerProviderStateMixin {
  late final Ticker _ticker = createTicker(_onTick);
  final _time = ValueNotifier<double>(0);

  bool get _twinkle =>
      widget.motion && !MediaQuery.disableAnimationsOf(context);

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _sync();
  }

  @override
  void didUpdateWidget(covariant FestiveGarland oldWidget) {
    super.didUpdateWidget(oldWidget);
    _sync();
  }

  void _sync() {
    if (_twinkle && !_ticker.isActive) {
      _ticker.start();
    } else if (!_twinkle && _ticker.isActive) {
      _ticker.stop();
      _time.value = 0;
    }
  }

  void _onTick(Duration elapsed) =>
      _time.value = elapsed.inMicroseconds / 1e6;

  @override
  void dispose() {
    _ticker.dispose();
    _time.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return SizedBox(
      height: FestiveGarland.height,
      child: Stack(
        children: [
          Positioned.fill(
            bottom: 18,
            child: IgnorePointer(
              child: CustomPaint(
                painter: _GarlandPainter(
                  time: _time,
                  twinkle: _twinkle,
                  wire: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.5),
                ),
              ),
            ),
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: Text(
              widget.greeting,
              style: theme.textTheme.labelMedium?.copyWith(
                color: theme.colorScheme.primary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _GarlandPainter extends CustomPainter {
  _GarlandPainter({
    required this.time,
    required this.twinkle,
    required this.wire,
  }) : super(repaint: time);

  final ValueNotifier<double> time;
  final bool twinkle;
  final Color wire;

  static const _colors = [
    Color(0xFFE53935),
    Color(0xFFFFC107),
    Color(0xFF43A047),
    Color(0xFF1E88E5),
  ];

  /// Расстояние между точками, где провод крепится, и между лампочками.
  static const _span = 72.0;
  static const _bulbStep = 18.0;

  @override
  void paint(Canvas canvas, Size size) {
    if (size.width <= 0) return;
    final sag = size.height * 0.55;
    const top = 3.0;

    // Высота провода в точке x: провисает дугой между креплениями.
    double wireY(double x) {
      final phase = (x % _span) / _span;
      return top + sag * math.sin(phase * math.pi);
    }

    final wirePaint = Paint()
      ..color = wire
      ..strokeWidth = 1.2
      ..style = PaintingStyle.stroke;
    final path = Path()..moveTo(0, wireY(0));
    for (var x = 2.0; x <= size.width; x += 2) {
      path.lineTo(x, wireY(x));
    }
    canvas.drawPath(path, wirePaint);

    final t = time.value;
    final bulb = Paint();
    var index = 0;
    for (var x = _bulbStep / 2; x < size.width; x += _bulbStep, index++) {
      final color = _colors[index % _colors.length];
      // У каждой лампочки своя фаза — мигают вразнобой, а не хором.
      final glow = twinkle
          ? 0.55 + 0.45 * math.sin(t * 2.4 + index * 1.7)
          : 1.0;
      final y = wireY(x) + 5;
      canvas.drawCircle(
        Offset(x, y),
        6,
        bulb..color = color.withValues(alpha: 0.18 * glow),
      );
      canvas.drawOval(
        Rect.fromCenter(center: Offset(x, y), width: 6, height: 8),
        bulb..color = color.withValues(alpha: 0.45 + 0.55 * glow),
      );
    }
  }

  @override
  bool shouldRepaint(covariant _GarlandPainter old) =>
      old.twinkle != twinkle || old.wire != wire;
}
