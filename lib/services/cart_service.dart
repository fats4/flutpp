import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../models/cart_model.dart';

class CartService with ChangeNotifier {
  List<CartItem> _items = [];

  List<CartItem> get items => _items;

  int get itemCount => _items.length;

  double get totalAmount {
    return _items.fold(0, (sum, item) => sum + (item.price * item.quantity));
  }

  Future<void> addItem(String id, String name, double price) async {
    final existingIndex = _items.indexWhere((item) => item.id == id);
    if (existingIndex >= 0) {
      _items[existingIndex].quantity += 1;
    } else {
      _items.add(CartItem(id: id, name: name, price: price));
    }
    await _saveCartToPrefs();
    notifyListeners();
  }

  Future<void> removeItem(String id) async {
    _items.removeWhere((item) => item.id == id);
    await _saveCartToPrefs();
    notifyListeners();
  }

  Future<void> clear() async {
    _items = [];
    await _saveCartToPrefs();
    notifyListeners();
  }

  Future<void> updateItemQuantity(String id, int newQuantity) async {
    final index = _items.indexWhere((item) => item.id == id);
    if (index >= 0) {
      if (newQuantity > 0) {
        _items[index].quantity = newQuantity;
      } else {
        _items.removeAt(index);
      }
      await _saveCartToPrefs();
      notifyListeners();
    }
  }

  Future<void> _saveCartToPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    final cartData = _items.map((item) => item.toMap()).toList();
    await prefs.setString('cart', json.encode(cartData));
  }

  Future<void> loadCartFromPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    if (prefs.containsKey('cart')) {
      final cartData = json.decode(prefs.getString('cart')!) as List<dynamic>;
      _items = cartData.map((item) => CartItem.fromMap(item)).toList();
      notifyListeners();
    }
  }
}
