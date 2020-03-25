import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dringo/screens/home/roomitem.dart';
import 'package:flutter/material.dart';

class ServerList extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: Firestore.instance.collection('rooms').snapshots(),
      builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
        if (snapshot.hasError) return new Text('Error: ${snapshot.error}');
        switch (snapshot.connectionState) {
          case ConnectionState.waiting:
            return new Text('Loading...');
          default:
            return new ListView(
              children:
                  snapshot.data.documents.map((DocumentSnapshot document) {
                return new RoomItem(
                  name: document['name'],
                  size: document['size'],
                  created: (document['created_at'] as Timestamp).toDate(),
                );
              }).toList(),
            );
        }
      },
    );
  }
}
