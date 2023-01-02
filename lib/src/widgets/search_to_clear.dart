import 'package:flutter/material.dart';

import '../util/util.dart';
import 'widgets.dart';

// ignore_for_file: public_member_api_docs

/// A Widget that animates between a search and
/// a clear icon.
class SearchToClear extends StatelessWidget {
  /// If `true`, the search icon will be shown.
  final bool isEmpty;
  final Duration duration;
  final VoidCallback onTap;
  final Color? color;
  final double size;
  final String searchButtonSemanticLabel;
  final String clearButtonSemanticLabel;

  /// Creates a Widget that animates between a search and
  /// a clear icon.
  const SearchToClear({
    Key? key,
    required this.isEmpty,
    required this.onTap,
    this.duration = const Duration(milliseconds: 500),
    this.color,
    this.size = 24.0,
    this.searchButtonSemanticLabel = 'Search',
    this.clearButtonSemanticLabel = 'Clear',
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AnimatedValue(
      value: isEmpty ? 0.0 : 1.0,
      duration: duration,
      builder: (context, value) {
        return CircularButton(
          onPressed: onTap,
          tooltip: value == 0.0
              ? searchButtonSemanticLabel
              : clearButtonSemanticLabel,
          icon: CustomPaint(
            size: Size.square(size),
            painter: _SearchToClearPainter(
              color ?? Theme.of(context).iconTheme.color ?? Colors.black,
              value,
            ),
          ),
        );
      },
    );
  }
}

class _SearchToClearPainter extends CustomPainter {
  final Color color;
  final double progress;
  _SearchToClearPainter(
    this.color,
    this.progress,
  );

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    final t = progress;

    final circleProgress = interval(0.0, 0.4, t, curve: Curves.easeIn);
    final lineProgress = interval(0.3, 0.8, t, curve: Curves.ease);
    final sLineProgress = interval(0.5, 1.0, t, curve: Curves.easeOut);

    canvas.clipRect(Rect.fromLTWH(0, 0, w, h));
    const padding = 0.225;
    canvas.translate(w * (padding / 2), h * (padding / 2));
    canvas.scale(1 - padding, 1 - padding);

    final sw = w * 0.125;
    final paint = Paint()
      ..color = color
      ..isAntiAlias = true
      ..strokeWidth = sw
      ..style = PaintingStyle.stroke;

    final radius = w * 0.26;
    final offset = radius + (sw / 2);

    // Draws the handle of the loop.
    final lineStart = Offset(radius * 2, radius * 2);
    final lineEnd = Offset(sw, sw);
    canvas.drawLine(
      Offset.lerp(lineStart, lineEnd, lineProgress)!,
      Offset(w - sw, h - sw),
      paint,
    );

    // Draws the circle of the loop.
    final circleStart = Offset(offset, offset);
    final circleEnd = Offset(-offset, -offset);
    final circle = Path()
      ..addArc(
        Rect.fromCircle(
          center: Offset.lerp(circleStart, circleEnd, lineProgress)!,
          radius: radius,
        ),
        32.0.radians,
        (360 * (1 - circleProgress)).radians,
      );
    canvas.drawPath(circle, paint);

    // Draws the second line that will make the cross.
    final sLineStart = Offset(sw, h - sw);
    final sLineEnd = Offset(w - sw, sw);
    canvas.drawLine(
      sLineStart,
      Offset.lerp(sLineStart, sLineEnd, sLineProgress)!,
      paint,
    );
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => true;
}
