import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dringo/screens/components/nicebutton.dart';
import 'package:dringo/screens/gamescreen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';

class BoardBuilder extends StatefulWidget {
  @override
  _BoardBuilderState createState() => _BoardBuilderState();
}

class _BoardBuilderState extends State<BoardBuilder> {
  // state variables
  int _size = 3;
  bool _loading = false;

  // needs to be filled with the maximum amount of fields we can have
  List<Map<String, String>> _board = List.filled(36, {"name": "", "id": null});

  _displayDialog({BuildContext parentContext, drinks, int cellNr}) async {
    final TextEditingController _typeAheadController = TextEditingController();
    var selectedId;
    return showDialog(
        context: parentContext,
        builder: (context) {
          return AlertDialog(
              title: Text('Add a drink'),
              content: TypeAheadField(
                textFieldConfiguration: TextFieldConfiguration(
                    textCapitalization: TextCapitalization.words,
                    autofocus: true,
                    controller: _typeAheadController),
                suggestionsCallback: (entered) {
                  return _getSuggestions(entered, drinks);
                },
                itemBuilder: (context, suggestion) {
                  return ListTile(
                    title: Text(suggestion['name']),
                  );
                },
                noItemsFoundBuilder: (context) {
                  return null;
                },
                onSuggestionSelected: (suggestion) {
                  selectedId = suggestion.documentID;
                  _typeAheadController.text = suggestion["name"];
                },
              ),
              actions: <Widget>[
                new FlatButton(
                  child: new Text('CANCEL'),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
                new FlatButton(
                    child: new Text('ADD'),
                    onPressed: (() async {
                      setState(() {
                        _board[cellNr] = {
                          "name": _typeAheadController.text,
                          "id": selectedId
                        };
                      });
                      Navigator.pop(context);
                    }))
              ]);
        });
  }

  Widget boardCell({int cellNr, drinks}) {
    return AspectRatio(
      aspectRatio: 1,
      child: InkWell(
        splashColor: Colors.red,
        onTap: () async {
          // some nice popup with autocomplete!
          _displayDialog(
              parentContext: context, drinks: drinks, cellNr: cellNr);
        },
        child: Padding(
          padding: const EdgeInsets.all(8),
          child: Center(
            child: Text(
              (_board[cellNr]["name"] is String ? _board[cellNr]["name"] : ""),
              textAlign: TextAlign.center,
            ),
          ),
        ),
      ),
    );
  }

  List<TableRow> buildBoard({size, board, drinks}) {
    // step through all fields (all there should be according to size, that is)
    int _cellNr = 0;
    List<TableRow> _board = [];
    for (var i = 0; i < size; i++) {
      List<Widget> _currentRow = [];
      for (var j = 0; j < size; j++) {
        _currentRow.add(boardCell(cellNr: _cellNr, drinks: drinks));
        _cellNr++;
      }
      _board.add(TableRow(children: _currentRow));
    }
    return _board;
  }

  _getSuggestions(String entered, AsyncSnapshot<QuerySnapshot> drinks) {
    return drinks.data.documents.where((drink) => (drink.data["name"] as String)
        .toLowerCase()
        .contains(entered.toLowerCase()));
  }

  submit() {}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("BYOB")),
      body: StreamBuilder<QuerySnapshot>(
          stream: Firestore.instance.collection("drinks").snapshots(),
          builder: (context, snapshot) {
            return Container(
              child: Padding(
                padding: const EdgeInsets.all(15.0),
                child: Column(
                  children: <Widget>[
                    SizedBox(
                      height: 30,
                    ),
                    Row(children: [
                      Text("Board size"),
                      Expanded(
                        child: Slider(
                          value: _size.toDouble(),
                          divisions: 4,
                          min: 2,
                          max: 6,
                          label: "${_size.toInt()} x ${_size.toInt()}",
                          onChanged: (value) {
                            setState(() {
                              _size = value.toInt();
                            });
                          },
                        ),
                      ),
                    ]),
                    SizedBox(
                      height: 30,
                    ),
                    Table(
                        border:
                            TableBorder.all(color: Colors.grey[300], width: 2),
                        defaultColumnWidth: FractionColumnWidth(0.9 / _size),
                        children: buildBoard(
                            size: _size, board: _board, drinks: snapshot)),
                    SizedBox(
                      height: 30,
                    ),
                    NiceButton(
                      loading: _loading,
                      text: "LET THE GAMES BEGIN",
                      onPressed: () {
                        Scaffold.of(context).showSnackBar(
                            SnackBar(content: Text('Doing stuff...')));
                        submit().then((roomId) {
                          // use that ID right away!
                          Navigator.of(context).pushReplacement(
                              MaterialPageRoute(builder: (context) {
                            return GameScreen(
                                name: "TODO NAME INPUT",
                                ref: Firestore.instance
                                    .collection("rooms")
                                    .document(roomId));
                          }));
                        }).catchError((error) {
                          Scaffold.of(context).showSnackBar(SnackBar(
                              backgroundColor: Colors.red,
                              content: Text(
                                error.toString(),
                                style: TextStyle(color: Colors.white),
                              )));
                        });
                      },
                    )
                  ],
                ),
              ),
            );
          }),
    );
  }
}
