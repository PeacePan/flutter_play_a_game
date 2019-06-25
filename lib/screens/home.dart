import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_play_a_game/games/mineaweeper/minesweeper.dart';
// import 'package:flutter_play_a_game/games/number_2048/number_2048.dart';
import 'package:flutter_play_a_game/games/tetris/tetris.dart';
import 'package:flutter_play_a_game/games/tic_tac_toe/tic_tac_toe.dart';
import 'package:flutter_play_a_game/layout.dart';

class HomeScreen extends StatefulWidget {
	HomeScreen({ Key key, }) : super(key: key);
	@override
	_HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
	@override
	Widget build(BuildContext context) {
    return Layout(
      initialState: LayoutState(
        currentBottomNavIndex: 0,
      ),
      children: [
        Minesweeper(),
        TicTacToe(),
        Tetris(),
        // Number2048(),
      ],
    );
  }
}