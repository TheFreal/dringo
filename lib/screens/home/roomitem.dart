import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dringo/screens/gamescreen.dart';
import 'package:flutter/material.dart';

class RoomItem extends StatelessWidget {
  final String name;
  final int size;
  final int players;
  final int percent;
  final DateTime created;
  final DocumentReference ref;

  const RoomItem(
      {Key key,
      this.name,
      this.size,
      this.players,
      this.created,
      this.ref,
      this.percent})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 1,
      margin: EdgeInsets.fromLTRB(15, 20, 15, 0),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
        side: BorderSide(color: Colors.grey[200], width: 1),
      ),
      child: InkWell(
        onTap: () {
          Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => GameScreen(
                        ref: ref,
                        name: name,
                      )));
        },
        child: Padding(
          padding: EdgeInsets.all(25),
          child: Row(
            children: <Widget>[
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      name,
                      style: TextStyle(fontSize: 21),
                    ),
                    SizedBox(height: 5),
                    Text(
                        "${DateTime.now().difference(created).inHours}h ago  -  ${size}x$size board - $players Players - $percent% done"),
                  ],
                ),
              ),
              Icon(Icons.grid_on)
            ],
          ),
        ),
      ),
    );
  }
}
