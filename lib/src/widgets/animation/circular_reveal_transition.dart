import 'dart:math';
import 'dart:ui';

import 'package:flutter/material.dart';

// ignore_for_file: public_member_api_docs

class CircularReveal extends StatelessWidget {
  final double fraction;
  final Alignment origin;
  final Offset offset;
  final Widget? child;
  final double? minRadius;
  final double? maxRadius;
  const CircularReveal({
    Key? key,
    this.fraction = 1.0,
    this.origin = Alignment.center,
    this.offset = Offset.zero,
    this.child,
    this.minRadius,
    this.maxRadius,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ClipPath(
      clipBehavior: Clip.antiAlias,
      clipper: _CircularRevealClipper(
        origin: origin,
        offset: offset,
        fraction: fraction,
        minRadius: minRadius,
        maxRadius: maxRadius,
      ),
      child: child,
    );
  }
}

class _CircularRevealClipper extends CustomClipper<Path> {
  final double fraction;
  final Alignment origin;
  final Offset offset;
  final double? minRadius;
  final double? maxRadius;
  const _CircularRevealClipper({
    this.fraction = 1.0,
    this.origin = Alignment.center,
    this.offset = Offset.zero,
    this.minRadius,
    this.maxRadius,
  });

  @override
  Path getClip(Size size) {
    final x = (origin.x + 1.0) / 2.0;
    final y = 1.0 - ((origin.y + 1.0) / 2.0);
    final center =
        Offset((size.width * x) + offset.dx, (size.height * y) + offset.dy);
    final minRadius = this.minRadius ?? 0.0;
    final maxRadius = this.maxRadius ?? calcMaxRadius(size, center);

    final radius = lerpDouble(minRadius, maxRadius, fraction) ?? 0;

    return Path()
      ..addOval(
        Rect.fromCircle(
          center: center,
          radius: radius,
        ),
      );
  }

  double calcMaxRadius(Size size, Offset center) {
    final w = max(center.dx, size.width - center.dx);
    final h = max(center.dy, size.height - center.dy);
    return sqrt((w * w) + (h * h));
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) {
    if (oldClipper is _CircularRevealClipper) {
      return oldClipper.fraction != fraction ||
          oldClipper.origin != origin ||
          oldClipper.offset != offset;
    }

    return false;
  }
}
