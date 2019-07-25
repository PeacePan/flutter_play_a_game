import 'package:flutter_web/material.dart';
import 'main.dart';
import 'screens/settings.dart';

const ICON_TITLES = [
  '俄羅斯方塊',
  '踩地雷',
  '井字遊戲',
];

class Layout extends StatefulWidget {
  final LayoutState initialState;
  final List<Widget> children;
  Layout({
    this.initialState,
    @required this.children,
  });
  @override
  LayoutState createState() => LayoutState(
    title: this.initialState?.title,
    currentBottomNavIndex: this.initialState?.currentBottomNavIndex,
  );
}

class LayoutState extends State<Layout> {
  final bool hideBottomNav;
  String title;
  int currentBottomNavIndex;
  LayoutState({
    this.title = '',
    this.currentBottomNavIndex = 0,
    this.hideBottomNav = false,
  });
  void updateTitle(String newTitle) {
    setState(() {
      title = newTitle;
    });
  }
  void updateBottomNavIndex(int newIndex) {
    setState(() {
      currentBottomNavIndex = newIndex;
      title = ICON_TITLES[newIndex];
    });
  }
  @override
  void initState() {
    super.initState();
    if (!hideBottomNav) {
      updateTitle(ICON_TITLES[currentBottomNavIndex]);
    }
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.settings),
            onPressed: onPressSettings,
          )
        ],
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: <Widget>[
            DrawerHeader(
              child: Text(
                '玩個遊戲',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                ),
              ),
              decoration: BoxDecoration(
                color: Colors.blue,
              ),
            ),
          ],
        ),
      ),
      body: Center(
        child: Container(
          alignment: Alignment.topCenter,
          constraints: BoxConstraints(
            maxWidth: 375,
            maxHeight: 667,
          ),
          child: widget.children[currentBottomNavIndex],
        ),
      ),
      bottomNavigationBar: hideBottomNav
        ? null
        : BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: currentBottomNavIndex,
        onTap: updateBottomNavIndex,
        items: <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.gamepad),
            title: Text(ICON_TITLES[0]),
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.brightness_high),
            title: Text(ICON_TITLES[1]),
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.grid_on),
            title: Text(ICON_TITLES[2]),
          ),
        ],
      ),
    );
  }
  void onPressSettings() {
    Navigator.push(context, MaterialPageRoute<Null>(
      builder: (BuildContext context) {
        final state = App.of(context);
        return SettingsScreen(
          configs: state.configs,
          configUpdater: state.updateConfig,
        );
      },
      fullscreenDialog: true,
    ));
  }
}
