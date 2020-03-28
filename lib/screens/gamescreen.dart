import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dringo/models/user.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

enum PopupActions {
  delete,
  share,
  copy,
}

class GameScreen extends StatelessWidget {
  final DocumentReference ref;
  final String name;

  const GameScreen({Key key, this.ref, this.name}) : super(key: key);

  List<TableRow> buildBoard({size, board, gameId}) {
    // step through all fields there should be
    int _cellNr = 0;
    List<TableRow> _board = [];
    for (var i = 0; i < size; i++) {
      List<BoardCell> _currentRow = [];
      for (var j = 0; j < size; j++) {
        _currentRow
            .add(BoardCell(cellNr: _cellNr, gameId: gameId, fullBoard: board));
        _cellNr++;
      }
      _board.add(TableRow(children: _currentRow));
    }
    return _board;
  }

  @override
  Widget build(BuildContext context) {
    final User user = Provider.of<User>(context);
    return StreamBuilder<DocumentSnapshot>(
      stream: ref.snapshots(),
      builder:
          (BuildContext context, AsyncSnapshot<DocumentSnapshot> snapshot) {
        if (!snapshot.data.exists) {
          Navigator.of(context).popUntil((route) => route.isFirst);
        }
        return Scaffold(
          backgroundColor: Colors.white,
          appBar: PreferredSize(
            preferredSize: Size.fromHeight(56),
            child: Builder(builder: (context) {
              return AppBar(
                actions: <Widget>[
                  PopupMenuButton<PopupActions>(
                    onSelected: (action) {
                      switch (action) {
                        case PopupActions.delete:
                          if (user.uid == snapshot.data.data["creator"]) {
                            ref.delete();
                          } else {
                            Scaffold.of(context).showSnackBar(SnackBar(
                              content: Text(
                                  "Only the creator of this room can delete it"),
                            ));
                          }
                          break;
                        default:
                      }
                    },
                    itemBuilder: (BuildContext context) {
                      return [
                        PopupMenuItem<PopupActions>(
                          value: PopupActions.delete,
                          child: Text("Delete this room"),
                        )
                      ];
                    },
                  ),
                ],
                title: Text(name),
                backgroundColor: Colors.red,
                elevation: 0,
              );
            }),
          ),
          body: Center(
            child: Builder(builder: (BuildContext context) {
              if (snapshot.hasError)
                return new Text('Error: ${snapshot.error}');
              switch (snapshot.connectionState) {
                case ConnectionState.waiting:
                  return Text('Loading...');
                default:
                  List board = snapshot.data.data["board"];
                  return Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Text("Invite code: ${snapshot.data.documentID}"),
                      SizedBox(height: 20),
                      Table(
                          border: TableBorder.all(
                              color: Colors.grey[300], width: 2),
                          defaultColumnWidth: FractionColumnWidth(
                              0.9 / snapshot.data.data["size"]),
                          children: buildBoard(
                            size: snapshot.data.data["size"],
                            board: board,
                            gameId: snapshot.data.documentID,
                          )),
                    ],
                  );
              }
            }),
          ),
        );
      },
    );
  }
}

class BoardCell extends StatefulWidget {
  const BoardCell({
    Key key,
    @required this.cellNr,
    @required this.gameId,
    @required this.fullBoard,
  }) : super(key: key);

  final int cellNr;
  final String gameId;
  final List fullBoard;

  @override
  _BoardCellState createState() => _BoardCellState();
}

class _BoardCellState extends State<BoardCell> {
  bool _loading = false;

  @override
  Widget build(BuildContext context) {
    Map<String, dynamic> cell = widget.fullBoard[widget.cellNr];
    bool done = cell["done"];
    return AspectRatio(
        aspectRatio: 1,
        child: AnimatedContainer(
          duration: Duration(seconds: 1),
          curve: Curves.easeOut,
          color: (done ? Colors.red[400] : Colors.white),
          child: InkWell(
            splashColor: Colors.green,
            onTap: () async {
              if (done) {
                Scaffold.of(context).showSnackBar(SnackBar(
                  content: Text("Already done"),
                ));
              } else {
                List updatedBoard = widget.fullBoard;
                updatedBoard[widget.cellNr]["done"] = true;
                await Firestore.instance
                    .collection("rooms")
                    .document(widget.gameId)
                    .updateData({"board": updatedBoard});
                setState(() {
                  _loading = true;
                });
              }
            },
            child: Center(
              child: (_loading && !done
                  ? CircularProgressIndicator()
                  : Text(
                      cell["name"].toString(),
                      style: TextStyle(
                          color: (done ? Colors.white : Colors.black)),
                    )),
            ),
          ),
        ));
  }
}

class Choice {
  const Choice({this.title, this.icon});

  final String title;
  final IconData icon;
}

const List<Choice> choices = const <Choice>[
  const Choice(title: 'Car', icon: Icons.directions_car),
  const Choice(title: 'Bicycle', icon: Icons.directions_bike),
  const Choice(title: 'Boat', icon: Icons.directions_boat),
  const Choice(title: 'Bus', icon: Icons.directions_bus),
  const Choice(title: 'Train', icon: Icons.directions_railway),
  const Choice(title: 'Walk', icon: Icons.directions_walk),
];

class ChoiceCard extends StatelessWidget {
  const ChoiceCard({Key key, this.choice}) : super(key: key);
  final Choice choice;

  @override
  Widget build(BuildContext context) {
    final TextStyle textStyle = Theme.of(context).textTheme.display1;
    return Card(
      color: Colors.white,
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            Icon(choice.icon, size: 128.0, color: textStyle.color),
            Text(choice.title, style: textStyle),
          ],
        ),
      ),
    );
  }
}
