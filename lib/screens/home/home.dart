import 'package:dringo/screens/home/serverlist.dart';
import 'package:dringo/services/auth.dart';
import 'package:flutter/material.dart';

class Home extends StatelessWidget {
  final AuthService _auth = AuthService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      bottomNavigationBar: BottomNavigationBar(items: [
        BottomNavigationBarItem(
          icon: Icon(Icons.group),
          title: Text("Games"),
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.grid_on),
          title: Text("Boards"),
        ),
      ]),
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
      body: ServerList(),
    );
  }
}
