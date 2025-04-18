import 'package:flutter/material.dart';
import 'dart:math' as math;

class ConfettiAnimation extends StatelessWidget {
  final Color habitColor;

  const ConfettiAnimation({Key? key, required this.habitColor})
    : super(key: key);

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: SizedBox(
        width: double.infinity,
        height: double.infinity,
        child: Stack(
          children: List.generate(30, (index) {
            final random = math.Random();
            final size = random.nextDouble() * 10 + 5;
            final initialPosition =
                random.nextDouble() * MediaQuery.of(context).size.width;
            final color =
                [
                  Colors.red,
                  Colors.green,
                  Colors.blue,
                  Colors.yellow,
                  Colors.purple,
                  Colors.orange,
                  habitColor,
                ][random.nextInt(7)];

            return Positioned(
              left: initialPosition,
              top: -20,
              child: TweenAnimationBuilder(
                tween: Tween<double>(
                  begin: 0,
                  end: MediaQuery.of(context).size.height + 50,
                ),
                duration: Duration(milliseconds: 1500 + random.nextInt(2000)),
                curve: Curves.easeOutQuad,
                builder: (context, double value, child) {
                  return Transform.translate(
                    offset: Offset(
                      initialPosition + math.sin(value / 50) * 20,
                      value,
                    ),
                    child: Transform.rotate(angle: value / 30, child: child!),
                  );
                },
                child: Opacity(
                  opacity: 0.7,
                  child: Container(
                    width: size,
                    height: size,
                    decoration:
                        random.nextBool()
                            ? BoxDecoration(
                              color: color,
                              shape: BoxShape.circle,
                            )
                            : BoxDecoration(
                              color: color,
                              borderRadius:
                                  random.nextBool()
                                      ? BorderRadius.circular(2)
                                      : null,
                            ),
                  ),
                ),
              ),
            );
          }),
        ),
      ),
    );
  }
}
