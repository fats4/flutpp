import 'package:flutter/material.dart';
import '../models/menu_model.dart';

class MenuDetailScreen extends StatelessWidget {
  final MenuModel menu;

  MenuDetailScreen({required this.menu});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(menu.name),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Center(
                child: Container(
                  constraints: BoxConstraints(
                    maxWidth: MediaQuery.of(context).size.width *
                        0.9, // 90% of screen width
                    maxHeight: 300, // Maximum height of 300 pixels
                  ),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8), // Rounded corners
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.network(
                      menu.imageUrl,
                      fit: BoxFit.contain, // Ensure image fits within the box
                    ),
                  ),
                ),
              ),
              SizedBox(height: 10),
              Text(
                menu.name,
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 10),
              Text(
                '\$${menu.price.toStringAsFixed(2)}',
                style: TextStyle(fontSize: 20, color: Colors.grey),
              ),
              SizedBox(height: 10),
              Text(
                'Description: bla bla',
                style: TextStyle(fontSize: 16),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
