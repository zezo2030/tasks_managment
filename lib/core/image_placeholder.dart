import 'package:flutter/material.dart';
import 'package:tasks_managment/core/constants.dart';

class OnboardingImagePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final Paint paint =
        Paint()
          ..color = AppColors.primaryColor
          ..style = PaintingStyle.fill;

    // Draw person body
    final Path personPath =
        Path()
          ..moveTo(size.width * 0.5, size.height * 0.3)
          ..lineTo(size.width * 0.6, size.height * 0.7)
          ..lineTo(size.width * 0.4, size.height * 0.7)
          ..close();

    canvas.drawPath(personPath, paint);

    // Draw person head
    canvas.drawCircle(
      Offset(size.width * 0.5, size.height * 0.25),
      size.width * 0.1,
      paint,
    );

    // Draw device
    final Paint devicePaint =
        Paint()
          ..color = AppColors.textDark
          ..style = PaintingStyle.fill;

    final deviceRect = Rect.fromLTWH(
      size.width * 0.2,
      size.height * 0.4,
      size.width * 0.3,
      size.height * 0.3,
    );

    canvas.drawRRect(
      RRect.fromRectAndRadius(deviceRect, Radius.circular(10)),
      devicePaint,
    );

    // Draw notes
    final Paint notesPaint =
        Paint()
          ..color = AppColors.cardOrange
          ..style = PaintingStyle.fill;

    final notesRect = Rect.fromLTWH(
      size.width * 0.6,
      size.height * 0.45,
      size.width * 0.25,
      size.height * 0.2,
    );

    canvas.drawRRect(
      RRect.fromRectAndRadius(notesRect, Radius.circular(10)),
      notesPaint,
    );

    // Draw task icons
    canvas.drawCircle(
      Offset(size.width * 0.2, size.height * 0.2),
      size.width * 0.05,
      Paint()..color = AppColors.cardBlue,
    );

    canvas.drawCircle(
      Offset(size.width * 0.8, size.height * 0.3),
      size.width * 0.05,
      Paint()..color = AppColors.cardPurple,
    );

    canvas.drawCircle(
      Offset(size.width * 0.75, size.height * 0.15),
      size.width * 0.05,
      Paint()..color = AppColors.secondaryColor,
    );
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}

class OnboardingImageWidget extends StatelessWidget {
  final double width;
  final double height;

  const OnboardingImageWidget({
    super.key,
    required this.width,
    required this.height,
  });

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: Size(width, height),
      painter: OnboardingImagePainter(),
    );
  }
}
