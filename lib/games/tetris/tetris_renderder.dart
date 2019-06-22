import 'package:flutter/material.dart';
import './tetris_data.dart';
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
      foregroundPainter: _TetrisPainter(
        data: Tetris.dataOf(context),
      ),
      painter: TetrisBGPainter(),
      size: widget.size,
    );
  }
}

/// 處理魔術方塊的畫面渲染
class _TetrisPainter extends CustomPainter {
  final TetrisData data;
  Paint mainPaint;

  _TetrisPainter({
    @required this.data,
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
    final panel = data.panel;
    final shape = data.currentShape;
    double blockWidth = size.width / COLS;
    double blockHeight = size.height / ROWS;
    for (int y = 0; y < ROWS; y++) {
      for (int x = 0; x < COLS; x++) {
        int colorIndex = panel[y][x];
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
      for (int y = 0; y < shape.height; y++) {
        for (int x = 0; x < shape.width; x++) {
          int colorIndex = shape.block[y][x];
          if (colorIndex > 0) {
            mainPaint.color = SHAPE_COLORS[colorIndex];
            drawBlock(
              canvas, mainPaint,
              x: data.currentX + x,
              y: data.currentY + y,
              blockWidth: blockWidth,
              blockHeight: blockHeight,
            );
          }
        }
      }
      // mainPaint.color = Colors.white;
      // canvas.drawLine(
      //   Offset(panel.currentX * blockWidth, 0),
      //   Offset(panel.currentX * blockWidth, size.height),
      //   mainPaint,
      // );
      // canvas.drawLine(
      //   Offset(panel.currentRight * blockWidth, 0),
      //   Offset(panel.currentRight * blockWidth, size.height),
      //   mainPaint,
      // );
      // canvas.drawLine(
      //   Offset(0, panel.currentBottom * blockHeight),
      //   Offset(size.width, panel.currentBottom * blockHeight),
      //   mainPaint,
      // );
    }
  }
  @override
  bool shouldRepaint(_TetrisPainter oldDelegate) => true;
}

class TetrisBGPainter extends CustomPainter {
  Paint mainPaint;
  TetrisBGPainter() {
    mainPaint = Paint()
      // ..color = Colors.grey[300]
      ..color = Colors.black
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