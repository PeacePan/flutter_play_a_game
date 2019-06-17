import 'package:flutter/material.dart';
import 'package:flutter_minesweeper/screens/home.dart';

void main() => runApp(App());

class App extends StatefulWidget {
	App({ Key key }) : super(key: key);
	@override
	_AppState createState() => _AppState();
}

class _AppState extends State<App> {
  @override
  void initState() {
    super.initState();
    /// App 載入完成
  }
  @override
  void dispose() {
    super.dispose();
    /// App 關閉
  }
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Play a Game',
      theme: ThemeData(
        primarySwatch: Colors.purple,
        accentColor: Colors.orangeAccent[400],
      ),
      home: HomeScreen(),
    );
  }
}
