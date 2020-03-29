import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dringo/models/user.dart';
import 'package:dringo/screens/gamescreen.dart';
import 'package:dringo/screens/home/roomitem.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ServerList extends StatelessWidget {
  TextEditingController _textFieldController = TextEditingController();

  final db = Firestore.instance;

  _displayDialog(BuildContext parentContext) async {
    String userId = Provider.of<User>(parentContext, listen: false).uid;
    return showDialog(
        context: parentContext,
        builder: (context) {
          return AlertDialog(
              title: Text('Going straight to the party, I see?'),
              content: TextFormField(
                textAlign: TextAlign.center,
                maxLength: 4,
                keyboardType: TextInputType.visiblePassword,
                maxLengthEnforced: true,
                textCapitalization: TextCapitalization.characters,
                style: TextStyle(
                    fontSize: 25, color: Theme.of(context).primaryColor),
                controller: _textFieldController,
                decoration: InputDecoration(hintText: "Invite code"),
              ),
              actions: <Widget>[
                new FlatButton(
                  child: new Text('CANCEL'),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
                new FlatButton(
                    child: new Text('JOIN'),
                    onPressed: (() async {
                      if (_textFieldController.text.length < 4) {
                        Navigator.of(context).pop();
                        Scaffold.of(parentContext).showSnackBar(SnackBar(
                          content: Text(
                              "Make sure your friends didn't give you a fake invite code"),
                        ));
                      } else {
                        DocumentSnapshot roomProbe = await db
                            .collection("rooms")
                            .document(
                                _textFieldController.value.text.toUpperCase())
                            .get();
                        if (roomProbe.exists) {
                          // add the user to the game and the game to the user
                          var batch = db.batch();
                          batch.updateData(roomProbe.reference, {
                            "players": FieldValue.arrayUnion([userId])
                          });
                          batch.updateData(
                            db.collection("users").document(userId),
                            {
                              "rooms": FieldValue.arrayUnion([
                                _textFieldController.value.text.toUpperCase()
                              ])
                            },
                          );
                          await batch.commit();
                          Navigator.of(context)
                              .pushReplacement(MaterialPageRoute(
                                  builder: (context) => GameScreen(
                                        name: roomProbe.data["name"],
                                        ref: roomProbe.reference,
                                      )));
                        } else {
                          Navigator.of(context).pop();
                          Scaffold.of(parentContext).showSnackBar(SnackBar(
                            content: Text(
                                "Couldn't find a room for that invite code :/"),
                          ));
                        }
                      }
                    }))
              ]);
        });
  }

  int getDoneness(List board) {
    var allFields = board.length;
    var complete = board.where((cell) => cell["done"]).length;
    return ((complete / allFields) * 100).round();
  }

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<User>(context, listen: false);
    return StreamBuilder<QuerySnapshot>(
      stream: db
          .collection('rooms')
          .where("players", arrayContains: user.uid)
          .orderBy('created_at', descending: true)
          .snapshots(),
      builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
        if (snapshot.hasError) return new Text('Error: ${snapshot.error}');
        switch (snapshot.connectionState) {
          case ConnectionState.waiting:
            return new Text('Loading...');
          default:
            // add all rooms to a big list
            List<Widget> allItems = [
              Padding(
                padding: const EdgeInsets.fromLTRB(15, 15, 15, 0),
                child: FlatButton(
                  shape: RoundedRectangleBorder(
                      borderRadius: new BorderRadius.circular(15.0),
                      side: BorderSide(color: Colors.red[300], width: 2)),
                  color: Colors.white,
                  onPressed: () => _displayDialog(context),
                  child: SizedBox(
                    width: double.infinity,
                    child: Padding(
                      padding: EdgeInsets.all(20),
                      child: Center(
                        child: Text(
                          'JOIN THROUGH INVITE CODE',
                          style: TextStyle(color: Colors.red, fontSize: 18),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              SizedBox(
                height: 20,
              ),
            ];
            List<Widget> roomItems =
                snapshot.data.documents.map((DocumentSnapshot document) {
              return new RoomItem(
                name: document['name'],
                size: document['size'],
                created: (document['created_at'] as Timestamp).toDate(),
                ref: document.reference,
                players: document['players'].length,
                percent: getDoneness(document['board']),
              );
            }).toList();
            allItems.insertAll(1, roomItems);
            return ListView(children: allItems);
        }
      },
    );
  }
}
