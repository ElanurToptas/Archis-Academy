import 'dart:math';
import 'package:flutter/material.dart';

class WaveformPainter extends CustomPainter {
  WaveformPainter({
    required this.amplitudes,
    required this.color,
    required this.isRecording,
  });

  final List<double> amplitudes;
  final Color color;
  final bool isRecording;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color.withValues(alpha: isRecording ? 0.85 : 0.25)
      ..strokeWidth = 3
      ..strokeCap = StrokeCap.round;

    final center = Offset(size.width / 2, size.height / 2);
    const baseRadius = 45.0; 
    final count = amplitudes.length;

    if (count == 0) return;

    for (var i = 0; i < count; i++) {
      final angle = (i / count) * 2 * pi;

      final normalized = isRecording ? amplitudes[i] : 0.05;
      final barLength = max(8.0, normalized * 40.0); 

      final startX = center.dx + baseRadius * cos(angle);
      final startY = center.dy + baseRadius * sin(angle);

      final endX = center.dx + (baseRadius + barLength) * cos(angle);
      final endY = center.dy + (baseRadius + barLength) * sin(angle);

      canvas.drawLine(
        Offset(startX, startY),
        Offset(endX, endY),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant WaveformPainter oldDelegate) =>
      oldDelegate.amplitudes != amplitudes ||
      oldDelegate.isRecording != isRecording ||
      oldDelegate.color != color;
}