import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

const MAX_OFFSET = 10;

/// 偵測手勢動作判斷魔術方塊操作行為
class GamePad extends StatefulWidget {
  final Widget child;
  final VoidCallback onUp;
  final VoidCallback onDown;
  final VoidCallback onLeft;
  final VoidCallback onRight;
  final VoidCallback onSwipeDown;
  final VoidCallback onTap;
  GamePad({
    @required this.child,
    this.onUp,
    this.onDown,
    this.onLeft,
    this.onRight,
    this.onSwipeDown,
    this.onTap,
  });
  @override
  State<StatefulWidget> createState() => _GamePadState();
}

class _GamePadState extends State<GamePad> {
  /// 方向移動時，自動發出控制指令
  Timer _autoFirer;
  /// 玩家目前操控的方向
  CtrlDirection _currentDirention = CtrlDirection.none;
  // /// 玩家首次觸碰螢幕時在螢幕上的 X 軸位置
  // double _sx;
  // /// 玩家首次觸碰螢幕時在螢幕上的 Y 軸位置
  // double _sy;
  // /// 玩家觸碰螢幕後當前觸碰的 X 軸位置
  // double _cx;
  // /// 玩家觸碰螢幕後當前觸碰的 Y 軸位置
  // double _cy;
  /// 玩家觸碰螢幕後與首次觸碰螢幕的 X 軸位置的總位移量
  double _tdx;
  /// 玩家觸碰螢幕後與首次觸碰螢幕的 Y 軸位置的總位移量
  double _tdy;
  /// 重置數據
  void _reset() {
    // _sx = _sy = _cx = _cy = _tdx = _tdy = null;
    _tdx = _tdy = null;
    _currentDirention = CtrlDirection.none;
    _autoFirer?.cancel();
    _autoFirer = null;
  }
  void _onKey(RawKeyEvent ev) {
    print(ev);
    if (ev is RawKeyUpEvent) {
      return;
    }
    final key = ev.data.physicalKey;
    if (key == PhysicalKeyboardKey.arrowLeft) {
      widget.onLeft();
    } else if (key == PhysicalKeyboardKey.arrowRight) {
      widget.onRight();
    } else if (key == PhysicalKeyboardKey.arrowUp) {
      widget.onUp();
    } else if (key == PhysicalKeyboardKey.arrowDown) {
      widget.onSwipeDown();
    }
  }
  @override
  void initState() {
    super.initState();
    RawKeyboard.instance.addListener(_onKey);
  }
  @override
  void dispose() {
    RawKeyboard.instance.removeListener(_onKey);
    _autoFirer?.cancel();
    super.dispose();
  }
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      child: widget.child,
      onTap: () {
        if (widget.onTap == null) return;
        widget.onTap();
      },
      onPanDown: (DragDownDetails details) {
        // _sx = _cx = details.globalPosition.dx;
        // _sy = _cy = details.globalPosition.dy;
        _tdx = _tdy = 0;
      },
      onPanUpdate: (DragUpdateDetails details) {
        // 一次下滑的距離超過設定值時即判斷執行下滑
        if (details.delta.dy > 10 && widget.onSwipeDown != null) {
          widget.onSwipeDown();
        }
        // _cx = details.globalPosition.dx;
        // _cy = details.globalPosition.dy;
        _tdx += details.delta.dx;
        _tdy += details.delta.dy;
        if (_tdx.abs() >= MAX_OFFSET || _tdy.abs() >= MAX_OFFSET) {
          _currentDirention = _getDirection(_tdx, _tdy);
          _tdx = _tdy = 0;
          if (_currentDirention == CtrlDirection.left && widget.onLeft != null) {
            widget.onLeft();
          } else if (_currentDirention == CtrlDirection.right && widget.onRight != null) {
            widget.onRight();
          } else if (_currentDirention == CtrlDirection.up && widget.onUp != null) {
            widget.onUp();
          } else if (_currentDirention == CtrlDirection.down && widget.onDown != null) {
            widget.onDown();
          }
        }
      },
      onPanEnd: (DragEndDetails details) { _reset(); },
      onPanCancel: _reset,
    );
  }
}
/// 根據輸入的座標位移量 [tx], [ty] 判斷移動的方向
CtrlDirection _getDirection(double tx, double ty) {
  CtrlDirection direction = CtrlDirection.none;
  if (tx.abs() >= ty.abs()) {
    if (tx > 0) {
      direction = CtrlDirection.right;
    } else if (tx < 0) {
      direction = CtrlDirection.left;
    } else {
      direction = CtrlDirection.none;
    }
  } else {
    if (ty > 0) {
      direction = CtrlDirection.down;
    } else if (ty < 0) {
      direction = CtrlDirection.up;
    } else {
      direction = CtrlDirection.none;
    }
  }
  return direction;
}
/// 手勢移動時的控制方向定義
enum CtrlDirection {
  none,
  up,
  down,
  left,
  right,
}
