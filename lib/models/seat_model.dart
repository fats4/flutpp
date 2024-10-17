class SeatModel {
  final String id;
  final bool isAvailable;

  SeatModel({required this.id, this.isAvailable = true});

  factory SeatModel.fromMap(Map<String, dynamic> map) {
    return SeatModel(
      id: map['id'],
      isAvailable: map['isAvailable'] ?? true,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'isAvailable': isAvailable,
    };
  }
}
