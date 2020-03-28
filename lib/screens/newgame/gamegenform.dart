import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dringo/models/user.dart';
import 'package:dringo/screens/components/nicebutton.dart';
import 'package:dringo/screens/gamescreen.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:provider/provider.dart';

class GameGenForm extends StatefulWidget {
  @override
  _GameGenFormState createState() => _GameGenFormState();
}

class _GameGenFormState extends State<GameGenForm> {
  final _formKey = GlobalKey<FormState>();
  String _name;
  double _size = 3;
  bool _loading = false;
  List<bool> _exclusions = [
    false,
    false,
    false,
    false,
    false,
    false,
    false,
    false
  ];

  List<String> filterNames = [
    "Non-Alcoholic",
    "Beer",
    "Wines",
    "Cocktails",
    "Longdrinks",
    "Hot drinks",
    "Shots",
    "Specials",
  ];

  Column buildFilters() {
    List<CheckboxListTile> checkboxes = [];
    for (int i = 0; i < _exclusions.length; i++) {
      checkboxes.add(
        CheckboxListTile(
            value: _exclusions[i],
            title: Text(filterNames[i]),
            controlAffinity: ListTileControlAffinity.leading,
            onChanged: (newVal) {
              List<bool> newExclusions = _exclusions;
              newExclusions[i] = newVal;
              setState(() {
                _exclusions = newExclusions;
              });
            }),
      );
    }
    return Column(
      children: checkboxes,
    );
  }

  Future<String> submit() async {
    setState(() {
      _loading = true;
    });
    List<int> filters = [];
    for (int i = 0; i < _exclusions.length; i++) {
      if (_exclusions[i]) {
        filters.add(i);
      }
    }
    var httpResponse = await http.post(
      "https://us-central1-dringo-300f0.cloudfunctions.net/openroom",
      body: json.encode({
        "size": _size.toInt(),
        "name": _name,
        "exclude": filters,
        "creator": Provider.of<User>(context, listen: false).uid
      }),
    );
    setState(() {
      _loading = false;
    });
    if (httpResponse.statusCode == 400) {
      throw ("Couldn't find enough drinks for your selection, sorry :(");
    } else if (httpResponse.statusCode == 200) {
      print("Room created at ${httpResponse.body}");
      return httpResponse.body;
    } else {
      print("${httpResponse.statusCode} ${httpResponse.body}");
      throw ("Some unknown error has occured");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          TextFormField(
            textCapitalization: TextCapitalization.sentences,
            decoration: InputDecoration(labelText: 'Game name'),
            style: TextStyle(fontSize: 25),
            validator: (value) {
              if (value.isEmpty) {
                return "How is your night supposed to be legendary if it doesn't even have a name?";
              } else if (value.length < 5) {
                return "Come on, put at least some effort into it!";
              }
              return null;
            },
            onSaved: (enteredName) {
              setState(() {
                _name = enteredName;
              });
            },
          ),
          SizedBox(
            height: 30,
          ),
          Row(children: [
            Text("Board size"),
            Expanded(
              child: Slider(
                value: _size,
                divisions: 3,
                min: 2,
                max: 5,
                label: "${_size.toInt()} x ${_size.toInt()}",
                onChanged: (value) {
                  setState(() {
                    _size = value;
                  });
                },
              ),
            ),
          ]),
          SizedBox(
            height: 30,
          ),
          Text("Exclude:"),
          SizedBox(
            height: 10,
          ),
          buildFilters(),
          SizedBox(
            height: 30,
          ),
          NiceButton(
            loading: _loading,
            text: "LET THE GAMES BEGIN",
            onPressed: () {
              // Validate returns true if the form is valid, or false
              // otherwise.
              if (_formKey.currentState.validate()) {
                // If the form is valid, display a Snackbar.
                _formKey.currentState.save();

                Scaffold.of(context)
                    .showSnackBar(SnackBar(content: Text('Doing stuff...')));
                submit().then((roomId) {
                  // use that ID right away!
                  Navigator.of(context)
                      .pushReplacement(MaterialPageRoute(builder: (context) {
                    return GameScreen(
                        name: _name,
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
              }
            },
          )
        ],
      ),
    );
  }
}
