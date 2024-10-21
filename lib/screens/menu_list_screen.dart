import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/menu_service.dart';
import '../services/cart_service.dart';
import '../models/menu_model.dart';
import 'cart_screen.dart';

class MenuListScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final cartService = Provider.of<CartService>(context);

    return Scaffold(
      body: StreamBuilder<List<MenuModel>>(
        stream: Provider.of<MenuService>(context, listen: false).getMenus(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text('No menu items available'));
          }
          return ListView.builder(
            itemCount: snapshot.data!.length,
            itemBuilder: (context, index) {
              MenuModel menu = snapshot.data![index];
              return ListTile(
                leading: Image.network(menu.imageUrl,
                    width: 50, height: 50, fit: BoxFit.cover),
                title: Text(menu.name),
                subtitle: Text('\$${menu.price.toStringAsFixed(2)}'),
                trailing: IconButton(
                  icon: Icon(Icons.add_shopping_cart),
                  onPressed: () {
                    cartService.addItem(menu.id, menu.name, menu.price);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('${menu.name} added to cart')),
                    );
                  },
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        child: Stack(
          children: [
            Icon(Icons.shopping_cart),
            Positioned(
              right: 0,
              top: 0,
              child: Container(
                padding: EdgeInsets.all(1),
                decoration: BoxDecoration(
                  color: Colors.red,
                  borderRadius: BorderRadius.circular(6),
                ),
                constraints: BoxConstraints(
                  minWidth: 12,
                  minHeight: 12,
                ),
                child: Text(
                  '${cartService.itemCount}',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 8,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          ],
        ),
        onPressed: () {
          Navigator.of(context).push(
            MaterialPageRoute(builder: (context) => CartScreen()),
          );
        },
      ),
    );
  }
}
