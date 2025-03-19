import 'package:flutter/material.dart';
import 'package:sprung/sprung.dart';

class InteractiveIcon extends StatefulWidget {
  final Widget Function(bool isHovered) builder;

  const InteractiveIcon({
    super.key,
    required this.builder,
  });

  @override
  InteractiveIconState createState() => InteractiveIconState();
}

class InteractiveIconState extends State<InteractiveIcon> {
  bool _hovering = false;

  @override
  Widget build(BuildContext context) {
    final hoverTransform = Matrix4.identity()
      ..translate(-3, -3, -3)
      ..scale(1.05);
    final transform = _hovering ? hoverTransform : Matrix4.identity();
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onHover: (_) => _hovered(true),
      onExit: (_) => _hovered(false),
      child: AnimatedContainer(
        curve: Sprung.overDamped,
        duration: const Duration(milliseconds: 300),
        transform: transform,
        child: widget.builder(_hovering),
      ),
    );
  }

  _hovered(bool hovered) {
    setState(() {
      _hovering = hovered;
    });
  }
}
