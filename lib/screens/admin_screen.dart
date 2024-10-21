import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/order_service.dart';
import '../services/seat_service.dart';
import '../services/menu_service.dart';
import '../models/seat_model.dart';
import '../models/menu_model.dart';
import '../models/cart_model.dart';
import 'add_menu_screen.dart';

class AdminScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          bottom: TabBar(
            tabs: [
              Tab(icon: Icon(Icons.receipt), text: 'Orders'),
              Tab(icon: Icon(Icons.event_seat), text: 'Seats'),
              Tab(icon: Icon(Icons.restaurant_menu), text: 'Menu'),
            ],
          ),
          elevation: 0,
          toolbarHeight: 0, // Remove the gap by setting toolbarHeight to 0
        ),
        body: TabBarView(
          children: [
            OrdersTab(),
            SeatsTab(),
            MenuTab(),
          ],
        ),
      ),
    );
  }
}

class OrdersTab extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final orderService = Provider.of<OrderService>(context);

    return StreamBuilder<List<Map<String, dynamic>>>(
      stream: orderService.getOrders(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        }
        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.receipt_long,
                    size: 80, color: const Color.fromARGB(255, 0, 0, 0)),
                SizedBox(height: 20),
                Text('No orders yet',
                    style: TextStyle(
                        fontSize: 18,
                        color: const Color.fromARGB(255, 0, 0, 0))),
              ],
            ),
          );
        }
        final orders = snapshot.data!;
        return ListView.builder(
          itemCount: orders.length,
          itemBuilder: (ctx, i) => Dismissible(
            key: Key(orders[i]['id']),
            background: Container(
              color: Colors.red,
              alignment: Alignment.centerRight,
              padding: EdgeInsets.only(right: 20),
              child: Icon(Icons.delete, color: Colors.white),
            ),
            direction: DismissDirection.endToStart,
            confirmDismiss: (direction) => _showDeleteConfirmDialog(context),
            onDismissed: (direction) {
              orderService.deleteOrder(orders[i]['id']);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Order deleted')),
              );
            },
            child: Card(
              margin: EdgeInsets.symmetric(horizontal: 15, vertical: 5),
              child: ListTile(
                leading: CircleAvatar(
                  child: Text('${i + 1}'),
                  backgroundColor: Theme.of(context).primaryColor,
                ),
                title: Text('Order #${orders[i]['id']}',
                    style: TextStyle(fontWeight: FontWeight.bold)),
                subtitle:
                    Text('Total: \$${orders[i]['total'].toStringAsFixed(2)}'),
                trailing: Icon(Icons.arrow_forward_ios),
                onTap: () => _showOrderDetails(context, orders[i]),
              ),
            ),
          ),
        );
      },
    );
  }

  Future<bool?> _showDeleteConfirmDialog(BuildContext context) {
    return showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Delete Order'),
        content: Text('Are you sure you want to delete this order?'),
        actions: [
          TextButton(
            child: Text('Cancel'),
            onPressed: () => Navigator.of(ctx).pop(false),
          ),
          ElevatedButton(
            child: Text('Delete'),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () => Navigator.of(ctx).pop(true),
          ),
        ],
      ),
    );
  }

  void _showOrderDetails(BuildContext context, Map<String, dynamic> order) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Order Details'),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildDetailRow('Order ID:', order['id']),
              _buildDetailRow('User ID:', order['userId']),
              _buildDetailRow(
                  'Total:', '\$${order['total'].toStringAsFixed(2)}'),
              _buildDetailRow('Order Type:', order['orderType']),
              _buildDetailRow('Additional Info:', order['additionalInfo']),
              SizedBox(height: 10),
              Text('Items:', style: TextStyle(fontWeight: FontWeight.bold)),
              ...(order['items'] as List<CartItem>).map(
                (item) => Padding(
                  padding: const EdgeInsets.only(left: 10),
                  child: Text(
                      '• ${item.name} x${item.quantity} (\$${item.price.toStringAsFixed(2)})'),
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            child: Text('Close'),
            onPressed: () => Navigator.of(ctx).pop(),
          ),
          ElevatedButton(
            child: Text('Delete'),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () {
              Navigator.of(ctx).pop();
              _deleteOrder(context, order['id']);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: TextStyle(fontWeight: FontWeight.bold)),
          SizedBox(width: 10),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }

  void _deleteOrder(BuildContext context, String orderId) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Delete Order'),
        content: Text('Are you sure you want to delete this order?'),
        actions: [
          TextButton(
            child: Text('Cancel'),
            onPressed: () => Navigator.of(ctx).pop(),
          ),
          ElevatedButton(
            child: Text('Delete'),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () {
              Navigator.of(ctx).pop();
              Provider.of<OrderService>(context, listen: false)
                  .deleteOrder(orderId);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Order deleted successfully')),
              );
            },
          ),
        ],
      ),
    );
  }
}

class SeatsTab extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final seatService = Provider.of<SeatService>(context);

    return StreamBuilder<List<SeatModel>>(
      stream: seatService.getSeats(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        }
        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.event_seat, size: 80, color: Colors.grey),
                SizedBox(height: 20),
                Text('No seats available',
                    style: TextStyle(fontSize: 18, color: Colors.grey)),
              ],
            ),
          );
        }
        final seats = snapshot.data!;
        return GridView.builder(
          padding: EdgeInsets.all(10),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 4, // Increased from 3 to 4
            childAspectRatio: 1, // Changed to 1 for square items
            crossAxisSpacing: 10,
            mainAxisSpacing: 10,
          ),
          itemCount: seats.length,
          itemBuilder: (ctx, i) => Card(
            color: seats[i].isAvailable ? Colors.green[100] : Colors.red[100],
            child: InkWell(
              onTap: () {
                seatService.updateSeatAvailability(
                    seats[i].id, !seats[i].isAvailable);
              },
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    seats[i].isAvailable
                        ? Icons.event_seat
                        : Icons.event_seat_outlined,
                    size: 24, // Reduced from 40
                    color: seats[i].isAvailable ? Colors.green : Colors.red,
                  ),
                  SizedBox(height: 4),
                  Text(
                    seats[i].id,
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                  ),
                  Text(
                    seats[i].isAvailable ? 'Free' : 'Occupied',
                    style: TextStyle(fontSize: 10),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class MenuTab extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final menuService = Provider.of<MenuService>(context);

    return Scaffold(
      body: StreamBuilder<List<MenuModel>>(
        stream: menuService.getMenus(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.restaurant_menu, size: 80, color: Colors.grey),
                  SizedBox(height: 20),
                  Text('No menu items available',
                      style: TextStyle(fontSize: 18, color: Colors.grey)),
                ],
              ),
            );
          }
          final menuItems = snapshot.data!;
          return ListView.builder(
            itemCount: menuItems.length,
            itemBuilder: (ctx, i) => Card(
              margin: EdgeInsets.symmetric(horizontal: 15, vertical: 5),
              child: ListTile(
                leading: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.network(
                    menuItems[i].imageUrl,
                    width: 50,
                    height: 50,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) =>
                        Icon(Icons.fastfood, size: 50),
                  ),
                ),
                title: Text(menuItems[i].name,
                    style: TextStyle(fontWeight: FontWeight.bold)),
                subtitle: Text('\$${menuItems[i].price.toStringAsFixed(2)}'),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: Icon(Icons.edit, color: Colors.blue),
                      onPressed: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) =>
                                AddMenuScreen(menuItem: menuItems[i]),
                          ),
                        );
                      },
                    ),
                    IconButton(
                      icon: Icon(Icons.delete, color: Colors.red),
                      onPressed: () => _showDeleteMenuConfirmDialog(
                          context, menuItems[i], menuService),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.add),
        onPressed: () {
          Navigator.of(context).push(
            MaterialPageRoute(builder: (context) => AddMenuScreen()),
          );
        },
      ),
    );
  }

  void _showDeleteMenuConfirmDialog(
      BuildContext context, MenuModel menuItem, MenuService menuService) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Delete Menu Item'),
        content: Text('Are you sure you want to delete ${menuItem.name}?'),
        actions: [
          TextButton(
            child: Text('Cancel'),
            onPressed: () => Navigator.of(ctx).pop(),
          ),
          ElevatedButton(
            child: Text('Delete'),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () {
              menuService.deleteMenu(menuItem.id);
              Navigator.of(ctx).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                    content: Text('${menuItem.name} deleted successfully')),
              );
            },
          ),
        ],
      ),
    );
  }
}
