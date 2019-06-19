import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_minesweeper/widgets/swipeable.dart';

const GRIDS = 3;
const PANNING_LIMIT = 20;
/// 隨機產生器種子
final randomGenerator = Random(DateTime.now().microsecondsSinceEpoch);

class Game2048 extends StatefulWidget {
	Game2048({ Key key, }) : super(key: key);
	@override
	_Game2048State createState() => _Game2048State();
}

class _Game2048State extends State<Game2048> {
  /// 每個格子單位
  final List<List<GameGrid>> grids = List();
  bool get isAllFilled {
    for (int y = 0; y < GRIDS; y++) {
      for (int x = 0; x < GRIDS; x++) {
        if (grids[y][x].number == null) return false;
      }
    }
    return true;
  }
  void resetGrids() {
    grids.clear();
    for (int r = 0; r < GRIDS; r++) {
      grids.add(List.generate(GRIDS, (x) => GameGrid()));
    }
  }
  void randomFillGrids() {
    int fill = 2;
    while (fill > 0) {
      if (isAllFilled) break;
      int y = randomGenerator.nextInt(GRIDS);
      int x = randomGenerator.nextInt(GRIDS);
      if (grids[y][x].number == null) {
        grids[y][x].number = 2;
        fill--;
      }
    }
  }
  @override
  void initState() {
    super.initState();
    resetGrids();
    randomFillGrids();
  }
	@override
	Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        Container(
          alignment: Alignment.center,
          padding: EdgeInsets.all(16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Column(
                children: <Widget>[
                  Text('得分'),
                  Text('2409'),
                ],
              ),
              Column(
                children: <Widget>[
                  Text('最高'),
                  Text('2409'),
                ],
              )
            ],
          ),
        ),
        Container(
          alignment: Alignment.center,
          padding: EdgeInsets.all(16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              IconButton(
                icon: Icon(Icons.redo),
                onPressed: () {},
              ),
              IconButton(
                color: Colors.redAccent,
                icon: Icon(Icons.sync),
                onPressed: () {},
              ),
            ],
          ),
        ),
        Swipeable(
          child: GridView.builder(
            physics: NeverScrollableScrollPhysics(),
            shrinkWrap: true,
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: GRIDS,
              mainAxisSpacing: 2,
              crossAxisSpacing: 2,
            ),
            padding: EdgeInsets.all(16),
            itemCount: GRIDS * GRIDS,
            itemBuilder: (BuildContext context, int index) {
              int y = (index / GRIDS).floor();
              int x = index - (GRIDS * y);
              final grid = grids[y][x];
              return Container(
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: Colors.black12,
                  border: Border(
                    left: BorderSide(color: Colors.grey[300], width: 4),
                    top: BorderSide(color: Colors.grey[300], width: 4),
                    right: BorderSide(color: Colors.black26, width: 4),
                    bottom: BorderSide(color: Colors.black26, width: 4),
                  ),
                ),
                child: Text(
                  grid.number != null ? grid.number.toString() : '',
                  style: TextStyle(fontSize: 24),),
              );
            },
          ),
          onSwipe: (SwipeDirection direction) {
            switch (direction) {
              case SwipeDirection.up:
                break;
              case SwipeDirection.down:
                break;
              case SwipeDirection.left:
                break;
              case SwipeDirection.right:
                break;
              case SwipeDirection.downLeft:
              case SwipeDirection.downRight:
              case SwipeDirection.upLeft:
              case SwipeDirection.upRight:
              default:
                break;
            }
          },
        ),
      ],
    );
  }
}

class GameGrid {
  int number;
  GameGrid({
    this.number,
  });
}