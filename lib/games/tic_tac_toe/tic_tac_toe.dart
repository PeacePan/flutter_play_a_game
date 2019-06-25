import 'dart:math';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_play_a_game/utlis.dart';

const int GRIDS = 9;
/// 隨機產生器種子
final randomGenerator = Random(DateTime.now().microsecondsSinceEpoch);

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
      turn = randomGenerator.nextInt(2);
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
                  alignment: Alignment.center,
                  color: winner == null ? Colors.black26 : Colors.black12,
                  child: widget,
                ),
                onTap: () {
                  if (grids[index] != null) {
                    alertMessage(
                      context: context,
                      title: '此格已下過',
                      okText: '知道了',
                      onOK: () { Navigator.pop(context); }
                    );
                    return;
                  }
                  setState(() {
                    grids[index] = turn;
                    if (hasWin(turn)) {
                      winner = turn;
                      alertMessage(
                        context: context,
                        titlePrefix: Icon(winner == 0 ? Icons.close : Icons.radio_button_unchecked),
                        title: ' 獲勝了',
                        okText: '再玩一次',
                        onOK: () {
                          Navigator.pop(context);
                          reset();
                        }
                      );
                    } else if (grids.fold(true, (isFlat, grid) => isFlat && grid != null)) {
                      winner = -1;
                      alertMessage(
                        context: context,
                        title: '平手',
                        okText: '再玩一次',
                        onOK: () {
                          Navigator.pop(context);
                          reset();
                        }
                      );
                    }
                    turn = turn == 1 ? 0 : 1;
                  });
                },
              ),
            );
          },
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('輪到 '),
            Icon(turn == 0 ? Icons.close : Icons.radio_button_unchecked),
          ],
        ),
        Container(
          alignment: Alignment.center,
          child: RaisedButton(
            child: Text('重來'),
            onPressed: reset,
          ),
        ),
      ],
    );
  }
}