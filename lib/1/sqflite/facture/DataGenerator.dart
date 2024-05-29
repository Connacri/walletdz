import 'dart:math';
import 'package:faker/faker.dart';
import 'DatabaseHelper.dart';

class DataGenerator {
  static Future<void> generateData() async {
    final db = await DatabaseHelper().database;

    // Supprimer les anciennes données
    try {
      await db.delete('Details_Facture');
      await db.delete('Factures');
      await db.delete('Produits');
      await db.delete('Clients');
      await db.delete('Fournisseurs');
    } catch (e) {
      print('Erreur lors de la suppression des données: $e');
    }

    // Insérer des fournisseurs
    for (int i = 0; i < 10; i++) {
      await db.insert('Fournisseurs', {
        'nom': faker.company.name(),
        'adresse': faker.address.streetAddress(),
        'telephone': faker.phoneNumber.de(),
        'email': faker.internet.email(),
        'cree_a': DateTime.now().toIso8601String(),
      });
    }

    // Insérer des clients
    for (int i = 0; i < 30; i++) {
      await db.insert('Clients', {
        'nom': faker.person.name(),
        'adresse': faker.address.streetAddress(),
        'telephone': faker.phoneNumber.de(),
        'email': faker.internet.email(),
        'cree_a': DateTime.now().toIso8601String(),
      });
    }

    // Insérer des produits
    for (int i = 0; i < 100; i++) {
      await db.insert('Produits', {
        'nom': faker.food.restaurant(),
        'description': faker.lorem.sentence(),
        'prix': Random().nextDouble() * 100,
        'quantite_en_stock': Random().nextInt(100),
        'fournisseur_id': Random().nextInt(10) + 1,
        'cree_a': DateTime.now().toIso8601String(),
      });
    }

    final List<Map<String, dynamic>> clients = await db.query('clients');

    // Récupérer la liste de tous les produits disponibles
    final List<Map<String, dynamic>> produits = await db.query('produits');

    for (int i = 0; i < 30; i++) {
      // Sélectionner un client aléatoire parmi la liste des clients disponibles
      final client = clients[Random().nextInt(clients.length)];
      int clientId = client['id'];
      double total = 0;

      // Créer une nouvelle facture
      int factureId = await db.insert('factures', {
        'client_id': clientId,
        'date': DateTime.now().toIso8601String(),
        'cree_a': DateTime.now().toIso8601String(),
      });

      // Générer un nombre aléatoire de produits à ajouter à la facture
      int nombreProduits = Random().nextInt(7 /*produits.length*/) + 1;

      // Sélectionner des produits aléatoires parmi la liste des produits disponibles
      final produitsAleatoires = List.from(produits)..shuffle();
      final produitsFacture = produitsAleatoires.sublist(0, nombreProduits);

      // Insérer chaque produit dans la table Details_Facture
      for (var produit in produitsFacture) {
        int produitId = produit['id'];
        int quantite = Random().nextInt(10) + 1;
        double prixUnitaire = produit['prix'];
        //  total += prixUnitaire * quantite;

        await db.insert('details_facture', {
          'facture_id': factureId,
          'produit_id': produitId,
          'quantite': quantite,
          'prix_unitaire': prixUnitaire,
        });
      }
    }
  }
}
