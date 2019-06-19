import 'dart:math';
import 'package:flutter/material.dart';

/// 可堆疊的總行數
const ROWS = 20;
/// 一行最多擺放的寬度
const COLS = 10;
/// 所有方塊形狀，每個方塊都為 4x4
const SHAPES = [
    // I
    [ 1, 1, 1, 1,
      0, 0, 0, 0,
      0, 0, 0, 0,
      0, 0, 0, 0 ],
    // L
    [ 1, 1, 1, 0,
      1, 0, 0, 0,
      0, 0, 0, 0,
      0, 0, 0, 0 ],
    // 鏡像 L
    [ 1, 1, 1, 0,
      0, 0, 1, 0,
      0, 0, 0, 0,
      0, 0, 0, 0 ],
    // ㄖ
    [ 1, 1, 0, 0,
      1, 1, 0, 0,
      0, 0, 0, 0,
      0, 0, 0, 0, ],
    // ㄣ
    [ 1, 1, 0, 0,
      0, 1, 1, 0,
      0, 0, 0, 0,
      0, 0, 0, 0 ],
    // 鏡像 ㄣ
    [ 0, 1, 1, 0,
      1, 1, 0, 0,
      0, 0, 0, 0,
      0, 0, 0, 0 ],
    // T
    [ 0, 1, 0, 0,
      1, 1, 1, 0,
      0, 0, 0, 0,
      0, 0, 0, 0 ],
];
/// 顯示的方塊顏色
const List<Color> SHAPE_COLORS = [
    Colors.black,
    Colors.cyan,
    Colors.orange,
    Colors.blue,
    Colors.yellow,
    Colors.red,
    Colors.green,
    Colors.purple
];
/// 隨機產生器種子
final randomGenerator = Random(DateTime.now().microsecondsSinceEpoch);

class Tetris extends StatefulWidget {
	Tetris({ Key key, }) : super(key: key);
	@override
	_TetrisState createState() => _TetrisState();
}

class _TetrisState extends State<Tetris> {
  List<List<int>> board = [];
  List<List<int>> currentShape;
  int currentX;
  int currentY;
  bool freezed;
  void init() {
    board.clear();
    for (int y = 0; y < ROWS; y++) {
      board.add(List.generate(COLS, (x) => 0));
    }
  }
  void newShape() {
    final id = randomGenerator.nextInt(SHAPES.length);
    final shape = SHAPES[id];
    final colorIndex = randomGenerator.nextInt(SHAPE_COLORS.length);
    currentShape = [];
    for (int y = 0; y < 4; y++) {
      currentShape.add(List.filled(4, null));
      for (int x = 0; x < 4; x++ ) {
        int i = 4 * y + x;
        if (shape[i] == 1) {
          currentShape[y][x] = colorIndex;
        } else {
          currentShape[y][x] = 0;
        }
      }
    }
    freezed = false;
    currentX = 4;
    currentY = 0;
  }
  @override
  void initState() {
    super.initState();
    init();
    newShape();
  }
  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    double boxWidth = size.width;
    double boxHeight = size.height - kBottomNavigationBarHeight - kToolbarHeight;
    return Container(
      width: boxWidth,
      height: boxHeight,
      color: Colors.black,
      child: Row(
        children: <Widget>[
          CustomPaint(
            painter: TetrisPainter(
              board: board,
              currentShape: currentShape,
              currentX: currentX,
              currentY: currentY,
            ),
            size: Size(boxWidth - 100, boxHeight)
          ),
          SizedBox(
            width: 100,
            child: Column(
              children: <Widget>[
                Text('', style: TextStyle(color: Colors.white)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class TetrisPainter extends CustomPainter {
  final List<List<int>> board;
  final int currentX;
  final int currentY;
  final List<List<int>> currentShape;
  Paint mainPaint;
  TetrisPainter({
    @required this.board,
    @required this.currentShape,
    @required this.currentX,
    @required this.currentY,
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
    // paint.style = PaintingStyle.stroke;
    // canvas.drawRect(
    //   Rect.fromLTWH(blockWidth * x, blockHeight * y, blockWidth - 1 , blockHeight - 1),
    //   paint
    // );
  }
  @override
  void paint(Canvas canvas, Size size) {
    double blockWidth = size.width / COLS;
    double blockHeight = size.height / ROWS;
    for (int x = 0; x < COLS; x++) {
      for (int y = 0; y < ROWS; y++) {
        if (board[y] is List && board[y][x] > 0) {
          mainPaint.color = SHAPE_COLORS[board[y][x]];
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
    print(currentShape);
    for (int y = 0; y < 4; y++) {
      for (int x = 0; x < 4; x++) {
        if (
          currentShape is List &&
          currentShape[y] is List &&
          currentShape[y][x] != 0
        ) {
          mainPaint.color = SHAPE_COLORS[currentShape[y][x]];
          drawBlock(
            canvas, mainPaint,
            x: currentX + x,
            y: currentY + y,
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
  }
  @override
  bool shouldRepaint(TetrisPainter oldDelegate) {
    return (
      oldDelegate.board != board ||
      oldDelegate.currentX != currentX ||
      oldDelegate.currentY != currentY ||
      oldDelegate.currentShape != currentShape
    );
  }
}
