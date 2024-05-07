import 'dart:async';
import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'models1.dart';

class UserProviderPref with ChangeNotifier {
  late UserModele _currentUser;
  UserModele get currentUser => _currentUser;

  SharedPreferences? _prefs;

  UserProvider() {
    _init();
  }

  Future<void> _init() async {
    _prefs = await SharedPreferences.getInstance();
    await _loadFromCache();
  }

  Future<void> _loadFromCache() async {
    final userJson = _prefs?.getString('currentUser');
    if (userJson != null) {
      _currentUser = UserModele.fromMap(jsonDecode(userJson), userJson);
    } else {
      // Charger des données par défaut si nécessaire
    }
  }

  Future<void> saveUser(UserModele user) async {
    _currentUser = user;
    await _prefs?.setString('currentUser', jsonEncode(user.toMap()));
    notifyListeners();
  }
}

// Fournisseur pour gérer l'état de l'utilisateur connecté
class UserProviderFire extends ChangeNotifier {
  User? _user =
      FirebaseAuth.instance.currentUser; // L'utilisateur Firebase Auth
  UserModele? _currentUser; // Modèle utilisateur Firestore
  bool _isDisposed = false; // Indicateur de suppression

  // Pour gérer le flux Firestore
  StreamSubscription<DocumentSnapshot>? _subscription;

  UserModele? get currentUser => _currentUser;

  UserProviderFire() {
    loadUser(); // Charger les données utilisateur au démarrage
    startListening(); // Commencer à écouter les changements en temps réel
  }

  @override
  void dispose() {
    _isDisposed = true;

    // Nettoyer le flux Firestore pour éviter les fuites de mémoire
    _subscription?.cancel();

    super.dispose(); // Appeler la méthode `dispose()` de la classe parente
  }

  // Charger les données utilisateur de Firestore
  Future<void> loadUser() async {
    if (_isDisposed) return; // Ne pas continuer si le fournisseur est supprimé
    if (_user == null) {
      print("Aucun utilisateur connecté.");
      return;
    }

    final userDoc = await FirebaseFirestore.instance
        .collection('Users')
        .doc(_user!.uid)
        .get();

    if (_isDisposed) return; // Vérification après opération asynchrone

    if (userDoc.exists) {
      _currentUser = UserModele.fromMap(userDoc.data()!, _user!.uid);
      notifyListeners(); // Informer les consommateurs si non supprimé
    } else {
      _currentUser = null;
    }
  }

  // Écouter les changements en temps réel dans Firestore
  void startListening() {
    _subscription = FirebaseFirestore.instance
        .collection('Users')
        .doc(_user!.uid)
        .snapshots()
        .listen((snapshot) {
      if (_isDisposed) return; // Ne pas continuer si supprimé

      if (snapshot.exists) {
        _currentUser = UserModele.fromMap(snapshot.data()!, _user!.uid);
      } else {
        _currentUser = null;
      }

      notifyListeners(); // Notifier uniquement si non supprimé
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
