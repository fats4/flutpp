import 'package:flutter/material.dart';
import '../models/seat_model.dart';

class SeatGridWidget extends StatelessWidget {
  final List<SeatModel> seats;
  final Function(String) onSeatSelected;
  final String? selectedSeatId;

  SeatGridWidget({
    required this.seats,
    required this.onSeatSelected,
    required this.selectedSeatId,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        width: 300, // Atur lebar sesuai kebutuhan
        child: GridView.builder(
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 5,
            childAspectRatio: 1.0,
            crossAxisSpacing: 10,
            mainAxisSpacing: 10,
          ),
          shrinkWrap: true,
          physics: NeverScrollableScrollPhysics(),
          itemCount: seats.length,
          itemBuilder: (context, index) {
            final seat = seats[index];
            final isSelected = seat.id == selectedSeatId;
            return GestureDetector(
              onTap: seat.isAvailable ? () => onSeatSelected(seat.id) : null,
              child: Container(
                decoration: BoxDecoration(
                  color: isSelected
                      ? Colors.blue
                      : seat.isAvailable
                          ? Colors.green
                          : Colors.red,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: isSelected ? Colors.yellow : Colors.transparent,
                    width: 2,
                  ),
                ),
                child: Center(
                  child: Text(
                    seat.id,
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
