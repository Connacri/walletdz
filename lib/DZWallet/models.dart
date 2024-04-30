import 'package:cloud_firestore/cloud_firestore.dart';

class UserModele {
  final String uid;
  final String name;
  final String? email; // Optionnel
  final int? phone; // Optionnel
  final String? avatar; // Optionnel
  final String? timeline; // Optionnel
  final bool? state; // Optionnel
  final String? role; // Optionnel
  final String plan;
  late double coins;
  final Timestamp lastActive;
  final Timestamp createdAt;
  final double stars;
  final String levelUser;
  final int userItemsNbr;

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

  // Méthode pour créer un objet User à partir d'un document Firestore
  factory UserModele.fromMap(Map<String, dynamic> data, String uid) {
    return UserModele(
      uid: uid,
      name: data['displayName'] ?? 'Nom Inconnu',
      email: data.containsKey('email') ? data['email'] as String? : null,
      phone: data.containsKey('phone') ? data['phone'] as int? : null,
      avatar: data.containsKey('avatar') ? data['avatar'] as String? : null,
      timeline:
          data.containsKey('timeline') ? data['timeline'] as String? : null,
      state: data.containsKey('state') ? data['state'] as bool? : null,
      role: data.containsKey('role') ? data['role'] as String? : null,
      plan: data.containsKey('plan') ? data['plan'] as String : 'free',
      coins: data.containsKey('coins') ? (data['coins'] as double) : 0.0,
      lastActive: data['lastActive'] as Timestamp,
      createdAt: data['createdAt'] as Timestamp,
      stars: data.containsKey('stars') ? (data['stars'] as double) : 0.0,
      levelUser:
          data.containsKey('levelUser') ? data['levelUser'] as String : 'begin',
      userItemsNbr:
          data.containsKey('userItemsNbr') ? (data['userItemsNbr'] as int) : 0,
    );
  }

  // Méthode pour convertir un objet User en carte de données pour Firestore
  Map<String, dynamic> toMap() {
    return {
      'id': uid,
      'displayName': name,
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

class Transactions {
  final String id;
  final double amount;
  final String description;
  final bool direction; // true pour entrée, false pour sortie
  final String state; // État de la transaction
  final DateTime timestamp;
  final String? avatar; // Chemin de l'avatar
  final String displayName;
  Transactions(
      {required this.id,
      required this.amount,
      required this.description,
      required this.direction,
      required this.state,
      required this.timestamp,
      required this.avatar,
      required this.displayName});

  // Méthode pour créer une instance à partir d'un document Firestore
  factory Transactions.fromDocument(DocumentSnapshot doc) {
    // Vérifiez si le document contient les champs attendus
    if (!doc.exists) {
      throw Exception("Document does not exist");
    }

    // Obtenir les valeurs avec vérification et valeur par défaut
    final id = doc.id; // ID du document
    final amount = doc['amount'] as double;
    final description = doc['description'] as String? ?? 'Pas de description';
    final direction = doc['direction'] as bool? ?? false; // Par défaut: sortie
    final state = doc['state'] as String? ?? 'inconnu'; // État par défaut
    final timestamp =
        (doc['timestamp'] as Timestamp?)?.toDate() ?? DateTime.now();
    final avatar = doc['avatar']; // Avatar URL optionnel
    final displayName = doc['displayName'];
    return Transactions(
      id: id,
      amount: amount,
      description: description,
      direction: direction,
      state: state,
      timestamp: timestamp,
      avatar: avatar,
      displayName: displayName,
    );
  }
}

class Wallet {
  final double balance;
  final List<Transaction> transactions;

  Wallet({
    required this.balance,
    required this.transactions,
  });
}

class Gaine {
  final double coins;

  Gaine({required this.coins});
}

class TransactionModel {
  String senderUserId;
  String receiverUserId;
  double amount;
  final Timestamp timestamp;
  // Utilisez Timestamp au lieu de DateTime

  TransactionModel({
    required this.senderUserId,
    required this.receiverUserId,
    required this.amount,
    required this.timestamp,
  });

  // Méthode pour convertir votre modèle en Map
  Map<String, dynamic> toMap() {
    return {
      'senderUserId': senderUserId,
      'receiverUserId': receiverUserId,
      'amount': amount,
      'timestamp': timestamp, // Conservez le Timestamp ici
    };
  }

  // Méthode pour créer un modèle à partir d'une Map
  factory TransactionModel.fromMap(Map<String, dynamic> map) {
    return TransactionModel(
      senderUserId: map['senderUserId'],
      receiverUserId: map['receiverUserId'],
      amount: map['amount'],
      timestamp: map['timestamp'], // Conservez le Timestamp ici
    );
  }
}

class TransactionsSous {
  final String id;
  final double amount;
  final String state;
  final bool direction;
  final String description;
  final Timestamp timestamp;

  TransactionsSous({
    required this.id,
    required this.amount,
    required this.state,
    required this.direction,
    required this.description,
    required this.timestamp,
  });

  // Méthode pour convertir votre modèle en Map
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'amount': amount,
      'state': state,
      'direction': direction,
      'description': description,
      'timestamp': timestamp,
    };
  }

  // Méthode pour créer un modèle à partir d'une Map
  factory TransactionsSous.fromMap(Map<String, dynamic> map) {
    return TransactionsSous(
      id: map['id'],
      amount: map['amount'],
      state: map['state'],
      direction: map['direction'],
      description: map['description'],
      timestamp: map['timestamp'],
    );
  }
}
