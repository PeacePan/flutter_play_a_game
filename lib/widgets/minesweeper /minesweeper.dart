import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';

const int ROWS = 6;
const int COLUMNS = 5;

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
const ONE_SEC = const Duration(seconds: 1);

class Minesweeper extends StatefulWidget {
	Minesweeper({ Key key, }) : super(key: key);
	@override
	_MinesweeperState createState() => _MinesweeperState();
}

class _MinesweeperState extends State<Minesweeper> {
  /// 隨機產生數字
  final _random = Random();
  /// 炸彈旗標設置 (座標對應布林值)
  final Map<int, Map<int, bool>> flags = Map();
  /// 每個格子單位
  List<List<GameGrid>> grids;
  /// 全部的炸彈數量
  int _totalBombs;
  /// 是否踩到炸彈遊戲結束
  bool _isGameover = false;
  /// 所有格子全搜尋，設置旗子數等於所有炸彈數
  bool _isWin = false;
  /// 計數遊戲時間
  Timer _timer;
  /// 一場遊戲開始時間
  DateTime gameStart;
  /// 一場遊戲結束時間
  DateTime gameEnd;
  /// 建立新遊戲
  void createGame({ int bombAmount }) {
    bombAmount = min(bombAmount, ROWS * COLUMNS);
    int total = bombAmount;
    final List<List<GameGrid>> newGrids = List.generate(
      ROWS, (y) => List.generate(COLUMNS, (x) => GameGrid()),
    );
    while (bombAmount > 0) {
      final rY = _random.nextInt(ROWS);
      final rX = _random.nextInt(COLUMNS);
      if (!newGrids[rY][rX].hasBomb) {
        newGrids[rY][rX].hasBomb = true;
        bombAmount--;
      }
    }
    setState(() {
      flags.clear();
      this.grids = newGrids;
      _totalBombs = total;
      _isGameover = false;
      if (_timer != null) _timer.cancel();
      _timer = Timer.periodic(ONE_SEC, (Timer timer) {
          if (_isGameover || _isWin) {
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
  bool checkWin() {
    int flagCount = 0;
    flags.forEach((index, row) {
        flagCount += row.entries.length;
    });
    print('flagCount: $flagCount');
    if (_totalBombs != flagCount) {
      return false;
    }
    int searchedCount = 0;
    grids.forEach((row) {
      row.forEach((col) {
        if (col.isSearched) searchedCount++;
      });
    });
    print('searchedCount + flagCount: ${searchedCount + flagCount}');
    print('ROWS * COLUMNS: ${ROWS * COLUMNS}');
    return searchedCount + flagCount == ROWS * COLUMNS;
  }
  @override
  void initState() {
    super.initState();
    // textEditingController.text = '';
    createGame(bombAmount: 5);
  }
  @override
  void dispose() {
    if (_timer != null) _timer.cancel();
    super.dispose();
  }
  @override
  Widget build(BuildContext context) {
    print('build');
    if (_isGameover == true) {
      print('!!!!!!!!!!!!!!!!! Gameover !!!!!!!!!!!!!!!!!!');
    }
    if (_isWin == true) {
      print('***************** You Win *****************');
    }

    return ListView(
      children: <Widget>[
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Container(
              margin: EdgeInsets.symmetric(vertical: 8),
              decoration: BoxDecoration(
                color: Colors.grey,
                borderRadius: BorderRadius.all(Radius.circular(48)),
                border: Border(
                  // left: BorderSide(color: Colors.black26, width: 15.0),
                  // right: BorderSide(color: Colors.black26, width: 15.0),
                  // top: BorderSide(color: Colors.black12, width: 10.0),
                  // bottom: BorderSide(color: Colors.black12, width: 10.0),
                ),
              ),
              child: IconButton(
                icon: Icon(
                  _isGameover
                    ? Icons.sentiment_very_dissatisfied
                    : Icons.sentiment_satisfied
                ),
                iconSize: 48.0,
                color: Colors.yellow[200],
                onPressed: () {
                  createGame(bombAmount: 5);
                },
              ),
            )
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
                widget = Icon(Icons.close);
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
              widget = Icon(Icons.assistant_photo);
            } else {
              widget = Text('');
            }
            return IgnorePointer(
              ignoring: _isGameover || _isWin,
              child: InkWell(
                child: Container(
                  alignment: Alignment(0.0, 0.0),
                  decoration: BoxDecoration(
                    color: grid.isSearched && grid.hasBomb
                      ? Colors.red
                      : _isGameover
                      ? Colors.black12
                      : Colors.black26,
                    border: grid.isSearched
                      ? null
                      : Border(
                      left: BorderSide(color: Colors.grey[300], width: 6),
                      top: BorderSide(color: Colors.grey[300], width: 6),
                      right: BorderSide(color: Colors.black26, width: 6),
                      bottom: BorderSide(color: Colors.black26, width: 6),
                    ),
                  ),
                  child: widget,
                ),
                onTap: () {
                  if (!grid.isSearched && grid.hasBomb) {
                    setState(() {
                      grid.isSearched = true;
                      _isGameover = true;
                    });
                    return;
                  }
                  setState(() {
                    searchBomb(x, y);
                    _isWin = checkWin();
                  });
                },
                onLongPress: () {
                  setState(() {
                    if (flags[y] == null) flags[y] = Map();
                    flags[y][x] = true;
                    _isWin = checkWin();
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
  bool hasBomb = false;
  bool isSearched = false;
  int aroundBombs = 0;
  GameGrid();
}
