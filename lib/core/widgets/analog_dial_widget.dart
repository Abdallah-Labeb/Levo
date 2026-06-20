import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:levo/app/theme/app_colors.dart';
import 'package:levo/app/theme/app_dimensions.dart';
import 'package:levo/app/theme/app_typography.dart';
import 'package:levo/app/theme/app_animations.dart';

/// Defines a colored arc zone within the analog dial.
class DialZone {
  const DialZone({required this.start, required this.end, required this.color});

  /// Start value, from 0.0 to 1.0.
  final double start;

  /// End value, from 0.0 to 1.0.
  final double end;

  /// The color to paint this zone arc.
  final Color color;
}

/// A skeuomorphic analog dial display with a rotating needle.
/// Reusable across Sound Meter and Light Meter features.
class AnalogDialWidget extends StatefulWidget {
  const AnalogDialWidget({
    super.key,
    required this.value,
    this.zones = const [],
    required this.title,
    required this.minLabel,
    required this.maxLabel,
    this.dialLabels,
    this.size = 240.0,
    this.overlayWidget,
  });

  /// Value to show on the dial, normalized from 0.0 to 1.0.
  final double value;

  /// List of colored zones on the dial scale.
  final List<DialZone> zones;

  /// The title of the dial (e.g. SPL).
  final String title;

  /// Minimum value label (e.g. 30).
  final String minLabel;

  /// Maximum value label (e.g. 130).
  final String maxLabel;

  /// List of numbers/labels to draw along the dial sweep.
  final List<String>? dialLabels;

  /// Diameter of the dial container.
  final double size;

  /// Optional widget positioned at the bottom overlay (e.g., LED display).
  final Widget? overlayWidget;

  @override
  State<AnalogDialWidget> createState() => _AnalogDialWidgetState();
}

class _AnalogDialWidgetState extends State<AnalogDialWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;
  double _oldValue = 0.0;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: AppAnimations.dialNeedle,
    );
    _animation = Tween<double>(
      begin: widget.value,
      end: widget.value,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));
  }

  @override
  void didUpdateWidget(covariant AnalogDialWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.value != widget.value) {
      _oldValue = oldWidget.value;
      _animation = Tween<double>(
        begin: _oldValue,
        end: widget.value,
      ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));
      _controller.forward(from: 0.0);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: widget.size,
      height: widget.size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // The CustomPainted dial background, zones, tick marks, and needle.
          RepaintBoundary(
            child: AnimatedBuilder(
              animation: _animation,
              builder: (context, child) {
                return CustomPaint(
                  size: Size(widget.size, widget.size),
                  painter: _DialPainter(
                    value: _animation.value,
                    zones: widget.zones,
                    title: widget.title,
                    minLabel: widget.minLabel,
                    maxLabel: widget.maxLabel,
                    dialLabels: widget.dialLabels,
                  ),
                );
              },
            ),
          ),
          // Embedded overlay widget (e.g. LED displays) at 70% down.
          if (widget.overlayWidget != null)
            Positioned(
              bottom: widget.size * 0.18,
              child: widget.overlayWidget!,
            ),
        ],
      ),
    );
  }
}

class _DialPainter extends CustomPainter {
  _DialPainter({
    required this.value,
    required this.zones,
    required this.title,
    required this.minLabel,
    required this.maxLabel,
    this.dialLabels,
  });

  final double value;
  final List<DialZone> zones;
  final String title;
  final String minLabel;
  final String maxLabel;
  final List<String>? dialLabels;

  // Pre-allocate paints for performance (Anti-pattern rule check)
  static final _bgPaint = Paint()
    ..color = const Color(0xFF0A0A0A)
    ..style = PaintingStyle.fill;

  static final _rimPaint = Paint()
    ..color = AppColors.kChromeDarker
    ..style = PaintingStyle.stroke
    ..strokeWidth = 3.0;

  static final _ringPaint = Paint()
    ..color = const Color(0xFF1A1A1A)
    ..style = PaintingStyle.stroke
    ..strokeWidth = 0.5;

  static final _needlePaint = Paint()
    ..color = AppColors.kDangerRed
    ..style = PaintingStyle.fill;

  static final _centerCapPaint = Paint()..style = PaintingStyle.fill;

  static final _tickPaint = Paint()..style = PaintingStyle.stroke;

  static final _zonePaint = Paint();

  static final _highlightPaint = Paint()
    ..color = const Color(0xAAFFFFFF)
    ..style = PaintingStyle.fill;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;

    // 1. Draw Dial Face Background
    canvas.drawCircle(center, radius - 2.0, _bgPaint);
    canvas.drawCircle(center, radius - 2.0, _rimPaint);

    // Draw 3 engraved concentric rings
    canvas.drawCircle(center, radius * 0.85, _ringPaint);
    canvas.drawCircle(center, radius * 0.70, _ringPaint);
    canvas.drawCircle(center, radius * 0.55, _ringPaint);

    // Sweep properties: 220 degrees total (-110 to +110).
    // In Flutter CustomPaint, 0 radians is 3 o'clock (pointing right).
    // So 12 o'clock is -pi/2, 6 o'clock is pi/2.
    // -110 degrees = -110 * pi / 180 = -1.91986 radians.
    // 220 degrees = 220 * pi / 180 = 3.83972 radians.
    const sweepStartDegrees =
        -200.0; // Starting sweep at 10 o'clock direction (-200 deg)
    const sweepAngleDegrees = 220.0;
    const sweepStartRad = (sweepStartDegrees) * math.pi / 180.0;
    const sweepAngleRad = sweepAngleDegrees * math.pi / 180.0;

    // 2. Draw Zone Arcs (green, yellow, orange, red zones)
    final arcRect = Rect.fromCircle(center: center, radius: radius * 0.78);
    for (final zone in zones) {
      final zoneStart = sweepStartRad + (zone.start * sweepAngleRad);
      final zoneSweep = (zone.end - zone.start) * sweepAngleRad;

      _zonePaint
        ..color = zone.color
        ..style = PaintingStyle.stroke
        ..strokeWidth = radius * 0.08
        ..strokeCap = StrokeCap.square;

      canvas.drawArc(arcRect, zoneStart, zoneSweep, false, _zonePaint);
    }

    // 3. Draw Tick Marks
    const totalTicks = 50; // 0% to 100% in 2% steps
    for (int i = 0; i <= totalTicks; i++) {
      final percent = i / totalTicks;
      final angle = sweepStartRad + (percent * sweepAngleRad);

      double tickLength = 4.0;
      double strokeWidth = 0.5;
      Color tickColor = AppColors.kChromeDark;

      if (i % 5 == 0) {
        // Major ticks (every 10%)
        tickLength = 10.0;
        strokeWidth = 1.5;
        tickColor = AppColors.kChromeLight;
      } else if (i % 2 == 0) {
        // Minor ticks (every 4%)
        tickLength = 6.0;
        strokeWidth = 1.0;
        tickColor = AppColors.kChromeMid;
      }

      _tickPaint
        ..color = tickColor
        ..strokeWidth = strokeWidth;

      final startOffset = Offset(
        center.dx + (radius * 0.73) * math.cos(angle),
        center.dy + (radius * 0.73) * math.sin(angle),
      );
      final endOffset = Offset(
        center.dx + (radius * 0.73 - tickLength) * math.cos(angle),
        center.dy + (radius * 0.73 - tickLength) * math.sin(angle),
      );
      canvas.drawLine(startOffset, endOffset, _tickPaint);
    }

    // 4. Draw Needle
    // needle rotation angle
    final needleAngle = sweepStartRad + (value.clamp(0.0, 1.0) * sweepAngleRad);
    final needleLength = radius * 0.65;

    // Draw thin elongated triangle for needle
    final needlePath = Path();
    final baseWidth = radius * 0.04;

    // Orthogonal angles for base points
    final baseAngle1 = needleAngle + math.pi / 2;
    final baseAngle2 = needleAngle - math.pi / 2;

    final pBase1 = Offset(
      center.dx + baseWidth * math.cos(baseAngle1),
      center.dy + baseWidth * math.sin(baseAngle1),
    );
    final pBase2 = Offset(
      center.dx + baseWidth * math.cos(baseAngle2),
      center.dy + baseWidth * math.sin(baseAngle2),
    );
    final pTip = Offset(
      center.dx + needleLength * math.cos(needleAngle),
      center.dy + needleLength * math.sin(needleAngle),
    );

    needlePath.moveTo(pBase1.dx, pBase1.dy);
    needlePath.lineTo(pBase2.dx, pBase2.dy);
    needlePath.lineTo(pTip.dx, pTip.dy);
    needlePath.close();

    canvas.drawPath(needlePath, _needlePaint);

    // 5. Draw Center Cap
    final capRadius = radius * 0.12;
    _centerCapPaint.shader = const RadialGradient(
      colors: [AppColors.kChromeLight, AppColors.kChromeDark],
    ).createShader(Rect.fromCircle(center: center, radius: capRadius));
    canvas.drawCircle(center, capRadius, _centerCapPaint);

    // Highlight dot on chrome center cap
    canvas.drawCircle(
      Offset(center.dx - capRadius * 0.3, center.dy - capRadius * 0.3),
      capRadius * 0.2,
      _highlightPaint,
    );

    // 6. Draw Min/Max Labels & Title Text
    // Draw Title Text above center if title is not empty
    if (title.isNotEmpty) {
      final titlePainter = TextPainter(
        text: TextSpan(
          text: title.toUpperCase(),
          style: AppTypography.kSectionHeader.copyWith(
            color: AppColors.kChromeMid,
            letterSpacing: 2.0,
          ),
        ),
        textDirection: TextDirection.ltr,
        textAlign: TextAlign.center,
      )..layout();
      titlePainter.paint(
        canvas,
        Offset(center.dx - titlePainter.width / 2, center.dy - radius * 0.35),
      );
    }

    // 6. Draw Dial Labels & Title Text
    if (dialLabels != null && dialLabels!.isNotEmpty) {
      final int n = dialLabels!.length;
      for (int i = 0; i < n; i++) {
        final double percent = i / (n - 1);
        final double angle = sweepStartRad + (percent * sweepAngleRad);
        final label = dialLabels![i];

        final labelPainter = TextPainter(
          text: TextSpan(
            text: label,
            style: AppTypography.kCaption.copyWith(
              fontFamily: 'ShareTechMono',
              fontSize: AppDimensions.fontSizeDialLabel,
              color: AppColors.kChromeMid,
            ),
          ),
          textDirection: TextDirection.ltr,
        )..layout();

        final x = center.dx + (radius * 0.55) * math.cos(angle) - labelPainter.width / 2;
        final y = center.dy + (radius * 0.55) * math.sin(angle) - labelPainter.height / 2;
        labelPainter.paint(canvas, Offset(x, y));
      }
    } else {
      // Min Label
      const minAngle = sweepStartRad;
      final minPainter = TextPainter(
        text: TextSpan(
          text: minLabel,
          style: AppTypography.kCaption.copyWith(
            fontFamily: 'ShareTechMono',
            fontSize: AppDimensions.fontSizeDialLabel,
            color: AppColors.kChromeMid,
          ),
        ),
        textDirection: TextDirection.ltr,
      )..layout();
      minPainter.paint(
        canvas,
        Offset(
          center.dx + (radius * 0.55) * math.cos(minAngle) - minPainter.width / 2,
          center.dy +
              (radius * 0.55) * math.sin(minAngle) -
              minPainter.height / 2,
        ),
      );

      // Max Label
      const maxAngle = sweepStartRad + sweepAngleRad;
      final maxPainter = TextPainter(
        text: TextSpan(
          text: maxLabel,
          style: AppTypography.kCaption.copyWith(
            fontFamily: 'ShareTechMono',
            fontSize: AppDimensions.fontSizeDialLabel,
            color: AppColors.kChromeMid,
          ),
        ),
        textDirection: TextDirection.ltr,
      )..layout();
      maxPainter.paint(
        canvas,
        Offset(
          center.dx + (radius * 0.55) * math.cos(maxAngle) - maxPainter.width / 2,
          center.dy +
              (radius * 0.55) * math.sin(maxAngle) -
              maxPainter.height / 2,
        ),
      );
    }
  }

  @override
  bool shouldRepaint(covariant _DialPainter oldDelegate) {
    return oldDelegate.value != value ||
        oldDelegate.title != title ||
        oldDelegate.minLabel != minLabel ||
        oldDelegate.maxLabel != maxLabel ||
        oldDelegate.zones != zones ||
        oldDelegate.dialLabels != dialLabels;
  }
}
