import 'dart:async';
import 'package:flutter/material.dart';
import './game_pad.dart';
import './tetris_data.dart';
import './tetris_renderder.dart';

/// 可堆疊的總行數
const ROWS = 20;
/// 一行最多擺放的寬度
const COLS = 10;

class Tetris extends StatefulWidget {
	Tetris({ Key key, }) : super(key: key);
  static TetrisData dataOf(BuildContext context) {
    final _TetrisStateContainer widgetInstance =
      context.inheritFromWidgetOfExactType(_TetrisStateContainer);
    return widgetInstance.data;
  }
	@override
	TetrisState createState() => TetrisState();
}

class TetrisState extends State<Tetris> {
  /// 魔術方塊面板資料
  TetrisData data;
  /// 魔術方塊下降間隔的計時器
  Timer _fallTimer;
  /// 用毫秒數來代表墜落速度
  int _fallingSpeed;
  /// 禁止移動
  bool _freezeMove;
  TetrisState() {
    this.data = TetrisData(rows: ROWS, cols: COLS);
    this._freezeMove = false;
  }
  void init() {
    _fallingSpeed = 100;
    _freezeMove = false;
    data.reset();
    putInShape();
  }
  void putInShape() {
    data.putInShape();
    _toggleFallTimer(true);
    setState(() {});
  }
  @override
  void initState() {
    super.initState();
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
      if (data.shouldFreeze()) {
        _freezeMove = true;
        print('到底了');
        print('bottom: ${data.currentBottom}');
        _toggleFallTimer(false);
        /// 到底時會有一個方塊要置底的休息時間
        _fallTimer = Timer(Duration(milliseconds: _fallingSpeed), () {
          data.mergeShapeToPanel();
          setState(() {});
          if (data.isGameOver) {
            print('!!!!! 遊戲結束 !!!!!');
            return;
          }
          data.putInShape();
          _toggleFallTimer(true);
          _freezeMove = false;
        });
        return;
      }
      data.moveCurrentShapeDown();
      setState(() {});
  }
  void _execMoveLeft() {
    if (_freezeMove) return;
    if (data.moveCurrentShapeLeft()) setState(() {});
  }
  void _execMoveRight() {
    if (_freezeMove) return;
    if (data.moveCurrentShapeRight()) setState(() {});
  }
  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.of(context).size;
    double boxWidth = size.width;
    double boxHeight = size.height - kBottomNavigationBarHeight - kToolbarHeight;
    return _TetrisStateContainer(
      data: this.data,
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
            if (data.rotateCurrentShape()) setState(() {});
          },
          onLeft: _execMoveLeft,
          onDownLeft: _execMoveLeft,
          onUpLeft: _execMoveLeft,
          onRight: _execMoveRight,
          onDownRight: _execMoveRight,
          onUpRight: _execMoveRight,
          onDown: () {

          },
          onSwipeDown: () {

          },
        ),
      ),
    );
  }
}

class _TetrisStateContainer extends InheritedWidget {
  final TetrisData data;
  _TetrisStateContainer({
    @required this.data,
    @required Widget child,
  }) : super(child: child);
  @override
  bool updateShouldNotify(_TetrisStateContainer old) => true;
}
