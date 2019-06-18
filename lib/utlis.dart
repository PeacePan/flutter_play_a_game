import 'package:flutter/material.dart';

Future<T> alertMessage<T>({
  @required BuildContext context,
  @required String title,
  @required String okText,
  Widget titlePrefix,
  String cancelText,
  VoidCallback onOK,
  VoidCallback onCancel,
}) {
  return showDialog<T>(
    context: context,
    builder: (BuildContext context) {
      final titleWidgets = <Widget>[
        Text(title, style: TextStyle(fontSize: 32)),
      ];
      if (titlePrefix != null) {
        titleWidgets.insert(0, titlePrefix);
      }
      final actionWidgets = <Widget>[
        SimpleDialogOption(
          child: Text(okText),
          onPressed: onOK,
        ),
      ];
      if (cancelText != null) {
        actionWidgets.add(
          SimpleDialogOption(
            child: Text(cancelText),
            onPressed: onCancel,
          )
        );
      }
      return SimpleDialog(
        title: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: titleWidgets,
        ),
        children: actionWidgets,
      );
    },
  );
}