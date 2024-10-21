import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/cart_service.dart';
import '../services/order_service.dart';
import '../services/auth_service.dart';

class DeliveryScreen extends StatefulWidget {
  @override
  _DeliveryScreenState createState() => _DeliveryScreenState();
}

class _DeliveryScreenState extends State<DeliveryScreen> {
  final _formKey = GlobalKey<FormState>();
  String _address = '';

  @override
  Widget build(BuildContext context) {
    final cartService = Provider.of<CartService>(context);
    final orderService = Provider.of<OrderService>(context, listen: false);
    final authService = Provider.of<AuthService>(context, listen: false);

    return Scaffold(
      appBar: AppBar(
        title: Text('Delivery Information'),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: EdgeInsets.all(16),
          children: [
            TextFormField(
              decoration: InputDecoration(labelText: 'Delivery Address'),
              maxLines: 3,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter a delivery address';
                }
                return null;
              },
              onSaved: (value) {
                _address = value!;
              },
            ),
            SizedBox(height: 20),
            ElevatedButton(
              child: Text('Place Order'),
              onPressed: () async {
                if (_formKey.currentState!.validate()) {
                  _formKey.currentState!.save();
                  try {
                    final user = authService.user;
                    if (user != null) {
                      await orderService.placeOrder(
                        user.id,
                        cartService.items,
                        cartService.totalAmount,
                        'delivery',
                        _address,
                      );
                      await cartService.clear();
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Order placed successfully!')),
                      );
                      Navigator.of(context).popUntil((route) => route.isFirst);
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                            content: Text('Please log in to place an order.')),
                      );
                    }
                  } catch (e) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                          content:
                              Text('Failed to place order. Please try again.')),
                    );
                  }
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}
