import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/cart_model.dart';

class OrderService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> placeOrder(String userId, List<CartItem> items, double total,
      String orderType, String additionalInfo) async {
    try {
      await _firestore.collection('orders').add({
        'userId': userId,
        'items': items.map((item) => item.toMap()).toList(),
        'total': total,
        'orderType': orderType,
        'additionalInfo': additionalInfo,
        'timestamp': FieldValue.serverTimestamp(),
      });
      print('Order placed successfully');
    } catch (e) {
      print('Error placing order: $e');
      throw e;
    }
  }

  Future<void> deleteOrder(String orderId) async {
    try {
      await _firestore.collection('orders').doc(orderId).delete();
      print('Order deleted successfully');
    } catch (e) {
      print('Error deleting order: $e');
      throw e;
    }
  }

  Stream<List<Map<String, dynamic>>> getOrders() {
    return _firestore
        .collection('orders')
        .orderBy('timestamp', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        final data = doc.data();
        return {
          'id': doc.id,
          'userId': data['userId'],
          'items': (data['items'] as List)
              .map((item) => CartItem.fromMap(item as Map<String, dynamic>))
              .toList(),
          'total': data['total'],
          'orderType': data['orderType'],
          'additionalInfo': data['additionalInfo'],
          'timestamp': data['timestamp'],
        };
      }).toList();
    });
  }
}
