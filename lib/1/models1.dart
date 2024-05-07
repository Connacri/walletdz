import 'package:cloud_firestore/cloud_firestore.dart';

class UserModele {
  final String uid;
  final String name;
  final String? email; // Optional
  final int? phone; // Optional
  final String? avatar; // Optional
  final String? timeline; // Optional
  final bool? state; // Optional
  final String? role; // Optional
  final String plan;
  double coins; // Mutable
  final Timestamp lastActive;
  final Timestamp createdAt;
  final double stars; // Optional
  final String levelUser; // Optional
  final int userItemsNbr; // Optional

  UserModele({
    required this.uid,
    required this.name,
    this.email,
    this.phone,
    this.avatar,
    this.timeline,
    this.state,
    this.role,
    required this.plan,
    required this.coins,
    required this.lastActive,
    required this.createdAt,
    required this.stars,
    required this.levelUser,
    required this.userItemsNbr,
  });

  // Méthode pour créer une instance à partir d'un document Firestore
  factory UserModele.fromMap(Map<String, dynamic> data, String uid) {
    return UserModele(
      uid: uid,
      name: data['displayName'] ?? 'Nom Inconnu',
      email: data['email'] as String? ?? '', // Default value if null
      phone: data['phone'] as int? ?? 0, // Default value if null
      avatar: data['avatar'] as String? ?? '',
      timeline: data['timeline'] as String? ?? '',
      state: data['state'] as bool? ?? false,
      role: data['role'] as String? ?? '',
      plan: data['plan'] ?? 'free', // Default plan
      coins: data['coins'] as double? ?? 0.0, // Default coins
      lastActive: data['lastActive'] as Timestamp,
      createdAt: data['createdAt'] as Timestamp,
      stars: data['stars'] as double? ?? 0.0,
      levelUser: data['levelUser'] as String? ?? 'begin',
      userItemsNbr: data['userItemsNbr'] as int? ?? 0,
    );
  }

  // Méthode pour convertir en carte de données pour Firestore
  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'name': name,
      'email': email,
      'phone': phone,
      'avatar': avatar,
      'timeline': timeline,
      'state': state,
      'role': role,
      'plan': plan,
      'coins': coins,
      'lastActive': lastActive,
      'createdAt': createdAt,
      'stars': stars,
      'levelUser': levelUser,
      'userItemsNbr': userItemsNbr,
    };
  }
}

// class Transfer {
//   final String id;
//   final String fromUser;
//   final String toUser;
//   final double amount;
//   final DateTime date;
//
//   Transfer({
//     required this.id,
//     required this.fromUser,
//     required this.toUser,
//     required this.amount,
//     required this.date,
//   });
//
//   Map<String, dynamic> toMap() {
//     return {
//       'id': id,
//       'fromUser': fromUser,
//       'toUser': toUser,
//       'amount': amount,
//       'date': date.toIso8601String(),
//     };
//   }
//
//   static Transfer fromMap(Map<String, dynamic> map) {
//     return Transfer(
//       id: map['id'],
//       fromUser: map['fromUser'],
//       toUser: map['toUser'],
//       amount: map['amount'],
//       date: DateTime.parse(map['date']),
//     );
//   }
// }

class Transactionss {
  final String id; // ID unique
  final double amount; // Montant de la transaction
  final String avatar; // Image associée
  final String description; // Description de la transaction
  final bool direction; // Direction (true = envoyé, false = reçu)
  final String displayName; // Nom à afficher
  final String state; // État de la transaction
  final Timestamp timestamp; // Horodatage de la transaction

  Transactionss({
    required this.id,
    required this.amount,
    required this.avatar,
    required this.description,
    required this.direction,
    required this.displayName,
    required this.state,
    required this.timestamp,
  });

  factory Transactionss.fromMap(Map<String, dynamic> map) {
    return Transactionss(
      id: map['id'] ?? '', // Gestion des valeurs par défaut
      amount: map['amount'] ?? 0.0,
      avatar: map['avatar'] ?? '',
      description: map['description'] ?? '',
      direction: map['direction'] ?? false,
      displayName: map['displayName'] ?? '',
      state: map['state'] ?? '',
      timestamp: map['timestamp'] ??
          Timestamp.now(), // Si pas de timestamp, utilisez le temps actuel
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'amount': amount,
      'avatar': avatar,
      'description': description,
      'direction': direction,
      'displayName': displayName,
      'state': state,
      'timestamp': timestamp,
    };
  }
}
