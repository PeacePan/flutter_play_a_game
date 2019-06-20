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
