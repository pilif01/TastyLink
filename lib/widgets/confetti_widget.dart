import 'package:flutter/material.dart';
import 'dart:math' as math;

class ConfettiWidget extends StatefulWidget {
  final bool isActive;
  final Duration duration;
  final Widget child;

  const ConfettiWidget({
    super.key,
    required this.isActive,
    required this.duration,
    required this.child,
  });

  @override
  State<ConfettiWidget> createState() => _ConfettiWidgetState();
}

class _ConfettiWidgetState extends State<ConfettiWidget>
    with TickerProviderStateMixin {
  late AnimationController _controller;
  late List<ConfettiParticle> _particles;
  final math.Random _random = math.Random();

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: widget.duration,
      vsync: this,
    );
    _particles = _generateParticles();
  }

  @override
  void didUpdateWidget(ConfettiWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isActive && !oldWidget.isActive) {
      _controller.forward().then((_) {
        _controller.reset();
      });
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  List<ConfettiParticle> _generateParticles() {
    final particles = <ConfettiParticle>[];
    for (int i = 0; i < 50; i++) {
      particles.add(ConfettiParticle(
        x: _random.nextDouble(),
        y: _random.nextDouble(),
        color: _getRandomColor(),
        size: _random.nextDouble() * 8 + 4,
        velocity: _random.nextDouble() * 2 + 1,
        angle: _random.nextDouble() * 2 * math.pi,
      ));
    }
    return particles;
  }

  Color _getRandomColor() {
    final colors = [
      Colors.green,
      Colors.orange,
      Colors.blue,
      Colors.purple,
      Colors.red,
      Colors.yellow,
    ];
    return colors[_random.nextInt(colors.length)];
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        widget.child,
        if (widget.isActive)
          AnimatedBuilder(
            animation: _controller,
            builder: (context, child) {
              return CustomPaint(
                painter: ConfettiPainter(
                  particles: _particles,
                  progress: _controller.value,
                ),
                size: Size.infinite,
              );
            },
          ),
      ],
    );
  }
}

class ConfettiParticle {
  final double x;
  final double y;
  final Color color;
  final double size;
  final double velocity;
  final double angle;

  ConfettiParticle({
    required this.x,
    required this.y,
    required this.color,
    required this.size,
    required this.velocity,
    required this.angle,
  });
}

class ConfettiPainter extends CustomPainter {
  final List<ConfettiParticle> particles;
  final double progress;

  ConfettiPainter({
    required this.particles,
    required this.progress,
  });

  @override
  void paint(Canvas canvas, Size size) {
    for (final particle in particles) {
      final paint = Paint()
        ..color = particle.color.withOpacity(1 - progress)
        ..style = PaintingStyle.fill;

      final x = particle.x * size.width;
      final y = particle.y * size.height + (progress * particle.velocity * 200);
      final rotation = particle.angle + (progress * 2 * math.pi);

      canvas.save();
      canvas.translate(x, y);
      canvas.rotate(rotation);
      canvas.drawRect(
        Rect.fromCenter(
          center: Offset.zero,
          width: particle.size,
          height: particle.size,
        ),
        paint,
      );
      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(ConfettiPainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}
