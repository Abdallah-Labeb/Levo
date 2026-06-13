import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:levo/app/theme/app_colors.dart';
import 'package:levo/app/theme/app_dimensions.dart';
import 'package:levo/features/spirit_level/bloc/spirit_level_state.dart';

/// A 1D horizontal edge level widget simulating a physical cylindrical glass vial.
class BubbleLevel1dWidget extends StatefulWidget {
  const BubbleLevel1dWidget({
    super.key,
    required this.roll,
    required this.status,
  });

  final double roll;
  final LevelStatus status;

  @override
  State<BubbleLevel1dWidget> createState() => _BubbleLevel1dWidgetState();
}

class _BubbleLevel1dWidgetState extends State<BubbleLevel1dWidget>
    with SingleTickerProviderStateMixin {
  late final Ticker _ticker;
  double _x = 0.0; // Bubble offset from center (-1.0 to 1.0)
  double _vx = 0.0; // Bubble velocity
  Duration _lastElapsed = Duration.zero;

  @override
  void initState() {
    super.initState();
    _ticker = createTicker(_onTick);
    _ticker.start();
  }

  @override
  void dispose() {
    _ticker.dispose();
    super.dispose();
  }

  void _onTick(Duration elapsed) {
    if (!mounted) return;

    if (_lastElapsed == Duration.zero) {
      _lastElapsed = elapsed;
      return;
    }

    double dt =
        (elapsed.inMicroseconds - _lastElapsed.inMicroseconds) / 1000000.0;
    _lastElapsed = elapsed;

    if (dt > 0.03) dt = 0.03;
    if (dt <= 0) return;

    // Spring constants
    const double stiffness = 120.0;
    const double damping = 18.0;

    // Max angle for deflection = 6.0 degrees
    const double maxAngle = 6.0;

    // Roll controls bubble movement along x-axis.
    // positive roll -> bubble shifts left (negative x).
    double targetX = -widget.roll / maxAngle;

    // Constrain target to boundary
    if (targetX.abs() > 1.0) {
      targetX = targetX.sign;
    }

    // Spring equations
    final double ax = stiffness * (targetX - _x) - damping * _vx;
    _vx += ax * dt;
    _x += _vx * dt;

    // Bound current position
    if (_x.abs() > 1.0) {
      _x = _x.sign;
      _vx = 0.0;
    }

    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final glowColor = widget.status == LevelStatus.level
        ? AppColors.kLevelGreen.withAlpha(40)
        : (widget.status == LevelStatus.close
              ? AppColors.kWarningYellow.withAlpha(25)
              : Colors.transparent);

    final borderColor = widget.status == LevelStatus.level
        ? AppColors.kLevelGreen
        : (widget.status == LevelStatus.close
              ? AppColors.kWarningYellow
              : AppColors.kChromeMid);

    return AnimatedContainer(
      duration: const Duration(milliseconds: 250),
      width: double.infinity,
      height: 80,
      margin: const EdgeInsets.symmetric(horizontal: AppDimensions.paddingL),
      decoration: BoxDecoration(
        color: AppColors.kSurfaceInset,
        border: Border.all(color: borderColor, width: 2.0),
        borderRadius: BorderRadius.circular(AppDimensions.radiusPanel),
        boxShadow: [
          BoxShadow(color: glowColor, blurRadius: 15.0, spreadRadius: 1.0),
          const BoxShadow(
            color: Color(0x77000000),
            offset: Offset(0, 4),
            blurRadius: 8.0,
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(AppDimensions.radiusPanel - 2),
        child: CustomPaint(
          painter: BubbleLevel1dPainter(x: _x, status: widget.status),
        ),
      ),
    );
  }
}

class BubbleLevel1dPainter extends CustomPainter {
  const BubbleLevel1dPainter({required this.x, required this.status});

  final double x;
  final LevelStatus status;

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Rect.fromLTWH(0, 0, size.width, size.height);
    final centerY = size.height / 2;
    final centerX = size.width / 2;

    // Draw background fluid tint
    final bgPaint = Paint()
      ..shader = const LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          Color(0xFF0F1A12),
          Color(0xFF060B08),
          Color(0xFF0C160E),
        ],
        stops: [0.0, 0.5, 1.0],
      ).createShader(rect);
    canvas.drawRect(rect, bgPaint);

    // Draw tube inner wall highlights (3D glass tube look)
    final wallPaint = Paint()
      ..color = Colors.white.withAlpha(20)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;
    canvas.drawLine(const Offset(0, 5), Offset(size.width, 5), wallPaint);
    canvas.drawLine(
      Offset(0, size.height - 5),
      Offset(size.width, size.height - 5),
      wallPaint,
    );

    // Draw level guidelines (two lines near center for target alignment)
    final linePaint = Paint()
      ..color = (status == LevelStatus.level
          ? AppColors.kLevelGreen.withAlpha(180)
          : AppColors.kChromeMid.withAlpha(100))
      ..strokeWidth = 2.0;

    // Center zone markings (e.g. 20 pixels apart)
    const double targetWidth = 35.0;
    canvas.drawLine(
      Offset(centerX - targetWidth / 2, 4),
      Offset(centerX - targetWidth / 2, size.height - 4),
      linePaint,
    );
    canvas.drawLine(
      Offset(centerX + targetWidth / 2, 4),
      Offset(centerX + targetWidth / 2, size.height - 4),
      linePaint,
    );

    // Draw secondary tick marks
    final tickPaint = Paint()
      ..color = AppColors.kChromeDark.withAlpha(100)
      ..strokeWidth = 1.0;
    for (int i = -3; i <= 3; i++) {
      if (i == 0) continue;
      final double dx = centerX + i * 50.0;
      canvas.drawLine(Offset(dx, 8), Offset(dx, size.height - 8), tickPaint);
    }

    // Calculate bubble position
    const double bubbleWidth = 45.0;
    const double bubbleHeight = 28.0;
    final double maxMovement = (size.width - bubbleWidth - 20) / 2;
    final double bubbleCenterX = centerX + x * maxMovement;
    final Rect bubbleRect = Rect.fromCenter(
      center: Offset(bubbleCenterX, centerY),
      width: bubbleWidth,
      height: bubbleHeight,
    );

    // Determine bubble color
    final Color bubbleColor = status == LevelStatus.level
        ? AppColors.kLevelGreen
        : (status == LevelStatus.close
              ? AppColors.kWarningYellow
              : const Color(0xFF5AB676));

    final Color bubbleDarkColor = status == LevelStatus.level
        ? const Color(0xFF1E522F)
        : (status == LevelStatus.close
              ? const Color(0xFF524410)
              : const Color(0xFF234C32));

    // Draw bubble capsule
    final RRect bubbleRRect = RRect.fromRectAndRadius(
      bubbleRect,
      const Radius.circular(14),
    );
    final bubblePaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [const Color(0xFFE6FFED), bubbleColor, bubbleDarkColor],
        stops: const [0.0, 0.6, 1.0],
      ).createShader(bubbleRect);
    canvas.drawRRect(bubbleRRect, bubblePaint);

    // Draw specular glare highlight inside bubble capsule
    final specularPaint = Paint()..color = Colors.white.withAlpha(200);
    final RRect specularRRect = RRect.fromRectAndRadius(
      Rect.fromLTWH(
        bubbleRect.left + 5,
        bubbleRect.top + 3,
        bubbleWidth - 10,
        4,
      ),
      const Radius.circular(2),
    );
    canvas.drawRRect(specularRRect, specularPaint);

    // Draw outer reflections on tube (light reflection spanning across horizontal tube)
    final glassShinePaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          Colors.white.withAlpha(35),
          Colors.white.withAlpha(0),
          Colors.white.withAlpha(0),
          Colors.white.withAlpha(15),
        ],
        stops: const [0.0, 0.25, 0.85, 1.0],
      ).createShader(rect);
    canvas.drawRect(rect, glassShinePaint);
  }

  @override
  bool shouldRepaint(covariant BubbleLevel1dPainter oldDelegate) {
    return oldDelegate.x != x || oldDelegate.status != status;
  }
}
