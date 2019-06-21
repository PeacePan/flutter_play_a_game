import 'dart:math';
import 'package:flutter/material.dart';
import './tetris.dart';

/// 隨機產生器種子
final randomGenerator = Random(DateTime.now().microsecondsSinceEpoch);

class Shape {
  /// 該方塊所屬的面板
  final List<List<int>> panel;
  /// 顯示顏色的編號
  final int colorIndex;
  /// 4 * 4 方塊模板
  final List<List<int>> patterns;
  /// 4 * 4 的方塊
  final List<List<int>> square = List.generate(4, (y) => List.generate(4, (x) => 0));
  /// 方塊模板的位置包含旋轉
  int patternIndex;
  /// 方塊所佔的矩形區域
  Rect _rect;
  /// 左上角的 X 座標
  int get left => _rect.left.toInt();
  /// 左上角的 X 座標 + 寬度
  int get right => _rect.right.toInt();
  /// 左上角的 Y 座標
  int get top => _rect.top.toInt();
  /// 左上角的 Y 座標 + 高度
  int get bottom => _rect.bottom.toInt();
  /// 方塊目前的所佔最大寬度
  int get width => _rect.width.toInt();
  /// 方塊目前的所佔最大高度
  int get height => _rect.height.toInt();
  Shape({
    @required this.panel,
    @required this.patterns,
    @required this.patternIndex,
    @required this.colorIndex,
  }) {
    List<int> pattern = patterns[patternIndex];
    for (int y = 0; y < 4; y++) {
      for (int x = 0; x < 4; x++) {
        int i = 4 * y + x;
        square[y][x] = pattern[i] == 1 ? colorIndex : 0;
      }
    }
    updateRect();
  }
  bool falling() {
    int nextTop = top + 1;
    return false;
  }
  bool moveRight() {
    int nextRight = min(right + 1, COLS - 1);
    if (right != nextRight) {
      _rect = Rect.fromLTWH(
        ((right + 1) - width).toDouble(),
        top.toDouble(),
        width.toDouble(),
        height.toDouble(),
      );
    }
    return false;
  }
  bool moveLeft() {
    int nextLeft = max(left - 1, 0);
    if (nextLeft != left) {
      _rect = Rect.fromLTWH(
        nextLeft.toDouble(),
        top.toDouble(),
        width.toDouble(),
        height.toDouble(),
      );
      return true;
    }
    return false;
  }
  bool moveDown() {
    int nextTop = top + 1;
    return false;
  }
  /// 旋轉方塊
  void rotate() {
    patternIndex = patternIndex + 1 >= patterns.length ? 0 : patternIndex + 1;
    List<int> pattern = patterns[patternIndex];
    for (int y = 0; y < 4; y++) {
      for (int x = 0; x < 4; x++) {
        int i = 4 * y + x;
        square[y][x] = pattern[i] == 1 ? colorIndex : 0;
      }
    }
    updateRect(left: this.left, top: this.top);
  }
  /// 更新方塊的寬高資訊
  void updateRect({ int left, int top }) {
    List<int> widths = List.filled(4, 0);
    List<int> heights = List.filled(4, 0);
    for (int x = 0; x < 4; x++) {
      for (int y = 0; y < 4; y++) {
        if (square[y][x] > 0) {
          widths[x] = heights[y] = 1;
        }
      }
    }
    int width = widths.reduce((val, elem) => val + elem);
    int height = heights.reduce((val, elem) => val + elem);
    left ??= ((COLS / 2) - (width / 2)).round();
    top ??= -height;
    _rect = Rect.fromLTWH(
      left.toDouble(),
      top.toDouble(),
      width.toDouble(),
      height.toDouble(),
    );
  }
  bool checkIsToBottom() {
    bool isToBottom = bottom + 1 > ROWS;
    if (!isToBottom) {
      for (int y = height - 1; y >= 0; y--) {
        /// 往下一格找，如果面板上有方塊，代表已到底
        bool hasBlock = false;
        int ty = (top + y + 1).toInt();
        if (ty > 0 && ty < ROWS) {
          for (int x = 0; x < width; x++) {
            int tx = (left + x).toInt();
            if (panel[ty][tx] > 0 && square[y][x] > 0) {
              hasBlock = true;
            }
          }
        }
        if (hasBlock) return true;
      }
    }
    return isToBottom;
  }
  /// 隨機產生一個方塊形狀
  static Shape random(List<List<int>> panel) {
    int patternsIndex = randomGenerator.nextInt(SHAPES.length);
    final patterns = SHAPES[patternsIndex];
    int patternIndex = randomGenerator.nextInt(patterns.length);
    final shape = Shape(
      panel: panel,
      patterns: patterns,
      patternIndex: patternIndex,
      colorIndex: 1 + randomGenerator.nextInt(SHAPE_COLORS.length - 1),
    );
    int rotateCount = randomGenerator.nextInt(4);
    while (rotateCount > 0) {
      shape.rotate();
      rotateCount--;
    }
    return shape;
  }
}

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

const SHAPES = [
  [
    [ 1, 1, 1, 1,
      0, 0, 0, 0,
      0, 0, 0, 0,
      0, 0, 0, 0 ],
    [ 1, 0, 0, 0,
      1, 0, 0, 0,
      1, 0, 0, 0,
      1, 0, 0, 0 ],
  ],
  [
    [ 1, 1, 1, 0,
      1, 0, 0, 0,
      0, 0, 0, 0,
      0, 0, 0, 0 ],
    [ 1, 0, 0, 0,
      1, 0, 0, 0,
      1, 1, 0, 0,
      0, 0, 0, 0 ],
    [ 0, 0, 1, 0,
      1, 1, 1, 0,
      0, 0, 0, 0,
      0, 0, 0, 0 ],
    [ 1, 1, 0, 0,
      0, 1, 0, 0,
      0, 1, 0, 0,
      0, 0, 0, 0 ],
  ],
  [
    [ 1, 1, 1, 0,
      0, 0, 1, 0,
      0, 0, 0, 0,
      0, 0, 0, 0 ],
    [ 0, 1, 0, 0,
      0, 1, 0, 0,
      1, 1, 0, 0,
      0, 0, 0, 0 ],
    [ 1, 0, 0, 0,
      1, 1, 1, 0,
      0, 0, 0, 0,
      0, 0, 0, 0 ],
    [ 1, 1, 0, 0,
      1, 0, 0, 0,
      1, 0, 0, 0,
      0, 0, 0, 0 ],
  ],
  [
    [ 1, 1, 0, 0,
      1, 1, 0, 0,
      0, 0, 0, 0,
      0, 0, 0, 0, ],
  ],
  [
    [ 1, 1, 0, 0,
      0, 1, 1, 0,
      0, 0, 0, 0,
      0, 0, 0, 0 ],
    [ 0, 1, 0, 0,
      1, 1, 0, 0,
      1, 0, 0, 0,
      0, 0, 0, 0 ],
  ],
  [
    [ 0, 1, 1, 0,
      1, 1, 0, 0,
      0, 0, 0, 0,
      0, 0, 0, 0 ],
    [ 1, 0, 0, 0,
      1, 1, 0, 0,
      0, 1, 0, 0,
      0, 0, 0, 0 ],
  ],
  [
    [ 0, 1, 0, 0,
      1, 1, 1, 0,
      0, 0, 0, 0,
      0, 0, 0, 0 ],
    [ 1, 0, 0, 0,
      1, 1, 0, 0,
      1, 0, 0, 0,
      0, 0, 0, 0 ],
    [ 1, 1, 1, 0,
      0, 1, 0, 0,
      0, 0, 0, 0,
      0, 0, 0, 0 ],
    [ 0, 1, 0, 0,
      1, 1, 0, 0,
      0, 1, 0, 0,
      0, 0, 0, 0 ],
  ],
];