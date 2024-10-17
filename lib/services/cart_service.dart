import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/cart_model.dart';

class CartService with ChangeNotifier {
  final String userId;
  final CollectionReference _cartCollection;

  CartService(this.userId)
      : _cartCollection = FirebaseFirestore.instance
            .collection('users')
            .doc(userId)
            .collection('cart');

  Future<void> addToCart(CartItem item) async {
    try {
      DocumentSnapshot existingItem =
          await _cartCollection.doc(item.menuId).get();
      if (existingItem.exists) {
        await _cartCollection
            .doc(item.menuId)
            .update({'quantity': FieldValue.increment(1)});
      } else {
        await _cartCollection.doc(item.menuId).set(item.toMap());
      }
      notifyListeners();
    } catch (e) {
      print("Error adding to cart: $e");
      throw e;
    }
  }

  Stream<List<CartItem>> getCartItems() {
    return _cartCollection.snapshots().map((snapshot) {
      return snapshot.docs
          .map((doc) =>
              CartItem.fromMap(doc.id, doc.data() as Map<String, dynamic>))
          .toList();
    });
  }

  Future<void> removeFromCart(String menuId) async {
    try {
      await _cartCollection.doc(menuId).delete();
      notifyListeners();
    } catch (e) {
      print("Error removing from cart: $e");
      throw e;
    }
  }

  Future<void> updateQuantity(String menuId, int quantity) async {
    try {
      await _cartCollection.doc(menuId).update({'quantity': quantity});
      notifyListeners();
    } catch (e) {
      print("Error updating quantity: $e");
      throw e;
    }
  }
}
