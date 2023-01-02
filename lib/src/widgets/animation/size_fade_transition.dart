import 'package:flutter/material.dart';

// ignore_for_file: public_member_api_docs

class SizeFadeTransition extends StatefulWidget {
  final Animation<double> animation;
  final Curve curve;
  final double sizeFraction;
  final Axis axis;
  final double axisAlignment;
  final Widget? child;
  const SizeFadeTransition({
    Key? key,
    required this.animation,
    this.sizeFraction = 0.5,
    this.curve = Curves.linear,
    this.axis = Axis.vertical,
    this.axisAlignment = 0.0,
    this.child,
  })  : assert(sizeFraction >= 0.0 && sizeFraction <= 1.0),
        super(key: key);

  @override
  _SizeFadeTransitionState createState() => _SizeFadeTransitionState();
}

class _SizeFadeTransitionState extends State<SizeFadeTransition> {
  late final curve =
      CurvedAnimation(parent: widget.animation, curve: widget.curve);
  late final size =
      CurvedAnimation(curve: Interval(0.0, widget.sizeFraction), parent: curve);
  late final opacity =
      CurvedAnimation(curve: Interval(widget.sizeFraction, 1.0), parent: curve);

  @override
  Widget build(BuildContext context) {
    return SizeTransition(
      sizeFactor: size,
      axis: widget.axis,
      axisAlignment: widget.axisAlignment,
      child: FadeTransition(
        opacity: opacity,
        child: widget.child,
      ),
    );
  }
}
