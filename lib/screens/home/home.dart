import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dringo/screens/home/serverlist.dart';
import 'package:dringo/screens/newgame/boardbuiler.dart';
import 'package:dringo/screens/newgame/gamegen.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:dringo/services/auth.dart';
import 'package:flutter/material.dart';

class Home extends StatelessWidget {
  final AuthService _auth = AuthService();
  Key scaffoldKey = Key("big_ol_scaffold");

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: scaffoldKey,
      backgroundColor: Colors.white,
      bottomNavigationBar: Builder(builder: (context) {
        return BottomNavigationBar(
          items: [
            BottomNavigationBarItem(
              icon: Icon(Icons.group),
              title: Text("My games"),
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.grid_on),
              title: Text("Public boards"),
            ),
          ],
          currentIndex: 0,
          selectedItemColor: Theme.of(context).primaryColor,
          onTap: (selected) {
            if (selected == 1) {
              Scaffold.of(context).showSnackBar(SnackBar(
                content: Text("Nope, that's not ready yet"),
              ));
            }
          },
        );
      }),
      appBar: AppBar(
        title: Text("Dringo"),
        backgroundColor: Colors.red,
        elevation: 0,
        actions: <Widget>[
          FlatButton.icon(
            onPressed: () async {
              await _auth.signOut();
            },
            icon: Icon(Icons.person),
            label: Text("Logout"),
          )
        ],
      ),
      floatingActionButton: SpeedDial(
        child: Icon(Icons.add),
        children: [
          SpeedDialChild(
              label: "Generate a new game",
              child: Icon(Icons.casino),
              onTap: () {
                Navigator.of(context)
                    .push(MaterialPageRoute(builder: (context) => GameGen()));
              }),
          SpeedDialChild(
              label: "Build your own board",
              child: Icon(Icons.edit),
              onTap: () {
                Navigator.of(context).push(
                    MaterialPageRoute(builder: (context) => BoardBuilder()));
              }),
        ],
      ),
      body: ServerList(),
    );
  }
}
