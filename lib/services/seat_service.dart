import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/seat_model.dart';

class SeatService {
  final CollectionReference _seatsCollection =
      FirebaseFirestore.instance.collection('seats');

  Stream<List<SeatModel>> getSeats() {
    return _seatsCollection.snapshots().map((snapshot) {
      return snapshot.docs.map((doc) {
        return SeatModel.fromMap(doc.data() as Map<String, dynamic>);
      }).toList();
    });
  }

  Future<void> updateSeatAvailability(String seatId, bool isAvailable) async {
    await _seatsCollection.doc(seatId).update({'isAvailable': isAvailable});
  }

  Future<void> initializeSeats() async {
    WriteBatch batch = FirebaseFirestore.instance.batch();
    var snapshots = await _seatsCollection.get();
    for (var doc in snapshots.docs) {
      batch.delete(doc.reference);
    }
    await batch.commit();

    batch = FirebaseFirestore.instance.batch();
    for (int i = 1; i <= 25; i++) {
      String seatId = 'A${i.toString().padLeft(2, '0')}';
      batch.set(_seatsCollection.doc(seatId), {
        'id': seatId,
        'isAvailable': true,
      });
    }
    await batch.commit();
    print('Seats initialized successfully');
  }

  Future<bool> areSeatsInitialized() async {
    var snapshot = await _seatsCollection.limit(1).get();
    return snapshot.docs.isNotEmpty;
  }

  Future<void> addSeat(String seatId) async {
    await _seatsCollection.doc(seatId).set({
      'id': seatId,
      'isAvailable': true,
    });
  }

  Future<void> removeSeat(String seatId) async {
    await _seatsCollection.doc(seatId).delete();
  }
}
