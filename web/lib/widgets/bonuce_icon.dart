// import 'dart:async';
import 'package:flutter_web/material.dart';

class BonuceIcon extends StatefulWidget {
  final IconData icon;
  final double size;
  final Color color;

  BonuceIcon(
    this.icon, {
    Key key,
    this.size = 24.0,
    this.color,
  }) : super(key: key);
  @override
  State<BonuceIcon> createState() => _BonuceIconState();
}

class _BonuceIconState extends State<BonuceIcon> with SingleTickerProviderStateMixin {
  final double dx = 4.0;
  AnimationController controller;
  Animation<double> animation;

  @override
  initState() {
    super.initState();
    controller = AnimationController(
        duration: Duration(milliseconds: 300), vsync: this);
    animation = Tween(begin: widget.size, end: widget.size + dx)
        .animate(controller);

    animation.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        controller.reverse();
      }
      // else if (status == AnimationStatus.dismissed) {
      //   Future.delayed(Duration(seconds: 2), () {
      //     if (!mounted) return;
      //     controller?.forward();
      //   });
      // }
    });
    controller.forward();
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return _Animator(
      icon: widget.icon,
      animation: animation,
      color: widget.color,
      size: widget.size + dx,
    );
  }
}

class _Animator extends AnimatedWidget {
  final double size;
  final IconData icon;
  final Color color;
  _Animator({
    Key key,
    this.icon,
    this.size,
    this.color,
    Animation<double> animation,
  }) : super(key: key, listenable: animation);

  @override
  Widget build(BuildContext context) {
    final Animation<double> animation = listenable;
    return Container(
      width: size,
      height: size,
      child: Center(
        child: Icon(
          icon,
          size: animation.value,
          color: color,
        ),
      ),
    );
  }
}