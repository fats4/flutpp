import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/cart_service.dart';

class DeliveryScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final cartService = Provider.of<CartService>(context);

    return Scaffold(
      appBar: AppBar(
        title: Text('Delivery'),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Delivery Address',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            TextField(
              decoration: InputDecoration(hintText: 'Enter your address'),
            ),
            SizedBox(height: 20),
            Text(
              'Total: \$${cartService.totalAmount.toStringAsFixed(2)}',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              child: Text('Pay Now'),
              onPressed: () {
                // TODO: Implement payment processing
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Payment processed successfully!')),
                );
                Navigator.of(context).popUntil((route) => route.isFirst);
                cartService.clear();
              },
            ),
          ],
        ),
      ),
    );
  }
}
