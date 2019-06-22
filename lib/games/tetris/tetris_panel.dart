import 'dart:math';
import 'package:flutter/material.dart';

/// 隨機產生器種子
final randomGenerator = Random(DateTime.now().microsecondsSinceEpoch);

class TetrisPanel {
  final int rows;
  final int cols;
  int get totalGrids => rows * cols;
  /// 魔術方塊的面板格子資料，紀錄每個格子資料
  List<List<int>> grids;
  /// 目前落下的魔術方塊
  Shape currentShape;
  /// 目前落下的方塊位置
  Offset _currentOffset;
  /// 下一個要落下的方塊
  Shape _nextShape;
  /// 面板上所有的魔術方塊
  List<Shape> _shapes;
  /// 落下方塊所在的 X 座標
  int get currentX {
    if (_currentOffset == null) return -1;
    return _currentOffset.dx.toInt();
  }
  /// 落下方塊的所在的 Y 座標
  int get currentY {
    if (_currentOffset == null) return -1;
    return _currentOffset.dy.toInt();
  }
  /// 落下方塊右側的位置
  int get currentRight {
    if (_currentOffset == null) return -1;
    return currentX + currentShape.width;
  }
  /// 落下方塊底部的位置
  int get currentBottom {
    if (_currentOffset == null) return -1;
    return currentY + currentShape.height;
  }
  /// 判斷遊戲是否結束
  bool get isGameOver => currentY < 0;
  TetrisPanel({
    @required this.rows,
    @required this.cols,
  }) {
    this.grids = List.generate(rows, (y) => List.generate(cols, (x) => 0));
    this._shapes = [];
    this._nextShape = Shape.random();
  }
  /// 重置資料，將所有的資料回歸原始狀態
  void reset() {
    for (int y = 0; y < rows; y++) {
      for (int x = 0; x < cols; x++) {
        grids[y][x] = 0;
      }
    }
    _shapes.clear();
    currentShape = _currentOffset = null;
    _nextShape = Shape.random();
  }
  /// 將下一個方塊放進遊戲面板裡，並同時產生下一個魔術方塊
  void putInShape() {
    currentShape = _nextShape;
    _currentOffset = Offset(
      // 初始 X 軸位置置中
      ((cols / 2) - (currentShape.width / 2)).roundToDouble(),
      // 初始 Y 軸位置完全隱藏方塊
      -currentShape.height.toDouble(),
    );
    _nextShape = Shape.random();
  }
  /// 往左移動目前的魔術方塊
  bool moveCurrentShapeLeft() {
    if (currentShape == null) return false;
    int nextX = currentX - 1;
    // 如果要往左移動的位置，目前面板已有方塊，則不處理移動
    if (
        nextX >= 0 &&
        _canMoveToX(currentX, nextX)
      ) {
      _currentOffset = Offset(
        nextX.toDouble(),
        currentY.toDouble(),
      );
      return true;
    }
    return false;
  }
  /// 往右移動目前的魔術方塊
  bool moveCurrentShapeRight() {
    if (currentShape == null) return false;
    int nextX = currentX + 1;
    int nextRight = nextX + currentShape.width;
    // 如果要往右移動的位置，目前面板已有方塊，則不處理移動
    if (
      nextRight <= cols &&
      _canMoveToX(currentRight - 1, nextRight - 1)
    ) {
      _currentOffset = Offset(
        nextX.toDouble(),
        currentY.toDouble(),
      );
      return true;
    }
    return false;
  }
  /// 往下移動目前的魔術方塊
  bool moveCurrentShapeDown() {
    if (currentShape == null) return false;
    int nextY = currentY + 1;
    int nextBottom = nextY + currentShape.height;
    // 如果要往下移動的位置，目前面板已有方塊，則不處理移動
    if (
      nextY + currentShape.height <= rows &&
      _canMoveToY(currentBottom - 1, nextBottom - 1)
    ) {
      _currentOffset = Offset(
        currentX.toDouble(),
        nextY.toDouble(),
      );
      return true;
    }
    return false;
  }
  /// 旋轉目前的魔術方塊
  bool rotateCurrentShape() {
    if (currentShape == null) return false;
    return currentShape.rotate();
  } 
  /// 檢查目前的魔術方塊是否卡住必須固定
  bool shouldFreeze() {
    bool isToBottom = currentBottom + 1 > rows;
    if (!isToBottom) {
      // 從方塊的下方往上找
      for (int y = currentShape.height - 1; y >= 0; y--) {
        bool hasBlock = false;
        int ty = (currentY + y + 1).toInt();
        // 往面板下一格找，如果面板上有方塊，代表無法再往下
        if (ty > 0 && ty < rows) {
          for (int x = 0; x < currentShape.width; x++) {
            int tx = (currentX + x).toInt();
            if (grids[ty][tx] > 0 && currentShape.block[y][x] > 0) {
              hasBlock = true;
            }
          }
        }
        if (hasBlock) return true;
      }
    }
    return isToBottom;
  }
  /// 把目前落下的方塊固定到面板上
  void mergeShapeToPanel() {
    final block = currentShape.block;
    for (int y = currentShape.height - 1; y >= 0; y--) {
      for (int x = 0; x < currentShape.width; x++) {
        if (block[y][x] > 0) {
          int ty = currentY + y;
          int tx = currentX + x;
          if (ty < 0) break;
          grids[ty][tx] = block[y][x];
        }
      }
    }
    _shapes.add(currentShape);
    currentShape = null;
  }
  /// 檢查目前的方塊是否可移動至目標 X 軸位置
  bool _canMoveToX(int fromX, int toX) {
    if (currentShape == null || currentY < 0) return false;
    final block = currentShape.block;
    int blockX = fromX - toX >= 0 ? 0 : currentShape.width - 1;
    // 檢查目前方塊的垂直軸是否都能移動過去
    for (int y = currentShape.height - 1; y >= 0; y--) {
      // 只要有一個位置衝突就不能移動過去
      if (grids[currentY + y][toX] > 0 && block[y][blockX] > 0) {
        return false;
      }
    }
    return true;
  }
  /// 檢查目前的方塊是否可移動至目標 Y 軸位置
  bool _canMoveToY(int fromY, int toY) {
    if (currentShape == null || currentX < 0) return false;
    final block = currentShape.block;
    int blockY = fromY - toY >= 0 ? 0 : currentShape.height - 1;
    // 檢查目前方塊的水平軸是否都能移動過去
    for (int x = 0; x < currentShape.width; x++) {
      // 只要有一個位置衝突就不能移動過去
      if (grids[toY][currentX + x] > 0 && block[blockY][x] > 0) {
        return false;
      }
    }
    return true;
  }
}

class Shape {
  /// 顯示顏色的編號
  final int colorIndex;
  /// 4 * 4 方塊模板
  final List<List<int>> patterns;
  /// 目前方塊模板的位置(樣板包含旋轉)
  int patternIndex;
  /// 4 * 4 的方塊
  List<List<int>> block;
  /// 方塊所佔的尺寸
  Size _size;
  /// 方塊目前的所佔最大寬度
  int get width => _size.width.toInt();
  /// 方塊目前的所佔最大高度
  int get height => _size.height.toInt();
  Shape({
    @required this.patterns,
    @required this.patternIndex,
    @required this.colorIndex,
  }) {
    this.block = List.generate(PATTERN_SIZE, (y) => List.generate(PATTERN_SIZE, (x) => 0));
    List<int> pattern = patterns[patternIndex];
    for (int y = 0; y < PATTERN_SIZE; y++) {
      for (int x = 0; x < PATTERN_SIZE; x++) {
        int i = PATTERN_SIZE * y + x;
        block[y][x] = pattern[i] == 1 ? colorIndex : 0;
      }
    }
    updateSize();
  }
  /// 旋轉方塊
  bool rotate() {
    patternIndex = patternIndex + 1 >= patterns.length ? 0 : patternIndex + 1;
    List<int> pattern = patterns[patternIndex];
    for (int y = 0; y < PATTERN_SIZE; y++) {
      for (int x = 0; x < PATTERN_SIZE; x++) {
        int i = PATTERN_SIZE * y + x;
        block[y][x] = pattern[i] == 1 ? colorIndex : 0;
      }
    }
    updateSize();
    return true;
  }
  /// 更新方塊的寬高資訊
  void updateSize() {
    List<double> widths = List.filled(PATTERN_SIZE, 0.0);
    List<double> heights = List.filled(PATTERN_SIZE, 0.0);
    for (int x = 0; x < PATTERN_SIZE; x++) {
      for (int y = 0; y < PATTERN_SIZE; y++) {
        if (block[y][x] > 0) {
          widths[x] = heights[y] = 1;
        }
      }
    }
    double width = widths.reduce((val, elem) => val + elem);
    double height = heights.reduce((val, elem) => val + elem);
    _size = Size(width, height);
  }
  /// 隨機產生一個方塊形狀
  static Shape random() {
    int patternsIndex = randomGenerator.nextInt(SHAPES.length);
    final patterns = SHAPES[patternsIndex];
    int patternIndex = randomGenerator.nextInt(patterns.length);
    final shape = Shape(
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
/// 每個魔術方塊樣板尺寸
const PATTERN_SIZE = 4;
/// 所有可能出現的魔術方塊樣板
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