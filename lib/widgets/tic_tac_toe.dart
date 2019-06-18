import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

const int GRIDS = 9;

class TicTacToe extends StatefulWidget {
	TicTacToe({ Key key, }) : super(key: key);
	@override
	_TicTacToeState createState() => _TicTacToeState();
}

class _TicTacToeState extends State<TicTacToe> {
  int turn;
  int remainStep;
  int winner;
  List<int> grids;
  void reset() {
    setState(() {
      turn = 0;
      remainStep = GRIDS;
      winner = null;
      grids = List.filled(GRIDS, null);
    });
  }
  bool hasWin(int turn) {
    return (
      (grids[0] == turn && grids[0] == grids[1] && grids[0] == grids[2]) ||
      (grids[0] == turn && grids[0] == grids[3] && grids[0] == grids[6]) ||
      (grids[0] == turn && grids[0] == grids[4] && grids[0] == grids[8]) ||
      (grids[1] == turn && grids[1] == grids[4] && grids[1] == grids[7]) ||
      (grids[2] == turn && grids[2] == grids[5] && grids[2] == grids[8]) ||
      (grids[3] == turn && grids[3] == grids[4] && grids[3] == grids[5]) ||
      (grids[6] == turn && grids[6] == grids[7] && grids[6] == grids[8]) ||
      (grids[2] == turn && grids[2] == grids[4] && grids[2] == grids[6])
    );
  }
  @override
  void initState() {
    super.initState();
    reset();
  }
	@override
	Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        GridView.builder(
          physics: NeverScrollableScrollPhysics(),
          shrinkWrap: true,
          scrollDirection: Axis.vertical,
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            mainAxisSpacing: 8,
            crossAxisSpacing: 8,
          ),
          padding: EdgeInsets.all(8),
          itemCount: GRIDS,
          itemBuilder: (BuildContext context, int index) {
            int grid = grids[index];
            Widget widget;
            switch (grid) {
              case 0:
                widget = Icon(Icons.close); break;
              case 1:
                widget = Icon(Icons.radio_button_unchecked); break;
              default:
                widget = Text(''); break;
            }
            return IgnorePointer(
              ignoring: winner != null,
              child: InkWell(
                child: Container(
                  height: 240,
                  alignment: Alignment(0.0, 0.0),
                  color: winner == null ? Colors.black26 : Colors.black12,
                  child: widget,
                ),
                onTap: () {
                  setState(() {
                    grids[index] = turn;
                    print(grids);
                    if (hasWin(turn)) {
                      winner = turn;
                      print('$winner 獲勝');
                    } else if (grids.fold(true, (isFlat, grid) => isFlat && grid != null)) {
                      winner = -1;
                      print('平手');
                    }
                    turn = turn == 1 ? 0 : 1;
                  });
                },
              ),
            );
          },
        )
      ],
    );
  }
}