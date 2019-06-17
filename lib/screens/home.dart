import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_minesweeper/layout.dart';
import 'package:flutter_minesweeper/widgets/minesweeper%20/minesweeper.dart';
import 'package:flutter_minesweeper/widgets/tic_tac_toe.dart';

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
        title: '玩個遊戲',
        currentBottomNavIndex: 0
      ),
      children: [
        TicTacToe(),
        Minesweeper(),
      ],
    );
  }
}