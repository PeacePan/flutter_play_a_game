import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_play_a_game/configs.dart';

typedef void ConfigUpdater(GameConfigs configs);

class SettingsScreen extends StatefulWidget {
  final GameConfigs configs;
  final ConfigUpdater configUpdater;
  SettingsScreen({
    Key key,
    @required this.configs,
    @required this.configUpdater,
  }) : super(key: key);
	@override
	_SettingsScreenState createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  Level currentMineweeperLevel;
  @override
  void initState() {
    super.initState();
    currentMineweeperLevel = widget.configs.mineweeperLevel;
  }
  @override
	Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('設定'),
      ),
      backgroundColor: Colors.white,
      body: ListView(
        children: <Widget>[
          Container(
            padding: EdgeInsets.only(left: 16, right: 16, top: 16),
            child: Text('踩地雷'),
          ),
          ListTile(
            title: Text('難度'),
            trailing: Text(LevelText[currentMineweeperLevel]),
            onTap: () async {
              showCupertinoModalPopup(
                context: context,
                builder: (BuildContext popupContext) {
                  void setLevel(Level level) {
                      widget.configs.mineweeperLevel = level;
                      widget.configUpdater(widget.configs);
                      Navigator.pop(popupContext);
                      setState(() {
                        currentMineweeperLevel = level;
                      });
                  }
                  return CupertinoActionSheet(
                    title: Text('設定難度'),
                    actions: <Widget>[
                      CupertinoButton(
                        child: Text(LevelText[Level.easy]),
                        onPressed: () => setLevel(Level.easy),
                      ),
                      CupertinoButton(
                        child: Text(LevelText[Level.medium]),
                        onPressed: () => setLevel(Level.medium),
                      ),
                      CupertinoButton(
                        child: Text(LevelText[Level.difficult]),
                        onPressed: () => setLevel(Level.difficult),
                      ),
                    ],
                    cancelButton: CupertinoButton(
                      child: Text('取消'),
                      onPressed: () {
                        Navigator.pop(popupContext);
                      },
                    ),
                  );
                },
              );
            },
          ),
        ],
      ),
    );
  }
}
