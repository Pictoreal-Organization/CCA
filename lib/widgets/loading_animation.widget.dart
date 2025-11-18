import 'package:flutter/material.dart';

class LoadingAnimation extends StatelessWidget {
  final double size;

  const LoadingAnimation({
    super.key,
    this.size = 120, // default size, you can override
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Image.asset(
        'assets/animations/loading_animation.gif',
        width: size,
        height: size,
        fit: BoxFit.contain,
      ),
    );
  }
}
