import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import '../../configs.dart';
import '../../main.dart';
import '../../utlis.dart';
import '../../widgets/bonuce_icon.dart';

const int ROWS = 14;
const int COLUMNS = 12;
const int TOTAL_GRIDS = ROWS * COLUMNS;
/// 周圍炸彈數的數字顏色
const BOMB_COLORS = [
  Colors.transparent,
  Colors.blue,
  Colors.green,
  Colors.red,
  Colors.indigo,
  Colors.pink,
  Colors.lightGreen,
  Colors.grey,
  Colors.black,
];
/// 1 秒鐘的定義
const ONE_SEC = const Duration(seconds: 1);
/// 隨機產生器種子
final randomGenerator = Random(DateTime.now().microsecondsSinceEpoch);

class Minesweeper extends StatefulWidget {
	Minesweeper({ Key key, }) : super(key: key);
	@override
	_MinesweeperState createState() => _MinesweeperState();
}

class _MinesweeperState extends State<Minesweeper> {
  /// 炸彈旗標設置 (座標對應布林值)
  final Map<int, Map<int, bool>> flags = Map();
  /// 每個格子單位
  final List<List<GameGrid>> grids = List();
  /// 全部的炸彈數量
  int _totalBombs;
  /// 是否踩到炸彈遊戲結束
  bool _isGameOver = false;
  /// 所有格子全搜尋，設置旗子數等於所有炸彈數
  bool _isGameWon = false;
  /// 計數遊戲時間
  Timer _timer;
  /// 一場遊戲開始時間
  DateTime gameStart;
  /// 一場遊戲結束時間
  DateTime gameEnd;
  /// 取得目前設置的旗子數
  int get flagCount {
    int _flagCount = 0;
    flags.forEach((index, row) {
        _flagCount += row.entries.length;
    });
    return _flagCount;
  }
  void resetGrids(bool isInit) {
    flags.clear();
    grids.clear();
    for (int r = 0; r < ROWS; r++) {
      grids.add(List.generate(COLUMNS, (x) => GameGrid(isSearched: isInit)));
    }
  }
  /// 建立新遊戲
  void createGame() {
    final Level level = App.of(context).configs.mineweeperLevel;
    int bombAmount;
    if (level == Level.difficult) {
      bombAmount =
        (TOTAL_GRIDS * 0.5).round() +
        randomGenerator.nextInt(10) -
        randomGenerator.nextInt(10);
    } else if (level == Level.medium) {
      bombAmount =
        (TOTAL_GRIDS * 0.25).round() +
        randomGenerator.nextInt(10) -
        randomGenerator.nextInt(10);
    } else {
      bombAmount =
        (TOTAL_GRIDS * 0.1).round() +
        randomGenerator.nextInt(10) -
        randomGenerator.nextInt(10);
    }
    bombAmount = min(bombAmount, TOTAL_GRIDS);
    int total = bombAmount;
    resetGrids(false);
    while (bombAmount > 0) {
      final rY = randomGenerator.nextInt(ROWS);
      final rX = randomGenerator.nextInt(COLUMNS);
      if (!grids[rY][rX].hasBomb) {
        grids[rY][rX].hasBomb = true;
        bombAmount--;
      }
    }
    setState(() {
      _totalBombs = total;
      _isGameOver = _isGameWon = false;
      _timer?.cancel();
      _timer = Timer.periodic(ONE_SEC, (Timer timer) {
          if (_isGameOver || _isGameWon) {
            timer.cancel();
            return;
          }
          setState(() {
            gameEnd = DateTime.now();
          });
        },
      );
      gameStart = gameEnd = DateTime.now();
    });
  }
  /// 搜尋周圍 8 格，若目標周圍的炸彈數為 0
  /// 則遞迴搜尋周圍 8 格
  void searchBomb(int x, int y) {
    if (x < 0 || y < 0 || x >= COLUMNS || y >= ROWS) return;
    if (grids[y][x].isSearched) return;
    int bombs = 0;
    for (int dy = -1; dy <= 1; dy++) {
      for (int dx = -1; dx <= 1; dx++) {
        if (dy == 0 && dx == 0) continue;
        int ay = y + dy;
        int ax = x + dx;
        if (ax < 0 || ay < 0 || ax >= COLUMNS || ay >= ROWS) continue;
        final grid = grids[ay][ax];
        if (grid.hasBomb) {
          bombs += 1;
        }
      }
    }
    grids[y][x].aroundBombs = bombs;
    grids[y][x].isSearched = true;
    if (bombs == 0) {
      for (int dy = -1; dy <= 1; dy++) {
        for (int dx = -1; dx <= 1; dx++) {
          if (dy == 0 && dx == 0) continue;
          int ay = y + dy;
          int ax = x + dx;
          if (ax < 0 || ay < 0 || ax >= COLUMNS || ay >= ROWS) continue;
          searchBomb(ax, ay);
        }
      }
    }
  }
  /// 檢查目前狀態是否已經獲勝
  /// 設置旗子數等於所有炸彈數且所有格子全已搜尋
  bool checkWin() {
    if (_totalBombs != flagCount) {
      return false;
    }
    int searchedCount = 0;
    grids.forEach((row) {
      row.forEach((col) {
        if (col.isSearched) searchedCount++;
      });
    });
    return searchedCount + flagCount == TOTAL_GRIDS;
  }
  @override
  void initState() {
    super.initState();
    resetGrids(true);
  }
  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
  @override
  Widget build(BuildContext context) {
    String timeString = '00:00';
    int remainBombs = 0;
    if (gameStart != null && gameEnd != null) {
      Duration gameTime = gameEnd.difference(gameStart);
      int minutes = gameTime.inMinutes;
      int seconds = (gameTime.inSeconds - (minutes * 60));
      timeString = '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
      remainBombs = _totalBombs - flagCount;
    }
    return ListView(
      children: <Widget>[
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: <Widget>[
            Container(
              color: Colors.black,
              width: 100,
              alignment: Alignment.center,
              padding: EdgeInsets.symmetric(vertical: 8, horizontal: 4),
              child: Text(
                remainBombs.toString().padLeft(3, '0'),
                style: TextStyle(
                  fontSize: 32,
                  color: Colors.red,
                ),
              ),
            ),
            Container(
              margin: EdgeInsets.symmetric(vertical: 8),
              decoration: BoxDecoration(
                color: Colors.grey,
                borderRadius: BorderRadius.all(Radius.circular(48)),
              ),
              child: IconButton(
                icon: Icon(
                  _isGameOver
                    ? Icons.sentiment_very_dissatisfied
                    : Icons.mood
                ),
                iconSize: 48.0,
                color: Colors.yellow[200],
                onPressed: () {
                  if (_isGameOver == false && _isGameWon == false) {
                    alertMessage(
                      context: context,
                      title: '建立新遊戲？',
                      okText: '確定',
                      cancelText: '取消',
                      onOK: () {
                        Navigator.pop(context);
                        createGame();
                      },
                      onCancel: () {
                        Navigator.pop(context);
                      },
                    );
                    return;
                  }
                  createGame();
                },
              ),
            ),
            Container(
              color: Colors.black,
              width: 100,
              alignment: Alignment.center,
              padding: EdgeInsets.symmetric(vertical: 8, horizontal: 4),
              child: Text(
                timeString,
                style: TextStyle(
                  fontSize: 32,
                  color: Colors.red,
                ),
              ),
            ),
          ],
        ),
        GridView.builder(
          physics: NeverScrollableScrollPhysics(),
          shrinkWrap: true,
          scrollDirection: Axis.vertical,
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: COLUMNS,
            mainAxisSpacing: 2,
            crossAxisSpacing: 2,
          ),
          padding: EdgeInsets.all(4),
          itemCount: ROWS * COLUMNS,
          itemBuilder: (BuildContext context, int index) {
            int y = (index / COLUMNS).floor();
            int x = index - (COLUMNS * y);
            final grid = grids[y][x];
            Widget widget;
            if (grid.isSearched) {
              if (grid.hasBomb) {
                widget = Icon(Icons.new_releases);
              } else {
                widget = Text(
                  grid.aroundBombs > 0
                   ? grid.aroundBombs.toString()
                   : '',
                  style: TextStyle(
                    fontSize: 24,
                    color: BOMB_COLORS[grid.aroundBombs],
                  ),
                );
              }
            } else if (
              flags[y] is Map &&
              flags[y][x] == true
            ) {
              widget = BonuceIcon(
                Icons.assistant_photo,
                color: Colors.red,
                size: 20,
              );
            } else {
              widget = Text('');
            }
            return IgnorePointer(
              ignoring: _isGameOver || _isGameWon,
              child: InkWell(
                child: Container(
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: grid.isSearched && grid.hasBomb
                      ? Colors.red
                      : _isGameOver
                      ? Colors.black12
                      : Colors.black26,
                    border: grid.isSearched
                      ? null
                      : Border(
                      left: BorderSide(color: Colors.grey[300], width: 4),
                      top: BorderSide(color: Colors.grey[300], width: 4),
                      right: BorderSide(color: Colors.black26, width: 4),
                      bottom: BorderSide(color: Colors.black26, width: 4),
                    ),
                  ),
                  child: widget,
                ),
                onTap: () {
                  if (!grid.isSearched && grid.hasBomb) {
                    /// 踩到炸彈遊戲結束
                    setState(() {
                      grid.isSearched = true;
                      _isGameOver = true;
                    });
                    return;
                  }
                  /// 如果採的位置有設置的旗子，
                  /// 但沒有炸彈則解除旗子的設置
                  if (
                    !grid.hasBomb &&
                    flags[y] is Map &&
                    flags[y][x] == true
                  ) {
                    flags[y].remove(x);
                  }
                  setState(() {
                    searchBomb(x, y);
                    _isGameWon = checkWin();
                    if (_isGameWon == true) {
                      /// 已達成獲勝條件
                      alertMessage(
                        context: context,
                        title: '厲害唷！',
                        okText: '新遊戲',
                        onOK: () {
                          Navigator.pop(context);
                          createGame();
                        }
                      );
                    }
                  });
                },
                onLongPress: () {
                  setState(() {
                    flags[y] ??= Map();
                    if (flags[y][x] == true) {
                      flags[y].remove(x);
                    } else {
                      flags[y][x] = true;
                    }
                    _isGameWon = checkWin();
                  });
                },
              ),
            );
          },
        ),
      ],
    );
  }
}

class GameGrid {
  bool hasBomb;
  bool isSearched;
  int aroundBombs;
  GameGrid({
    this.isSearched = false,
    this.hasBomb = false,
    this.aroundBombs = 0,
  });
}
