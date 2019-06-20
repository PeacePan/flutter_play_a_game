import 'package:flutter/material.dart';
import './consts.dart';

typedef void ActionCallback();

/// 偵測手勢動作判斷魔術方塊操作行為
class GamePad extends StatefulWidget {
  /// 一次手勢移動的像素量
  static double safeZone = 20.0;
  /// 100ms 才能輸入一次指令
  static double inputInterval = 100;
  final Widget child;
  final ActionCallback onUp;
  final ActionCallback onDown;
  final ActionCallback onLeft;
  final ActionCallback onRight;
  final ActionCallback onUpLeft;
  final ActionCallback onUpRight;
  final ActionCallback onDownLeft;
  final ActionCallback onDownRight;
  final ActionCallback onSwipeDown;
  GamePad({
    @required this.child,
    this.onUp,
    this.onDown,
    this.onLeft,
    this.onRight,
    this.onUpLeft,
    this.onUpRight,
    this.onDownLeft,
    this.onDownRight,
    this.onSwipeDown,
  });
  @override
  State<StatefulWidget> createState() => _GamePadState();
}

class _GamePadState extends State<GamePad> {
  DateTime _lastInputTime = DateTime.now();
  /// 玩家目前操控的方向
  CtrlDirection _currentDirention = CtrlDirection.none;
  /// 玩家首次觸碰螢幕時在螢幕上的 X 軸位置
  double _sx;
  /// 玩家首次觸碰螢幕時在螢幕上的 Y 軸位置
  double _sy;
  /// 玩家觸碰螢幕後當前觸碰的 X 軸位置
  double _cx;
  /// 玩家觸碰螢幕後當前觸碰的 Y 軸位置
  double _cy;
  /// 玩家觸碰螢幕後與首次觸碰螢幕的 X 軸位置的總位移量
  double _tdx;
  /// 玩家觸碰螢幕後與首次觸碰螢幕的 Y 軸位置的總位移量
  double _tdy;
  /// 重置數據
  void reset() {
    _sx = _sy = _cx = _cy = _tdx = _tdy = null;
    _currentDirention = CtrlDirection.none;
  }
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      child: widget.child,
      onPanDown: (DragDownDetails details) {
        _sx = _cx = details.globalPosition.dx;
        _sy = _cy = details.globalPosition.dy;
        _tdx = _tdy = 0;
      },
      onPanUpdate: (DragUpdateDetails details) {
        int mSec = DateTime.now().difference(_lastInputTime).inMilliseconds;
        if (
          _sx == null || _sy == null ||
          mSec < GamePad.inputInterval
        ) return;
        _lastInputTime = DateTime.now();
        
        _cx = details.globalPosition.dx;
        _cy = details.globalPosition.dy;
        _tdx += details.delta.dx;
        _tdy += details.delta.dy;
        _currentDirention = getDirection(_tdx, _tdy, GamePad.safeZone);
        if (_currentDirention == CtrlDirection.left && widget.onLeft != null) {
          widget.onLeft();
        } else if (_currentDirention == CtrlDirection.right && widget.onRight != null) {
          widget.onRight();
        } else if (_currentDirention == CtrlDirection.up && widget.onUp != null) {
          widget.onUp();
        } else if (_currentDirention == CtrlDirection.down && widget.onDown != null) {
          widget.onDown();
        } else if (_currentDirention == CtrlDirection.upLeft && widget.onUpLeft != null) {
          widget.onUpLeft();
        } else if (_currentDirention == CtrlDirection.upRight && widget.onUpRight != null) {
          widget.onUpRight();
        } else if (_currentDirention == CtrlDirection.downLeft && widget.onDownLeft != null) {
          widget.onDownLeft();
        } else if (_currentDirention == CtrlDirection.downRight && widget.onDownRight!= null) {
          widget.onDownRight();
        }
        // 一次下滑的距離超過設定值時即判斷執行下滑
        if (details.delta.dy > GamePad.safeZone) {
          if (widget.onSwipeDown == null) return;
          widget.onSwipeDown();
        }
      },
      onPanEnd: (DragEndDetails details) {
        reset();
      },
      onPanCancel: () {
        reset();
      },
    );
  }
}
/// 根據輸入的座標位移量 [dx], [dy] 與 安全區域值 [safeZone] 判斷移動的方向
CtrlDirection getDirection(double dx, double dy, double safeZone) {
  CtrlDirection dirention = CtrlDirection.none;
  if (dx > safeZone) {
    dirention = CtrlDirection.right;
  } else if (dx < -safeZone) {
    dirention = CtrlDirection.left;
  }
  if (dy > safeZone) {
    if (dirention == CtrlDirection.right) {
      dirention = CtrlDirection.downRight;
    } else if (dirention == CtrlDirection.left) {
      dirention = CtrlDirection.downLeft;
    } else {
      dirention = CtrlDirection.down;
    }
  } else if (dy < -safeZone) {
    if (dirention == CtrlDirection.right) {
      dirention = CtrlDirection.upRight;
    } else if (dirention == CtrlDirection.left) {
      dirention = CtrlDirection.upLeft;
    } else {
      dirention = CtrlDirection.up;
    }
  }
  return dirention;
}