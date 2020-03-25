import 'package:dringo/models/user.dart';
import 'package:dringo/screens/auth/authenticate.dart';
import 'package:dringo/screens/home/home.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class Wrapper extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final user = Provider.of<User>(context);
    print(user);
    // either return home or authenticate
    if (user == null) {
      return Authenticate();
    } else {
      return Home();
    }
  }
}
