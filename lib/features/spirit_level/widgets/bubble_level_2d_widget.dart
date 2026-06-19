import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:levo/app/theme/app_animations.dart';
import 'package:levo/app/theme/app_colors.dart';
import 'package:levo/features/spirit_level/bloc/spirit_level_state.dart';

/// A 2D circular bubble level utilizing spring physics to simulate fluid movement.
class BubbleLevel2dWidget extends StatefulWidget {
  const BubbleLevel2dWidget({
    super.key,
    required this.pitch,
    required this.roll,
    required this.status,
  });

  final double pitch;
  final double roll;
  final LevelStatus status;

  @override
  State<BubbleLevel2dWidget> createState() => _BubbleLevel2dWidgetState();
}

class _BubbleLevel2dWidgetState extends State<BubbleLevel2dWidget>
    with SingleTickerProviderStateMixin {
  late final Ticker _ticker;
  double _x = 0.0; // Current position x relative to center (-1.0 to 1.0)
  double _y = 0.0; // Current position y relative to center (-1.0 to 1.0)
  double _vx = 0.0; // Velocity x
  double _vy = 0.0; // Velocity y
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

    // Cap time steps to prevent numerical explosion during lag spikes
    if (dt > 0.03) dt = 0.03;
    if (dt <= 0) return;

    // Spring properties
    const double stiffness = 50.0;
    const double damping = 9.0;

    // Target positions mapped from pitch and roll.
    // Let's map a tilt of 6.0 degrees to the maximum edge of the vial.
    const double maxAngle = 6.0;

    // Roll controls horizontal (x), pitch controls vertical (y).
    // Tilting right (positive roll) shifts bubble left (negative x).
    // Tilting forward (positive pitch) shifts bubble down (positive y).
    double targetX = -widget.roll / maxAngle;
    double targetY = widget.pitch / maxAngle;

    // Restrict the target to a unit circle (maximum deflection = 1.0)
    double targetDist = math.sqrt(targetX * targetX + targetY * targetY);
    if (targetDist > 1.0) {
      targetX /= targetDist;
      targetY /= targetDist;
    }

    // Euler integration of the mass-spring-damper system:
    // F = -k*x - c*v
    final double ax = stiffness * (targetX - _x) - damping * _vx;
    final double ay = stiffness * (targetY - _y) - damping * _vy;

    _vx += ax * dt;
    _vy += ay * dt;
    _x += _vx * dt;
    _y += _vy * dt;

    // Bound the bubble within the circular limit
    final double currentDist = math.sqrt(_x * _x + _y * _y);
    if (currentDist > 1.0) {
      _x /= currentDist;
      _y /= currentDist;
      _vx = 0; // Reset velocity in case of hard wall collision
      _vy = 0;
    }

    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    // Determine outer ring glow color based on LevelStatus
    final glowColor = widget.status == LevelStatus.level
        ? AppColors.kLevelGreen.withAlpha(51) // Glow green
        : (widget.status == LevelStatus.close
              ? AppColors.kWarningYellow.withAlpha(30)
              : Colors.transparent);

    final borderColor = widget.status == LevelStatus.level
        ? AppColors.kLevelGreen
        : (widget.status == LevelStatus.close
              ? AppColors.kWarningYellow
              : AppColors.kChromeMid);

    return LayoutBuilder(
      builder: (context, constraints) {
        final double size = math.min(
          math.min(constraints.maxWidth, constraints.maxHeight),
          240.0,
        );
        final double innerSize = size - 20.0;

        return AnimatedContainer(
          duration: AppAnimations.bubbleSnap,
          width: size,
          height: size,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: AppColors.kSurfaceInset,
            border: Border.all(color: borderColor, width: 2.0),
            boxShadow: [
              BoxShadow(color: glowColor, blurRadius: size * 0.08, spreadRadius: 2.0),
              const BoxShadow(
                color: Color(0x99000000),
                offset: Offset(2, 6),
                blurRadius: 10.0,
              ),
            ],
          ),
          child: Center(
            child: SizedBox(
              width: innerSize,
              height: innerSize,
              child: CustomPaint(
                painter: BubbleLevel2dPainter(x: _x, y: _y, status: widget.status),
              ),
            ),
          ),
        );
      },
    );
  }
}

class BubbleLevel2dPainter extends CustomPainter {
  BubbleLevel2dPainter({
    required this.x,
    required this.y,
    required this.status,
  });

  final double x;
  final double y;
  final LevelStatus status;

  // Pre-allocated Paint objects to avoid memory allocations inside paint()
  final Paint _bgPaint = Paint();
  final Paint _ringPaint = Paint()
    ..style = PaintingStyle.stroke
    ..strokeWidth = 1.0;
  final Paint _centerTargetPaint = Paint()
    ..style = PaintingStyle.stroke
    ..strokeWidth = 1.8;
  final Paint _bubbleFillPaint = Paint();
  final Paint _bubbleOuterBorderPaint = Paint()
    ..style = PaintingStyle.stroke
    ..strokeWidth = 1.5;
  final Paint _bubbleBorderPaint = Paint()
    ..style = PaintingStyle.stroke
    ..strokeWidth = 1.0;
  final Paint _bubbleInnerReflectPaint = Paint()
    ..style = PaintingStyle.stroke
    ..strokeWidth = 0.8;
  final Paint _bubbleSpecularPaint = Paint();
  final Paint _glassShinePaint = Paint();
  final Paint _glassBorderPaint = Paint()
    ..style = PaintingStyle.stroke
    ..strokeWidth = 1.5;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final outerRadius = size.width / 2;
    final Rect boundaryRect = Rect.fromCircle(center: center, radius: outerRadius);

    // 1. Draw background fluid container (Option 3A: Glowing neon-lime fluid)
    _bgPaint.shader = const RadialGradient(
      colors: [
        AppColors.kVialFluidMid,
        AppColors.kVialFluidLowerMid,
        AppColors.kVialFluidBottom,
      ],
      stops: [0.0, 0.6, 1.0],
    ).createShader(boundaryRect);
    canvas.drawCircle(center, outerRadius, _bgPaint);

    // 2. Draw grid rings (Option 3A: Black concentric target rings)
    _ringPaint.color = AppColors.kBlack.withAlpha(90);
    _centerTargetPaint.color = AppColors.kBlack.withAlpha(200);

    canvas.drawCircle(center, 25.0, _centerTargetPaint); // Center target ring (matches bubble radius)
    canvas.drawCircle(center, 50.0, _ringPaint);         // 2.5-deg ring
    canvas.drawCircle(center, 90.0, _ringPaint);         // 5-deg ring

    // 3. Draw black crosshair lines
    canvas.drawLine(
      Offset(center.dx - outerRadius + 10.0, center.dy),
      Offset(center.dx + outerRadius - 10.0, center.dy),
      _ringPaint,
    );
    canvas.drawLine(
      Offset(center.dx, center.dy - outerRadius + 10.0),
      Offset(center.dx, center.dy + outerRadius - 10.0),
      _ringPaint,
    );

    // 4. Calculate bubble position
    const double bubbleRadius = 25.0;
    final double maxMovement = outerRadius - bubbleRadius - 8.0;
    final Offset bubbleCenter = Offset(
      center.dx + x * maxMovement,
      center.dy + y * maxMovement,
    );
    final Rect bubbleRect = Rect.fromCircle(center: bubbleCenter, radius: bubbleRadius);

    // Draw bubble clear/transparent air center
    _bubbleFillPaint.shader = RadialGradient(
      center: const Alignment(-0.25, -0.25),
      radius: 0.85,
      colors: [
        Colors.white.withAlpha(150),
        Colors.white.withAlpha(15),
        Colors.transparent,
      ],
      stops: const [0.0, 0.55, 1.0],
    ).createShader(bubbleRect);
    canvas.drawCircle(bubbleCenter, bubbleRadius, _bubbleFillPaint);

    // Draw bubble double boundary (Option 3A: Outer dark border + inner dark border)
    _bubbleOuterBorderPaint.color = AppColors.kVialRefractionDark.withAlpha(200);
    canvas.drawCircle(bubbleCenter, bubbleRadius, _bubbleOuterBorderPaint);

    _bubbleBorderPaint.color = AppColors.kVialRefractionDark.withAlpha(140);
    canvas.drawCircle(bubbleCenter, bubbleRadius - 1.2, _bubbleBorderPaint);

    // Draw secondary inner soft light highlight on the border
    _bubbleInnerReflectPaint.color = AppColors.kVialRefractionLight;
    canvas.drawCircle(bubbleCenter, bubbleRadius - 2.2, _bubbleInnerReflectPaint);

    // Draw primary white glint reflection on top-left of bubble
    _bubbleSpecularPaint.color = Colors.white.withAlpha(220);
    canvas.drawCircle(
      Offset(
        bubbleCenter.dx - bubbleRadius * 0.3,
        bubbleCenter.dy - bubbleRadius * 0.3,
      ),
      bubbleRadius * 0.2,
      _bubbleSpecularPaint,
    );

    // 5. Draw outer glass glare overlay
    _glassShinePaint.shader = const LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: [
        Color(0x2DFFFFFF),
        Color(0x00FFFFFF),
      ],
    ).createShader(boundaryRect);
    canvas.drawCircle(center, outerRadius, _glassShinePaint);

    _glassBorderPaint.color = const Color(0x19FFFFFF);
    canvas.drawCircle(center, outerRadius - 1.0, _glassBorderPaint);
  }

  @override
  bool shouldRepaint(covariant BubbleLevel2dPainter oldDelegate) {
    return oldDelegate.x != x ||
        oldDelegate.y != y ||
        oldDelegate.status != status;
  }
}
