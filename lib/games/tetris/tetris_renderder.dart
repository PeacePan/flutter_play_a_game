import 'package:flutter/material.dart';
import './tetris_data.dart';
import './tetris.dart';

class NextShapeRenderder extends StatelessWidget {
  final Size size;
  NextShapeRenderder({
    @required this.size,
  });
  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _NextShapePainter(
        data: Tetris.dataOf(context),
      ),
      size: this.size,
    );
  }
}
class _NextShapePainter extends CustomPainter {
  final TetrisData data;
  _NextShapePainter({
    @required this.data,
  });
  @override
  void paint(Canvas canvas, Size size) {
    final nextShape = data.nextShape;
    if (nextShape == null) return;
    Size blockSize = Size(size.width / 5, size.height / 5);
    Size blockWithBorderSize = Size(blockSize.width - 1, blockSize.height - 1);
    Paint paint = Paint()
      ..color = Colors.white
      ..strokeJoin = StrokeJoin.round
      ..strokeCap = StrokeCap.round
      ..strokeWidth = 1;
    double centerX = size.width / 2;
    double blockWidthHalf = blockSize.width / 2;
    double left = centerX - blockWidthHalf - (nextShape.width / 2.5 * blockSize.width);
    for (int y = 0; y < nextShape.height; y++) {
      for (int x = 0; x < nextShape.width; x++) {
        int colorIndex = nextShape.block[y][x];
        if (colorIndex == 0) continue;
        paint.color = TETRIS_COLORS[colorIndex];
        _drawBlock(
          canvas, paint,
          offset: Offset(left + (blockSize.width * x), blockSize.height * y),
          size: blockWithBorderSize,
        );
      }
    }
  }
  @override
  bool shouldRepaint(CustomPainter oldDelegate) => true;
}

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
  _TetrisPainter({
    @required this.data,
  });
  @override
  void paint(Canvas canvas, Size size) {
    List<List<int>> panel = data.panel;
    Shape shape = data.currentShape;
    Size blockSize = Size(size.width / data.cols, size.height / data.rows);
    Size blockWithBorderSize = Size(blockSize.width - 1, blockSize.height - 1);
    Paint paint = Paint()
      ..color = Colors.white
      ..strokeJoin = StrokeJoin.round
      ..strokeCap = StrokeCap.round
      ..strokeWidth = 1;
    // 繪製目前整個面板上的方塊內容
    for (int y = 0; y < data.rows; y++) {
      for (int x = 0; x < data.cols; x++) {
        int colorIndex = panel[y][x];
        if (colorIndex > 0) {
          paint.color = TETRIS_COLORS[colorIndex];
          _drawBlock(
            canvas, paint,
            offset: Offset(blockSize.width * x, blockSize.height * y),
            size: blockWithBorderSize,
          );
        }
      }
    }
    if (shape != null) {
      int fallingDownY = data.findFallingDownY();
      shape.forEachBlock((value, x, y) {
        int colorIndex = shape.block[y][x];
        if (colorIndex > 0) {
          // 繪製目前落下的魔術方塊
          paint.color = TETRIS_COLORS[colorIndex];
          _drawBlock(
            canvas, paint,
            offset: Offset(
              (data.currentX + x) * blockSize.width,
              (data.currentY + y) * blockSize.height,
            ),
            size: blockWithBorderSize,
          );
          // 繪製落下位置的預覽
          paint.color = Colors.white.withOpacity(0.33);
          _drawBlock(
            canvas, paint,
            offset: Offset(
              (data.currentX + x) * blockSize.width,
              (fallingDownY + y) * blockSize.height,
            ),
            size: blockWithBorderSize,
          );
        }
      });
      // paint.color = Colors.white;
      // canvas.drawLine(
      //   Offset(panel.currentX * blockWidth, 0),
      //   Offset(panel.currentX * blockWidth, size.height),
      //   paint,
      // );
      // canvas.drawLine(
      //   Offset(panel.currentRight * blockWidth, 0),
      //   Offset(panel.currentRight * blockWidth, size.height),
      //   paint,
      // );
      // canvas.drawLine(
      //   Offset(0, panel.currentBottom * blockHeight),
      //   Offset(size.width, panel.currentBottom * blockHeight),
      //   paint,
      // );
    }
  }
  @override
  bool shouldRepaint(_TetrisPainter oldDelegate) => true;
}

class TetrisBGPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    Rect rect = Offset.zero & size;
    Paint paint = Paint()
      ..strokeJoin = StrokeJoin.round
      ..strokeCap = StrokeCap.round
      ..strokeWidth = 1
      ..shader = LinearGradient(
    colors: <Color>[
        Colors.purple,
        Colors.black,
        Colors.purple,
      ],
      stops: [
        0.0,
        0.5,
        1.0,
      ],
    ).createShader(rect);
    canvas.drawRect(rect, paint);
  }
  @override
  bool shouldRepaint(TetrisBGPainter oldDelegate) => true;
}

void _drawBlock(Canvas canvas, Paint paint, {
  @required Offset offset,
  @required Size size,
}) {
  Rect rect = offset & size;
  paint.style = PaintingStyle.fill;
  canvas.drawRect(rect, paint);

  paint.shader = LinearGradient(
    colors: <Color>[
      Colors.white.withOpacity(0.75),
      Colors.white.withOpacity(0.3),
      paint.color,
    ],
    stops: [
      0.0,
      0.75,
      1.0,
    ],
  ).createShader(rect);
  canvas.drawRect(rect, paint);
  paint.shader = null;
  // paint.style = PaintingStyle.stroke;
  // paint.color = Colors.white;
  // canvas.drawRect(rect, paint);
}