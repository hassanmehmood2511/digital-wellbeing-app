import 'package:flutter/material.dart';

class AuthBackgroundPainter extends CustomPainter {
  const AuthBackgroundPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..style = PaintingStyle.fill
      ..isAntiAlias = true;
    final topPath = Path()
      ..moveTo(0, 0)
      ..lineTo(size.width * 0.30, 0)
      ..cubicTo(
        size.width * 0.23,
        size.height * 0.09,
        size.width * 0.12,
        size.height * 0.09,
        0,
        size.height * 0.14,
      )
      ..close();

    paint.color = const Color(0xFFE8F5E9);
    canvas.drawPath(topPath, paint);
  }

  @override
  bool shouldRepaint(covariant AuthBackgroundPainter oldDelegate) => false;
}
