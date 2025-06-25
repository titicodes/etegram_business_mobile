import 'package:flutter/material.dart';

class LaserScannerAnimation extends StatefulWidget {
  const LaserScannerAnimation({super.key});

  @override
  State<LaserScannerAnimation> createState() => _LaserScannerAnimationState();
}

class _LaserScannerAnimationState extends State<LaserScannerAnimation>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);
    _animation = Tween<double>(begin: 0.0, end: 1.0).animate(_controller);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (_, constraints) {
        final height = constraints.maxHeight;
        return AnimatedBuilder(
          animation: _animation,
          builder: (_, __) {
            return CustomPaint(
              painter: _LaserPainter(offset: _animation.value * height),
              size: Size(constraints.maxWidth, height),
            );
          },
        );
      },
    );
  }
}

class _LaserPainter extends CustomPainter {
  final double offset;

  _LaserPainter({required this.offset});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.redAccent
      ..strokeWidth = 2.5;

    canvas.drawLine(
      Offset(0, offset),
      Offset(size.width, offset),
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
