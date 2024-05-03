import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Modèle de transfert
class Transfer {
  final String id;
  final String fromUser;
  final String toUser;
  final double amount;
  final DateTime date;

  Transfer({
    required this.id,
    required this.fromUser,
    required this.toUser,
    required this.amount,
    required this.date,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'fromUser': fromUser,
      'toUser': toUser,
      'amount': amount,
      'date': date.toIso8601String(),
    };
  }

  static Transfer fromMap(Map<String, dynamic> map) {
    return Transfer(
      id: map['id'],
      fromUser: map['fromUser'],
      toUser: map['toUser'],
      amount: map['amount'],
      date: DateTime.parse(map['date']),
    );
  }
}

// Provider pour gérer les données
class TransfersProvider with ChangeNotifier {
  late final FirebaseFirestore _firestore;
  late final SharedPreferences _prefs;

  double _balance = 0.0;
  double get balance => _balance;

  List<Transfer> _recentTransfers = [];
  List<Transfer> get recentTransfers => _recentTransfers;

  List<Transfer> _allTransfers = [];
  List<Transfer> get allTransfers => _allTransfers;

  TransfersProvider() {
    _firestore = FirebaseFirestore.instance;
    _init();
  }

  Future<void> _init() async {
    _prefs = await SharedPreferences.getInstance();

    await _loadFromCache();
    await _fetchFromFirestore();
  }

  Future<void> _loadFromCache() async {
    // Charger le solde depuis le cache
    _balance = _prefs.getDouble('balance') ?? 0.0;

    // Charger les transferts récents depuis le cache
    List<String>? recentTransfersJson = _prefs.getStringList('recentTransfers');
    if (recentTransfersJson != null) {
      _recentTransfers = recentTransfersJson
          .map((e) => Transfer.fromMap(Map.from(jsonDecode(e))))
          .toList();
    }

    // Charger tous les transferts depuis le cache
    List<String>? allTransfersJson = _prefs.getStringList('allTransfers');
    if (allTransfersJson != null) {
      _allTransfers = allTransfersJson
          .map((e) => Transfer.fromMap(Map.from(jsonDecode(e))))
          .toList();
    }

    notifyListeners();
  }

  Future<void> _fetchFromFirestore() async {
    // Obtenir le solde et les transferts depuis Firestore
    final DocumentSnapshot balanceDoc =
        await _firestore.collection('users').doc('current_user').get();
    _balance = balanceDoc.data()?['balance'] ?? 0.0;

    final QuerySnapshot transferDocs = await _firestore
        .collection('transfers')
        .orderBy('date', descending: true)
        .get();

    _allTransfers = transferDocs.docs
        .map((doc) => Transfer.fromMap(doc.data() as Map<String, dynamic>))
        .toList();

    // Obtenir les utilisateurs récemment transférés
    _recentTransfers = _allTransfers
        .map((t) => t.toUser)
        .toSet() // Supprimer les doublons
        .map((user) => _allTransfers.firstWhere((t) => t.toUser == user))
        .toList();

    // Mettre à jour le cache
    await _prefs.setDouble('balance', _balance);
    await _prefs.setStringList(
      'recentTransfers',
      _recentTransfers.map((t) => jsonEncode(t.toMap())).toList(),
    );
    await _prefs.setStringList(
      'allTransfers',
      _allTransfers.map((t) => jsonEncode(t.toMap())).toList(),
    );

    notifyListeners();
  }
}
