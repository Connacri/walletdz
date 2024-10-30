import 'package:objectbox/objectbox.dart';

@Entity()
class Room {
  int id;
  String name;

  Room({this.id = 0, required this.name});
}

@Entity()
class Locater {
  int id;
  String name;
  Locater({this.id = 0, required this.name});
}

@Entity()
class Reservation {
  int id;
  final int roomId;
  final int locaterId;
  final DateTime startDate;
  final DateTime endDate;
  final double pricePerNight;
  final String status;

  Reservation({
    this.id = 0,
    required this.roomId,
    required this.locaterId,
    required this.startDate,
    required this.endDate,
    required this.pricePerNight,
    required this.status,
  });
}
