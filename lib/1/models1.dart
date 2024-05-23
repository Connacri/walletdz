import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:cloud_firestore/cloud_firestore.dart';

class UserModele {
  final String uid;
  final String name;
  final String? email;
  final int? phone;
  final String? avatar;
  final String? timeline;
  final bool? state;
  final String? role;
  final String plan;
  double coins;
  final Timestamp lastActive;
  final Timestamp createdAt;
  final double? stars;
  final String? levelUser;
  final int? userItemsNbr;

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
    this.stars,
    this.levelUser,
    this.userItemsNbr,
  });

  factory UserModele.fromMap(Map<String, dynamic> data, String uid) {
    return UserModele(
      uid: uid,
      name: data['name'] ?? 'Nom Inconnu',
      email: data['email'] as String?,
      phone: data['phone'] as int?,
      avatar: data['avatar'] as String?,
      timeline: data['timeline'] as String?,
      state: data['state'] as bool?,
      role: data['role'] as String?,
      plan: data['plan'] ?? 'free',
      coins: (data['coins'] as num?)?.toDouble() ?? 0.0,
      lastActive: data['lastActive'] as Timestamp,
      createdAt: data['createdAt'] as Timestamp,
      stars: (data['stars'] as num?)?.toDouble() ?? 0.0,
      levelUser: data['levelUser'] as String?,
      userItemsNbr: data['userItemsNbr'] as int?,
    );
  }

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
      'lastActive': lastActive.toDate().toIso8601String(),
      'createdAt': createdAt.toDate().toIso8601String(),
      'stars': stars,
      'levelUser': levelUser,
      'userItemsNbr': userItemsNbr,
    };
  }
}

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
      id: map['id'] ?? '',
      // Gestion des valeurs par défaut
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

class Gaine {
  final double coins;

  Gaine({required this.coins});
}
