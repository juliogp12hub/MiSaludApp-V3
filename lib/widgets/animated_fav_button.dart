import 'package:flutter/material.dart';

class AnimatedFavButton extends StatefulWidget {
  final bool isFav;
  final VoidCallback onTap;
  final double size;

  const AnimatedFavButton({
    super.key,
    required this.isFav,
    required this.onTap,
    this.size = 30,
  });

  @override
  State<AnimatedFavButton> createState() => _AnimatedFavButtonState();
}

class _AnimatedFavButtonState extends State<AnimatedFavButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scale;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    );

    _scale = Tween<double>(begin: 1.0, end: 1.3).animate(_controller);
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () async {
        _controller.forward().then((_) => _controller.reverse());
        widget.onTap();
      },
      child: ScaleTransition(
        scale: _scale,
        child: Icon(
          widget.isFav ? Icons.favorite : Icons.favorite_border,
          color: widget.isFav ? Colors.red : Colors.grey,
          size: widget.size,
        ),
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}
