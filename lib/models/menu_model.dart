class MenuModel {
  final String id;
  final String name;
  final double price;
  final String imageUrl;

  MenuModel({
    required this.id,
    required this.name,
    required this.price,
    required this.imageUrl,
  });

  factory MenuModel.fromMap(Map<String, dynamic> data, String id) {
    return MenuModel(
      id: id,
      name: data['name'] ?? '',
      price: (data['price'] ?? 0.0).toDouble(),
      imageUrl: data['imageUrl'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'price': price,
      'imageUrl': imageUrl,
    };
  }
}
