import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import 'models.dart';

// class WalletProvider extends ChangeNotifier {
//   final String currentUser;
//   double _balance = 0.0;
//   List<Transactions> _transactions = [];
//   StreamSubscription<DocumentSnapshot>? _userSubscription;
//   StreamSubscription<QuerySnapshot>? _transactionsSubscription;
//
//   double get balance => _balance;
//   List<Transactions> get transactions => _transactions;
//   int transMax = 30;
//
//   WalletProvider({required this.currentUser}) {
//     _subscribeToData(transMax);
//   }
//
//   void _subscribeToData(transMax) {
//     // Écoutez les changements dans le document utilisateur
//     _userSubscription = FirebaseFirestore.instance
//         .collection('Users')
//         .doc(currentUser)
//         .snapshots()
//         .listen((doc) {
//       if (doc.exists) {
//         _balance = doc.data()!['coins'] as double;
//         notifyListeners();
//       }
//     });
//
//     // Écoutez les changements dans la collection des transactions
//     _transactionsSubscription = FirebaseFirestore.instance
//         .collection('Users')
//         .doc(currentUser)
//         .collection('transactions')
//         .orderBy('timestamp', descending: true)
//         .snapshots()
//         .listen((querySnapshot) {
//       _transactions = querySnapshot.docs.map((doc) {
//         return Transactions.fromDocument(doc);
//       }).toList();
//
//       _removeExcessTransactions(transMax); // Limiter à cinq transactions
//       notifyListeners();
//     });
//   }
//
//   void _removeExcessTransactions(transMax) {
//     if (_transactions.length > transMax) {
//       final excessTransactions = _transactions.sublist(transMax);
//       for (final transaction in excessTransactions) {
//         FirebaseFirestore.instance
//             .collection('Users')
//             .doc(currentUser)
//             .collection('transactions')
//             .doc(transaction.id) // Utilisez l'ID unique pour supprimer
//             .delete();
//       }
//
//       _transactions = _transactions.sublist(
//           0, transMax); // Gardez les 5 premières transactions
//     }
//   }
//
//   @override
//   void dispose() {
//     _userSubscription?.cancel();
//     _transactionsSubscription?.cancel();
//     super.dispose();
//   }
//
//   Color getBalanceTextColor() {
//     // Retourner la couleur en fonction des conditions
//     final lastTransaction =
//         _transactions.isNotEmpty ? _transactions.first : null;
//
//     if (_balance < 100) {
//       return Colors.red; // Moins de 100 DZD
//     } else if (lastTransaction != null) {
//       if (lastTransaction.amount > 0) {
//         return Colors.blue; // Reçu
//       } else if (lastTransaction.amount < 0) {
//         return Colors.orange; // Dépensé
//       }
//     }
//
//     return Colors.black; // Aucune transaction ou inchangé
//   }
// }
//
// class UserProvider with ChangeNotifier {
//   double _coins = 0; // La valeur initiale des coins.
//   String _displayName = '';
//   String _email = '';
//   String _avatar = '';
//
//   double get coins => _coins; // Accesseur pour récupérer la valeur des coins.
//   String get displayName =>
//       _displayName; // Accesseur pour récupérer le nom d'utilisateur.
//   String get email =>
//       _email; // Accesseur pour récupérer l'adresse e-mail de l'utilisateur.
//   String get avatar =>
//       _avatar; // Accesseur pour récupérer l'URL de l'avatar de l'utilisateur.
//   // Déclaration de la variable d'instance pour la gestion des abonnements
//   bool _isDisposed = false; // Variable pour suivre si le provider est supprimé
//   StreamSubscription<DocumentSnapshot>? _coinsSubscription;
//   // Méthode pour mettre à jour la valeur des coins.
//   UserModele? _user; // Utilisez UserModele si c'est le bon type
//   UserModele? get user => _user;
//
//   void updateCoins(double newCoins) {
//     _coins = newCoins;
//     notifyListeners(); // Notifie les écouteurs du changement.
//   }
//
//   void fetchUserAndWatchCoins(String userId) {
//     FirebaseFirestore.instance
//         .collection('Users')
//         .doc(userId)
//         .get()
//         .then((userDoc) {
//       if (!_isDisposed && userDoc.exists) {
//         final userData = userDoc.data();
//         if (userData != null) {
//           _coins = userData['coins']?.toDouble() ?? 0;
//           _displayName = userData['displayName'] ?? '';
//           _email = userData['email'] ?? '';
//           _avatar = userData['avatar'] ?? '';
//
//           notifyListeners(); // Notifier les écouteurs du changement.
//
//           // Mise en place de la surveillance de "coins" pour les mises à jour futures.
//           _coinsSubscription = FirebaseFirestore.instance
//               .collection('Users')
//               .doc(userId)
//               .snapshots()
//               .listen((docSnapshot) {
//             if (!_isDisposed && docSnapshot.exists) {
//               final coins = docSnapshot['coins'];
//               if (coins != null) {
//                 _coins = coins
//                     .toDouble(); // Mettre à jour la valeur locale des coins.
//                 if (!_isDisposed) {
//                   // Vérifiez avant de notifier
//                   notifyListeners();
//                 } // Notifier les écouteurs du changement.
//               }
//             }
//           });
//         }
//       }
//     });
//   }
//
//   // void fetchUserAndWatchCoins(String userId) {
//   //   FirebaseFirestore.instance
//   //       .collection('Users')
//   //       .doc(userId)
//   //       .get()
//   //       .then((userDoc) {
//   //     if (!_isDisposed && userDoc.exists) {
//   //       final userData = userDoc.data();
//   //       if (userData != null) {
//   //         // Créez une instance de User à partir du document Firestore
//   //         _user = UserModele.fromMap(userData, userId); // Correction
//   //
//   //         // Notifiez les auditeurs que le profil utilisateur a été chargé
//   //         notifyListeners();
//   //
//   //         // Configurez la surveillance du champ 'coins'
//   //         _coinsSubscription = FirebaseFirestore.instance
//   //             .collection('Users')
//   //             .doc(userId)
//   //             .snapshots()
//   //             .listen((docSnapshot) {
//   //           if (!_isDisposed && docSnapshot.exists) {
//   //             final coins = docSnapshot['coins'];
//   //             if (coins != null && _user != null) {
//   //               _user!.coins =
//   //                   coins.toDouble(); // Mettez à jour la valeur des coins.
//   //               if (!_isDisposed) {
//   //                 // Vérifiez avant de notifier
//   //                 notifyListeners();
//   //               }
//   //             }
//   //           }
//   //         });
//   //       }
//   //     }
//   //   });
//   // }
//
//   @override
//   void dispose() {
//     _isDisposed = true; // Marquez le provider comme supprimé
//     _coinsSubscription?.cancel(); // Annulez l'abonnement
//     super.dispose();
//   }
//
//   final FirebaseFirestore _firestore = FirebaseFirestore.instance;
//
//   Map<String, dynamic> _currentUserData = {};
//   Map<String, dynamic> get currentUserData => _currentUserData;
//
//   Future<Map<String, dynamic>> fetchCurrentUserData() async {
//     final user = FirebaseAuth.instance.currentUser;
//
//     if (user != null) {
//       final String currentUserId = user.uid;
//       final DocumentSnapshot<Map<String, dynamic>> userSnapshot =
//           await _firestore.collection('Users').doc(currentUserId).get();
//
//       if (userSnapshot.exists) {
//         _currentUserData = userSnapshot.data()!;
//         notifyListeners();
//         return _currentUserData;
//       }
//     }
//
//     return {}; // Renvoie un objet vide si les données ne sont pas trouvées
//   }
//
//   Map<String, dynamic> _scannedUserData = {};
//   Map<String, dynamic> get scannedUserData => _scannedUserData;
//
//   Future<Map<String, dynamic>> fetchScannedUserData(String scannedUser) async {
//     if (scannedUser != null) {
//       final DocumentSnapshot<Map<String, dynamic>> userSnapshot =
//           await _firestore.collection('Users').doc(scannedUser).get();
//
//       if (userSnapshot.exists) {
//         _scannedUserData = userSnapshot.data()!;
//
//         notifyListeners();
//         return _scannedUserData; // Ajoutez cette ligne pour renvoyer les données
//       }
//     }
//
//     return {}; // Ajoutez cette ligne pour renvoyer un objet vide si les données ne sont pas trouvées
//   }
//
//   Stream<List<Gaine>>? get gainesStream {
//     return FirebaseFirestore.instance
//         .collection('gaines')
//         .snapshots()
//         .map((querySnapshot) {
//       return querySnapshot.docs.map((doc) {
//         return Gaine(coins: doc['coins']);
//       }).toList();
//     });
//   }
// }

class WalletProvider extends ChangeNotifier {
  final String currentUser;
  double _balance = 0.0;
  List<Transactions> _transactions = [];
  StreamSubscription<DocumentSnapshot>? _userSubscription;
  StreamSubscription<QuerySnapshot>? _transactionsSubscription;

  double get balance => _balance;

  List<Transactions> get transactions => _transactions;

  WalletProvider({required this.currentUser}) {
    _subscribeToData();
  }

  void _subscribeToData() {
    // Écouter les changements du document utilisateur
    _userSubscription = FirebaseFirestore.instance
        .collection('Users')
        .doc(currentUser)
        .snapshots()
        .listen((doc) {
      if (doc.exists && doc.data() != null) {
        final data = doc.data()!;
        _balance = data['coins'] as double? ?? 0.0;
        notifyListeners();
      }
    });

    // Écouter les changements dans la collection des transactions
    _transactionsSubscription = FirebaseFirestore.instance
        .collection('Users')
        .doc(currentUser)
        .collection('transactions')
        .orderBy('timestamp', descending: true)
        //.limit(30) // Limiter le nombre de transactions pour éviter l'excès
        .snapshots()
        .listen((querySnapshot) {
      _transactions = querySnapshot.docs.map((doc) {
        return Transactions.fromDocument(doc);
      }).toList();

      notifyListeners();
    });
  }

  @override
  void dispose() {
    _userSubscription?.cancel(); // Annuler les abonnements
    _transactionsSubscription?.cancel();
    super.dispose();
  }

  // Méthode pour obtenir la couleur du texte en fonction du solde
  Color getBalanceTextColor() {
    if (_balance < 100) {
      return Colors.red;
    } else {
      return Colors.black;
    }
  }
}

class UserProvider with ChangeNotifier {
  double _coins = 0.0; // La valeur initiale des coins
  String _displayName = '';
  String _email = '';
  String _avatar = '';

  // Getters pour accéder aux valeurs
  double get coins => _coins;

  String get displayName => _displayName;

  String get email => _email;

  String get avatar => _avatar;
  bool _isDisposed = false; // Suivre si le provider est supprimé
  StreamSubscription<DocumentSnapshot>? _coinsSubscription;
  UserModele? _user;

  UserModele? get user => _user;

  void fetchUserAndWatchCoins(String userId) {
    _coinsSubscription?.cancel(); // Annuler toute souscription précédente

    FirebaseFirestore.instance
        .collection('Users')
        .doc(userId)
        .snapshots() // Utilisation de snapshots pour la surveillance en temps réel
        .listen((docSnapshot) {
      if (!_isDisposed && docSnapshot.exists && docSnapshot.data() != null) {
        final userData = docSnapshot.data()!;
        _coins = userData['coins'] as double? ?? 0.0;
        _displayName = userData['displayName'] ?? '';
        _email = userData['email'] ?? '';
        _avatar = userData['avatar'] ?? '';

        notifyListeners(); // Notifier les écouteurs
      }
    });
  }

  @override
  void dispose() {
    _isDisposed = true;
    _coinsSubscription?.cancel(); // Annuler l'abonnement
    super.dispose();
  }

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Map<String, dynamic> _currentUserData = {};

  Map<String, dynamic> get currentUserData => _currentUserData;

  Future<Map<String, dynamic>> fetchCurrentUserData() async {
    final user = FirebaseAuth.instance.currentUser;

    if (user != null) {
      final String currentUserId = user.uid;
      final DocumentSnapshot<Map<String, dynamic>> userSnapshot =
          await _firestore.collection('Users').doc(currentUserId).get();

      if (userSnapshot.exists) {
        _currentUserData = userSnapshot.data()!;
        notifyListeners();
        return _currentUserData;
      }
    }

    return {}; // Renvoie un objet vide si les données ne sont pas trouvées
  }

  Map<String, dynamic> _scannedUserData = {};

  Map<String, dynamic> get scannedUserData => _scannedUserData;

  Future<Map<String, dynamic>> fetchScannedUserData(String scannedUser) async {
    if (scannedUser != null) {
      final DocumentSnapshot<Map<String, dynamic>> userSnapshot =
          await _firestore.collection('Users').doc(scannedUser).get();

      if (userSnapshot.exists) {
        _scannedUserData = userSnapshot.data()!;

        notifyListeners();
        return _scannedUserData; // Ajoutez cette ligne pour renvoyer les données
      }
    }

    return {}; // Ajoutez cette ligne pour renvoyer un objet vide si les données ne sont pas trouvées
  }

  Stream<List<Gaine>>? get gainesStream {
    return FirebaseFirestore.instance
        .collection('gaines')
        .snapshots()
        .map((querySnapshot) {
      return querySnapshot.docs.map((doc) {
        return Gaine(coins: doc['coins']);
      }).toList();
    });
  }
}
