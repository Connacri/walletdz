// class Profile {
//   Profile({
//     required this.id,
//     required this.username,
//     required this.createdAt,
//   });
//
//   /// User ID of the profile
//   final String id;
//
//   /// Username of the profile
//   final String username;
//
//   /// Date and time when the profile was created
//   final DateTime createdAt;
//
//   Profile.fromMap(Map<String, dynamic> map)
//       : id = map['id'],
//         username = map['username'],
//         createdAt = DateTime.parse(map['created_at']);
// }
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
      email: data['email'] as String? ?? '',
      // Default value if null
      phone: data['phone'] as int? ?? 0,
      // Default value if null
      avatar: data['avatar'] as String? ?? '',
      timeline: data['timeline'] as String? ?? '',
      state: data['state'] as bool? ?? false,
      role: data['role'] as String? ?? '',
      plan: data['plan'] ?? 'free',
      // Default plan
      coins: data['coins'] as double? ?? 0.0,
      // Default coins
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

class Message {
  Message({
    required this.id,
    required this.profileId,
    required this.content,
    required this.createdAt,
    required this.isMine,
  });

  /// ID of the message
  final String id;

  /// ID of the user who posted the message
  final String profileId;

  /// Text content of the message
  final String content;

  /// Date and time when the message was created
  final DateTime createdAt;

  /// Whether the message is sent by the user or not.
  final bool isMine;

  Message.fromMap({
    required Map<String, dynamic> map,
    required String myUserId,
  })  : id = map['id'],
        profileId = map['profile_id'],
        content = map['content'],
        createdAt = DateTime.parse(map['created_at']),
        isMine = myUserId == map['profile_id'];
}

class Profile {
  Profile({
    required this.profileId,
    required this.email,
    required this.username,
    required this.createdAt,
    required this.idTiers,
    required this.send,
    required this.status,
    required this.avatar,
    required this.timeline,
    required this.amount,
  });

  /// Profile ID (UUID)
  final String profileId;

  /// Email of the profile
  final String email;

  /// Username of the profile
  final String username;

  /// Date and time when the profile was created
  final DateTime createdAt;

  /// ID tiers
  final String idTiers;

  /// Send status
  final bool send;

  /// Status
  final bool status;

  /// Avatar URL or path
  final String avatar;

  /// Timeline information
  final String timeline;

  /// Amount in the profile
  final double amount;

  /// Creates a `Profile` instance from a map
  Profile.fromMap(Map<String, dynamic> map)
      : profileId = map['profile_id'],
        email = map['email'],
        username = map['username'],
        createdAt = DateTime.parse(map['created_at']),
        idTiers = map['id_tiers'],
        send = map['send'],
        status = map['status'],
        avatar = map['avatar'],
        timeline = map['timeline'],
        amount = (map['amount'] is int)
            ? (map['amount'] as int).toDouble()
            : map['amount'] as double;

  /// Converts a `Profile` instance to a map
  Map<String, dynamic> toMap() {
    return {
      'profile_id': profileId,
      'email': email,
      'username': username,
      'created_at': createdAt.toIso8601String(),
      'id_tiers': idTiers,
      'send': send,
      'status': status,
      'avatar': avatar,
      'timeline': timeline,
      'amount': amount,
    };
  }
}
