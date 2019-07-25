import 'package:flutter_web/cupertino.dart';
import 'package:flutter_web/material.dart';
import 'package:flutter_web/widgets.dart';
import '../games/mineaweeper/minesweeper.dart';
// import '../games/number_2048/number_2048.dart';
import '../games/tetris/tetris.dart';
import '../games/tic_tac_toe/tic_tac_toe.dart';
import '../widgets/loading.dart';
import '../configs.dart';
import '../layout.dart';
import '../main.dart';

class HomeScreen extends StatefulWidget {
	HomeScreen({ Key key, }) : super(key: key);
	@override
	_HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool _inited = false;
  void _initData() async {
    try {
      Level mineweeperLevel = Level.easy;
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
        Tetris(),
        Minesweeper(),
        TicTacToe(),
        // Number2048(),
      ],
    );
  }
}