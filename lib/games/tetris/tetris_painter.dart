import 'package:flutter/material.dart';
import './shape.dart';
import './tetris.dart';

class TertisRenderder extends StatefulWidget {
  final Size size;
  TertisRenderder({
    @required this.size,
  });
  @override
  _TertisRenderderState createState() => _TertisRenderderState();
}

class _TertisRenderderState extends State<TertisRenderder> {
  @override
  void initState() {
    super.initState();
  }
  @override
  void dispose() {
    super.dispose();
  }
  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      foregroundPainter: TetrisPainter(
        state: Tetris.of(context),
      ),
      painter: TetrisBGPainter(),
      size: widget.size,
    );
  }
}

/// 處理魔術方塊的畫面渲染
class TetrisPainter extends CustomPainter {
  final TetrisState state;
  Paint mainPaint;

  TetrisPainter({
    this.state,
  }) {
    mainPaint = Paint()
      ..color = Colors.white
      ..strokeJoin = StrokeJoin.round
      ..strokeCap = StrokeCap.round
      ..strokeWidth = 1;
  }
  drawBlock(Canvas canvas, Paint paint, {
    @required int x,
    @required int y,
    @required double blockWidth,
    @required double blockHeight,
  }) {
    paint.style = PaintingStyle.fill;
    canvas.drawRect(
      Rect.fromLTWH(blockWidth * x, blockHeight * y, blockWidth - 1 , blockHeight - 1),
      paint
    );
    // paint.style = PaintingStyle.stroke;
    // paint.color = Colors.white;
    // canvas.drawRect(
    //   Rect.fromLTWH(blockWidth * x, blockHeight * y, blockWidth - 1 , blockHeight - 1),
    //   paint
    // );
  }
  @override
  void paint(Canvas canvas, Size size) {
    final shape = state.currentShape;
    double blockWidth = size.width / COLS;
    double blockHeight = size.height / ROWS;
    canvas.save();
    for (int y = 0; y < ROWS; y++) {
      for (int x = 0; x < COLS; x++) {
        int colorIndex = state.panel[y][x];
        if (colorIndex > 0) {
          mainPaint.color = SHAPE_COLORS[colorIndex];
          drawBlock(
            canvas, mainPaint,
            x: x,
            y: y,
            blockWidth: blockWidth,
            blockHeight: blockHeight,
          );
        }
      }
    }
    if (shape != null) {
      for (int y = 0; y < 4; y++) {
        for (int x = 0; x < 4; x++) {
          int colorIndex = shape.square[y][x];
          if (colorIndex > 0) {
            mainPaint.color = SHAPE_COLORS[colorIndex];
            drawBlock(
              canvas, mainPaint,
              x: shape.left.toInt() + x,
              y: shape.top.toInt() + y,
              blockWidth: blockWidth,
              blockHeight: blockHeight,
            );
          }
        }
      }
      mainPaint.color = Colors.white;
      canvas.drawLine(
        Offset(0, shape.bottom * blockHeight),
        Offset(size.width, shape.bottom * blockHeight),
        mainPaint,
      );
      canvas.drawLine(
        Offset(shape.left * blockWidth, 0),
        Offset(shape.left * blockWidth, size.height),
        mainPaint,
      );
      canvas.drawLine(
        Offset(shape.right * blockWidth, 0),
        Offset(shape.right * blockWidth, size.height),
        mainPaint,
      );
      canvas.restore();
    }
  }
  @override
  bool shouldRepaint(TetrisPainter oldDelegate) => true;
}

class TetrisBGPainter extends CustomPainter {
  Paint mainPaint;
  TetrisBGPainter() {
    mainPaint = Paint()
      ..color = Colors.grey[300]
      ..strokeJoin = StrokeJoin.round
      ..strokeCap = StrokeCap.round
      ..strokeWidth = 1;
  }
  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), mainPaint);
  }
  @override
  bool shouldRepaint(TetrisBGPainter oldDelegate) => true;
}