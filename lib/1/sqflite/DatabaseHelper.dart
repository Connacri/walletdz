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
      montant DECIMAL(10, 2),
      id_client INTEGER,
      FOREIGN KEY (id_client) REFERENCES client(id_client)
    )
  ''');

    await db.execute('''
    CREATE TABLE fournisseur_produit (
      id_fournisseur INTEGER,
      id_produit INTEGER,
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
    print(clientIds);

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

    // Insertion des produits
    for (int i = 0; i < 10000; i++) {
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
      await db.insert('produit', produit.toMap());

      // Insertion des liens produit-fournisseur
      FournisseurProduit fournisseurProduit = FournisseurProduit(
        idFournisseur: fournisseurId,
        idProduit: i + 1,
      );
      await db.insert('fournisseur_produit', fournisseurProduit.toMap());
    }

    // Insertion des factures
    for (int i = 0; i < 1000; i++) {
      int clientId = faker.randomGenerator.element(clientIds);
      int produitId = faker.randomGenerator.integer(10000, min: 1);
      Facture facture = Facture(
        numero: faker.guid.guid(),
        date: faker.date.dateTime(),
        montant: faker.randomGenerator.decimal(min: 101),
        idClient: clientId,
      );
      await db.insert('facture', facture.toMap());

      // Insertion des liens facture-produit
      FactureProduit factureProduit = FactureProduit(
        idFacture: i + 1,
        idProduit: produitId,
        prixVente: faker.randomGenerator.decimal(min: 101),
      );
      await db.insert('facture_produit', factureProduit.toMap());
    }
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

  Future<List<Facture>> getFactures() async {
    Database db = await database;
    final List<Map<String, dynamic>> factureMaps = await db.query('facture');
    final List<Map<String, dynamic>> factureProduitMaps =
        await db.query('facture_produit');

    List<Facture> factures = [];

    for (var factureMap in factureMaps) {
      Facture facture = Facture.fromMap(factureMap);

      // Récupérer les produits associés à cette facture
      List<Map<String, dynamic>> produitsAssocies = factureProduitMaps
          .where((element) => element['id_facture'] == facture.idFacture)
          .toList();

      for (var produitAssocie in produitsAssocies) {
        Produit produit = await getProduitById(produitAssocie['id_produit']);
        double prixVente = produitAssocie['prixVente'];

        // Créer une instance de FactureProduit pour représenter la relation entre la facture et le produit
        FactureProduit factureProduit = FactureProduit(
          idFacture: facture.idFacture!,
          idProduit: produit.idProduit!,
          prixVente: prixVente,
        );

        // Ajouter l'objet FactureProduit à la liste des produits de la facture
        facture.produits.add(factureProduit);
      }

      factures.add(facture);
    }

    return factures;
  }

  Future<List<Fournisseur>> getAllFournisseurs() async {
    Database db = await database;
    final List<Map<String, dynamic>> maps = await db.query('fournisseur');
    print(maps);

    return List.generate(maps.length, (i) {
      return Fournisseur.fromMap(maps[i]);
    });
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
