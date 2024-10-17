import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import '../models/user_model.dart';

class AuthService with ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  UserModel? _userModel;

  UserModel? get user => _userModel;

  Future<bool> signIn(String email, String password) async {
    try {
      UserCredential result = await _auth.signInWithEmailAndPassword(
          email: email, password: password);
      User? user = result.user;
      if (user != null) {
        _userModel = UserModel(id: user.uid, email: user.email!);
        notifyListeners();
        return true;
      }
      return false;
    } catch (e) {
      print(e.toString());
      return false;
    }
  }

  Future<bool> register(String email, String password) async {
    try {
      UserCredential result = await _auth.createUserWithEmailAndPassword(
          email: email, password: password);
      User? user = result.user;
      if (user != null) {
        _userModel = UserModel(id: user.uid, email: user.email!);
        notifyListeners();
        return true;
      }
      return false;
    } catch (e) {
      print(e.toString());
      return false;
    }
  }

  Future<void> signOut() async {
    await _auth.signOut();
    _userModel = null;
    notifyListeners();
  }
}
