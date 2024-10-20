import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user_model.dart';

class AuthService with ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  UserModel? _userModel;

  UserModel? get user => _userModel;

  AuthService() {
    _auth.authStateChanges().listen((User? user) {
      if (user != null) {
        _userModel = UserModel(id: user.uid, email: user.email!);
      } else {
        _userModel = null;
      }
      notifyListeners();
    });
  }

  Future<bool> signIn(String email, String password) async {
    try {
      UserCredential result = await _auth.signInWithEmailAndPassword(
          email: email, password: password);
      User? user = result.user;
      if (user != null) {
        _userModel = UserModel(id: user.uid, email: user.email!);
        await _saveUserToPrefs();
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
        await _saveUserToPrefs();
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
    await _removeUserFromPrefs();
    notifyListeners();
  }

  Future<void> _saveUserToPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('userId', _userModel!.id);
    await prefs.setString('userEmail', _userModel!.email);
  }

  Future<void> _removeUserFromPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('userId');
    await prefs.remove('userEmail');
  }

  Future<void> tryAutoLogin() async {
    final prefs = await SharedPreferences.getInstance();
    if (!prefs.containsKey('userId')) return;

    final userId = prefs.getString('userId');
    final userEmail = prefs.getString('userEmail');

    _userModel = UserModel(id: userId!, email: userEmail!);
    notifyListeners();
  }
}