import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/cart_service.dart';
import 'delivery_screen.dart';
import 'dine_in_screen.dart';

class CheckoutScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final cartService = Provider.of<CartService>(context);

    return Scaffold(
      appBar: AppBar(
        title: Text('Checkout'),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: cartService.items.length,
              itemBuilder: (ctx, i) => ListTile(
                title: Text(cartService.items[i].name),
                subtitle: Text('Quantity: ${cartService.items[i].quantity}'),
                trailing: Text(
                    '\$${(cartService.items[i].price * cartService.items[i].quantity).toStringAsFixed(2)}'),
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.all(8.0),
            child: Text(
              'Total: \$${cartService.totalAmount.toStringAsFixed(2)}',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
          ),
          ElevatedButton(
            child: Text('Delivery'),
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (context) => DeliveryScreen()),
              );
            },
          ),
          ElevatedButton(
            child: Text('Dine In'),
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (context) => DineInScreen()),
              );
            },
          ),
        ],
      ),
    );
  }
}
