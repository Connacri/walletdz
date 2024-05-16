import 'dart:async';
import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'models1.dart';

// class UserProviderFire extends ChangeNotifier {
//   User? _user =
//       FirebaseAuth.instance.currentUser; // L'utilisateur Firebase Auth
//   // Modèle utilisateur Firestore
//   bool _isDisposed = false; // Indicateur de suppression
//
//   // Pour gérer le flux Firestore
//   StreamSubscription<DocumentSnapshot>? _subscription;
//   UserModele? _currentUser;
//   UserModele? get currentUser => _currentUser;
//
//   UserProviderFire() {
//     loadUser(); // Charger les données utilisateur au démarrage
//     startListening(); // Commencer à écouter les changements en temps réel
//   }
//
//   @override
//   void dispose() {
//     _isDisposed = true;
//
//     // Nettoyer le flux Firestore pour éviter les fuites de mémoire
//     _subscription?.cancel();
//
//     super.dispose(); // Appeler la méthode `dispose()` de la classe parente
//   }
//
//   // Charger les données utilisateur de Firestore (une seule fois au démarrage)
//   Future<void> loadUser() async {
//     if (_isDisposed || _currentUser != null)
//       return; // Ne pas recharger si déjà chargé ou supprimé
//     if (_user == null) {
//       print("Aucun utilisateur connecté.");
//       return;
//     }
//
//     final userDoc = await FirebaseFirestore.instance
//         .collection('Users')
//         .doc(_user!.uid)
//         .get();
//
//     if (_isDisposed) return; // Vérification après opération asynchrone
//
//     if (userDoc.exists) {
//       _currentUser = UserModele.fromMap(userDoc.data()!, _user!.uid);
//       notifyListeners(); // Informer les consommateurs si non supprimé
//     } else {
//       _currentUser = null;
//     }
//   }
//
//   // Écouter les changements en temps réel dans Firestore pour garder le modèle à jour
//   void startListening() {
//     if (_user != null && _subscription == null) {
//       _subscription = FirebaseFirestore.instance
//           .collection('Users')
//           .doc(_user!.uid)
//           .snapshots()
//           .listen((snapshot) {
//         if (_isDisposed) return;
//
//         if (snapshot.exists) {
//           _currentUser = UserModele.fromMap(snapshot.data()!, _user!.uid);
//           notifyListeners(); // Notifier uniquement si non supprimé
//         }
//       });
//     }
//   }
//
//   UserModele? _scannedUserData;
//   UserModele? get scannedUserData => _scannedUserData;
//
//   Future<UserModele?> fetchScannedUserData(String scannedUser) async {
//     final DocumentSnapshot<Map<String, dynamic>> userSnapshot =
//         await FirebaseFirestore.instance
//             .collection('Users')
//             .doc(scannedUser)
//             .get();
//
//     if (userSnapshot.exists) {
//       // Assignation correcte des données
//       _scannedUserData = UserModele.fromMap(userSnapshot.data()!, scannedUser);
//
//       // Notifiez les consommateurs
//       notifyListeners();
//       return _scannedUserData;
//     }
//
//     // Retourne null si aucune donnée trouvée
//     return null;
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

class UserProviderFire extends ChangeNotifier {
  SharedPreferences? _prefs; // Shared Preferences
  User? _user = FirebaseAuth.instance.currentUser; // Utilisateur Firebase Auth
  bool _isDisposed = false; // Indicateur de suppression

  StreamSubscription<DocumentSnapshot>?
      _subscription; // Écoute des flux Firestore

  UserModele? _currentUser; // Champ privé pour stocker l'utilisateur actuel
  // Getter public pour accéder au champ privé
  UserModele? get currentUser => _currentUser;

  UserProviderFire() {
    initializeSharedPreferences(); // Initialiser Shared Preferences
    loadUser(); // Charger les données utilisateur
    startListening(); // Écouter les changements en temps réel
  }

  Future<void> initializeSharedPreferences() async {
    _prefs = await SharedPreferences
        .getInstance(); // Obtenir l'instance de Shared Preferences
  }

  @override
  void dispose() {
    _isDisposed = true;
    _subscription?.cancel(); // Nettoyer le flux Firestore
    super.dispose(); // Appeler la méthode `dispose()` de la classe parente
  }

  Future<void> loadUser() async {
    if (_isDisposed) return; // Éviter des opérations inutiles

    // Vérifier les données utilisateur dans Shared Preferences
    if (_prefs != null && _prefs!.containsKey('currentUser')) {
      final userJson = _prefs!.getString(
          'currentUser'); // Récupérer les données depuis Shared Preferences
      if (userJson != null) {
        // Charger le modèle utilisateur depuis le JSON
        final userMap = jsonDecode(userJson); // Convertir le JSON en carte
        _currentUser = UserModele.fromMap(userMap, _user!.uid); // Créer l'objet
        notifyListeners(); // Notifier les auditeurs
        return; // Arrêter l'exécution
      }
    }

    // Si pas de données dans Shared Preferences, charger depuis Firestore
    if (_user != null) {
      final userDoc = await FirebaseFirestore.instance
          .collection('Users')
          .doc(_user!.uid)
          .get();

      if (userDoc.exists && userDoc.data() != null) {
        _currentUser = UserModele.fromMap(userDoc.data()!, _user!.uid);
        // Sauvegarder dans Shared Preferences
        _prefs!.setString('currentUser', jsonEncode(userDoc.data()!));
        notifyListeners(); // Notifier les auditeurs
      }
    }
  }

  void startListening() {
    if (_user != null && _subscription == null) {
      _subscription = FirebaseFirestore.instance
          .collection('Users')
          .doc(_user!.uid)
          .snapshots()
          .listen((snapshot) {
        if (_isDisposed) return; // Ne rien faire si l'objet est supprimé

        if (snapshot.exists && snapshot.data() != null) {
          _currentUser = UserModele.fromMap(snapshot.data()!, _user!.uid);
          _prefs!.setString(
              'currentUser',
              jsonEncode(
                  snapshot.data()!)); // Mettre à jour dans Shared Preferences
          notifyListeners(); // Notifier les auditeurs
        }
      });
    }
  }

  Future<void> updateCurrentUser(UserModele updatedUser) async {
    if (_currentUser != null) {
      _currentUser = updatedUser;
      _prefs!.setString(
          'currentUser',
          jsonEncode(
              updatedUser.toMap())); // Mettre à jour dans Shared Preferences
      notifyListeners(); // Notifier les auditeurs
    }
  }

  UserModele? _scannedUserData;

  UserModele? get scannedUserData => _scannedUserData;

  Future<UserModele?> fetchScannedUserData(String scannedUser) async {
    final DocumentSnapshot<Map<String, dynamic>> userSnapshot =
        await FirebaseFirestore.instance
            .collection('Users')
            .doc(scannedUser)
            .get();

    if (userSnapshot.exists) {
      // Assignation correcte des données
      _scannedUserData = UserModele.fromMap(userSnapshot.data()!, scannedUser);

      // Notifiez les consommateurs
      notifyListeners();
      return _scannedUserData;
    }

    // Retourne null si aucune donnée trouvée
    return null;
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

  // Retourne un flux qui émet les données utilisateur
  Stream<UserModele?> get userStream {
    User? user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      return Stream.value(null); // Émettre une valeur null si aucun utilisateur
    }

    return FirebaseFirestore.instance
        .collection('Users')
        .doc(user.uid)
        .snapshots()
        .map((snapshot) {
      if (snapshot.exists && snapshot.data() != null) {
        return UserModele.fromMap(
            snapshot.data()!, user.uid); // Convertir le document en UserModele
      } else {
        return null; // Retourner null si le document n'existe pas
      }
    });
  }
}

class TransfersProvider extends ChangeNotifier {
  List<Transactionss> _allTransfers = []; // Liste des transactions
  List<Transactionss> get allTransfers =>
      _allTransfers; // Accès à la liste des transferts

  SharedPreferences? _prefs;
  bool _isDisposed = false; // Indicateur de suppression
  StreamSubscription<QuerySnapshot>?
      _subscription; // Pour gérer le flux Firestore

  TransfersProvider() {
    _init(); // Initialiser le fournisseur
  }

  Future<void> _init() async {
    _prefs = await SharedPreferences
        .getInstance(); // Obtenir l'instance de SharedPreferences
    await _loadFromCache(); // Charger à partir du cache
    await _loadFromFirestore(); // Charger à partir de Firestore
  }

  @override
  void dispose() {
    _isDisposed = true; // Marquer le fournisseur comme supprimé

    // Nettoyer le flux pour éviter les fuites de mémoire
    _subscription?.cancel();

    super.dispose(); // Appeler la méthode dispose de la classe parente
  }

  // Charger les transferts depuis SharedPreferences
  Future<void> _loadFromCache() async {
    if (_isDisposed) return; // Évitez d'agir après suppression

    final transfersJson =
        _prefs?.getStringList('transfers'); // Obtenir la liste des transferts
    if (transfersJson != null) {
      _allTransfers = transfersJson
          .map((e) => Transactionss.fromMap(jsonDecode(e)))
          .toList(); // Convertir les données JSON en objets Transaction
    }

    if (!_isDisposed) {
      notifyListeners(); // Notifier les consommateurs si non supprimé
    }
  }

  int currentPage = 1; // Page initiale
  final int itemsPerPage = 10; // Nombre d'éléments par page
  List<Transactionss> get paginatedTransfers {
    final startIndex = (currentPage - 1) * itemsPerPage;
    final endIndex = startIndex + itemsPerPage;
    return _allTransfers.sublist(
        startIndex, endIndex.clamp(0, _allTransfers.length));
  }

  void loadNextPage() {
    if (currentPage * itemsPerPage >= _allTransfers.length) {
      // Si la page suivante dépasse le nombre d'éléments disponibles,
      // nous devrions recharger depuis Firestore
      _loadFromFirestore().then((_) {
        currentPage++; // Augmentez la page actuelle
        notifyListeners(); // Notifiez les écouteurs pour la mise à jour de la pagination
      });
    } else {
      currentPage++; // Sinon, chargez la page suivante
      notifyListeners();
    }
  }

  // Charger les transferts depuis Firestore
  Future<void> _loadFromFirestore() async {
    if (_isDisposed)
      return; // Ne pas continuer si le fournisseur a été supprimé

    _subscription = FirebaseFirestore.instance
        .collection('Users')
        .doc(FirebaseAuth
            .instance.currentUser?.uid) // Obtenir l'utilisateur actuel
        .collection('transactions')
        .orderBy('timestamp', descending: false) // Accéder à la sous-collection
        .snapshots() // Écouter les modifications
        .listen((snapshot) {
      if (_isDisposed) return; // Ne pas continuer si supprimé

      _allTransfers = snapshot.docs
          .map((doc) => Transactionss.fromMap(doc.data()))
          .toList(); // Convertir les documents en objets Transaction

      if (!_isDisposed) {
        notifyListeners(); // Notifier les consommateurs si non supprimé
      }
    });
  }

  // Sauvegarder les transferts dans SharedPreferences
  Future<void> saveTransfersToCache(List<Transactionss> transfers) async {
    if (_isDisposed) return; // Évitez d'agir après suppression

    _allTransfers = transfers; // Mettre à jour la liste interne
    await _prefs?.setStringList(
      'transfers',
      transfers
          .map((e) => jsonEncode(e.toMap()))
          .toList(), // Stocker sous forme de JSON
    );

    if (!_isDisposed) {
      notifyListeners(); // Notifier après sauvegarde dans le cache
    }
  }

  // Sauvegarder les transferts dans Firestore
  Future<void> saveTransfersToFirestore(List<Transactionss> transfers) async {
    if (_isDisposed) return; // Évitez d'agir après suppression

    final batch = FirebaseFirestore.instance
        .batch(); // Utiliser des opérations de batch pour optimisation
    for (var transfer in transfers) {
      final ref = FirebaseFirestore.instance
          .collection('Users')
          .doc(FirebaseAuth.instance.currentUser?.uid)
          .collection('transactions')
          .doc(transfer.id); // Référence à la sous-collection
      batch.set(ref, transfer.toMap()); // Enregistrer chaque transaction
    }

    await batch.commit(); // Commiter toutes les opérations du batch

    if (!_isDisposed) {
      notifyListeners(); // Notifier après sauvegarde dans Firestore
    }
  }
}
