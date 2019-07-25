import 'package:flutter_web/material.dart';
import 'package:flutter_web/cupertino.dart';

class Loading extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: Alignment.center,
      color: Colors.white,
      width: double.infinity,
      height: double.infinity,
      child: CircularProgressIndicator(
        backgroundColor: Colors.transparent,
      ),
    );
  }
}
