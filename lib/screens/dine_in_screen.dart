import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/seat_service.dart';
import '../services/cart_service.dart';
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
    final seatService = Provider.of<SeatService>(context, listen: false);
    final cartService = Provider.of<CartService>(context);

    return Scaffold(
      appBar: AppBar(
        title: Text('Choose a Seat'),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                'Screen',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 20),
              StreamBuilder<List<SeatModel>>(
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
              SizedBox(height: 20),
              Text(
                'Selected Seat: ${selectedSeatId ?? "None"}',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 20),
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
                        await seatService.updateSeatAvailability(
                            selectedSeatId!, false);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Order placed successfully!')),
                        );
                        Navigator.of(context)
                            .popUntil((route) => route.isFirst);
                        cartService.clear();
                      },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
