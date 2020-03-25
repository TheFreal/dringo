import 'package:flutter/material.dart';

class RoomItem extends StatelessWidget {
  final String name;
  final int size;
  final int players;
  final DateTime created;

  const RoomItem({Key key, this.name, this.size, this.players, this.created})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      margin: EdgeInsets.fromLTRB(15, 20, 15, 0),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
        side: BorderSide(color: Colors.grey[300], width: 1),
      ),
      child: Padding(
        padding: EdgeInsets.all(25),
        child: Column(
          children: <Widget>[
            Text(
              name,
              style: TextStyle(fontSize: 21),
            ),
            SizedBox(height: 5),
            Text(
                "${DateTime.now().difference(created).inHours}h ago  -  ${size}x$size board"),
          ],
        ),
      ),
    );
  }
}
