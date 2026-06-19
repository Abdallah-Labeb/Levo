import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:levo/app/theme/app_animations.dart';
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
    const double stiffness = 50.0;
    const double damping = 9.0;

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

    return LayoutBuilder(
      builder: (context, constraints) {
        final double height = math.min(50.0, constraints.maxHeight);

        return AnimatedContainer(
          duration: AppAnimations.bubbleSnap,
          width: double.infinity,
          height: height,
          margin: const EdgeInsets.symmetric(horizontal: AppDimensions.paddingL),
          decoration: BoxDecoration(
            color: AppColors.kSurfaceInset,
            border: Border.all(color: borderColor, width: 2.0),
            borderRadius: BorderRadius.circular(AppDimensions.radiusDisplay),
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
            borderRadius: BorderRadius.circular(AppDimensions.radiusDisplay - 2),
            child: CustomPaint(
              painter: BubbleLevel1dPainter(x: _x, status: widget.status),
            ),
          ),
        );
      },
    );
  }
}

class BubbleLevel1dPainter extends CustomPainter {
  BubbleLevel1dPainter({required this.x, required this.status});

  final double x;
  final LevelStatus status;

  // Pre-allocated Paint objects to avoid memory allocations inside paint()
  final Paint _bgPaint = Paint();
  final Paint _wallPaint = Paint()
    ..style = PaintingStyle.stroke
    ..strokeWidth = 1.0;
  final Paint _linePaint = Paint()..strokeWidth = 2.0;
  final Paint _lineHighlightPaint = Paint()..strokeWidth = 0.8;
  final Paint _tickPaint = Paint()..strokeWidth = 1.0;
  final Paint _bubbleBorderPaint = Paint()
    ..style = PaintingStyle.stroke
    ..strokeWidth = 1.5;
  final Paint _bubbleOuterBorderPaint = Paint()
    ..style = PaintingStyle.stroke
    ..strokeWidth = 1.0;
  final Paint _bubbleInnerReflectPaint = Paint()
    ..style = PaintingStyle.stroke
    ..strokeWidth = 0.8;
  final Paint _bubbleFillPaint = Paint();
  final Paint _bubbleSpecularPaint = Paint();
  final Paint _bubbleSecondaryGlintPaint = Paint();
  final Paint _glassShinePaint = Paint();
  final Paint _capPaint = Paint();
  final Paint _capRightPaint = Paint();
  final Paint _dividerShadowPaint = Paint();
  final Paint _dividerShadowRightPaint = Paint();
  final Paint _edgeHighlightPaint = Paint()..strokeWidth = 1.0;
  final Paint _screwPaint = Paint();
  final Paint _screwSlotPaint = Paint()..strokeWidth = 1.0;

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Rect.fromLTWH(0, 0, size.width, size.height);
    final centerY = size.height / 2;
    final centerX = size.width / 2;
    const double capWidth = 28.0; // Option 1B: Wider aluminum end caps

    // 1. Draw glowing neon-lime background fluid tint
    _bgPaint.shader = const LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: [
        AppColors.kVialFluidTop,
        AppColors.kVialFluidUpperMid,
        AppColors.kVialFluidMid,
        AppColors.kVialFluidLowerMid,
        AppColors.kVialFluidBottom,
      ],
      stops: [0.0, 0.15, 0.5, 0.85, 1.0],
    ).createShader(rect);
    canvas.drawRect(rect, _bgPaint);

    // 2. Draw tube inner wall highlights (3D glass tube look)
    _wallPaint.color = AppColors.kVialRefractionLight;
    canvas.drawLine(const Offset(capWidth, 5), Offset(size.width - capWidth, 5), _wallPaint);
    canvas.drawLine(
      Offset(capWidth, size.height - 5),
      Offset(size.width - capWidth, size.height - 5),
      _wallPaint,
    );

    // 3. Draw level guidelines (Option 1B: Black guidelines matching bubble width exactly)
    const double targetWidth = 52.0; // Matches bubble width exactly
    _linePaint.color = AppColors.kBlack;
    _lineHighlightPaint.color = AppColors.kVialRefractionLight;

    // Left Guideline
    final double leftGuideX = centerX - targetWidth / 2;
    canvas.drawLine(
      Offset(leftGuideX, 4),
      Offset(leftGuideX, size.height - 4),
      _linePaint,
    );
    canvas.drawLine(
      Offset(leftGuideX - 1.0, 4),
      Offset(leftGuideX - 1.0, size.height - 4),
      _lineHighlightPaint,
    );

    // Right Guideline
    final double rightGuideX = centerX + targetWidth / 2;
    canvas.drawLine(
      Offset(rightGuideX, 4),
      Offset(rightGuideX, size.height - 4),
      _linePaint,
    );
    canvas.drawLine(
      Offset(rightGuideX - 1.0, 4),
      Offset(rightGuideX - 1.0, size.height - 4),
      _lineHighlightPaint,
    );

    // 4. Draw secondary tick marks
    _tickPaint.color = AppColors.kVialRefractionDark.withAlpha(40);
    for (int i = -3; i <= 3; i++) {
      if (i == 0) continue;
      final double dx = centerX + i * 50.0;
      // Skip drawing if ticks fall inside/behind the metal end caps
      if (dx < capWidth + 5.0 || dx > size.width - capWidth - 5.0) continue;
      canvas.drawLine(Offset(dx, 8), Offset(dx, size.height - 8), _tickPaint);
    }

    // 5. Calculate bubble position restricting it to within the liquid chamber
    const double bubbleWidth = 52.0; // Option 1B: Slightly wider bubble
    const double bubbleHeight = 32.0;
    final double liquidWidth = size.width - (capWidth * 2);
    final double maxMovement = (liquidWidth - bubbleWidth - 8.0) / 2;
    final double bubbleCenterX = centerX + x * maxMovement;
    final Rect bubbleRect = Rect.fromCenter(
      center: Offset(bubbleCenterX, centerY),
      width: bubbleWidth,
      height: bubbleHeight,
    );

    final RRect bubbleRRect = RRect.fromRectAndRadius(
      bubbleRect,
      const Radius.circular(16.0),
    );

    // Draw bubble clear/transparent air center
    _bubbleFillPaint.shader = RadialGradient(
      center: const Alignment(0.0, -0.3),
      radius: 0.85,
      colors: [
        Colors.white.withAlpha(160),
        Colors.white.withAlpha(15),
        Colors.transparent,
      ],
      stops: const [0.0, 0.55, 1.0],
    ).createShader(bubbleRect);
    canvas.drawRRect(bubbleRRect, _bubbleFillPaint);

    // Draw bubble double boundary (Option 1B: Outer dark border + inner dark border)
    _bubbleOuterBorderPaint.color = AppColors.kVialRefractionDark.withAlpha(200);
    canvas.drawRRect(bubbleRRect, _bubbleOuterBorderPaint);

    final RRect innerRRect = RRect.fromRectAndRadius(
      bubbleRect.deflate(1.2),
      const Radius.circular(14.8),
    );
    _bubbleBorderPaint.color = AppColors.kVialRefractionDark.withAlpha(150);
    canvas.drawRRect(innerRRect, _bubbleBorderPaint);

    // Draw secondary inner soft light highlight on the border
    _bubbleInnerReflectPaint.color = AppColors.kVialRefractionLight;
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        bubbleRect.deflate(2.2),
        const Radius.circular(13.8),
      ),
      _bubbleInnerReflectPaint,
    );

    // Draw primary white glint reflection on top edge of bubble
    _bubbleSpecularPaint.color = Colors.white.withAlpha(220);
    final RRect specularRRect = RRect.fromRectAndRadius(
      Rect.fromLTWH(
        bubbleRect.left + 8.0,
        bubbleRect.top + 3.0,
        bubbleWidth - 16.0,
        4.0,
      ),
      const Radius.circular(2.0),
    );
    canvas.drawRRect(specularRRect, _bubbleSpecularPaint);

    // Draw secondary lower soft glint
    _bubbleSecondaryGlintPaint.color = Colors.white.withAlpha(90);
    final RRect secondaryGlintRRect = RRect.fromRectAndRadius(
      Rect.fromLTWH(
        bubbleRect.left + 12.0,
        bubbleRect.bottom - 6.0,
        bubbleWidth - 24.0,
        2.0,
      ),
      const Radius.circular(1.0),
    );
    canvas.drawRRect(secondaryGlintRRect, _bubbleSecondaryGlintPaint);

    // 6. Draw outer specular reflections on horizontal glass tube
    _glassShinePaint.shader = LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: [
        Colors.white.withAlpha(45),
        Colors.white.withAlpha(0),
        Colors.white.withAlpha(0),
        Colors.white.withAlpha(20),
      ],
      stops: const [0.0, 0.2, 0.85, 1.0],
    ).createShader(rect);
    canvas.drawRect(rect, _glassShinePaint);

    // 7. Draw brushed-metal end-caps
    final Rect leftCapRect = Rect.fromLTWH(0, 0, capWidth, size.height);
    final Rect rightCapRect = Rect.fromLTWH(size.width - capWidth, 0, capWidth, size.height);

    _capPaint.shader = const LinearGradient(
      begin: Alignment.centerLeft,
      end: Alignment.centerRight,
      colors: [
        AppColors.kVialMetalCapStart,
        AppColors.kVialMetalCapMid1,
        AppColors.kVialMetalCapMid2,
        AppColors.kVialMetalCapMid3,
        AppColors.kVialMetalCapEnd,
      ],
      stops: [0.0, 0.25, 0.5, 0.75, 1.0],
    ).createShader(leftCapRect);

    _capRightPaint.shader = const LinearGradient(
      begin: Alignment.centerLeft,
      end: Alignment.centerRight,
      colors: [
        AppColors.kVialMetalCapStart,
        AppColors.kVialMetalCapMid1,
        AppColors.kVialMetalCapMid2,
        AppColors.kVialMetalCapMid3,
        AppColors.kVialMetalCapEnd,
      ],
      stops: [0.0, 0.25, 0.5, 0.75, 1.0],
    ).createShader(rightCapRect);

    canvas.drawRect(leftCapRect, _capPaint);
    canvas.drawRect(rightCapRect, _capRightPaint);

    // Option 1B: Draw mounting screws in the metal cap brackets
    const double leftScrewX = 14.0;
    final double rightScrewX = size.width - 14.0;

    final Rect leftScrewRect = Rect.fromCircle(center: Offset(leftScrewX, centerY), radius: 3.5);
    _screwPaint.shader = const RadialGradient(
      colors: [AppColors.kChromeLight, AppColors.kChromeDark],
    ).createShader(leftScrewRect);
    canvas.drawCircle(Offset(leftScrewX, centerY), 3.5, _screwPaint);

    final Rect rightScrewRect = Rect.fromCircle(center: Offset(rightScrewX, centerY), radius: 3.5);
    _screwPaint.shader = const RadialGradient(
      colors: [AppColors.kChromeLight, AppColors.kChromeDark],
    ).createShader(rightScrewRect);
    canvas.drawCircle(Offset(rightScrewX, centerY), 3.5, _screwPaint);

    // Screw slots
    _screwSlotPaint.color = AppColors.kChromeDarker;
    canvas.drawLine(
      Offset(leftScrewX - 2.0, centerY - 2.0),
      Offset(leftScrewX + 2.0, centerY + 2.0),
      _screwSlotPaint,
    );
    canvas.drawLine(
      Offset(rightScrewX - 2.0, centerY - 2.0),
      Offset(rightScrewX + 2.0, centerY + 2.0),
      _screwSlotPaint,
    );

    // Draw shadow divider on cap inner edges to provide 3D depth overlay
    final Rect leftShadowRect = Rect.fromLTWH(capWidth, 0, 4.0, size.height);
    _dividerShadowPaint.shader = const LinearGradient(
      begin: Alignment.centerLeft,
      end: Alignment.centerRight,
      colors: [
        Color(0xB4000000),
        Color(0x00000000),
      ],
    ).createShader(leftShadowRect);
    canvas.drawRect(leftShadowRect, _dividerShadowPaint);

    final Rect rightShadowRect = Rect.fromLTWH(size.width - capWidth - 4.0, 0, 4.0, size.height);
    _dividerShadowRightPaint.shader = const LinearGradient(
      begin: Alignment.centerRight,
      end: Alignment.centerLeft,
      colors: [
        Color(0xB4000000),
        Color(0x00000000),
      ],
    ).createShader(rightShadowRect);
    canvas.drawRect(rightShadowRect, _dividerShadowRightPaint);

    // Draw inner edge highlights at the metal-to-liquid boundary
    _edgeHighlightPaint.color = const Color(0x82FFFFFF);
    canvas.drawLine(const Offset(capWidth, 0), Offset(capWidth, size.height), _edgeHighlightPaint);
    canvas.drawLine(Offset(size.width - capWidth, 0), Offset(size.width - capWidth, size.height), _edgeHighlightPaint);
  }

  @override
  bool shouldRepaint(covariant BubbleLevel1dPainter oldDelegate) {
    return oldDelegate.x != x || oldDelegate.status != status;
  }
}
