import 'dart:math';
import 'package:flutter_web/material.dart';

/// 隨機產生器種子
final randomGenerator = Random(DateTime.now().microsecondsSinceEpoch);

class TetrisData {
  final int rows;
  final int cols;
  int get totalGrids => rows * cols;
  /// 魔術方塊的面板格子資料，紀錄每個格子資料
  List<List<int>> panel;
  /// 下一個要落下的方塊
  Shape nextShape;
  /// 目前落下的魔術方塊
  Shape currentShape;
  /// 目前落下的方塊位置
  Offset _currentOffset;
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
  /// 是否可往下移動
  bool get canMoveDown => currentY + 1 <= findFallingDownY();
  TetrisData({
    @required this.rows,
    @required this.cols,
  }) {
    this.panel = List.generate(rows, (y) => List.generate(cols, (x) => 0));
    this._shapes = [];
    this.nextShape = Shape.random();
  }
  /// 重置資料，將所有的資料回歸原始狀態
  void reset() {
    for (int y = 0; y < rows; y++) {
      for (int x = 0; x < cols; x++) {
        panel[y][x] = 0;
      }
    }
    _shapes.clear();
    currentShape = _currentOffset = null;
    nextShape = Shape.random();
    int rotateCount = randomGenerator.nextInt(4);
    while (--rotateCount >= 0) { nextShape.rotate(); }
  }
  /// 將下一個方塊放進遊戲面板裡，並同時產生下一個魔術方塊
  void putInShape() {
    currentShape = nextShape;
    _currentOffset = Offset(
      // 初始 X 軸位置置中
      ((cols / 2) - (currentShape.width / 2)).roundToDouble(),
      // 初始 Y 軸位置完全隱藏方塊
      -currentShape.height.toDouble(),
    );
    nextShape = Shape.random();
    int rotateCount = randomGenerator.nextInt(4);
    while (--rotateCount >= 0) { nextShape.rotate(); }
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
    if (!(currentShape != null && canMoveDown)) return false;
    _currentOffset = Offset(
      currentX.toDouble(),
      (currentY + 1).toDouble(),
    );
    return true;
  }
  /// 將目前的方塊直接落下
  void fallingDown() {
    _currentOffset = Offset(
      currentX.toDouble(),
      findFallingDownY().toDouble(),
    );
  }
  /// 旋轉目前的魔術方塊
  bool rotateCurrentShape() {
    if (currentShape == null) return false;
    bool canRotate = true;
    /// 先判斷旋轉後的方塊是否合法，合法時才能旋轉
    Shape rotatedShape = Shape(
      patterns: currentShape.patterns,
      patternIndex: currentShape.patternIndex,
      colorIndex: currentShape.colorIndex,
    );
    rotatedShape.rotate();
    rotatedShape.forEachBlock((value, x, y) {
      if (currentX + x < 0) {
        _currentOffset = Offset(
          0,
          currentY.toDouble(),
        );
      } else if (currentX + x > cols - rotatedShape.width) {
        _currentOffset = Offset(
          (cols - rotatedShape.width).toDouble(),
          currentY.toDouble(),
        );
      }
      int ty = currentY + y;
      int tx = currentX + x;
      if (
        ty >= 0 && ty < rows &&
        tx >= 0 && tx < cols &&
        panel[ty][tx] > 0 && value > 0
      ) {
        canRotate = false;
      }
    }, reverse: true);
    if (canRotate) {
      currentShape = rotatedShape;
    }
    return canRotate;
  }
  /// 把目前的方塊固定到面板上
  void mergeShapeToPanel() {
    final block = currentShape.block;
    for (int y = currentShape.height - 1; y >= 0; y--) {
      for (int x = 0; x < currentShape.width; x++) {
        if (block[y][x] > 0) {
          int ty = currentY + y;
          int tx = currentX + x;
          if (ty < 0) break;
          panel[ty][tx] = block[y][x];
        }
      }
    }
    _shapes.add(currentShape);
    currentShape = null;
  }
  /// 檢查是否有填滿，回傳得到的分數
  int cleanLines() {
    int score = 0;
    int bonus = 0;
    int y = rows - 1;
    while (y >= 0) {
      bool shouldClean = true;
      for (int x = 0; x < cols; x++) {
        if (panel[y][x] == 0) {
          shouldClean = false;
          break;
        }
      }
      if (shouldClean) {
        score += 100 + bonus;
        // 每多一行疊加 100 分
        bonus += 100;
        // 將目標清空格的上方空格都往下移
        for (int dy = y; dy >= 0; dy--) {
          for (int x = 0; x < cols; x++) {
            panel[dy][x] = dy - 1 >= 0 ? panel[dy - 1][x] : 0;
          }
        }
      } else {
        y--;
      }
    }
    return score;
  }
  /// 找到方塊能直接落下的 Y 軸位移量
  int findFallingDownY() {
    for (int fY = currentY + 1; fY <= rows - currentShape.height; fY++) {
      bool blocked = false;
      currentShape.forEachBlock((value, x, y) {
        if (fY + y < 0) return;
        if (panel[fY + y][currentX + x] > 0) {
          blocked = true;
        }
      }, reverse: true);
      if (blocked) {
        return fY - 1;
      }
    }
    return rows - currentShape.height;
  }
  /// 檢查目前的方塊是否可移動至目標 X 軸位置
  bool _canMoveToX(int fromX, int toX) {
    if (currentShape == null) return false;
    final block = currentShape.block;
    int blockX = fromX - toX >= 0 ? 0 : currentShape.width - 1;
    // 檢查目前方塊的垂直軸是否都能移動過去
    for (int y = currentShape.height - 1; y >= 0; y--) {
      if (currentY + y < 0) continue;
      int blockValue = block[y][blockX];
      if (blockValue == 0) {
        blockValue = block[y][fromX - toX >= 0 ? blockX + 1 : blockX - 1];
      }
      // 只要有一個位置衝突就不能移動過去
      if (panel[currentY + y][toX] > 0 && blockValue > 0) {
        return false;
      }
    }
    return true;
  }
}
typedef void ShapeForEachCallback(int value, int x, int y);
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
    forEachBlock((value, x, y) {
        int i = PATTERN_SIZE * y + x;
        block[y][x] = pattern[i] == 1 ? colorIndex : 0;
    }, ignoreZero: false);
    updateSize();
  }
  void forEachBlock(ShapeForEachCallback callback, {
    ignoreZero = true,
    reverse = false,
  }) {
    if (reverse) {
      for (int y = PATTERN_SIZE - 1; y >= 0; y--) {
        for (int x = PATTERN_SIZE - 1; x >= 0; x--) {
          if (ignoreZero && block[y][x] == 0) continue;
          callback(block[y][x], x, y);
        }
      }
    } else {
      for (int y = 0; y < PATTERN_SIZE; y++) {
        for (int x = 0; x < PATTERN_SIZE; x++) {
          if (ignoreZero && block[y][x] == 0) continue;
          callback(block[y][x], x, y);
        }
      }
    }
  }
  /// 旋轉方塊
  void rotate() {
    patternIndex = patternIndex + 1 >= patterns.length ? 0 : patternIndex + 1;
    List<int> pattern = patterns[patternIndex];
    forEachBlock((value, x, y) {
        int i = PATTERN_SIZE * y + x;
        block[y][x] = pattern[i] == 1 ? colorIndex : 0;
    }, ignoreZero: false);
    updateSize();
  }
  /// 更新方塊的寬高資訊
  void updateSize() {
    double _offsetX = 0;
    double _offsetY = 0;
    List<double> widths = List.filled(PATTERN_SIZE, 0.0);
    List<double> heights = List.filled(PATTERN_SIZE, 0.0);
    for (int x = 0; x < PATTERN_SIZE; x++) {
      for (int y = 0; y < PATTERN_SIZE; y++) {
        if (block[y][x] > 0) {
          widths[x] = heights[y] = 1;
        }
        if (heights[y] == 1 && _offsetY == 0) _offsetY = y.toDouble();
      }
      if (widths[x] == 1 && _offsetX == 0) _offsetX = x.toDouble();
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
      colorIndex: 1 + randomGenerator.nextInt(TETRIS_COLORS.length - 1),
    );
    return shape;
  }
}

/// 顯示的方塊顏色
const List<Color> TETRIS_COLORS = [
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
