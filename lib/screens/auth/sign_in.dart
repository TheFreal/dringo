import 'package:dringo/models/user.dart';
import 'package:dringo/screens/components/nicebutton.dart';
import 'package:dringo/services/auth.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class SignIn extends StatefulWidget {
  final Function toggleView;

  const SignIn({Key key, this.toggleView}) : super(key: key);
  @override
  _SignInState createState() => _SignInState();
}

class _SignInState extends State<SignIn> {
  final AuthService _auth = AuthService();
  final _formKey = GlobalKey<FormState>();

  String username = '';
  String password = '';
  String error = '';
  bool loading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.red[100],
      appBar: AppBar(
        actions: <Widget>[
          FlatButton.icon(
            onPressed: widget.toggleView,
            icon: Icon(Icons.person),
            label: Text("Register"),
          )
        ],
        backgroundColor: Colors.red,
        elevation: 0.0,
        title: Text("Sign In"),
      ),
      body: Container(
          padding: EdgeInsets.symmetric(
            vertical: 20,
            horizontal: 50,
          ),
          child: Form(
            key: _formKey,
            child: Column(children: [
              SizedBox(height: 20),
              TextFormField(
                decoration: InputDecoration(labelText: "Username"),
                validator: ((val) => val.isEmpty ? "Enter a username" : null),
                onChanged: (val) {
                  setState(() {
                    username = val;
                  });
                },
              ),
              SizedBox(height: 20),
              TextFormField(
                decoration: InputDecoration(labelText: "Password"),
                validator: ((val) =>
                    val.length < 5 ? "Enter a proper password" : null),
                onChanged: (val) {
                  setState(() {
                    password = val;
                  });
                },
                obscureText: true,
              ),
              SizedBox(height: 40),
              NiceButton(
                loading: loading,
                text: "LET ME IN ALREADY",
                onPressed: () async {
                  if (_formKey.currentState.validate()) {
                    setState(() {
                      loading = true;
                    });
                    dynamic result = await _auth.signInUsernameAndPassword(
                        username, password);
                    if (!(result is User)) {
                      setState(() {
                        loading = false;
                        error = (result as PlatformException).message;
                      });
                    }
                  }
                },
              ),
              SizedBox(height: 20),
              Text(error)
            ]),
          )),
    );
  }
}
