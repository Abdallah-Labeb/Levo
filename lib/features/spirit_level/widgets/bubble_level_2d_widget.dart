import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:levo/app/theme/app_colors.dart';
import 'package:levo/app/theme/app_dimensions.dart';
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

    double dt = (elapsed.inMicroseconds - _lastElapsed.inMicroseconds) / 1000000.0;
    _lastElapsed = elapsed;

    // Cap time steps to prevent numerical explosion during lag spikes
    if (dt > 0.03) dt = 0.03;
    if (dt <= 0) return;

    // Spring properties
    const double stiffness = 120.0;
    const double damping = 18.0;

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

    return AnimatedContainer(
      duration: const Duration(milliseconds: 250),
      width: 240,
      height: 240,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: AppColors.kSurfaceInset,
        border: Border.all(color: borderColor, width: 2.0),
        boxShadow: [
          BoxShadow(
            color: glowColor,
            blurRadius: 20.0,
            spreadRadius: 2.0,
          ),
          const BoxShadow(
            color: Color(0x99000000),
            offset: Offset(2, 6),
            blurRadius: 10.0,
          ),
        ],
      ),
      child: Center(
        child: SizedBox(
          width: 220,
          height: 220,
          child: CustomPaint(
            painter: BubbleLevel2dPainter(
              x: _x,
              y: _y,
              status: widget.status,
            ),
          ),
        ),
      ),
    );
  }
}

class BubbleLevel2dPainter extends CustomPainter {
  const BubbleLevel2dPainter({
    required this.x,
    required this.y,
    required this.status,
  });

  final double x;
  final double y;
  final LevelStatus status;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final outerRadius = size.width / 2;

    // Draw background fluid container (dark-green tint fluid glass)
    final bgPaint = Paint()
      ..shader = const RadialGradient(
        colors: [
          Color(0xFF0F1A12),
          Color(0xFF070B08),
        ],
      ).createShader(Rect.fromCircle(center: center, radius: outerRadius));
    canvas.drawCircle(center, outerRadius, bgPaint);

    // Draw grid rings (concentric target rings)
    final ringPaint = Paint()
      ..color = AppColors.kChromeDark.withAlpha(120)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;

    // Perfect Center Target
    final centerTargetPaint = Paint()
      ..color = (status == LevelStatus.level
          ? AppColors.kLevelGreen.withAlpha(150)
          : AppColors.kChromeMid.withAlpha(80))
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;
    
    canvas.drawCircle(center, 20.0, centerTargetPaint); // 1-deg ring
    canvas.drawCircle(center, 50.0, ringPaint);        // 2.5-deg ring
    canvas.drawCircle(center, 90.0, ringPaint);        // 5-deg ring

    // Draw crosshair lines
    canvas.drawLine(
      Offset(center.dx - outerRadius + 10, center.dy),
      Offset(center.dx + outerRadius - 10, center.dy),
      ringPaint,
    );
    canvas.drawLine(
      Offset(center.dx, center.dy - outerRadius + 10),
      Offset(center.dx, center.dy + outerRadius - 10),
      ringPaint,
    );

    // Calculate bubble position
    // Bubble max translation distance: outer radius minus bubble radius minus wall buffer
    const double bubbleRadius = 25.0;
    final double maxMovement = outerRadius - bubbleRadius - 8.0;
    final Offset bubbleCenter = Offset(
      center.dx + x * maxMovement,
      center.dy + y * maxMovement,
    );

    // Determine bubble colors based on level status
    final Color bubbleBaseColor = status == LevelStatus.level
        ? AppColors.kLevelGreen
        : (status == LevelStatus.close ? AppColors.kWarningYellow : const Color(0xFF5AB676));

    final Color bubbleDarkColor = status == LevelStatus.level
        ? const Color(0xFF1E522F)
        : (status == LevelStatus.close ? const Color(0xFF524410) : const Color(0xFF234C32));

    // Draw the bubble 3D gradient
    final bubblePaint = Paint()
      ..shader = RadialGradient(
        center: const Alignment(-0.25, -0.25), // light source top-left
        colors: [
          const Color(0xFFE6FFED),
          bubbleBaseColor,
          bubbleDarkColor,
        ],
        stops: const [0.0, 0.65, 1.0],
      ).createShader(Rect.fromCircle(center: bubbleCenter, radius: bubbleRadius));
    canvas.drawCircle(bubbleCenter, bubbleRadius, bubblePaint);

    // Draw specular reflection highlight on the bubble
    final specularPaint = Paint()
      ..color = Colors.white.withAlpha(220)
      ..style = PaintingStyle.fill;
    canvas.drawCircle(
      Offset(bubbleCenter.dx - bubbleRadius * 0.3, bubbleCenter.dy - bubbleRadius * 0.3),
      bubbleRadius * 0.2,
      specularPaint,
    );

    // Draw outer glass glare overlay (half-moon shine on top right/left)
    final glassPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          Colors.white.withAlpha(40),
          Colors.white.withAlpha(0),
        ],
      ).createShader(Rect.fromCircle(center: center, radius: outerRadius));
    canvas.drawCircle(center, outerRadius, glassPaint);

    final glassBorderPaint = Paint()
      ..color = Colors.white.withAlpha(25)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;
    canvas.drawCircle(center, outerRadius - 1.0, glassBorderPaint);
  }

  @override
  bool shouldRepaint(covariant BubbleLevel2dPainter oldDelegate) {
    return oldDelegate.x != x || oldDelegate.y != y || oldDelegate.status != status;
  }
}
