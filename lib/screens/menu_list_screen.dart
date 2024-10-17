import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/menu_service.dart';
import '../models/menu_model.dart';

class MenuListScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Menu List')),
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
              );
            },
          );
        },
      ),
    );
  }
}
