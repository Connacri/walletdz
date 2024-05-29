import 'package:flutter/material.dart';
import 'DatabaseHelper.dart';
import 'models.dart';

class FournisseurProvider with ChangeNotifier {
  List<Fournisseur> _fournisseurs = [];

  List<Fournisseur> get fournisseurs => _fournisseurs;

  Future<void> fetchFournisseurs() async {
    final db = await DatabaseHelper().database;
    final List<Map<String, dynamic>> maps = await db.query('fournisseurs');

    _fournisseurs = List.generate(maps.length, (i) {
      return Fournisseur.fromMap(maps[i]);
    });
    print(_fournisseurs);
    notifyListeners();
  }

  Future<void> addFournisseur(Fournisseur fournisseur) async {
    final db = await DatabaseHelper().database;
    await db.insert('fournisseurs', fournisseur.toMap());
    fetchFournisseurs();
  }

  Future<void> updateFournisseur(Fournisseur fournisseur) async {
    final db = await DatabaseHelper().database;
    await db.update(
      'fournisseurs',
      fournisseur.toMap(),
      where: 'id = ?',
      whereArgs: [fournisseur.id],
    );
    fetchFournisseurs();
  }

  Future<void> deleteFournisseur(int id) async {
    final db = await DatabaseHelper().database;
    await db.delete(
      'fournisseurs',
      where: 'id = ?',
      whereArgs: [id],
    );
    fetchFournisseurs();
  }
}
