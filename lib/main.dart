import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_minesweeper/configs.dart';
import 'package:flutter_minesweeper/screens/home.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() => runApp(App());

class App extends StatefulWidget {
	App({ Key key }) : super(key: key);
  static AppState of(BuildContext context) {
    final _AppStateContainer widgetInstance = context.inheritFromWidgetOfExactType(_AppStateContainer);
    return widgetInstance.state;
  }
	@override
	AppState createState() => AppState();
}

class AppState extends State<App> {
  GameConfigs configs = GameConfigs(mineweeperLevel: Level.easy);
  void updateConfig(GameConfigs newConfigs) async {
    setState(() { configs = newConfigs; });
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setInt('mineweeperLevel', newConfigs.mineweeperLevel.index);
    print('set mineweeperLevel: ${newConfigs.mineweeperLevel.index}');
  }
  @override
  void initState() {
    super.initState();
    // () async {
    //   print('SharedPreferences loading');
    //   SharedPreferences prefs = await SharedPreferences.getInstance();
    //   int levelIndex = prefs.getInt('mineweeperLevel');
    //   Level mineweeperLevel = levelIndex != null
    //     ? Level.values[levelIndex]
    //     : Level.easy;
    //   print('mineweeperLevel: $mineweeperLevel');
    //   // App 載入完成
    //   setState(() {
    //     configs.mineweeperLevel = mineweeperLevel;
    //   });
    //   print('SharedPreferences loaded');
    // }();
  }
  @override
  void dispose() {
    super.dispose();
    // App 關閉
  }
  Future<SharedPreferences> getPrefs() async {
    return await SharedPreferences.getInstance();
  }
  @override
  Widget build(BuildContext context) {
    return _AppStateContainer(
      state: this,
      child: FutureBuilder<SharedPreferences>(
        future: getPrefs(),
        builder: (BuildContext context, AsyncSnapshot<SharedPreferences> snapshot) {
          switch (snapshot.connectionState) {
            case ConnectionState.none:
            case ConnectionState.waiting:
              return Container(
                color: Colors.white,
                width: 0,
                height: 0,
              );
            default:
              print('SharedPreferences loading');
              SharedPreferences prefs = snapshot.data;
              int levelIndex = prefs.getInt('mineweeperLevel');
              print('levelIndex: $levelIndex');
              Level mineweeperLevel = levelIndex != null
                ? Level.values[levelIndex]
                : Level.easy;
              print('mineweeperLevel: $mineweeperLevel');
              configs.mineweeperLevel = mineweeperLevel;
              print('SharedPreferences loaded');
              return MaterialApp(
                title: 'Play a Game',
                theme: ThemeData(
                  primarySwatch: Colors.purple,
                  accentColor: Colors.orangeAccent[400],
                ),
                home: HomeScreen(),
              );
          }
        },
      ),
    );
  }
}


class _AppStateContainer extends InheritedWidget {
  final AppState state;
  _AppStateContainer({
    @required this.state,
    @required Widget child,
  }) : super(child: child);
  @override
  bool updateShouldNotify(_AppStateContainer old) => true;
}