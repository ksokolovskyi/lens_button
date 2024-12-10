import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/physics.dart';

class LensButton extends StatefulWidget {
  const LensButton({super.key});

  @override
  State<LensButton> createState() => _LensButtonState();
}

class _LensButtonState extends State<LensButton> {
  final _isHovered = ValueNotifier(false);

  final _isPressed = ValueNotifier(false);

  @override
  void dispose() {
    _isHovered.dispose();
    _isPressed.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: DecoratedBox(
        position: DecorationPosition.foreground,
        decoration: const ShapeDecoration(
          shape: RoundedRectangleBorder(
            side: BorderSide(color: Color(0xFFEDEDED)),
            borderRadius: BorderRadius.all(Radius.circular(10)),
          ),
        ),
        child: ClipRRect(
          borderRadius: const BorderRadius.all(Radius.circular(10)),
          child: GestureDetector(
            onTapDown: (_) => _isPressed.value = true,
            onTapUp: (_) => _isPressed.value = false,
            onTapCancel: () => _isPressed.value = false,
            child: MouseRegion(
              cursor: SystemMouseCursors.click,
              onHover: (_) => _isHovered.value = true,
              onExit: (_) => _isHovered.value = false,
              child: Stack(
                children: [
                  const Positioned.fill(
                    child: ColoredBox(color: Colors.white),
                  ),
                  Positioned.fill(
                    child: ValueListenableBuilder(
                      valueListenable: _isHovered,
                      builder: (context, isHovered, child) {
                        return AnimatedOpacity(
                          opacity: isHovered ? 0 : 1,
                          duration: const Duration(milliseconds: 170),
                          curve: Curves.ease,
                          child: child,
                        );
                      },
                      child: const DecoratedBox(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Color(0xFFFEFEFE),
                              Color(0xFFFBFBFB),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(
                      top: 14,
                      bottom: 14,
                      left: 26,
                      right: 24,
                    ),
                    child: ValueListenableBuilder(
                      valueListenable: _isPressed,
                      builder: (context, isPressed, child) {
                        return AnimatedScale(
                          scale: isPressed ? 0.985 : 1,
                          duration: const Duration(milliseconds: 170),
                          child: child,
                        );
                      },
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Flexible(
                            child: Text(
                              'Developer Preview',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontFamily: 'Inter',
                                fontWeight: FontWeight.w500,
                                color: Color(0xFF2C2D30),
                                fontSize: 15,
                                height: 1.1,
                                letterSpacing: -0.13,
                              ),
                            ),
                          ),
                          const SizedBox(width: 6),
                          ValueListenableBuilder(
                            valueListenable: _isHovered,
                            builder: (context, isHovered, _) {
                              return _Circle(isHovered: isHovered);
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _Circle extends StatefulWidget {
  const _Circle({
    required this.isHovered,
  });

  final bool isHovered;

  @override
  State<_Circle> createState() => _CircleState();
}

class _CircleState extends State<_Circle> with TickerProviderStateMixin {
  late final _colorController = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 170),
  );

  late final _color = ColorTween(
    begin: const Color(0x4D2C2D30),
    end: const Color(0x992C2D30),
  ).chain(CurveTween(curve: Curves.ease)).animate(_colorController);

  late final _translationController = AnimationController.unbounded(
    vsync: this,
  );

  final _translationSimulation = SpringSimulation(
    const SpringDescription(
      stiffness: 250,
      damping: 22,
      mass: 1,
    ),
    0,
    1,
    0,
  );

  late final _translation = Tween<double>(
    begin: 0,
    end: 20,
  ).animate(_translationController);

  @override
  void initState() {
    super.initState();

    if (widget.isHovered) {
      _colorController.value = 1;
      _translationController.value = 1;
    } else {
      _colorController.value = 0;
      _translationController.value = 0;
    }
  }

  @override
  void didUpdateWidget(_Circle oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.isHovered == widget.isHovered) {
      return;
    }

    if (widget.isHovered) {
      _colorController.forward();
      _translationController.animateWith(_translationSimulation);
    } else {
      _colorController.reverse();
      _translationController.value = 0;
    }
  }

  @override
  void dispose() {
    _colorController.dispose();
    _translationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Transform.rotate(
      angle: 225 * math.pi / 180,
      child: ClipRRect(
        borderRadius: const BorderRadius.all(Radius.circular(8)),
        child: SizedBox.square(
          dimension: 16,
          child: Stack(
            children: [
              Positioned.fill(
                child: AnimatedBuilder(
                  animation: _color,
                  builder: (context, _) {
                    final color = _color.value!;

                    return DecoratedBox(
                      decoration: BoxDecoration(
                        color: color.withOpacity(color.opacity * 0.12),
                      ),
                    );
                  },
                ),
              ),
              AnimatedBuilder(
                animation: _translationController,
                builder: (context, child) {
                  return Transform.translate(
                    offset: Offset(0, _translation.value),
                    child: child,
                  );
                },
                child: AnimatedBuilder(
                  animation: _color,
                  builder: (context, _) {
                    final color = _color.value!;

                    return Stack(
                      alignment: Alignment.center,
                      children: [
                        _Arrow(color: color),
                        Transform.translate(
                          offset: const Offset(0, -20),
                          child: _Arrow(color: color),
                        ),
                      ],
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Arrow extends StatelessWidget {
  const _Arrow({
    required this.color,
  });

  final Color color;

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: const Size.square(16),
      painter: _ArrowPainter(color: color),
    );
  }
}

class _ArrowPainter extends CustomPainter {
  const _ArrowPainter({
    required this.color,
  });

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final path = Path()
      ..moveTo(8, 4.812)
      ..lineTo(8, 11.312)
      ..moveTo(8, 11.312)
      ..lineTo(10.5, 8.812)
      ..moveTo(8, 11.312)
      ..lineTo(5.5, 8.812);

    final paint = Paint()
      ..color = color.withOpacity(color.opacity * 0.8)
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(_ArrowPainter oldDelegate) {
    return oldDelegate.color != color;
  }
}
