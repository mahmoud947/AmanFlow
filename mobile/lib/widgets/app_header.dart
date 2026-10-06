import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../core/theme.dart';

/// Teal gradient backdrop with faint contour lines, sits behind the top of a screen.
class HeaderBackdrop extends StatelessWidget {
  final double height;
  const HeaderBackdrop({super.key, required this.height});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [AppColors.primary, Color(0xFF3A9DAE), AppColors.surface],
          stops: [0, 0.6, 1],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
      child: CustomPaint(painter: _ContourPainter(), size: Size.infinite),
    );
  }
}

class _ContourPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withValues(alpha: 0.12)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2;
    for (var i = 0; i < 5; i++) {
      final path = Path()..moveTo(0, 30.0 + i * 26);
      for (double x = 0; x <= size.width; x += 8) {
        path.lineTo(x, 30.0 + i * 26 + math.sin(x / 55 + i) * 14);
      }
      canvas.drawPath(path, paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// Greeting row, designed to sit on the teal backdrop.
class AppHeader extends StatelessWidget {
  final String greeting;
  final String name;
  const AppHeader({super.key, required this.greeting, required this.name});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 44,
          height: 44,
          decoration: const BoxDecoration(
            color: Colors.white,
            shape: BoxShape.circle,
          ),
          child: IconButton(
            tooltip: 'Notifications',
            onPressed: () {},
            icon: const Icon(
              Icons.notifications_none_rounded,
              color: AppColors.primary,
            ),
          ),
        ),
        const SizedBox(width: AppSpacing.md - 4),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                greeting,
                style: const TextStyle(color: Colors.white70, fontSize: 13),
              ),
              Text(
                name,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
        CircleAvatar(
          radius: 22,
          backgroundColor: Colors.white,
          child: Text(
            name.isEmpty ? '?' : name[0],
            style: const TextStyle(
              color: AppColors.primary,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
      ],
    );
  }
}
