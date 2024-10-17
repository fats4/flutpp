class CartItem {
  final String id;
  final String menuId;
  final String name;
  final double price;
  int quantity;

  CartItem({
    required this.id,
    required this.menuId,
    required this.name,
    required this.price,
    this.quantity = 1,
  });

  Map<String, dynamic> toMap() {
    return {
      'menuId': menuId,
      'name': name,
      'price': price,
      'quantity': quantity,
    };
  }

  factory CartItem.fromMap(String id, Map<String, dynamic> map) {
    return CartItem(
      id: id,
      menuId: map['menuId'],
      name: map['name'],
      price: map['price'],
      quantity: map['quantity'],
    );
  }
}
