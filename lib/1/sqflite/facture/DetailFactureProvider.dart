import 'package:flutter/material.dart';
import 'DatabaseHelper.dart';
import 'models.dart';

class DetailFactureProvider with ChangeNotifier {
  //List<DetailFacture> _detailsFacture = [];
  List<Map<String, dynamic>> _detailsFacture = [];
  Facture? _facture;
  double _totalFacture = 0;

  // List<DetailFacture> get detailsFacture => _detailsFacture;
  List<Map<String, dynamic>> get detailsFacture => _detailsFacture;
  Facture? get facture => _facture;
  double get totalFacture => _totalFacture;

  Future<void> fetchDetailsFacture(int factureId) async {
    final db = await DatabaseHelper().database;

    // Jointure pour récupérer les informations des produits
    final List<Map<String, dynamic>> detailsMaps = await db.rawQuery('''
      SELECT 
        details_facture.*, 
        produits.nom AS produit_nom, 
        produits.description AS produit_description, 
        produits.prix
      FROM 
        details_facture
      JOIN 
        produits ON details_facture.produit_id = produits.id
      WHERE 
        details_facture.facture_id = ?
    ''', [factureId]);

    _detailsFacture = detailsMaps;

    // Calculer le total de la facture
    _totalFacture = _detailsFacture.fold(
      0,
      (previousValue, detailFacture) =>
          previousValue + (detailFacture['prix'] * detailFacture['quantite']),
    );
    // Récupérer les informations de la facture
    final List<Map<String, dynamic>> factureMaps = await db.query(
      'factures',
      where: 'id = ?',
      whereArgs: [factureId],
    );

    if (factureMaps.isNotEmpty) {
      _facture = Facture.fromMap(factureMaps.first);
    } else {
      _facture = null;
    }

    notifyListeners();
  }

  Future<void> addDetailFacture(DetailFacture detailFacture) async {
    final db = await DatabaseHelper().database;
    await db.insert('details_facture', detailFacture.toMap());
    fetchDetailsFacture(detailFacture.factureId);
  }

  Future<void> updateDetailFacture(DetailFacture detailFacture) async {
    final db = await DatabaseHelper().database;
    await db.update(
      'details_facture',
      detailFacture.toMap(),
      where: 'id = ?',
      whereArgs: [detailFacture.id],
    );
    fetchDetailsFacture(detailFacture.factureId);
  }

  Future<void> deleteDetailFacture(int id, int factureId) async {
    final db = await DatabaseHelper().database;
    await db.delete(
      'details_facture',
      where: 'id = ?',
      whereArgs: [id],
    );
    fetchDetailsFacture(factureId);
  }
}
