import 'package:flutter/material.dart';
import 'package:flutter_play_a_game/configs.dart';
import 'package:flutter_play_a_game/screens/home.dart';
import 'package:flutter_play_a_game/screens/initial.dart';
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
  Future<void> updateConfig(GameConfigs newConfigs) async {
    setState(() { configs = newConfigs; });
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setInt('mineweeperLevel', newConfigs.mineweeperLevel.index);
  }
  @override
  void initState() {
    super.initState();
  }
  @override
  void dispose() {
    super.dispose();
    // App 關閉
  }
  @override
  Widget build(BuildContext context) {
    return _AppStateContainer(
      state: this,
      child: MaterialApp(
        title: 'Play a Game',
        theme: ThemeData(
          primarySwatch: Colors.purple,
          accentColor: Colors.orangeAccent[400],
        ),
        initialRoute: '/initial',
        routes: {
          '/': (context) => HomeScreen(),
          '/initial': (context) => InitialScreen(),
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
