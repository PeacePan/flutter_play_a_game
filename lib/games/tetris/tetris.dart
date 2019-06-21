import 'dart:math';
import 'dart:async';
import 'package:flutter/material.dart';
import './game_pad.dart';
import './shape.dart';
import './tetris_painter.dart';

/// 可堆疊的總行數
const ROWS = 20;
/// 一行最多擺放的寬度
const COLS = 10;
/// 總格子數
const TOTAL_GRIDS = ROWS * COLS;
/// 所有方塊形狀，每個方塊都為 4x4

/// 隨機產生器種子
final randomGenerator = Random(DateTime.now().microsecondsSinceEpoch);

class Tetris extends StatefulWidget {
	Tetris({ Key key, }) : super(key: key);
  static TetrisState of(BuildContext context) {
    final _TetrisStateContainer widgetInstance =
      context.inheritFromWidgetOfExactType(_TetrisStateContainer);
    return widgetInstance.data;
  }
	@override
	TetrisState createState() => TetrisState();
}

class TetrisState extends State<Tetris> {
  /// 魔術方塊面板，數值是顏色的 id
  List<List<int>> panel;
  /// 目前落下的方塊
  Shape currentShape;
  /// 下一個產生的方塊
  Shape nextShape;
  /// 遊戲結束，畫面暫停
  bool freezed;
  /// 魔術方塊下降間隔的計時器
  Timer _fallTimer;
  /// 用毫秒數來代表墜落速度
  int _fallingSpeed;

  void init() {
    for (int y = 0; y < ROWS; y++) {
      for (int x = 0; x < COLS; x++) {
        panel[y][x] = 0;
      }
    }
    _fallingSpeed = 100;
    currentShape = nextShape = null;
    newShape();
  }
  void newShape() {
    currentShape = nextShape != null ? nextShape : Shape.random(panel);
    nextShape = Shape.random(panel);
    freezed = false;
    _toggleFallTimer(true);
    setState(() {});
  }
  /// 把目前落下的方塊固定到面板上
  void mergeShapeToPanel() {
    int top = currentShape.top.toInt();
    int left = currentShape.left.toInt();
    int height = currentShape.height.toInt();
    bool isGameOver = false;
    for (int y = height - 1; y >= 0; y--) {
      for (int x = 0; x < currentShape.width; x++) {
        if (currentShape.square[y][x] > 0) {
          int ty = top + y;
          int tx = left + x;
          if (ty < 0) {
            isGameOver = true;
            break;
          }
          panel[ty][tx] = currentShape.square[y][x];
        }
      }
      if (isGameOver) break;
    }
    currentShape = null;
    if (isGameOver) {
      print('!!!!!!!!!! Game over !!!!!!!!!!!!!!');
      return;
    }
    newShape();
  }
  @override
  void initState() {
    super.initState();
    panel = List.generate(ROWS, (y) => List.generate(COLS, (x) => 0));
    init();
  }
  @override
  void dispose() {
    _fallTimer?.cancel();
    super.dispose();
  }
  void _toggleFallTimer(bool shouldEnable) {
    if (!shouldEnable && _fallTimer != null) {
      _fallTimer.cancel();
      _fallTimer = null;
    } else if (shouldEnable) {
      _fallTimer?.cancel();
      _fallTimer = Timer.periodic(Duration(milliseconds: _fallingSpeed), _fallingDown);
    }
  }
  void _fallingDown(Timer _timer) {
      if (currentShape.checkIsToBottom()) {
        print('到底了, bottom: ${currentShape.bottom}');
        _timer.cancel();
        _fallTimer = Timer(Duration(milliseconds: _fallingSpeed), () {
          mergeShapeToPanel();
          setState(() {});
        });
        return;
      }
      currentShape.moveDown();
      setState(() {});
  }
  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.of(context).size;
    double boxWidth = size.width;
    double boxHeight = size.height - kBottomNavigationBarHeight - kToolbarHeight;
    return _TetrisStateContainer(
      data: this,
      child: Container(
        width: boxWidth,
        height: boxHeight,
        color: Colors.black,
        child: GamePad(
          child: Row(
            children: <Widget>[
              TertisRenderder(size: Size(boxWidth - 100, boxHeight)),
              Container(
                width: 100,
                decoration: BoxDecoration(
                  border: Border(
                    left: BorderSide(color: Colors.white, width: 1.0),
                  ),
                ),
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
          onTap: () {
            if (currentShape == null) return;
            currentShape.rotate();
            setState(() {});
          },
          onLeft: () {
            if (currentShape == null) return;
            if (currentShape.moveLeft()) setState(() {});
          },
          onRight: () {
            if (currentShape == null) return;
            if (currentShape.moveRight()) setState(() {});
          },
        ),
      ),
    );
  }
}

class _TetrisStateContainer extends InheritedWidget {
  final TetrisState data;
  _TetrisStateContainer({
    @required this.data,
    @required Widget child,
  }) : super(child: child);
  @override
  bool updateShouldNotify(_TetrisStateContainer old) => true;
}
