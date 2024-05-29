import 'package:flutter/widgets.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:faker/faker.dart';

import 'models.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  static Database? _database;

  factory DatabaseHelper() {
    return _instance;
  }

  DatabaseHelper._internal();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    String path = join(await getDatabasesPath(), 'stock.db');
    return await openDatabase(
      path,
      version: 1,
      onCreate: _onCreate,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    print('Creating tables');
    await db.execute('''
    CREATE TABLE categorie (
      id_categorie INTEGER PRIMARY KEY AUTOINCREMENT,
      name TEXT
    )
  '''); // doit etre creer la 1ere avant produit

    await db.execute('''
    CREATE TABLE client (
      id_client INTEGER PRIMARY KEY AUTOINCREMENT,
      nom TEXT,
      telephone TEXT
    )
  ''');

    await db.execute('''
    CREATE TABLE fournisseur (
      id_fournisseur INTEGER PRIMARY KEY,
      nom TEXT,
      contact TEXT
    )
  ''');

    await db.execute('''
    CREATE TABLE produit (
      id_produit INTEGER PRIMARY KEY,
      name TEXT,
      prixAchat REAL,
      prixVente REAL,
      derniereModification DATE,
      photo TEXT,
      id_categorie INTEGER,
      FOREIGN KEY (id_categorie) REFERENCES categorie(id_categorie)
    )
  ''');

    await db.execute('''
    CREATE TABLE facture (
      id_facture INTEGER PRIMARY KEY,
      numero TEXT,
      date DATE,
      id_client INTEGER,
      FOREIGN KEY (id_client) REFERENCES client(id_client)
    )
  ''');

    await db.execute('''
    CREATE TABLE fournisseur_produit (
      id_fournisseur INTEGER,
      id_produit INTEGER,
      quantity_produit INTEGER,
      FOREIGN KEY (id_fournisseur) REFERENCES fournisseur(id_fournisseur),
      FOREIGN KEY (id_produit) REFERENCES produit(id_produit),
      PRIMARY KEY (id_fournisseur, id_produit)
    )
  ''');

    await db.execute('''
    CREATE TABLE facture_produit (
      id_facture INTEGER,
      id_produit INTEGER,
      prixVente REAL,
      quantity INTEGER,
      PRIMARY KEY (id_facture, id_produit),
      FOREIGN KEY (id_facture) REFERENCES facture(id_facture),
      FOREIGN KEY (id_produit) REFERENCES produit(id_produit)
    )
  ''');

    print('Tables created successfully');
  }

  Future<void> fillWithFakeData() async {
    final faker = Faker();
    Database db = await database;

    // Insertion des catégories
    List<int> categoryIds = [];
    for (int i = 0; i < 10; i++) {
      Categorie categorie = Categorie(
        name: faker.food.cuisine(),
      );
      int categoryId = await db.insert('categorie', categorie.toMap());
      categoryIds.add(categoryId);
    }
    print('Fake categories inserted successfully');

    // Insertion des clients
    List<int> clientIds = [];
    for (int i = 0; i < 200; i++) {
      Client client = Client(
        nom: faker.person.name(),
        telephone: faker.phoneNumber.de().toString(),
      );
      int clientId = await db.insert('client', client.toMap());
      clientIds.add(clientId);
    }
    print('Fake clients inserted successfully');

    // Insertion des fournisseurs
    List<int> fournisseurIds = [];
    for (int i = 0; i < 20; i++) {
      Fournisseur fournisseur = Fournisseur(
        nom: faker.company.name(),
        contact: faker.person.name(),
      );
      int fournisseurId = await db.insert('fournisseur', fournisseur.toMap());
      fournisseurIds.add(fournisseurId);
    }
    print('Fake suppliers inserted successfully');

    // Insertion des produits
    List<int> produitIds = [];
    for (int i = 0; i < 100; i++) {
      int categoryId = faker.randomGenerator.element(categoryIds);
      int fournisseurId = faker.randomGenerator.element(fournisseurIds);
      Produit produit = Produit(
        name: faker.lorem.word(),
        prixAchat: faker.randomGenerator.decimal(min: 150, scale: 1),
        prixVente: faker.randomGenerator.decimal(min: 352, scale: 2),
        derniereModification: faker.date.dateTime(),
        photo: faker.image.image(),
        idCategorie: categoryId,
      );
      int produitId = await db.insert('produit', produit.toMap());
      produitIds.add(produitId);

      // Insertion des liens produit-fournisseur
      FournisseurProduit fournisseurProduit = FournisseurProduit(
        idFournisseur: fournisseurId,
        idProduit: produitId,
        quantity_produit: faker.randomGenerator.integer(66),
      );
      await db.insert('fournisseur_produit', fournisseurProduit.toMap());
    }
    print('Fake products inserted successfully');

    // Insertion des factures
    for (int i = 0; i < 100; i++) {
      int clientId = faker.randomGenerator.element(clientIds);
      int produitId = faker.randomGenerator.integer(10000, min: 1);
      Facture facture = Facture(
        numero: faker.guid.guid(),
        date: faker.date.dateTime(),
        idClient: clientId,
      );
      await db.insert('facture', facture.toMap());

      // Insertion des liens facture-produit
      FactureProduit factureProduit = FactureProduit(
        idFacture: i + 1,
        idProduit: produitId,
        prixVente: faker.randomGenerator.decimal(min: 101),
        quantity: faker.randomGenerator.integer(50),
      );
      await db.insert('facture_produit', factureProduit.toMap());
      print('Fake factureProduit inserted successfully');
    }
    print('Fake invoices inserted successfully');
  }

  Future<List<Produit>> getProduits() async {
    Database db = await database;
    final List<Map<String, dynamic>> maps = await db.query('produit');
    print(maps);
    return List.generate(maps.length, (i) {
      return Produit.fromMap(maps[i]);
    });
  }

  Future<List<Client>> getClients() async {
    Database db = await database;
    final List<Map<String, dynamic>> maps = await db.query('client');
    print(maps);

    return List.generate(maps.length, (i) {
      return Client.fromMap(maps[i]);
    });
  }

  Future<Produit> getProduitById(int idProduit) async {
    Database db = await database;
    List<Map<String, dynamic>> produits = await db.query(
      'produit',
      where: 'id_produit = ?',
      whereArgs: [idProduit],
    );

    if (produits.isNotEmpty) {
      return Produit.fromMap(produits.first);
    } else {
      throw Exception('Produit with id $idProduit not found');
    }
  }

  Future<List<Fournisseur>> getAllFournisseurs() async {
    Database db = await database;
    final List<Map<String, dynamic>> maps = await db.query('fournisseur');
    print(maps);

    return List.generate(maps.length, (i) {
      return Fournisseur.fromMap(maps[i]);
    });
  }

  Future<List<Facture>> getFactures() async {
    Database db = await database;

    // Requête SQL pour récupérer les factures avec leurs détails
    final String query = '''
    SELECT 
      f.id_facture, f.numero, f.date, f.id_client
    FROM facture f
  ''';

    final List<Map<String, dynamic>> results = await db.rawQuery(query);

    // Liste pour stocker les factures
    List<Facture> factures = [];

    // Parcourir les résultats de la requête
    for (var row in results) {
      // Créer une facture à partir des données récupérées
      Facture facture = Facture(
        idFacture: row['id_facture'],
        numero: row['numero'],
        date: DateTime.parse(row['date']),
        idClient: row['id_client'],
      );

      // Ajouter la facture à la liste
      factures.add(facture);
    }

    // Retourner la liste des factures
    return factures;
  }

  Future<List<FactureProduit>> getFactureProduit(int idFacture) async {
    Database db = await database;

    final List<Map<String, dynamic>> results = await db.query(
      'facture_produit',
      where: 'id_facture = ?',
      whereArgs: [idFacture],
    );

    // Convertir les résultats en liste d'objets FactureProduit
    List<FactureProduit> factureProduits = results.map((row) {
      return FactureProduit(
        idFacture: row['id_facture'],
        idProduit: row['id_produit'],
        prixVente: row['prixVente'],
        quantity: row['quantity'],
      );
    }).toList();

    // Retourner la liste des FactureProduit associés à la facture spécifiée
    return factureProduits;
  }

  Future<Map<Facture, List<Produit>>> getDetailsFacture(int idFacture) async {
    Database db = await database;

    // Récupérer les détails de la facture
    final List<Map<String, dynamic>> factureMaps = await db.query(
      'facture',
      where: 'id_facture = ?',
      whereArgs: [idFacture],
    );

    // Récupérer les produits associés à la facture
    final List<Map<String, dynamic>> produitMaps = await db.query(
      'facture_produit',
      where: 'id_facture = ?',
      whereArgs: [idFacture],
    );

    // Convertir les résultats en objets Facture et Produit
    Facture facture = Facture.fromMap(factureMaps.first);
    List<Produit> produits = [];

    for (var produitMap in produitMaps) {
      int idProduit = produitMap['id_produit'];
      Produit produit = await getProduitById(idProduit);
      produits.add(produit);
    }

    // Retourner une map contenant la facture et la liste des produits associés
    return {facture: produits};
  }

  Future<int> deleteProduit(int id) async {
    Database db = await database;
    return await db.delete(
      'produit',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<int> deleteClient(int id) async {
    Database db = await database;
    return await db.delete(
      'client',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<int> deleteFacture(int id) async {
    Database db = await database;
    return await db.delete(
      'facture',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<void> clearDatabase() async {
    Database db = await database;
    List<String> tables = [
      'categorie',
      'fournisseur',
      'produit',
      'client',
      'facture',
      'facture_produit',
      'fournisseur_produit'
    ];

    for (String table in tables) {
      await db.delete(table);
      await db.execute('DELETE FROM sqlite_sequence WHERE name="$table"');
    }

    String path = join(await getDatabasesPath(), 'stock.db');
    await databaseFactory.deleteDatabase(path);
    _database = null;
    print('Database deleted successfully');
    print('Database cleared and indexes reset successfully');
  }
}
