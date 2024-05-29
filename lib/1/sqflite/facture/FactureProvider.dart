import 'package:flutter/material.dart';
import 'DatabaseHelper.dart';

import 'models.dart';

// class FactureProvider with ChangeNotifier {
//   List<Map<String, dynamic>> _factures = [];
//   Facture? _facture;
//   List<Map<String, dynamic>> get factures => _factures;
//   Facture? get facture => _facture;
//
//   List<Map<String, dynamic>> _clients = [];
//   Client? _client;
//   List<Map<String, dynamic>> get clients => _clients;
//   Client? get client => _client;
//
//   Future<void> fetchFactures() async {
//     final db = await DatabaseHelper().database;
//     //final List<Map<String, dynamic>> maps = await db.query('factures');
//
//     // Jointure pour récupérer les informations des clients associés aux factures
//     final List<Map<String, dynamic>> maps = await db.rawQuery(
//       '''
//       SELECT
//       factures.*,
//         clients.nom AS clients_nom,
//         clients.telephone AS clients_telephone
//       FROM
//         factures
//       JOIN
//         clients ON factures.client_id = clients.id
//       WHERE
//         factures.client_id = ?
//     ''',
//     );
//
//     _clients = maps;
//
//     // Récupérer les informations de la facture spécifique
//     final List<Map<String, dynamic>> clientMaps = await db.query(
//       'factures',
//       //where: 'id = ?',
//     );
//     _factures = clientMaps;
//
//     notifyListeners();
//   }
//
//
//   Future<void> fetchClient(int clientId) async {
//     final db = await DatabaseHelper().database;
//
//     // Jointure pour récupérer les informations des clients associés aux factures
//     final List<Map<String, dynamic>> detailsMaps = await db.rawQuery('''
//       SELECT
//       factures.*,
//         clients.nom AS clients_nom,
//         clients.telephone AS clients_telephone
//       FROM
//         factures
//       JOIN
//         clients ON factures.client_id = clients.id
//       WHERE
//         factures.client_id = ?
//     ''', [clientId]);
//
//     _clients = detailsMaps;
//
//     // Récupérer les informations de la facture spécifique
//     final List<Map<String, dynamic>> clientMaps = await db.query(
//       'clients',
//       where: 'id = ?',
//       whereArgs: [clientId],
//     );
//
//     if (clientMaps.isNotEmpty) {
//       _client = Client.fromMap(clientMaps.first);
//     } else {
//       _client = null;
//     }
//
//     notifyListeners();
//   }
//
//   Future<void> addFacture(Facture facture) async {
//     final db = await DatabaseHelper().database;
//     await db.insert('factures', facture.toMap());
//     fetchFactures();
//   }
//
//   Future<void> updateFacture(Facture facture) async {
//     final db = await DatabaseHelper().database;
//     await db.update(
//       'factures',
//       facture.toMap(),
//       where: 'id = ?',
//       whereArgs: [facture.id],
//     );
//     fetchFactures();
//   }
//
//   Future<void> deleteFacture(int id) async {
//     final db = await DatabaseHelper().database;
//     await db.delete(
//       'factures',
//       where: 'id = ?',
//       whereArgs: [id],
//     );
//     fetchFactures();
//   }
// }

// class FactureProvider extends ChangeNotifier {
//   List<FactureAvecClient> _factures = [];
//
//   List<FactureAvecClient> get factures => _factures;
//
//   Future<void> obtenirFacturesAvecClients() async {
//     // Ouvrir la connexion à la base de données
//     final db = await DatabaseHelper().database;
//
//     // Requête SQL pour récupérer les factures avec les noms des clients
//     final List<Map<String, dynamic>> resultat = await db.rawQuery('''
//       SELECT factures.id, clients.nom, factures.date
//       FROM factures factures
//       JOIN clients clients ON factures.client_id = clients.id
//     ''');
//
//     // Convertir les résultats en objets FactureAvecClient
//     _factures = resultat
//         .map((map) => FactureAvecClient(
//               id: map['id'],
//               nomClient: map['nom'],
//               date: DateTime.parse(map['date']),
//             ))
//         .toList();
//     print(_factures);
//     // Notifier les écouteurs qu'une mise à jour a eu lieu
//     notifyListeners();
//   }
// }

class FactureProvider extends ChangeNotifier {
  List<FactureAvecClient> _factures = [];

  List<FactureAvecClient> get factures => _factures;

  Future<void> obtenirFacturesAvecClients() async {
    final db = await DatabaseHelper().database;

    final List<Map<String, dynamic>> resultat = await db.rawQuery('''
      SELECT
        f.id,
        c.nom AS nom_client,
        c.ID AS id_client,
        f.date,
        p.id AS produit_id,
        p.nom AS nom_produit,
        df.quantite,
        df.prix_unitaire
      FROM factures f
      JOIN clients c ON f.client_id = c.id
      JOIN details_facture df ON f.id = df.facture_id
      JOIN produits p ON df.produit_id = p.id
    ''');

    Map<int, FactureAvecClient> facturesMap = {};

    for (var row in resultat) {
      int factureId = row['id'];
      int idClient = row['id_client'];
      String? nomClient = row['nom_client'];
      DateTime date = DateTime.parse(row['date']);

      if (!facturesMap.containsKey(factureId)) {
        facturesMap[factureId] = FactureAvecClient(
          id: factureId,
          idClient: idClient,
          nomClient:
              nomClient ?? '', // Utilise une chaîne vide si nomClient est null
          date: date,
          produits: [],
        );
      }

      FactureAvecClient facture = facturesMap[factureId]!;
      facture.produits.add(
        ProduitFacture(
          produitId: row['produit_id'],
          nomProduit: row['nom_produit'] ??
              '', // Utilise une chaîne vide si nomProduit est null
          quantite: row['quantite'],
          prixUnitaire: row['prix_unitaire'],
        ),
      );
    }

    _factures = facturesMap.values.toList();
    notifyListeners();
  }
}
