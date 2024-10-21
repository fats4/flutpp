import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user_model.dart';

class AuthService with ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  UserModel? _userModel;

  UserModel? get user => _userModel;

  AuthService() {
    _auth.authStateChanges().listen((User? user) {
      if (user != null) {
        _getUserData(user.uid);
      } else {
        _userModel = null;
        notifyListeners();
      }
    });
  }

  Future<void> _getUserData(String uid) async {
    try {
      DocumentSnapshot doc =
          await _firestore.collection('users').doc(uid).get();
      if (doc.exists) {
        _userModel = UserModel.fromMap(doc.data() as Map<String, dynamic>);
        notifyListeners();
      }
    } catch (e) {
      print("Error getting user data: $e");
    }
  }

  Future<bool> signIn(String email, String password) async {
    try {
      UserCredential result = await _auth.signInWithEmailAndPassword(
          email: email, password: password);
      User? user = result.user;
      if (user != null) {
        await _getUserData(user.uid);
        await _saveUserToPrefs();
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
        // Create a new user document in Firestore
        await _firestore.collection('users').doc(user.uid).set({
          'id': user.uid,
          'email': user.email,
          'role': 'user', // Default role is user
        });
        await _getUserData(user.uid);
        await _saveUserToPrefs();
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
    await prefs.setString(
        'userRole', _userModel!.role == UserRole.admin ? 'admin' : 'user');
  }

  Future<void> _removeUserFromPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('userId');
    await prefs.remove('userEmail');
    await prefs.remove('userRole');
  }

  Future<void> tryAutoLogin() async {
    final prefs = await SharedPreferences.getInstance();
    if (!prefs.containsKey('userId')) return;

    final userId = prefs.getString('userId');
    final userEmail = prefs.getString('userEmail');
    final userRole = prefs.getString('userRole');

    _userModel = UserModel(
      id: userId!,
      email: userEmail!,
      role: userRole == 'admin' ? UserRole.admin : UserRole.user,
    );
    notifyListeners();
  }
}
