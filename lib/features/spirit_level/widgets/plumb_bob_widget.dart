import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:levo/app/theme/app_colors.dart';
import 'package:levo/app/theme/app_dimensions.dart';
import 'package:levo/features/spirit_level/bloc/spirit_level_state.dart';

/// A Plumb Bob visualization that simulates a heavy metallic weight hanging from a string.
/// The bob sways on a 2D projection based on roll (left-right) and pitch (depth/y-axis).
class PlumbBobWidget extends StatefulWidget {
  const PlumbBobWidget({
    super.key,
    required this.pitch,
    required this.roll,
    required this.status,
  });

  final double pitch;
  final double roll;
  final LevelStatus status;

  @override
  State<PlumbBobWidget> createState() => _PlumbBobWidgetState();
}

class _PlumbBobWidgetState extends State<PlumbBobWidget>
    with SingleTickerProviderStateMixin {
  late final Ticker _ticker;

  // Angular pendulum state (roll axis)
  double _theta = 0.0;
  double _omega = 0.0;

  // Length extension state (pitch axis)
  double _dy = 0.0;
  double _vy = 0.0;

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

    // String angular oscillation physics
    const double stiffnessAngle = 100.0;
    const double dampingAngle = 12.0;

    // Target angle (in radians) is determined by the negative roll
    final double targetTheta = -widget.roll * math.pi / 180.0;

    final double torque =
        stiffnessAngle * (targetTheta - _theta) - dampingAngle * _omega;
    _omega += torque * dt;
    _theta += _omega * dt;

    // Vertical stretch physics (projecting pitch)
    const double stiffnessY = 80.0;
    const double dampingY = 10.0;

    // Pitch tilts forward/backward. Positive pitch pulls the string down.
    final double targetDy = widget.pitch * 1.5;

    final double ay = stiffnessY * (targetDy - _dy) - dampingY * _vy;
    _vy += ay * dt;
    _dy += _vy * dt;

    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final glowColor = widget.status == LevelStatus.level
        ? AppColors.kLevelGreen.withAlpha(45)
        : (widget.status == LevelStatus.close
              ? AppColors.kWarningYellow.withAlpha(20)
              : Colors.transparent);

    final targetBorderColor = widget.status == LevelStatus.level
        ? AppColors.kLevelGreen
        : (widget.status == LevelStatus.close
              ? AppColors.kWarningYellow
              : AppColors.kChromeDark);

    return Expanded(
      child: Padding(
        padding: const EdgeInsets.all(AppDimensions.paddingL),
        child: Container(
          decoration: BoxDecoration(
            color: AppColors.kSurfaceInset,
            border: Border.all(color: AppColors.kBorderHighlight, width: 1.0),
            borderRadius: BorderRadius.circular(AppDimensions.radiusPanel),
            boxShadow: const [
              BoxShadow(
                color: Color(0x55000000),
                blurRadius: 10,
                offset: Offset(0, 4),
              ),
            ],
          ),
          child: LayoutBuilder(
            builder: (context, constraints) {
              return Stack(
                children: [
                  // Circular alignment crosshair at the resting point
                  Positioned(
                    left: constraints.maxWidth / 2 - 25,
                    bottom: 40 - 25 + 15, // centered around resting bob tip
                    child: Container(
                      width: 50,
                      height: 50,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: targetBorderColor,
                          width: 2.0,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: glowColor,
                            blurRadius: 10,
                            spreadRadius: 1.0,
                          ),
                        ],
                      ),
                      child: Center(
                        child: Container(
                          width: 8,
                          height: 8,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: targetBorderColor.withAlpha(150),
                          ),
                        ),
                      ),
                    ),
                  ),
                  CustomPaint(
                    size: Size(constraints.maxWidth, constraints.maxHeight),
                    painter: PlumbBobPainter(
                      theta: _theta,
                      dy: _dy,
                      status: widget.status,
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}

class PlumbBobPainter extends CustomPainter {
  PlumbBobPainter({
    required this.theta,
    required this.dy,
    required this.status,
  });

  final double theta;
  final double dy;
  final LevelStatus status;

  final Paint pegPaint = Paint();
  final Paint shadowPaint = Paint();
  final Paint stringPaint = Paint();
  final Paint bobShadowPaint = Paint();
  final Paint bobFillPaint = Paint();
  final Paint collarPaint = Paint();
  final Paint loopPaint = Paint();

  @override
  void paint(Canvas canvas, Size size) {
    final double startX = size.width / 2;
    const double startY = 15.0; // hanging point anchor

    // Set pendulum string length
    // Leave some space at the bottom (e.g. 80 pixels)
    final double baseLength = size.height - startY - 80.0;
    final double length = baseLength + dy;

    // Calculate bob center position
    final double bobCenterX = startX + length * math.sin(theta);
    final double bobCenterY = startY + length * math.cos(theta);

    // Draw suspension peg at the top center
    pegPaint.shader = const RadialGradient(
      colors: [AppColors.kChromeLight, AppColors.kChromeDark],
    ).createShader(
      Rect.fromCircle(center: Offset(startX, startY), radius: 6.0),
    );
    canvas.drawCircle(Offset(startX, startY), 6.0, pegPaint);

    // Draw pendulum string line (machined dark thread shadow + thread line)
    shadowPaint
      ..color = Colors.black.withAlpha(120)
      ..strokeWidth = 1.5;
    // Offset shadow slightly to the right-bottom
    canvas.drawLine(
      Offset(startX + 2.0, startY + 2.0),
      Offset(bobCenterX + 2.0, bobCenterY + 2.0),
      shadowPaint,
    );

    stringPaint
      ..color = AppColors.kChromeMid
      ..strokeWidth = 1.2;
    canvas.drawLine(
      Offset(startX, startY),
      Offset(bobCenterX, bobCenterY),
      stringPaint,
    );

    // Draw the brass weight (teardrop Bob shape)
    // Height & width of the bob weight
    const double bobWidth = 36.0;
    const double bobHeight = 55.0;

    canvas.save();
    canvas.translate(bobCenterX, bobCenterY);
    // Rotate the bob structure to align with the string angle
    canvas.rotate(theta);

    // Draw a shadow for the bob shape
    bobShadowPaint
      ..color = Colors.black.withAlpha(100)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4.0);

    final Path bobPath = _getTeardropPath(bobWidth, bobHeight);
    canvas.drawPath(bobPath.shift(const Offset(3, 4)), bobShadowPaint);

    // Fill brass bob
    bobFillPaint.shader = const RadialGradient(
      center: Alignment(-0.25, -0.3),
      colors: [
        Color(0xFFFFF0B3), // highlight
        Color(0xFFDFB831), // brass mid
        Color(0xFF7A610B), // brass dark shade
      ],
      stops: [0.0, 0.55, 1.0],
    ).createShader(
      Rect.fromCenter(
        center: Offset.zero,
        width: bobWidth,
        height: bobHeight,
      ),
    );
    canvas.drawPath(bobPath, bobFillPaint);

    // Draw brass tip highlight or collar lines
    collarPaint
      ..color = const Color(0xFF665108)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;
    canvas.drawLine(
      const Offset(-bobWidth / 4, -bobHeight / 4),
      const Offset(bobWidth / 4, -bobHeight / 4),
      collarPaint,
    );

    // Draw small attachment loop at top of bob
    loopPaint
      ..color = AppColors.kChromeMid
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;
    canvas.drawCircle(const Offset(0, -bobHeight / 2 - 2), 3.0, loopPaint);

    canvas.restore();
  }

  Path _getTeardropPath(double w, double h) {
    final Path path = Path();
    // Start at bottom sharp tip pointing straight down
    path.moveTo(0, h / 2);
    // Left curve going up to the rounded top head
    path.cubicTo(-w / 2, h / 6, -w / 2, -h / 2, 0, -h / 2);
    // Right curve going back down to the tip
    path.cubicTo(w / 2, -h / 2, w / 2, h / 6, 0, h / 2);
    path.close();
    return path;
  }

  @override
  bool shouldRepaint(covariant PlumbBobPainter oldDelegate) {
    return oldDelegate.theta != theta ||
        oldDelegate.dy != dy ||
        oldDelegate.status != status;
  }
}
