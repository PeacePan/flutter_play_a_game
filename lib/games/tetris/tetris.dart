import 'dart:async';
import 'package:flutter/material.dart';
import './game_pad.dart';
import './tetris_data.dart';
import './tetris_renderder.dart';

/// 可堆疊的總行數
const ROWS = 20;
/// 一行最多擺放的寬度
const COLS = 10;
/// 設定的遊戲等級，一共六級
/// 用毫秒數來代表墜落速度
const LEVELS = const [
  Duration(milliseconds: 600),
  Duration(milliseconds: 500),
  Duration(milliseconds: 400),
  Duration(milliseconds: 300),
  Duration(milliseconds: 200),
  Duration(milliseconds: 100),
];
/// 分數升級門檻
const LEVEL_UP = const [
  1000,
  5000,
  10000,
  20000,
  50000
];
const double RIGHT_PANEL_WIDTH = 100.0;
const TextStyle INFO_TEXT_STYLE = TextStyle(
  color: Colors.white,
  fontSize: 20,
);

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

class TetrisState extends State<Tetris> with WidgetsBindingObserver {
  /// 魔術方塊面板資料
  TetrisData data;
  /// 魔術方塊下降間隔的計時器
  Timer _fallTimer;
  /// 魔術方塊到底時短暫停頓的計時器
  Timer _restTimer;
  /// 禁止移動
  bool _freezeMove;
  /// 禁止移動
  bool _gameover;
  /// 目前等級
  int _level;
  /// 遊戲總得分數
  int _score;
  /// App 目前的狀態
  AppLifecycleState _appLifecycleState;
  /// 遊戲進行中
  bool get _isPause => _fallTimer == null && _restTimer == null;
  TetrisState() {
    this.data = TetrisData(rows: ROWS, cols: COLS);
    this._freezeMove = false;
    this._score = this._level = 0;
  }
  void init() {
    _score = _level = 0;
    _freezeMove = _gameover = false;
    data.reset();
    putInShape();
  }
  void putInShape() {
    data.putInShape();
    _toggleFallTimer(true);
    setState(() {});
  }
  @override
  void didChangeAppLifecycleState(AppLifecycleState lifecycleState) {
    _appLifecycleState = lifecycleState;
    switch (_appLifecycleState) {
      case AppLifecycleState.resumed:
        _toggleFallTimer(true);
        print('!!!!! 恢復遊戲 !!!!!');
        break;
      case AppLifecycleState.inactive:
      case AppLifecycleState.paused:
      default:
        _toggleFallTimer(false);
        _toggleRestTimer(false);
        print('!!!!! 遊戲暫停 !!!!!');
        break;
    }
  }
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    init();
  }
  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _fallTimer?.cancel();
    _restTimer?.cancel();
    super.dispose();
  }
  void _toggleFallTimer(bool shouldEnable) {
    if (!shouldEnable && _fallTimer != null) {
      _fallTimer.cancel();
      _fallTimer = null;
    } else if (shouldEnable) {
      _fallTimer?.cancel();
      _fallTimer = Timer.periodic(LEVELS[_level], _execMoveDown);
    }
  }
  void _toggleRestTimer(bool shouldEnable) {
    if (!shouldEnable && _restTimer != null) {
      _restTimer.cancel();
      _restTimer = null;
    } else if (shouldEnable) {
      _restTimer?.cancel();
      _restTimer = Timer(LEVELS[_level], _afterRest);
    }
  }
  /// 到底時會有一個方塊要置底的休息時間
  void _afterRest() {
    if (data.canMoveDown) {
      _execMoveDown(_restTimer);
      _toggleRestTimer(true);
      return;
    }
    data.mergeShapeToPanel();
    _score += (data.cleanLines() * (_level + 1));
    if (_level < LEVELS.length && _score >= LEVEL_UP[_level]) {
      _level++;
    }
    if (data.isGameOver) {
      print('!!!!! 遊戲結束 !!!!!');
      _gameover = true;
      _toggleFallTimer(false);
      _toggleRestTimer(false);
    } else {
      data.putInShape();
      _toggleFallTimer(true);
      _freezeMove = false;
    }
    setState(() {});
  }
  /// 直接執行讓方塊直接落下
  void _execFallingDown() {
    _toggleFallTimer(false);
    _freezeMove = true;
    data.fallingDown();
    _toggleRestTimer(true);
    setState(() {});
  }
  /// 執行方塊落下一格的處理
  void _execMoveDown(Timer _timer) {
    if (!data.canMoveDown) {
      _freezeMove = true;
      print('到底了, bottom: ${data.currentBottom}');
      _toggleFallTimer(false);
      _toggleRestTimer(true);
      return;
    }
    data.moveCurrentShapeDown();
    setState(() {});
  }
  /// 執行往左移動
  void _execMoveLeft() {
    if (_freezeMove) return;
    if (data.moveCurrentShapeLeft()) setState(() {});
  }
  /// 執行往右移動
  void _execMoveRight() {
    if (_freezeMove) return;
    if (data.moveCurrentShapeRight()) setState(() {});
  }
  /// 執行方塊旋轉
  void _execRotate() {
    if (data.rotateCurrentShape()) setState(() {});
  }
  /// 暫停/復原遊戲
  void _togglePause() {
    setState(() {
      if (_isPause) {
        _toggleFallTimer(true);
      } else {
        _toggleFallTimer(false);
        _toggleRestTimer(false);
      }
    });
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
              TertisRenderder(size: Size(boxWidth - RIGHT_PANEL_WIDTH, boxHeight)),
              Container(
                width: RIGHT_PANEL_WIDTH,
                decoration: BoxDecoration(
                  border: Border(
                    left: BorderSide(color: Colors.white, width: 1.0),
                  ),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: <Widget>[
                    NextShapeRenderder(size: Size(RIGHT_PANEL_WIDTH, RIGHT_PANEL_WIDTH)),
                    Container(
                      padding: EdgeInsets.symmetric(vertical: 16),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: <Widget>[
                          Text('等級',
                            textAlign: TextAlign.center,
                            style: INFO_TEXT_STYLE,
                          ),
                          Text('${_level + 1}', 
                            textAlign: TextAlign.center,
                            style: INFO_TEXT_STYLE,
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: EdgeInsets.only(bottom: 16),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: <Widget>[
                          Text('分數',
                            textAlign: TextAlign.center,
                            style: INFO_TEXT_STYLE,
                          ),
                          Text('$_score', 
                            textAlign: TextAlign.center,
                            style: INFO_TEXT_STYLE,
                          ),
                        ],
                      ),
                    ),
                    Container(
                      margin: EdgeInsets.only(top: 16, bottom: 16),
                      child: IgnorePointer(
                        ignoring: _gameover,
                        child: IconButton(
                          icon: Icon(
                            _isPause ? Icons.play_arrow : Icons.pause
                          ),
                          iconSize: 32,
                          color: Colors.white,
                          onPressed: _togglePause,
                        ),
                      ),
                    ),
                    Container(
                      margin: EdgeInsets.only(top: 16, bottom: 24),
                      child:  IconButton(
                        icon: Icon(Icons.sync),
                        iconSize: 32,
                        color: Colors.white,
                        onPressed: init,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          onTap: _execRotate,
          onLeft: _execMoveLeft,
          onRight: _execMoveRight,
          onSwipeDown: _execFallingDown,
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
