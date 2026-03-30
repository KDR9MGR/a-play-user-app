import 'package:flutter/material.dart';

class SquircleContainer extends StatelessWidget {
  final Widget child;
  final double radius;

  const SquircleContainer({
    super.key,
    required this.child,
    this.radius = 20.0,
  });

  @override
  Widget build(BuildContext context) {
    return ClipPath(
        clipper:  ShapeBorderClipper(
          shape: ContinuousRectangleBorder(
          borderRadius: BorderRadius.all(
            Radius.circular(radius),
          ),
        ),
        ),
        child: child);
  }
}
