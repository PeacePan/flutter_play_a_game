import 'dart:io' show Platform;
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';

class Loading extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final child = Platform.isIOS
      ? CupertinoActivityIndicator()
      : CircularProgressIndicator(
        backgroundColor: Colors.transparent,
      );
    return Container(
      alignment: Alignment.center,
      color: Colors.white,
      width: double.infinity,
      height: double.infinity,
      child: child,
    );
  }
}
