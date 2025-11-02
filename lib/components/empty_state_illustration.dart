import 'package:flutter/material.dart';
import 'app_theme.dart';

/// A simple illustration widget showing vertical lines (empty state graphic)
class EmptyStateIllustration extends StatelessWidget {
  final double size;
  
  const EmptyStateIllustration({
    super.key,
    this.size = 64,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(
        painter: _EmptyStatePainter(),
      ),
    );
  }
}

class _EmptyStatePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppTheme.textDark
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;

    final width = size.width;
    final height = size.height;
    
    // Draw vertical lines at different positions
    // Line 1 (leftmost, shorter)
    canvas.drawLine(
      Offset(width * 0.2, height * 0.5),
      Offset(width * 0.2, height * 0.8),
      paint,
    );
    
    // Line 2 (taller)
    canvas.drawLine(
      Offset(width * 0.35, height * 0.3),
      Offset(width * 0.35, height * 0.85),
      paint,
    );
    
    // Line 3 (medium)
    canvas.drawLine(
      Offset(width * 0.5, height * 0.4),
      Offset(width * 0.5, height * 0.8),
      paint,
    );
    
    // Line 4 (taller)
    canvas.drawLine(
      Offset(width * 0.65, height * 0.25),
      Offset(width * 0.65, height * 0.85),
      paint,
    );
    
    // Line 5 (diagonal)
    canvas.drawLine(
      Offset(width * 0.8, height * 0.25),
      Offset(width * 0.95, height * 0.75),
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

