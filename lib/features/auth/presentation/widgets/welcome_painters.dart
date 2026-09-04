import 'package:flutter/material.dart';
import 'package:makhzanflow/core/theme/mf_tokens.dart';

class DecorativeCirclesPainter extends CustomPainter {
  const DecorativeCirclesPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    final paintOrange = Paint()
      ..color = MFTokens.accent.withValues(alpha: 0.1)
      ..style = PaintingStyle.fill;

    final paintWhite = Paint()
      ..color = MFTokens.gradientOverlaySubtle
      ..style = PaintingStyle.fill;

    canvas.drawCircle(Offset(w * 0.76, h * 0.16), w * 0.184, paintOrange);
    canvas.drawCircle(Offset(w * 0.16, h * 0.75), w * 0.132, paintWhite);
    canvas.drawCircle(Offset(w * 0.17, h * 0.36), w * 0.066, paintOrange);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class StockIconPainter extends CustomPainter {
  const StockIconPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = MFTokens.textOnPrimary
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.5
      ..strokeCap = StrokeCap.round;

    final l = size.width;
    final t = size.height;

    canvas.drawRect(
      Rect.fromLTRB(l * 0.083, t * 0.132, l * 0.917, t * 0.917),
      paint,
    );
    canvas.drawLine(Offset(l * 0.083, t * 0.4), Offset(l * 0.917, t * 0.4), paint);
    canvas.drawLine(Offset(l * 0.5, t * 0.132), Offset(l * 0.5, t * 0.4), paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
