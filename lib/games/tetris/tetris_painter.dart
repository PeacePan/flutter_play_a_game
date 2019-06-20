import 'package:flutter/material.dart';
import './consts.dart';
import './tetris.dart';

/// 處理魔術方塊的畫面渲染
class TetrisPainter extends CustomPainter {
  final TetrisState state;
  final VoidCallback onPainted;
  Paint mainPaint;
  TetrisPainter({
    @required this.state,
    this.onPainted,
  }) {
    mainPaint = Paint();
    mainPaint.color = Colors.white;
    mainPaint.strokeJoin = StrokeJoin.round;
    mainPaint.strokeCap = StrokeCap.round;
    mainPaint.strokeWidth = 1;
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
    paint.style = PaintingStyle.stroke;
    paint.color = Colors.white;
    canvas.drawRect(
      Rect.fromLTWH(blockWidth * x, blockHeight * y, blockWidth - 1 , blockHeight - 1),
      paint
    );
  }
  @override
  void paint(Canvas canvas, Size size) {
    double blockWidth = size.width / COLS;
    double blockHeight = size.height / ROWS;
    for (int y = 0; y < ROWS; y++) {
      for (int x = 0; x < COLS; x++) {
        int i = COLS * y + x;
        int colorIndex = state.panel[i];
        // if (colorIndex > 0) {
        mainPaint.color = SHAPE_COLORS[colorIndex];
        drawBlock(
          canvas, mainPaint,
          x: x,
          y: y,
          blockWidth: blockWidth,
          blockHeight: blockHeight,
        );
        // }
      }
    }
    for (int y = 0; y < 4; y++) {
      for (int x = 0; x < 4; x++) {
        int i = 4 * y + x;
        int colorIndex = state.currentShape.square[i];
        if (colorIndex > 0) {
          mainPaint.color = SHAPE_COLORS[colorIndex];
          drawBlock(
            canvas, mainPaint,
            x: state.currentShape.left.toInt() + x,
            y: state.currentShape.top.toInt() + y,
            blockWidth: blockWidth,
            blockHeight: blockHeight,
          );
        }
      }
    }
    mainPaint.color = Colors.white;
    canvas.drawLine(
      Offset(size.width, 0),
      Offset(size.width, size.height),
      mainPaint,
    );
    if (onPainted != null) onPainted();
  }
  @override
  bool shouldRebuildSemantics(CustomPainter oldDelegate) {
    return super.shouldRebuildSemantics(oldDelegate);
  }
  @override
  bool shouldRepaint(TetrisPainter oldDelegate) => true;
}
