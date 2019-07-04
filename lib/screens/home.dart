import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_play_a_game/configs.dart';
import 'package:flutter_play_a_game/games/mineaweeper/minesweeper.dart';
// import 'package:flutter_play_a_game/games/number_2048/number_2048.dart';
import 'package:flutter_play_a_game/games/tetris/tetris.dart';
import 'package:flutter_play_a_game/games/tic_tac_toe/tic_tac_toe.dart';
import 'package:flutter_play_a_game/layout.dart';
import 'package:flutter_play_a_game/main.dart';
import 'package:flutter_play_a_game/widgets/loading.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HomeScreen extends StatefulWidget {
	HomeScreen({ Key key, }) : super(key: key);
	@override
	_HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool _inited = false;
  void _initData() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      int levelIndex = prefs.getInt('mineweeperLevel');
      Level mineweeperLevel = levelIndex != null
        ? Level.values[levelIndex]
        : Level.easy;
      AppState appState = App.of(context);
      appState.configs.mineweeperLevel = mineweeperLevel;
      await appState.updateConfig(appState.configs);
    } catch (ex) {
      print(ex);
    } finally {
      setState(() { _inited = true; });
    }
  }
  @override
  void initState() {
    super.initState();
    _initData();
  }
	@override
	Widget build(BuildContext context) {
    if (!_inited) return Loading();
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