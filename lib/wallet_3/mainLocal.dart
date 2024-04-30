import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../f_wallet/home.dart';
import 'Models.dart';
import 'home.dart';

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

class UserProvider with ChangeNotifier {
  double _coins = 0; // La valeur initiale des coins.
  String _displayName = '';
  String _email = '';
  String _avatar = '';

  double get coins => _coins; // Accesseur pour récupérer la valeur des coins.
  String get displayName =>
      _displayName; // Accesseur pour récupérer le nom d'utilisateur.
  String get email =>
      _email; // Accesseur pour récupérer l'adresse e-mail de l'utilisateur.
  String get avatar =>
      _avatar; // Accesseur pour récupérer l'URL de l'avatar de l'utilisateur.

  // Méthode pour mettre à jour la valeur des coins.
  void updateCoins(double newCoins) {
    _coins = newCoins;
    notifyListeners(); // Notifie les écouteurs du changement.
  }

  // Méthode pour récupérer le document utilisateur une seule fois et surveiller les "coins".
  void fetchUserAndWatchCoins(String userId) {
    FirebaseFirestore.instance
        .collection('Users')
        .doc(userId)
        .get()
        .then((userDoc) {
      if (userDoc.exists) {
        final userData = userDoc.data();
        if (userData != null) {
          _coins = userData['coins']?.toDouble() ?? 0;
          _displayName = userData['displayName'] ?? '';
          _email = userData['email'] ?? '';
          _avatar = userData['avatar'] ?? '';

          notifyListeners(); // Notifier les écouteurs du changement.

          // Mise en place de la surveillance de "coins" pour les mises à jour futures.
          FirebaseFirestore.instance
              .collection('users')
              .doc(userId)
              .snapshots()
              .listen((docSnapshot) {
            if (docSnapshot.exists) {
              final coins = docSnapshot['coins'];
              if (coins != null) {
                _coins = coins
                    .toDouble(); // Mettre à jour la valeur locale des coins.
                notifyListeners(); // Notifier les écouteurs du changement.
              }
            }
          });
        }
      }
    });
  }

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Map<String, dynamic> _currentUserData = {};
  Map<String, dynamic> get currentUserData => _currentUserData;

  Future<Map<String, dynamic>> fetchCurrentUserData() async {
    final User? user = FirebaseAuth.instance.currentUser;

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

  Stream<List<Gaine>> get gainesStream {
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

class MyWallet3 extends StatelessWidget {
  const MyWallet3({
    super.key,
    required this.userId,
  });

  final String userId;
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => UserProvider()),
      ],
      child: MaterialApp(
        locale: const Locale('fr', 'FR'),
        debugShowCheckedModeBanner: false,
        themeMode: ThemeMode.dark,
        theme: ThemeData(
          fontFamily: 'oswald',
          useMaterial3: true,
          colorScheme: ColorScheme.fromSwatch(
              primarySwatch: Colors.lightBlue, backgroundColor: Colors.white),
        ),
        home: h0me(
          userId: userId,
        ),
      ),
    );
  }
}
