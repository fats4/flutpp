import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/cart_service.dart';
import '../services/order_service.dart';
import '../services/auth_service.dart';
import '../services/seat_service.dart';
import '../models/seat_model.dart';
import '../widgets/seat_grid_widget.dart';

class DineInScreen extends StatefulWidget {
  @override
  _DineInScreenState createState() => _DineInScreenState();
}

class _DineInScreenState extends State<DineInScreen> {
  String? selectedSeatId;

  @override
  Widget build(BuildContext context) {
    final cartService = Provider.of<CartService>(context);
    final orderService = Provider.of<OrderService>(context, listen: false);
    final authService = Provider.of<AuthService>(context, listen: false);
    final seatService = Provider.of<SeatService>(context, listen: false);

    return Scaffold(
      appBar: AppBar(
        title: Text('Choose a Seat'),
      ),
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder<List<SeatModel>>(
              stream: seatService.getSeats(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                }
                if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return Center(child: Text('No seats available'));
                }
                return SeatGridWidget(
                  seats: snapshot.data!,
                  selectedSeatId: selectedSeatId,
                  onSeatSelected: (seatId) {
                    setState(() {
                      selectedSeatId = seatId;
                    });
                  },
                );
              },
            ),
          ),
          Padding(
            padding: EdgeInsets.all(16.0),
            child: Column(
              children: [
                Text(
                  'Total: \$${cartService.totalAmount.toStringAsFixed(2)}',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 20),
                ElevatedButton(
                  child: Text('Confirm Seat and Order'),
                  onPressed: selectedSeatId == null
                      ? null
                      : () async {
                          try {
                            final user = authService.user;
                            if (user != null) {
                              await orderService.placeOrder(
                                user.id,
                                cartService.items,
                                cartService.totalAmount,
                                'dine_in',
                                selectedSeatId!,
                              );
                              await seatService.updateSeatAvailability(
                                  selectedSeatId!, false);
                              await cartService.clear();
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                    content:
                                        Text('Order placed successfully!')),
                              );
                              Navigator.of(context)
                                  .popUntil((route) => route.isFirst);
                            } else {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                    content: Text(
                                        'Please log in to place an order.')),
                              );
                            }
                          } catch (e) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                  content: Text(
                                      'Failed to place order. Please try again.')),
                            );
                          }
                        },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
