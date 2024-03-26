import 'package:flutter/material.dart';

class AnimatedImage extends StatefulWidget {
  const AnimatedImage({super.key});

  @override
  AnimatedImageState createState() => AnimatedImageState();
}

class AnimatedImageState extends State<AnimatedImage>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    );
    _animation = Tween<double>(
      begin: 0,
      end: 5,
    ).animate(_controller);
    _controller.repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Transform.rotate(
          // offset: Offset(_animation.value, _animation.value),
          angle: _animation.value,
          child: Image.asset('images/logo.png'),
        );
      },
    );
  }
}
