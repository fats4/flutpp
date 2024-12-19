import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/cart_model.dart';

class OrderService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> placeOrder(String userId, List<CartItem> items, double total,
      String orderType, String additionalInfo) async {
    try {
      final orderItems = items
          .map((item) => {
                'id': item.id,
                'name': item.name,
                'price': item.price,
                'quantity': item.quantity,
              })
          .toList();

      await _firestore.collection('orders').add({
        'userId': userId,
        'items': orderItems,
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

  Stream<List<Map<String, dynamic>>> getUserOrders(String userId) {
    if (userId.isEmpty) {
      print('Warning: Empty userId provided');
      return Stream.value([]);
    }

    print('Fetching orders for user: $userId');

    return _firestore
        .collection('orders')
        .where('userId', isEqualTo: userId)
        .snapshots()
        .map((snapshot) {
      print('Received ${snapshot.docs.length} orders from Firestore');

      final orders = snapshot.docs
          .map((doc) {
            final data = doc.data();
            try {
              print('Processing order: ${doc.id}');
              print('Raw data: $data');

              if (data['items'] == null) {
                print('Warning: No items found for order ${doc.id}');
                return null;
              }

              final items = (data['items'] as List?)
                      ?.map((item) {
                        if (item is! Map) {
                          print(
                              'Warning: Invalid item format in order ${doc.id}');
                          return null;
                        }
                        return {
                          'id': item['id']?.toString() ?? '',
                          'name': item['name']?.toString() ?? '',
                          'price': double.tryParse(
                                  item['price']?.toString() ?? '0') ??
                              0.0,
                          'quantity': int.tryParse(
                                  item['quantity']?.toString() ?? '1') ??
                              1,
                        };
                      })
                      .whereType<Map<String, dynamic>>()
                      .toList() ??
                  [];

              if (items.isEmpty) {
                print('Warning: No valid items processed for order ${doc.id}');
                return null;
              }

              return {
                'id': doc.id,
                'userId': data['userId']?.toString() ?? '',
                'items': items,
                'total':
                    double.tryParse(data['total']?.toString() ?? '0') ?? 0.0,
                'orderType': data['orderType']?.toString() ?? '',
                'additionalInfo': data['additionalInfo']?.toString() ?? '',
                'timestamp': data['timestamp'],
              };
            } catch (e, stackTrace) {
              print('Error processing order ${doc.id}: $e');
              print('Stack trace: $stackTrace');
              return null;
            }
          })
          .whereType<Map<String, dynamic>>()
          .toList();

      print('Processed ${orders.length} valid orders');

      // Sort orders by timestamp
      orders.sort((a, b) {
        final aTimestamp = a['timestamp'] as Timestamp;
        final bTimestamp = b['timestamp'] as Timestamp;
        return bTimestamp.compareTo(aTimestamp); // descending order
      });

      return orders;
    });
  }
}
