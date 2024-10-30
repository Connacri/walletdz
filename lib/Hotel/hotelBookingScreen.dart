import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'Entity.dart';

class HotelBookingScreen extends StatelessWidget {
  final List<Room> rooms;
  final List<Reservation> reservations;
  final DateTime startDate;
  final DateTime endDate;

  HotelBookingScreen({
    required this.rooms,
    required this.reservations,
    required this.startDate,
    required this.endDate,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Calendrier horizontal
        _buildHorizontalCalendar(),
        Expanded(
          child: Row(
            children: [
              // Liste des chambres
              _buildRoomList(),
              // Grille de réservation
              _buildReservationGrid(),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildHorizontalCalendar() {
    // Calendrier dynamique s'adaptant aux réservations
    return Container(
      height: 50,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: endDate.difference(startDate).inDays,
        itemBuilder: (context, index) {
          DateTime currentDay = startDate.add(Duration(days: index));
          return Container(
            width: 70,
            alignment: Alignment.center,
            child: Text(
              "${currentDay.day}/${currentDay.month}",
              style: TextStyle(fontSize: 16),
            ),
          );
        },
      ),
    );
  }

  Widget _buildRoomList() {
    return Container(
      width: 100,
      child: ListView.builder(
        itemCount: rooms.length,
        itemBuilder: (context, index) {
          return Container(
            height: 80,
            alignment: Alignment.center,
            child: Text(rooms[index].name),
          );
        },
      ),
    );
  }

  Widget _buildReservationGrid() {
    return Expanded(
      child: ListView.builder(
        itemCount: rooms.length,
        itemBuilder: (context, roomIndex) {
          return Row(
            children: [
              // Liste des jours pour chaque chambre
              Expanded(
                child: Stack(
                  children: reservations
                      .where((res) => res.roomId == rooms[roomIndex].id)
                      .map((reservation) => _buildReservationBar(reservation))
                      .toList(),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildReservationBar(Reservation reservation) {
    int startOffset = reservation.startDate.difference(startDate).inDays;
    int reservationDuration =
        reservation.endDate.difference(reservation.startDate).inDays;

    return Positioned(
      left: startOffset * 70.0, // Taille par jour
      width: reservationDuration * 70.0,
      child: GestureDetector(
        onTap: () {
          // Logique pour afficher les détails de réservation
        },
        child: Container(
          height: 80,
          margin: EdgeInsets.all(4),
          decoration: BoxDecoration(
            color: _getReservationColor(reservation),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Locataire: ${reservation.locaterId}', // Assumes locaterName
                style: TextStyle(color: Colors.white),
              ),
              Text(
                'Prix: \$${reservation.pricePerNight.toStringAsFixed(2)}',
                style: TextStyle(color: Colors.white),
              ),
              Text(
                'État: ${reservation.status}',
                style: TextStyle(color: Colors.white),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Color _getReservationColor(Reservation reservation) {
    // Couleurs différentes selon l'état de la réservation ou locataire
    if (reservation.status == "confirmé") {
      return Colors.green;
    } else if (reservation.status == "annulé") {
      return Colors.red;
    } else {
      return Colors.blue;
    }
  }
}
