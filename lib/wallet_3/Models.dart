import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel {
  final String id;
  final String avatar;
  final double coins;
  final DateTime createdAt;
  final bool dialogShown;
  final String displayName;
  final String email;
  final DateTime lastActive;
  final String levelUser;
  final int phone;
  final String plan;
  final String role;
  final int stars;
  final bool state;
  final String timeline;
  final int userItemsNbr;
  

  UserModel({
    required this.id,
    required this.avatar,
    required this.coins,
    required this.createdAt,
    required this.dialogShown,
    required this.displayName,
    required this.email,
    required this.lastActive,
    required this.levelUser,
    required this.phone,
    required this.plan,
    required this.role,
    required this.stars,
    required this.state,
    required this.timeline,
    required this.userItemsNbr,
  });

  // Méthode pour créer une instance UserModel à partir d'une carte (Map)
  factory UserModel.fromMap(Map<String, dynamic> data) {
    return UserModel(
      id: data['id'],
      avatar: data['avatar'],
      coins: data['coins'],
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      dialogShown: data['dialogShown'],
      displayName: data['displayName'],
      email: data['email'],
      lastActive: (data['lastActive'] as Timestamp).toDate(),
      levelUser: data['levelUser'],
      phone: data['phone'],
      plan: data['plan'],
      role: data['role'],
      stars: data['stars'],
      state: data['state'],
      timeline: data['timeline'],
      userItemsNbr: data['userItemsNbr'],
    );
  }

  // Méthode pour convertir UserModel en une carte (Map)
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'avatar': avatar,
      'coins': coins,
      'createdAt': createdAt,
      'dialogShown': dialogShown,
      'displayName': displayName,
      'email': email,
      'lastActive': lastActive,
      'levelUser': levelUser,
      'phone': phone,
      'plan': plan,
      'role': role,
      'stars': stars,
      'state': state,
      'timeline': timeline,
      'userItemsNbr': userItemsNbr,
    };
  }
}

class Transaction {
  final String receiverUserId;
  final String senderUserId;
  final Timestamp timestamp;
  final int amount;

  Transaction(
      {required this.receiverUserId,
      required this.senderUserId,
      required this.timestamp,
      required this.amount});
}

class Gaine {
  final double coins;

  Gaine({required this.coins});
}

class ListFood2 {
  String docId;
  String item;
  String desc;
  String image;
  String flav;
  String cat;
  int price;
  Timestamp createdAt;
  String user;

  ListFood2({
    required this.docId,
    required this.item,
    required this.desc,
    required this.image,
    required this.price,
    required this.cat,
    required this.flav,
    required this.createdAt,
    required this.user,
  });
  // factory ListFood2.fromSnapshot(
  //     DocumentSnapshot<Map<String, dynamic>> snapshot) {
  //   Map<String, dynamic> data = snapshot.data()!;
  //   return ListFood2(
  //     docId: data['docId'],
  //     item: data['item'],
  //     flav: data['flav'],
  //     desc: data['desc'],
  //     price: data['price'],
  //     image: data['image'],
  //     cat: data['cat'] ?? '',
  //     createdAt: data['createdAt'],
  //     user: data['user'],
  //   );
  // }

  factory ListFood2.fromMap(Map<String, dynamic> map) {
    return ListFood2(
      docId: map['docId'],
      item: map['item'],
      desc: map['desc'],
      image: map['image'],
      price: map['price'],
      cat: map['cat'] ?? '',
      flav: map['flav'],
      createdAt: map['createdAt'],
      user: map['user'],
    );
  }
  Map<String, dynamic> toMap() {
    return {
      'docId': docId,
      'item': item,
      'desc': desc,
      'image': image,
      'price': price,
      'cat': cat,
      'flav': flav,
      'createdAt': createdAt,
      'user': user,
    };
  }

  factory ListFood2.fromSnapshot(QueryDocumentSnapshot<Object?> snapshot) {
    Map<String, dynamic> data = snapshot.data() as Map<String, dynamic>;
    return ListFood2(
      docId: data['docId'],
      item: data['item'],
      flav: data['flav'],
      desc: data['desc'],
      price: data['price'],
      image: data['image'],
      cat: data['cat'] ?? '',
      createdAt: data['createdAt'],
      user: data['user'],
    );
  }
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
