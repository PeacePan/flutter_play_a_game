import 'package:flutter/material.dart';

typedef void SwipeCallback(SwipeDirection direction);

class Swipeable extends StatefulWidget {
  static double swipeLimit = 20;
  final Widget child;
  final SwipeCallback onSwipe;
	Swipeable({
    Key key,
    @required this.child,
    @required this.onSwipe,
  }) : super(key: key);
	@override
	_SwipeableState createState() => _SwipeableState();
}

class _SwipeableState extends State<Swipeable> {
  double dx;
  double dy;
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      child: widget.child,
      onPanDown: (details) {
        dx = dy = 0;
      },
      onPanUpdate: (details) {
        if (dx == null || dy == null) return;
        dx += details.delta.dx;
        dy += details.delta.dy;
        SwipeDirection direction;
        if (dx > Swipeable.swipeLimit) {
          direction = SwipeDirection.right;
          dx = null;
        } else if (dx < -Swipeable.swipeLimit) {
          direction = SwipeDirection.left;
          dx = null;
        }
        if (dy > Swipeable.swipeLimit) {
          if (direction == SwipeDirection.right) {
            direction = SwipeDirection.downRight;
          } else if (direction == SwipeDirection.left) {
            direction = SwipeDirection.downLeft;
          } else {
            direction = SwipeDirection.down;
          }
          dy = null;
        } else if (dy < -Swipeable.swipeLimit) {
          if (direction == SwipeDirection.right) {
            direction = SwipeDirection.upRight;
          } else if (direction == SwipeDirection.left) {
            direction = SwipeDirection.upLeft;
          } else {
            direction = SwipeDirection.up;
          }
          dy = null;
        }
        if (direction == null) return;
        widget.onSwipe(direction);
      },
    );
  }
}

enum SwipeDirection {
  up,
  upLeft,
  upRight,
  right,
  downRight,
  down,
  downLeft,
  left,
}
