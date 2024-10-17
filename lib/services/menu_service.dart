import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import '../models/menu_model.dart';

class MenuService with ChangeNotifier {
  final CollectionReference _menuCollection =
      FirebaseFirestore.instance.collection('menus');

  Future<void> addMenu(MenuModel menu) async {
    try {
      await _menuCollection.add(menu.toMap());
      notifyListeners();
    } catch (e) {
      print("Error in MenuService.addMenu: $e");
      throw e;
    }
  }

  Stream<List<MenuModel>> getMenus() {
    return _menuCollection.snapshots().map((snapshot) {
      return snapshot.docs.map((doc) {
        return MenuModel.fromMap(doc.data() as Map<String, dynamic>, doc.id);
      }).toList();
    });
  }
}
