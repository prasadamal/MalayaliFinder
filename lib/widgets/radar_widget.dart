import 'dart:math';
import 'package:flutter/material.dart';

import '../models/user_model.dart';
import '../utils/app_colors.dart';

/// Radar widget that animates sweeping rings and plots nearby Malayalees.
class RadarWidget extends StatefulWidget {
  final List<UserModel> nearbyUsers;
  final double radarRange; // km
  final bool isActive;

  const RadarWidget({
    super.key,
    required this.nearbyUsers,
    required this.radarRange,
    required this.isActive,
  });

  @override
  State<RadarWidget> createState() => _RadarWidgetState();
}

class _RadarWidgetState extends State<RadarWidget>
    with TickerProviderStateMixin {
  late AnimationController _sweepController;
  late AnimationController _pulseController;
  late Animation<double> _sweepAngle;
  late Animation<double> _pulseScale;

  @override
  void initState() {
    super.initState();

    _sweepController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    );
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    );

    _sweepAngle = Tween<double>(begin: 0, end: 2 * pi).animate(
      CurvedAnimation(parent: _sweepController, curve: Curves.linear),
    );
    _pulseScale = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    if (widget.isActive) {
      _sweepController.repeat();
      _pulseController.repeat(reverse: true);
    }
  }

  @override
  void didUpdateWidget(RadarWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isActive && !_sweepController.isAnimating) {
      _sweepController.repeat();
      _pulseController.repeat(reverse: true);
    } else if (!widget.isActive && _sweepController.isAnimating) {
      _sweepController.stop();
      _pulseController.stop();
    }
  }

  @override
  void dispose() {
    _sweepController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: Listenable.merge([_sweepAngle, _pulseScale]),
      builder: (context, _) {
        return CustomPaint(
          painter: _RadarPainter(
            nearbyUsers: widget.nearbyUsers,
            sweepAngle: _sweepAngle.value,
            pulseScale: _pulseScale.value,
            isActive: widget.isActive,
            radarRange: widget.radarRange,
          ),
          child: const SizedBox.expand(),
        );
      },
    );
  }
}

class _RadarPainter extends CustomPainter {
  final List<UserModel> nearbyUsers;
  final double sweepAngle;
  final double pulseScale;
  final bool isActive;
  final double radarRange;

  _RadarPainter({
    required this.nearbyUsers,
    required this.sweepAngle,
    required this.pulseScale,
    required this.isActive,
    required this.radarRange,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final centre = Offset(size.width / 2, size.height / 2);
    final radius = min(size.width, size.height) / 2 - 8;

    _drawBackground(canvas, centre, radius);
    _drawRings(canvas, centre, radius);
    _drawCrossHairs(canvas, centre, radius);

    if (isActive) {
      _drawSweep(canvas, centre, radius);
      _drawUserDots(canvas, centre, radius);
    }

    _drawCentreDot(canvas, centre);
  }

  void _drawBackground(Canvas canvas, Offset centre, double radius) {
    final paint = Paint()
      ..shader = RadialGradient(
        colors: [
          AppColors.primaryDark.withOpacity(0.9),
          AppColors.background.withOpacity(0.95),
        ],
      ).createShader(Rect.fromCircle(center: centre, radius: radius));
    canvas.drawCircle(centre, radius, paint);

    // Border
    canvas.drawCircle(
      centre,
      radius,
      Paint()
        ..color = AppColors.radar.withOpacity(0.5)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.5,
    );
  }

  void _drawRings(Canvas canvas, Offset centre, double radius) {
    final paint = Paint()
      ..color = AppColors.radar.withOpacity(0.2)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.8;

    for (int i = 1; i <= 4; i++) {
      canvas.drawCircle(centre, radius * i / 4, paint);
    }
  }

  void _drawCrossHairs(Canvas canvas, Offset centre, double radius) {
    final paint = Paint()
      ..color = AppColors.radar.withOpacity(0.2)
      ..strokeWidth = 0.8;

    canvas.drawLine(
        Offset(centre.dx - radius, centre.dy),
        Offset(centre.dx + radius, centre.dy),
        paint);
    canvas.drawLine(
        Offset(centre.dx, centre.dy - radius),
        Offset(centre.dx, centre.dy + radius),
        paint);
    // Diagonal lines
    final d = radius * cos(pi / 4);
    canvas.drawLine(
        Offset(centre.dx - d, centre.dy - d),
        Offset(centre.dx + d, centre.dy + d),
        paint);
    canvas.drawLine(
        Offset(centre.dx + d, centre.dy - d),
        Offset(centre.dx - d, centre.dy + d),
        paint);
  }

  void _drawSweep(Canvas canvas, Offset centre, double radius) {
    final sweepPaint = Paint()
      ..shader = SweepGradient(
        startAngle: sweepAngle - 1.2,
        endAngle: sweepAngle,
        colors: [
          AppColors.radar.withOpacity(0),
          AppColors.radar.withOpacity(0.5),
        ],
        transform: GradientRotation(sweepAngle - 1.2),
      ).createShader(Rect.fromCircle(center: centre, radius: radius))
      ..style = PaintingStyle.fill;

    canvas.drawArc(
      Rect.fromCircle(center: centre, radius: radius),
      sweepAngle - 1.2,
      1.2,
      true,
      sweepPaint,
    );

    // Sweep line
    canvas.drawLine(
      centre,
      Offset(
        centre.dx + radius * cos(sweepAngle),
        centre.dy + radius * sin(sweepAngle),
      ),
      Paint()
        ..color = AppColors.radar.withOpacity(0.8)
        ..strokeWidth = 1.5,
    );
  }

  void _drawUserDots(Canvas canvas, Offset centre, double radius) {
    final rng = Random(42); // deterministic positions

    for (int i = 0; i < nearbyUsers.length; i++) {
      final angle = rng.nextDouble() * 2 * pi;
      final distance = rng.nextDouble() * 0.85 + 0.05; // 5%..90% of radius
      final dotPos = Offset(
        centre.dx + radius * distance * cos(angle),
        centre.dy + radius * distance * sin(angle),
      );

      final user = nearbyUsers[i];
      final dotColor = user.isVerifiedMalayali
          ? AppColors.radar
          : AppColors.accentLight;

      // Glow
      canvas.drawCircle(
        dotPos,
        8,
        Paint()..color = dotColor.withOpacity(0.25),
      );
      // Dot
      canvas.drawCircle(
        dotPos,
        4,
        Paint()..color = dotColor,
      );
      // Ring
      canvas.drawCircle(
        dotPos,
        6,
        Paint()
          ..color = dotColor.withOpacity(0.6)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1,
      );
    }
  }

  void _drawCentreDot(Canvas canvas, Offset centre) {
    // Outer glow
    canvas.drawCircle(
      centre,
      16,
      Paint()..color = AppColors.primary.withOpacity(0.3),
    );
    canvas.drawCircle(
      centre,
      10,
      Paint()..color = AppColors.primaryLight.withOpacity(0.5),
    );
    // Centre dot (you)
    canvas.drawCircle(
      centre,
      6,
      Paint()..color = AppColors.primaryLight,
    );
  }

  @override
  bool shouldRepaint(_RadarPainter old) =>
      old.sweepAngle != sweepAngle ||
      old.pulseScale != pulseScale ||
      old.isActive != isActive ||
      old.nearbyUsers.length != nearbyUsers.length;
}
