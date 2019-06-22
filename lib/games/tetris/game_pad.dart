import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// 指令重複觸發的 ms 間隔
const AUTO_FIRE_INTERVAL = const Duration(milliseconds: 100);

/// 偵測手勢動作判斷魔術方塊操作行為
class GamePad extends StatefulWidget {
  final Widget child;
  final VoidCallback onUp;
  final VoidCallback onDown;
  final VoidCallback onLeft;
  final VoidCallback onRight;
  final VoidCallback onUpLeft;
  final VoidCallback onUpRight;
  final VoidCallback onDownLeft;
  final VoidCallback onDownRight;
  final VoidCallback onSwipeDown;
  final VoidCallback onTap;
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
    } else if (key == PhysicalKeyboardKey.space) {
      widget.onSwipeDown();
    }
  }
  void _fireDirention(Timer _timer) {
    if (_currentDirention == CtrlDirection.none) return;
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
        _sx = _cx = details.globalPosition.dx;
        _sy = _cy = details.globalPosition.dy;
        _tdx = _tdy = 0;
        _autoFirer = Timer.periodic(AUTO_FIRE_INTERVAL, _fireDirention);
      },
      onPanUpdate: (DragUpdateDetails details) {
        _cx = details.globalPosition.dx;
        _cy = details.globalPosition.dy;
        _tdx += details.delta.dx;
        _tdy += details.delta.dy;
        _currentDirention = getDirection(_tdx, _tdy, 0);
        // 一次下滑的距離超過設定值時即判斷執行下滑
        if (details.delta.dy > 0) {
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
/// 手勢移動時的控制方向定義
enum CtrlDirection {
  none,
  up,
  upLeft,
  upRight,
  right,
  downRight,
  down,
  downLeft,
  left,
}
