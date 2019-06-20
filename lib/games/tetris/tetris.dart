import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import './consts.dart';
import './game_pad.dart';
import './tetris_painter.dart';

/// 隨機產生器種子
final randomGenerator = Random(DateTime.now().microsecondsSinceEpoch);

class Tetris extends StatefulWidget {
	Tetris({ Key key, }) : super(key: key);
	@override
	TetrisState createState() => TetrisState();
}

class TetrisState extends State<Tetris> with SingleTickerProviderStateMixin {
  /// 魔術方塊面板，數值是顏色的 id
  List<int> panel;
  /// 目前落下的方塊
  Shape currentShape;
  /// 下一個產生的方塊
  Shape nextShape;
  /// 遊戲結束，畫面暫停
  bool freezed;
  /// 目前面板的最低水位，為 0 時遊戲結束
  int bottom;
  /// 魔術方塊下降間隔的計時器
  Timer _runner;
  /// 用毫秒數來代表墜落速度
  int fallingSpeed;

  void init() {
    panel ??= List.filled(ROWS * COLS, 0);
    panel.fillRange(0, panel.length - 1, 0);
    bottom = ROWS - 1;
    fallingSpeed = 500;
    newShape();
  }
  void newShape() {
    currentShape = nextShape != null ? nextShape : Shape(
      pattern: SHAPES[randomGenerator.nextInt(SHAPES.length)],
      colorIndex: 1 + randomGenerator.nextInt(SHAPE_COLORS.length - 1),
      angle: randomGenerator.nextInt(4) * 90,
    );
    nextShape = Shape(
      pattern: SHAPES[randomGenerator.nextInt(SHAPES.length)],
      colorIndex: 1 + randomGenerator.nextInt(SHAPE_COLORS.length - 1),
      angle: randomGenerator.nextInt(4) * 90,
    );
    freezed = false;
    _runner?.cancel();
    _runner = Timer.periodic(Duration(milliseconds: fallingSpeed), (Timer _timer) {
      if (!fallingDown()) _timer.cancel();
    });
  }
  bool fallingDown() {
    double bottom = min(currentShape.bottom + 1, ROWS.toDouble() - 1);
    double top = bottom - currentShape.height;
    if (top != currentShape.top) {
      setState(() { currentShape.top = top; });
      return true;
    }
    return false;
  }
  void checkShapeToBottom() {
    bool isToBottom = currentShape.bottom == ROWS - 1;
    print('isToBottom: $isToBottom');
    if (!isToBottom) {
      for (int x = currentShape.left.toInt(); x <= currentShape.right; x++) {
        int i = COLS * currentShape.bottom.toInt() + x;
        if (panel[i] > 0) {
          isToBottom = true;
          break;
        }
      }
    }
    if (isToBottom) {
      print('到底了');
      pasteShapeToPanel();
      newShape();
    }
  }
  /// 把目前落下的方塊固定到面板上
  void pasteShapeToPanel() {
    int top = (currentShape.bottom - currentShape.height).toInt();
    int left = currentShape.left.toInt();
    for (int y = 0; y < currentShape.height; y++) {
      for (int x = 0; x < currentShape.width; x++) {
        int i = 4 * y + x;
        if (currentShape.pattern[i] > 0) {
          print('top + y: ${top + y}');
          print('left + x: ${left + x}');
          int panelIndex = COLS * (top + y) + (left + x);
          panel[panelIndex] = currentShape.colorIndex;
        }
      }
    }
  }
  @override
  void initState() {
    super.initState();
    init();
  }
  @override
  void dispose() {
    _runner?.cancel();
    super.dispose();
  }
  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.of(context).size;
    double boxWidth = size.width;
    double boxHeight = size.height - kBottomNavigationBarHeight - kToolbarHeight;
    return Container(
      width: boxWidth,
      height: boxHeight,
      color: Colors.black,
      child: Row(
        children: <Widget>[
          GamePad(
            child: CustomPaint(
              painter: TetrisPainter(
                state: this,
                onPainted: checkShapeToBottom,
              ),
              size: Size(boxWidth - 100, boxHeight),
            ),
            onLeft: () {
              if (currentShape == null) return;
              double left = max(currentShape.left - 1, 0);
              if (left != currentShape.left) {
                setState(() {
                  currentShape.left = left;
                });
                print('onLeft currentLeft: ${currentShape.left}');
              }
            },
            onRight: () {
              if (currentShape == null) return;
              double left = min(currentShape.left + 1, COLS - currentShape.width);
              if (left != currentShape.left) {
                setState(() {
                  currentShape.left = left;
                });
                print('onRight currentLeft: ${currentShape.left}');
              }
            },
          ),
          SizedBox(
            width: 100,
            child: Column(
              children: <Widget>[
                RaisedButton(
                  child: Text('新遊戲'),
                  onPressed: init,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class Shape {
  /// 4 * 4 的方塊 (以一維陣列定義)
  List<int> square;
  /// 方塊模板 (以一維陣列定義)
  List<int> pattern;
  /// 顯示顏色的編號
  int colorIndex;
  /// 目前旋轉的角度，必須是 [0] [90] [180] [270]
  int angle;
  /// 方塊所佔的矩形區域
  Rect _rect;
  /// 左上角的 X 座標
  double get left => _rect.left;
  set left(value) { _rect = Rect.fromLTWH(value, top, width, height); }
  /// 左上角的 X 座標 + 寬度
  double get right => _rect.right;
  /// 左上角的 Y 座標
  double get top => _rect.top;
  set top(value) { _rect = Rect.fromLTWH(left, value, width, height); }
  /// 左上角的 Y 座標 + 高度
  double get bottom => _rect.bottom;
  /// 方塊目前的所佔最大寬度
  double get width => _rect.width;
  /// 方塊目前的所佔最大高度
  double get height => _rect.height;
  Shape({
    @required this.pattern,
    @required this.colorIndex,
    this.angle = 0,
  }) {
    square = List.filled(4 * 4, 0);
    List<double> widths = List.filled(4, 0.0);
    for (int y = 0; y < 4; y++) {
      double wStart = -1;
      double wEnd = -1;
      for (int x = 0; x < 4; x++) {
        int i = 4 * y + x;
        if (pattern[i] == 1) {
          square[i] = colorIndex;
          if (wStart == -1) wStart = wEnd = x.toDouble();
          else wEnd = x.toDouble();
        }
      }
      widths[y] = wEnd >= 0 ? (wEnd - wStart) + 1 : 0;
    }
    double maxW = 0;
    double maxH = 0;
    widths.sort();
    widths.forEach((double width) {
      maxW = max(maxW, width);
      if (width > 0) maxH++;
    });
    double width = maxW;
    double height = maxH;
    double left = ((COLS / 2) - (width / 2)).roundToDouble();
    double top = 0;
    _rect = Rect.fromLTWH(left, top, width, height);
    if (angle != 0) rotateTo(angle);
    print('left: $left');
    print('top: $top');
    print('width: $width');
    print('height: $height');
    print('angle: $angle');
  }

  void rotateTo(int angle) {
    int prevAngle = this.angle;
    switch (angle) {
      case 90:
      case 180:
      case 270:
      default:
    }
    this.angle = angle;
  }
}