import 'dart:math';
import 'package:flutter/material.dart';

const int ROWS = 6;
const int COLUMNS = 3;

class Minesweeper extends StatefulWidget {
	Minesweeper({ Key key, }) : super(key: key);
	@override
	_MinesweeperState createState() => _MinesweeperState();
}

class _MinesweeperState extends State<Minesweeper> {
  final random = Random();
  final Map<int, Map<int, bool>> flags = Map();
  List<List<GameGrid>> grids;
  int totalBombs;
  bool isGameover = false;
  bool isWin = false;

  // TextEditingController textEditingController = TextEditingController();
  // int inputBombAmount;

  void createGame({ int bombAmount }) {
    bombAmount = min(bombAmount, ROWS * COLUMNS);
    int total = bombAmount;
    final List<List<GameGrid>> newGrids = List.generate(
      ROWS, (y) => List.generate(COLUMNS, (x) => GameGrid()),
    );
    while (bombAmount > 0) {
      final rY = random.nextInt(ROWS);
      final rX = random.nextInt(COLUMNS);
      if (!newGrids[rY][rX].hasBomb) {
        newGrids[rY][rX].hasBomb = true;
        bombAmount--;
      }
    }
    setState(() {
      flags.clear();
      this.grids = newGrids;
      totalBombs = total;
      isGameover = false;
    });
  }
  void searchBomb(int x, int y) {
    if (x < 0 || y < 0 || x >= COLUMNS || y >= ROWS) return;
    if (grids[y][x].isSearched) return;
    print('searchBomb: $y, $x');
    int bombs = 0;
    for (int i = -1; i <= 1; i++) {
      for (int j = -1; j <= 1; j++) {
        if (i == 0 && j == 0) continue;
        int ay = y + i;
        int ax = x + j;
        if (ax < 0 || ay < 0 || ax >= COLUMNS || ay >= ROWS) continue;
        final grid = grids[ay][ax];
        if (grid.hasBomb) {
          bombs += 1;
        }
      }
    }
    print('bombs: $bombs');
    grids[y][x].aroundBombs = bombs;
    grids[y][x].isSearched = true;
    if (bombs == 0) {
      for (int i = -1; i <= 1; i++) {
        for (int j = -1; j <= 1; j++) {
          if (i == 0 && j == 0) continue;
          int ay = y + i;
          int ax = x + j;
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
    if (totalBombs != flagCount) {
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
    createGame(bombAmount: 2);
  }
  @override
  Widget build(BuildContext context) {
    print('build');
    if (isGameover == true) {
      print('!!!!!!!!!!!!!!!!! Gameover !!!!!!!!!!!!!!!!!!');
    }
    if (isWin == true) {
      print('***************** You Win *****************');
    }

    return Column(
      children: <Widget>[
        // TextField(
        //   controller: textEditingController,
        //   onChanged: (text) {

        //   },
        // ),
        Container(
          margin: EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            color: Colors.grey,
            borderRadius: BorderRadius.all(Radius.circular(8)),
            border: Border(
              // left: BorderSide(color: Colors.black26, width: 15.0),
              // right: BorderSide(color: Colors.black26, width: 15.0),
              // top: BorderSide(color: Colors.black12, width: 10.0),
              // bottom: BorderSide(color: Colors.black12, width: 10.0),
            ),
          ),
          child: IconButton(
            icon: Icon(Icons.sentiment_satisfied),
            iconSize: 48.0,
            color: Colors.yellow[200],
            onPressed: () {
              createGame(bombAmount: 2);
            },
          ),
        ),
        GridView.builder(
          physics: NeverScrollableScrollPhysics(),
          shrinkWrap: true,
          scrollDirection: Axis.vertical,
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: ROWS,
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
                  widget = Text(grid.aroundBombs.toString());
              }
            } else if (
              flags[x] is Map &&
              flags[y][x] == true
            ) {
              widget = Icon(Icons.radio_button_checked);
            } else {
              widget = Text('');
            }
            return IgnorePointer(
              ignoring: isGameover,
              child: InkWell(
                child: Container(
                  alignment: Alignment(0.0, 0.0),
                  color: grid.isSearched && grid.hasBomb
                    ? Colors.red
                    : isGameover
                    ? Colors.black12
                    : Colors.black26,
                  child: widget,
                ),
                onTap: () {
                  if (!grid.isSearched && grid.hasBomb) {
                    setState(() {
                      grid.isSearched = true;
                      isGameover = true;
                    });
                    return;
                  }
                  setState(() {
                    searchBomb(x, y);
                    print('search over');
                    isWin = checkWin();
                    print('isWin: $isWin');
                  });
                },
                onLongPress: () {
                  setState(() {
                    if (flags[y] == null) flags[y] = Map();
                    flags[y][x] = true;
                    isWin = checkWin();
                    print('isWin: $isWin');
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
