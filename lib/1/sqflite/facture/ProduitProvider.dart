import 'package:flutter/material.dart';
import 'DatabaseHelper.dart';
import 'models.dart';

class ProduitProvider with ChangeNotifier {
  List<Produit> _produits = [];

  List<Produit> get produits => _produits;

  Future<void> fetchProduits() async {
    final db = await DatabaseHelper().database;
    final List<Map<String, dynamic>> maps = await db.query('Produits');

    _produits = List.generate(maps.length, (i) {
      return Produit.fromMap(maps[i]);
    });

    notifyListeners();
  }

  Future<void> addProduit(Produit produit) async {
    final db = await DatabaseHelper().database;
    await db.insert('Produits', produit.toMap());
    fetchProduits();
  }

  Future<void> updateProduit(Produit produit) async {
    final db = await DatabaseHelper().database;
    await db.update(
      'Produits',
      produit.toMap(),
      where: 'ID = ?',
      whereArgs: [produit.id],
    );
    fetchProduits();
  }

  Future<void> deleteProduit(int id) async {
    final db = await DatabaseHelper().database;
    await db.delete(
      'Produits',
      where: 'ID = ?',
      whereArgs: [id],
    );
    fetchProduits();
  }
}
