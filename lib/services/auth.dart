import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dringo/models/user.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // create userobject based on firebase user
  User _userFromFirebaseUser(FirebaseUser user) {
    return user != null ? User(uid: user.uid) : null;
  }

  // auth change user stream
  Stream<User> get user {
    return _auth.onAuthStateChanged.map(_userFromFirebaseUser);
  }

  // anonymous sign in
  Future signInAnon() async {
    try {
      AuthResult result = await _auth.signInAnonymously();
      FirebaseUser user = result.user;
      return _userFromFirebaseUser(user);
    } catch (e) {
      print(e.toString());
      return null;
    }
  }

  Future signInUsernameAndPassword(String username, String password) async {
    try {
      AuthResult result = await _auth.signInWithEmailAndPassword(
          email: "$username@dringomail.com", password: password);
      FirebaseUser user = result.user;
      return _userFromFirebaseUser(user);
    } catch (e) {
      print(e.toString());
      return e;
    }
  }

  // username/password sign up
  Future signUpUsernameAndPassword(String username, String password) async {
    try {
      AuthResult result = await _auth.createUserWithEmailAndPassword(
          email: "$username@dringomail.com", password: password);
      FirebaseUser user = result.user;
      // create a user data database entry
      await Firestore.instance
          .collection("users")
          .document(result.user.uid)
          .setData({
        "rooms": [],
      });
      return _userFromFirebaseUser(user);
    } catch (e) {
      print(e.toString());
      return e;
    }
  }

  // sign out
  Future signOut() async {
    try {
      return await _auth.signOut();
    } catch (e) {
      print(e.toString());
      return null;
    }
  }
}
