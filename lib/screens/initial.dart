import 'package:flutter/material.dart';
import 'package:flutter_minesweeper/configs.dart';
import 'package:flutter_minesweeper/main.dart';
import 'package:shared_preferences/shared_preferences.dart';

class InitialScreen extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _InitialScreenState();
}

class _InitialScreenState extends State<InitialScreen> {
  void initData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    int levelIndex = prefs.getInt('mineweeperLevel');
    Level mineweeperLevel = levelIndex != null
      ? Level.values[levelIndex]
      : Level.easy;
    AppState appState = App.of(context);
    appState.configs.mineweeperLevel = mineweeperLevel;
    await appState.updateConfig(appState.configs);
    await Navigator.pushNamed(context, '/');
    Navigator.pop(context);
  }
  @override
  void initState() {
    super.initState();
    initData();
  }
  @override
  void dispose() {
    super.dispose();
  }
  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      width: double.infinity,
      height: double.infinity,
    );
  }
}