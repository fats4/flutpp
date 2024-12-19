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
        backgroundColor: Colors.white,
        appBar: AppBar(
          bottom: TabBar(
            labelColor: Color(0xFFFF5722),
            unselectedLabelColor: Colors.grey[600],
            indicatorColor: Color(0xFFFF5722),
            tabs: [
              Tab(icon: Icon(Icons.receipt), text: 'Orders'),
              Tab(icon: Icon(Icons.event_seat), text: 'Seats'),
              Tab(icon: Icon(Icons.restaurant_menu), text: 'Menu'),
            ],
          ),
          elevation: 0,
          toolbarHeight: 0,
          backgroundColor: Colors.white,
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
          return Center(
            child: CircularProgressIndicator(
              color: Color(0xFFFF5722),
            ),
          );
        }
        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.receipt_long,
                  size: 80,
                  color: Color(0xFFFF5722).withOpacity(0.5),
                ),
                SizedBox(height: 16),
                Text(
                  'No orders yet',
                  style: TextStyle(
                    fontSize: 18,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          );
        }
        final orders = snapshot.data!;
        return ListView.builder(
          padding: EdgeInsets.all(16),
          itemCount: orders.length,
          itemBuilder: (ctx, i) => Dismissible(
            key: Key(orders[i]['id']),
            background: Container(
              color: Colors.red.shade100,
              alignment: Alignment.centerRight,
              padding: EdgeInsets.only(right: 20),
              child: Icon(Icons.delete, color: Colors.red),
            ),
            direction: DismissDirection.endToStart,
            confirmDismiss: (direction) => _showDeleteConfirmDialog(context),
            onDismissed: (direction) {
              orderService.deleteOrder(orders[i]['id']);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Order deleted'),
                  backgroundColor: Color(0xFFFF5722),
                ),
              );
            },
            child: Card(
              elevation: 0,
              margin: EdgeInsets.only(bottom: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
                side: BorderSide(
                  color: Color(0xFFFF5722).withOpacity(0.2),
                ),
              ),
              child: ListTile(
                contentPadding: EdgeInsets.all(16),
                leading: Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    color: Color(0xFFFBE9E7),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Center(
                    child: Text(
                      '${i + 1}',
                      style: TextStyle(
                        color: Color(0xFFFF5722),
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                  ),
                ),
                title: Text(
                  'Order #${orders[i]['id']}',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(height: 4),
                    Text(
                      'Total: \$${orders[i]['total'].toStringAsFixed(2)}',
                      style: TextStyle(
                        color: Color(0xFFFF5722),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                trailing: Icon(
                  Icons.arrow_forward_ios,
                  color: Color(0xFFFF5722),
                  size: 20,
                ),
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
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15),
        ),
        title: Text(
          'Delete Order',
          style: TextStyle(color: Color(0xFFFF5722)),
        ),
        content: Text('Are you sure you want to delete this order?'),
        actions: [
          TextButton(
            child: Text(
              'Cancel',
              style: TextStyle(color: Colors.grey[600]),
            ),
            onPressed: () => Navigator.of(ctx).pop(false),
          ),
          ElevatedButton(
            child: Text('Delete'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
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
      backgroundColor: Colors.white,
      body: StreamBuilder<List<MenuModel>>(
        stream: menuService.getMenus(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
              child: CircularProgressIndicator(
                color: Color(0xFFFF5722),
              ),
            );
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.restaurant_menu,
                    size: 80,
                    color: Color(0xFFFF5722).withOpacity(0.5),
                  ),
                  SizedBox(height: 16),
                  Text(
                    'No menu items yet',
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            );
          }

          final menuItems = snapshot.data!;
          return ListView.builder(
            padding: EdgeInsets.all(16),
            itemCount: menuItems.length,
            itemBuilder: (ctx, i) => Card(
              elevation: 0,
              margin: EdgeInsets.only(bottom: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
                side: BorderSide(
                  color: Color(0xFFFF5722).withOpacity(0.2),
                ),
              ),
              child: Padding(
                padding: EdgeInsets.all(12),
                child: Row(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Image.network(
                        menuItems[i].imageUrl,
                        width: 80,
                        height: 80,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) => Container(
                          width: 80,
                          height: 80,
                          decoration: BoxDecoration(
                            color: Color(0xFFFBE9E7),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Icon(
                            Icons.fastfood,
                            size: 40,
                            color: Color(0xFFFF5722),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            menuItems[i].name,
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: 4),
                          Text(
                            '\$${menuItems[i].price.toStringAsFixed(2)}',
                            style: TextStyle(
                              fontSize: 16,
                              color: Color(0xFFFF5722),
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: Icon(Icons.edit_outlined),
                          color: Color(0xFFFF5722),
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
                          icon: Icon(Icons.delete_outline),
                          color: Colors.red[300],
                          onPressed: () => _showDeleteMenuConfirmDialog(
                              context, menuItems[i], menuService),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Color(0xFFFF5722),
        elevation: 2,
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
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15),
        ),
        title: Text(
          'Delete Menu Item',
          style: TextStyle(color: Color(0xFFFF5722)),
        ),
        content: Text('Are you sure you want to delete ${menuItem.name}?'),
        actions: [
          TextButton(
            child: Text(
              'Cancel',
              style: TextStyle(color: Colors.grey[600]),
            ),
            onPressed: () => Navigator.of(ctx).pop(),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: Text('Delete'),
            onPressed: () {
              menuService.deleteMenu(menuItem.id);
              Navigator.of(ctx).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('${menuItem.name} deleted successfully'),
                  backgroundColor: Color(0xFFFF5722),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
