import 'package:dringo/models/user.dart';
import 'package:dringo/screens/components/nicebutton.dart';
import 'package:dringo/services/auth.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class Register extends StatefulWidget {
  final Function toggleView;

  const Register({Key key, this.toggleView}) : super(key: key);

  @override
  _RegisterState createState() => _RegisterState();
}

class _RegisterState extends State<Register> {
  final AuthService _auth = AuthService();
  final _formKey = GlobalKey<FormState>();

  String username = '';
  String password = '';
  String passwordConfirm = '';
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
            label: Text("Sign in"),
          )
        ],
        backgroundColor: Colors.red,
        elevation: 0.0,
        title: Text("Sign Up"),
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
                onChanged: (val) {
                  setState(() {
                    username = val;
                  });
                },
                validator: ((val) => val.isEmpty ? "Enter a username" : null),
              ),
              SizedBox(height: 20),
              TextFormField(
                decoration: InputDecoration(labelText: "Password"),
                onChanged: (val) {
                  setState(() {
                    password = val;
                  });
                },
                validator: ((val) {
                  if (val.isEmpty) {
                    return "You'll probably need a password, bud...";
                  } else if (val.toLowerCase().contains("password") ||
                      password.contains("123") ||
                      password.length < 5) {
                    return "Come on, it's like you WANT your account stolen";
                  } else {
                    return null;
                  }
                }),
                obscureText: true,
              ),
              SizedBox(height: 20),
              TextFormField(
                decoration: InputDecoration(labelText: "Confirm password"),
                onChanged: (val) {
                  setState(() {
                    passwordConfirm = val;
                  });
                },
                validator: (val) => (val != password
                    ? "That's not even the same password, learn to type!"
                    : null),
                obscureText: true,
              ),
              SizedBox(height: 40),
              NiceButton(
                loading: loading,
                text: "SIGN ME THE FUCK UP",
                onPressed: () async {
                  if (_formKey.currentState.validate()) {
                    setState(() {
                      loading = true;
                    });
                    dynamic result = await _auth.signUpUsernameAndPassword(
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
