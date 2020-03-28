import 'package:dringo/screens/newgame/gamegenform.dart';
import 'package:flutter/material.dart';

class GameGen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("New game"),
        backgroundColor: Colors.red,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Padding(
          child: GameGenForm(),
          padding: EdgeInsets.all(30),
        ),
      ),
    );
  }
}
