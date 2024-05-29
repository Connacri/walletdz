import 'package:flutter/cupertino.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  factory DatabaseHelper() => _instance;
  DatabaseHelper._internal();

  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    String path =
        join(await getDatabasesPath(), 'gestion_stock_facturation.db');
    return await openDatabase(
      path,
      version: 1,
      onCreate: _onCreate,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    await _createTables(db);
  }

  Future<void> _createTables(Database db) async {
    await db.execute('''
    CREATE TABLE fournisseurs (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      nom TEXT NOT NULL,
      adresse TEXT,
      telephone TEXT NOT NULL,
      email TEXT,
      cree_a TIMESTAMP DEFAULT CURRENT_TIMESTAMP
    )
  ''');

    await db.execute('''
    CREATE TABLE clients (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      nom TEXT NOT NULL,
      adresse TEXT,
      telephone TEXT,
      email TEXT,
      cree_a TIMESTAMP DEFAULT CURRENT_TIMESTAMP
    )
  ''');

    await db.execute('''
    CREATE TABLE produits (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      nom TEXT NOT NULL,
      description TEXT,
      prix REAL NOT NULL,
      quantite_en_stock INTEGER NOT NULL,
      fournisseur_id INTEGER,
      cree_a TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
      FOREIGN KEY (fournisseur_id) REFERENCES fournisseurs(id)
    )
  ''');

    await db.execute('''
    CREATE INDEX idx_fournisseur_id ON produits(fournisseur_id)
  ''');

    await db.execute('''
    CREATE TABLE factures (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      client_id INTEGER,
      date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
      FOREIGN KEY (client_id) REFERENCES clients(id)
    )
  ''');

    await db.execute('''
    CREATE INDEX idx_client_id ON factures(client_id)
  ''');

    await db.execute('''
    CREATE TABLE details_facture (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      facture_id INTEGER,
      produit_id INTEGER,
      quantite INTEGER NOT NULL,
      prix_unitaire REAL NOT NULL,
      FOREIGN KEY (facture_id) REFERENCES factures(id),
      FOREIGN KEY (produit_id) REFERENCES produits(id)
    )
  ''');

    await db.execute('''
    CREATE INDEX idx_facture_id ON details_facture(facture_id)
  ''');

    await db.execute('''
    CREATE INDEX idx_produit_id ON details_facture(produit_id)
  ''');
  }

  Future<void> deleteDatabaseFile() async {
    String path =
        join(await getDatabasesPath(), 'gestion_stock_facturation.db');
    await databaseFactory.deleteDatabase(path);
    print('Base de données supprimée avec succès');
    _database = null; // Réinitialiser l'instance de la base de données
  }
}
