import 'dart:io';
import 'package:flutter/material.dart';

class LayoutStateContainer extends InheritedWidget {
  final LayoutState state;
  LayoutStateContainer({
    @required this.state,
    @required Widget child,
  }) : super(child: child);

  @override
  bool updateShouldNotify(LayoutStateContainer old) => true;
}

class Layout extends StatefulWidget {
  final LayoutState initialState;
  final List<Widget> children;

  Layout({
    this.initialState,
    @required this.children,
  });
  static LayoutState of(BuildContext context) {
    final LayoutStateContainer widgetInstance = context.inheritFromWidgetOfExactType(LayoutStateContainer);
    return widgetInstance.state;
  }
  @override
  LayoutState createState() => LayoutState(
    title: this.initialState?.title,
    currentBottomNavIndex: this.initialState?.currentBottomNavIndex,
  );
}

class LayoutState extends State<Layout> {
  String title;
  int currentBottomNavIndex;
  LayoutState({
    this.title = '',
    this.currentBottomNavIndex = 0,
  });
  void updateTitle(String newTitle) {
    setState(() {
      title = newTitle;
    });
  }
  void updateBottomNavIndex(int newIndex) {
    setState(() {
      currentBottomNavIndex = newIndex;
    });
  }
  @override
  void initState() {
    super.initState();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: <Widget>[
            ListTile(
              title: Text('離開'),
              onTap: () {
                exit(0);
              },
            ),
          ],
        ),
      ),
      body: widget.children[currentBottomNavIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: currentBottomNavIndex,
        onTap: updateBottomNavIndex,
        items: <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            title: Text('井字遊戲'),
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.mail),
            title: Text('踩地雷'),
          ),
        ],
      ),
    );
  }
}