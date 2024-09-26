import 'dart:io';
import 'dart:isolate';
import 'dart:math';
import 'package:excel/excel.dart';
import 'package:faker/faker.dart';
import 'package:flutter/material.dart';
import 'package:objectbox/objectbox.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import '../../objectbox.g.dart';
import 'Entity.dart';
import 'dart:math' show Random;

class ObjectBox {
  late final Store store;
  late final Box<User> userBox;
  late final Box<Crud> crud;
  late final Box<Produit> produitBox;
  late final Box<Approvisionnement> approvisionnementBox;
  late final Box<Fournisseur> fournisseurBox;
  late final Box<Facture> factureBox;
  late final Box<LigneFacture> ligneFacture;
  late final Box<Client> clientBox;

  static final ObjectBox _singleton = ObjectBox._internal();

  factory ObjectBox() {
    return _singleton;
  }
  final random = Random();
  ObjectBox._internal();

  Future<void> init() async {
    final dir = await getApplicationDocumentsDirectory();
    if (!Store.isOpen('${dir.path}/objectbox')) {
      store = await openStore(directory: '${dir.path}/objectbox');
      userBox = Box<User>(store);
      crud = Box<Crud>(store);
      produitBox = Box<Produit>(store);
      approvisionnementBox = Box<Approvisionnement>(store);
      fournisseurBox = Box<Fournisseur>(store);
      factureBox = Box<Facture>(store);
      ligneFacture = Box<LigneFacture>(store);
      clientBox = Box<Client>(store);
    }
  }

  void close() {
    store.close();
  }

  void fillWithFakeData(int userCount, int clientCount, int fournisseurCount,
      int produitCount, int approvisionnementCount) {
    final faker = Faker();
    final random = Random();
    List<String> roles = [
      'admin',
      'public',
      'vendeur',
      'owner',
      'manager',
      'it'
    ];
    Set<String> qrSet = {}; // Utiliser un Set pour garantir l'unicité des QR

    // Créer des utilisateurs
    List<User> users = List.generate(userCount, (index) {
      roles.shuffle(random); // Mélanger les rôles
      return User(
        phone: faker.phoneNumber.de(),
        username: faker.person.name(),
        password: faker.internet.password(),
        email: faker.internet.email(),
        role: roles.first, // Assigner le premier rôle après mélange
      );
    });

    userBox.putMany(users);

    // Créer des fournisseurs
    List<Fournisseur> fournisseurs = List.generate(fournisseurCount, (index) {
      String uniqueQr;
      do {
        uniqueQr = faker.randomGenerator.integer(999999).toString();
      } while (qrSet.contains(uniqueQr)); // Vérifier l'unicité du QR
      qrSet.add(uniqueQr);

      return Fournisseur(
        nom: faker.company.name(),
        phone: faker.phoneNumber.us(),
        adresse: faker.address.streetAddress(),
        qr: uniqueQr, // QR unique
      )..crud.target = Crud(
          createdBy: 0,
          updatedBy: 0,
          deletedBy: 0,
          dateCreation: faker.date.dateTime(minYear: 2010, maxYear: 2024),
          derniereModification:
              faker.date.dateTime(minYear: 2000, maxYear: DateTime.now().year),
        );
    });

    fournisseurBox.putMany(fournisseurs);

    // Créer des produits
    List<Produit> produits = List.generate(produitCount, (index) {
      String uniqueQr;
      do {
        uniqueQr = faker.randomGenerator.integer(999999).toString();
      } while (qrSet.contains(uniqueQr)); // Vérifier l'unicité du QR
      qrSet.add(uniqueQr);

      return Produit(
        image: 'https://picsum.photos/200/300?random=$index',
        nom: faker.food.dish(),
        prixVente: faker.randomGenerator.decimal(min: 500, scale: 2),
        description: faker.lorem.sentence(),
        qr: uniqueQr, // QR unique
        minimStock: faker.randomGenerator.decimal(min: 1, scale: 2),
        alertPeremption: random.nextInt(5),
      )..crud.target = Crud(
          createdBy: 0,
          updatedBy: 0,
          deletedBy: 0,
          dateCreation: faker.date.dateTime(minYear: 2010, maxYear: 2024),
          derniereModification:
              faker.date.dateTime(minYear: 2000, maxYear: DateTime.now().year),
        );
    });

    produitBox.putMany(produits);

    // Créer des approvisionnements
    List<Approvisionnement> approvisionnements =
        List.generate(approvisionnementCount, (_) {
      final produit = produits[random.nextInt(produits.length)];
      final fournisseur = fournisseurs[random.nextInt(fournisseurs.length)];
      return Approvisionnement(
        quantite: faker.randomGenerator.decimal(min: 10, scale: 2),
        prixAchat: faker.randomGenerator.decimal(min: 100, scale: 2),
        datePeremption:
            faker.date.dateTimeBetween(DateTime.now(), DateTime(2025, 12, 31)),
      )
        ..crud.target = Crud(
          createdBy: 0,
          updatedBy: 0,
          deletedBy: 0,
          dateCreation: faker.date.dateTime(minYear: 2010, maxYear: 2024),
          derniereModification:
              faker.date.dateTime(minYear: 2000, maxYear: DateTime.now().year),
        )
        ..produit.target = produit
        ..fournisseur.target = fournisseur;
    });

    approvisionnementBox.putMany(approvisionnements);

    // Créer des clients
    List<Client> clients = List.generate(clientCount, (index) {
      String uniqueQr;
      do {
        uniqueQr = faker.randomGenerator.integer(999999).toString();
      } while (qrSet.contains(uniqueQr)); // Vérifier l'unicité du QR
      qrSet.add(uniqueQr);

      return Client(
        qr: uniqueQr, // QR unique
        nom: faker.person.name(),
        phone: faker.phoneNumber.us(),
        adresse: faker.address.streetAddress(),
        description: faker.lorem.sentence(),
      )..crud.target = Crud(
          createdBy: 0,
          updatedBy: 0,
          deletedBy: 0,
          dateCreation: faker.date.dateTime(minYear: 2010, maxYear: 2024),
          derniereModification:
              faker.date.dateTime(minYear: 2000, maxYear: DateTime.now().year),
        );
    });

    clientBox.putMany(clients);

    // Créer des factures et les associer aux clients
    for (var client in clients) {
      int numberOfFactures = faker.randomGenerator.integer(50);
      List<Facture> factures = List.generate(numberOfFactures, (_) {
        String uniqueQr;
        do {
          uniqueQr = faker.randomGenerator.integer(999999).toString();
        } while (qrSet.contains(uniqueQr)); // Vérifier l'unicité du QR
        qrSet.add(uniqueQr);

        Facture facture = Facture(
          qr: uniqueQr, // QR unique
          impayer: faker.randomGenerator.decimal(min: 0, scale: 2),
          date: faker.date.dateTime(minYear: 2010, maxYear: 2024),
        )..crud.target = Crud(
            createdBy: 0,
            updatedBy: 0,
            deletedBy: 0,
            dateCreation: faker.date.dateTime(minYear: 2010, maxYear: 2024),
            derniereModification: faker.date
                .dateTime(minYear: 2000, maxYear: DateTime.now().year),
          );

        // Créer des lignes de facture
        int numberOfLignes = faker.randomGenerator.integer(5, min: 1);
        for (int i = 0; i < numberOfLignes; i++) {
          final produit = produits[random.nextInt(produits.length)];
          final ligneFacture = LigneFacture(
            quantite: faker.randomGenerator.decimal(min: 1, scale: 10),
            prixUnitaire: produit.prixVente,
          );
          ligneFacture.produit.target = produit;
          ligneFacture.facture.target = facture;
          facture.lignesFacture.add(ligneFacture);
        }

        return facture;
      });

      client.factures.addAll(factures);
    }

    clientBox.putMany(clients);
  }

  Future<void> importProduitsDepuisExcel(
    String filePath,
    int userCount,
    int clientCount,
    int fournisseurCount,
  ) async {
    final faker = Faker();
    final random = Random();
    final file = File(filePath);
    final bytes = await file.readAsBytes();
    final excel = Excel.decodeBytes(bytes);
    final roles = ['admin', 'public', 'vendeur', 'owner', 'manager', 'it'];

    // Création des utilisateurs
    final users = List.generate(userCount, (_) {
      roles.shuffle(random);
      return User(
        phone: faker.phoneNumber.de(),
        username: faker.person.name(),
        password: faker.internet.password(),
        email: faker.internet.email(),
        role: roles.first,
      )..crud.target = Crud(
          createdBy: 0,
          updatedBy: 0,
          deletedBy: 0,
          dateCreation: DateTime.now(),
          derniereModification: DateTime.now(),
        );
    });
    await userBox.putMany(users);

    // Création des fournisseurs
    final fournisseurs = List.generate(fournisseurCount, (_) {
      final now = DateTime.now();
      return Fournisseur(
        nom: faker.company.name(),
        phone: faker.phoneNumber.us(),
        adresse: faker.address.streetAddress(),
        qr: faker.randomGenerator.integer(999999).toString(),
      )..crud.target = Crud(
          createdBy: 0,
          updatedBy: 0,
          deletedBy: 0,
          dateCreation: faker.date.dateTime(minYear: 2010, maxYear: now.year),
          derniereModification:
              faker.date.dateTime(minYear: 2000, maxYear: now.year),
        );
    });
    await fournisseurBox.putMany(fournisseurs);

    // Importation des produits depuis Excel
    for (var table in excel.tables.keys) {
      for (var row in excel.tables[table]!.rows.skip(1)) {
        final designation = row[1]?.value?.toString() ?? faker.food.dish();
        final prixAchat = double.tryParse(row[6]?.value?.toString() ?? '') ??
            faker.randomGenerator.decimal();
        final prixVente = prixAchat * 1.3;
        final stock = double.tryParse(row[5]?.value?.toString() ?? '') ??
            faker.randomGenerator.integer(100).toDouble();

        // Création d'un produit
        final produit = Produit(
          qr: row[10]?.value?.toString(),
          image:
              'https://picsum.photos/200/300?random=${faker.randomGenerator.integer(5000)}',
          nom: designation,
          description: row[1]?.value?.toString() ?? faker.lorem.sentence(),
          prixVente: prixVente,
          minimStock: faker.randomGenerator.decimal(min: 1, scale: 2),
          alertPeremption: Random().nextInt(1000),
        )..crud.target = Crud(
            createdBy: faker.randomGenerator.integer(1000),
            updatedBy: faker.randomGenerator.integer(1000),
            deletedBy: faker.randomGenerator.integer(1000),
            dateCreation: faker.date.dateTime(minYear: 2010, maxYear: 2024),
            derniereModification: faker.date
                .dateTime(minYear: 2000, maxYear: DateTime.now().year),
          );

        // Création des approvisionnements pour chaque produit
        final nombreApprovisionnements =
            faker.randomGenerator.integer(10, min: 1);
        for (int i = 0; i < nombreApprovisionnements; i++) {
          final fournisseur = fournisseurs[random.nextInt(fournisseurs.length)];

          final approvisionnement = Approvisionnement(
            quantite: faker.randomGenerator.integer(100).toDouble(),
            prixAchat: prixAchat,
            datePeremption: faker.date.dateTime(
                minYear: DateTime.now().year, maxYear: DateTime.now().year + 2),
          )
            ..produit.target = produit
            ..fournisseur.target = fournisseur
            ..crud.target = Crud(
              createdBy: faker.randomGenerator.integer(1000),
              updatedBy: faker.randomGenerator.integer(1000),
              deletedBy: faker.randomGenerator.integer(1000),
              dateCreation: DateTime.now(),
              derniereModification: DateTime.now(),
            );

          produit.approvisionnements.add(approvisionnement);
        }

        await produitBox.put(produit);
      }
    }

    // Création des clients et factures
    final clients = List.generate(clientCount, (_) {
      final client = Client(
        qr: faker.randomGenerator.integer(999999).toString(),
        nom: faker.person.name(),
        phone: faker.phoneNumber.us(),
        adresse: faker.address.streetAddress(),
        description: faker.lorem.sentence(),
      )..crud.target = Crud(
          createdBy: 0,
          updatedBy: 0,
          deletedBy: 0,
          dateCreation: faker.date.dateTime(minYear: 2010, maxYear: 2024),
          derniereModification:
              faker.date.dateTime(minYear: 2000, maxYear: DateTime.now().year),
        );

      // Création d'un nombre aléatoire de factures pour chaque client
      final nombreFactures = faker.randomGenerator.integer(50);
      client.factures
          .addAll(List.generate(nombreFactures, (_) => _createFacture(faker)));

      return client;
    });
    await clientBox.putMany(clients);

    // Création des factures sans clients
    final facturesSansClient = List.generate(
      faker.randomGenerator.integer(10, min: 1),
      (_) => _createFacture(faker),
    );
    await factureBox.putMany(facturesSansClient);
  }

  Facture _createFacture(Faker faker) {
    final facture = Facture(
      qr: faker.randomGenerator.integer(999999).toString(),
      impayer: faker.randomGenerator.decimal(min: 0, scale: 2),
      date: faker.date.dateTime(minYear: 2010, maxYear: 2024),
    )..crud.target = Crud(
        createdBy: 0,
        updatedBy: 0,
        deletedBy: 0,
        dateCreation: faker.date.dateTime(minYear: 2010, maxYear: 2024),
        derniereModification:
            faker.date.dateTime(minYear: 2000, maxYear: DateTime.now().year),
      );

    // Create invoice lines
    final numberOfLignes = faker.randomGenerator.integer(5, min: 1);
    for (int j = 0; j < numberOfLignes; j++) {
      final randomProductId =
          faker.randomGenerator.integer(produitBox.count()) + 1;
      final produit = produitBox.get(randomProductId);
      if (produit != null) {
        final ligneFacture = LigneFacture(
          quantite: faker.randomGenerator.decimal(min: 1, scale: 10),
          prixUnitaire: produit.prixVente,
        );
        ligneFacture.produit.target = produit;
        ligneFacture.facture.target = facture;
        facture.lignesFacture.add(ligneFacture);
      }
    }

    return facture;
  }

  // Future<void> importProduitsDepuisExcel(String filePath, int userCount,
  //     int clientCount, int fournisseurCount) async {
  //   final faker = Faker();
  //   final file = File(filePath);
  //   final bytes = file.readAsBytesSync();
  //   final excel = Excel.decodeBytes(bytes);
  //   List<String> roles = [
  //     'admin',
  //     'public',
  //     'vendeur',
  //     'owner',
  //     'manager',
  //     'it'
  //   ];
  //
  //   // Créer des fournisseurs
  //   List<User> users = List.generate(userCount, (index) {
  //     roles.shuffle(Random()); // Shuffle the roles list in place
  //     return User(
  //       phone: faker.phoneNumber.de(),
  //       username: faker.person.name(),
  //       password: faker.internet.password(),
  //       email: faker.internet.email(),
  //       role: roles.first, // Assign the first role in the shuffled list
  //     );
  //   });
  //
  //   userBox.putMany(users);
  //
  //   // Créer des fournisseurs
  //   List<Fournisseur> fournisseurs = List.generate(fournisseurCount, (index) {
  //     return Fournisseur(
  //       nom: faker.company.name(),
  //       phone: faker.phoneNumber.us(),
  //       adresse: faker.address.streetAddress(),
  //       qr: faker.randomGenerator.integer(999999).toString(),
  //       dateCreation: faker.date.dateTime(minYear: 2010, maxYear: 2024),
  //       derniereModification:
  //           faker.date.dateTime(minYear: 2000, maxYear: DateTime.now().year),
  //       createdBy: 0,
  //       updatedBy: 0,
  //       deletedBy: 0,
  //     );
  //   });
  //   fournisseurBox.putMany(fournisseurs);
  //
  //   for (var table in excel.tables.keys) {
  //     for (var row in excel.tables[table]!.rows.skip(1)) {
  //       // Lire les valeurs depuis le fichier Excel avec conversion explicite en String
  //       String designation = row[1]?.value.toString() ?? faker.food.dish();
  //       double prixAchat = double.tryParse(row[6]!.value.toString()) ??
  //           faker.randomGenerator.decimal();
  //       double prixVente = prixAchat * 1.3;
  //       double? stock = double.tryParse(row[5]!.value.toString()) != null ||
  //               double.tryParse(row[5]!.value.toString()) != 0
  //           ? double.tryParse(row[5]!.value.toString())
  //           : faker.randomGenerator.integer(100).toDouble();
  //       // Créer un objet produit
  //       final produit = Produit(
  //         qr: row[10]?.value.toString(),
  //         image:
  //             'https://picsum.photos/200/300?random=${faker.randomGenerator.integer(5000)}',
  //         nom: designation,
  //         description: row[1]?.value.toString() ?? faker.lorem.sentence(),
  //         origine: faker.address.country(),
  //         prixAchat: prixAchat,
  //         prixVente: prixVente,
  //         stock: stock!,
  //         createdBy: faker.randomGenerator.integer(1000),
  //         updatedBy: faker.randomGenerator.integer(1000),
  //         deletedBy: faker.randomGenerator.integer(1000),
  //         datePeremption: faker.date
  //             .dateTimeBetween(DateTime.now(), DateTime(2024, 12, 31)),
  //         dateCreation: faker.date.dateTime(minYear: 2010, maxYear: 2024),
  //         derniereModification:
  //             faker.date.dateTime(minYear: 2000, maxYear: DateTime.now().year),
  //         stockUpdate:
  //             faker.date.dateTime(minYear: 2000, maxYear: DateTime.now().year),
  //         stockinit: faker.randomGenerator.decimal(min: 200),
  //         minimStock: faker.randomGenerator.decimal(min: 1, scale: 2),
  //         alertPeremption: Random().nextInt(1000),
  //       );
  //       // Associer entre 1 et 10 fournisseurs aléatoires au produit
  //       int numberOfFournisseurs = faker.randomGenerator.integer(10, min: 1);
  //       for (int i = 0; i < numberOfFournisseurs; i++) {
  //         int randomIndex = faker.randomGenerator.integer(fournisseurs.length);
  //         produit.fournisseurs.add(fournisseurs[randomIndex]);
  //       }
  //
  //       // Sauvegarder le produit dans ObjectBox
  //       produitBox.put(produit);
  //     }
  //   }
  //
  //   // Créer des clients et les associer à des factures
  //   List<Client> clients = List.generate(clientCount, (index) {
  //     final client = Client(
  //       qr: faker.randomGenerator.integer(999999).toString(),
  //       nom: faker.person.name(),
  //       phone: faker.phoneNumber.us(),
  //       adresse: faker.address.streetAddress(),
  //       description: faker.lorem.sentence(),
  //       dateCreation: faker.date.dateTime(minYear: 2010, maxYear: 2024),
  //       derniereModification:
  //           faker.date.dateTime(minYear: 2000, maxYear: DateTime.now().year),
  //       createdBy: 0,
  //       updatedBy: 0,
  //       deletedBy: 0,
  //     );
  //
  //     // Créer un nombre aléatoire de factures pour chaque client
  //     final numberOfFactures = faker.randomGenerator.integer(50);
  //     for (int i = 0; i < numberOfFactures; i++) {
  //       final facture = Facture(
  //         qr: faker.randomGenerator.integer(999999).toString(),
  //         impayer: faker.randomGenerator.decimal(min: 0, scale: 2),
  //         date: faker.date.dateTime(minYear: 2010, maxYear: 2024),
  //         createdBy: 0,
  //         updatedBy: 0,
  //         deletedBy: 0,
  //       );
  //
  //       // Créer des lignes de facture
  //       final numberOfLignes = faker.randomGenerator.integer(5, min: 1);
  //       for (int j = 0; j < numberOfLignes; j++) {
  //         // Get a random product from the produitBox
  //         final randomProductId =
  //             faker.randomGenerator.integer(produitBox.count()) + 1;
  //         final produit = produitBox.get(randomProductId);
  //
  //         if (produit != null) {
  //           final ligneFacture = LigneFacture(
  //             quantite: faker.randomGenerator.decimal(min: 1, scale: 10),
  //             prixUnitaire: produit.prixVente,
  //           );
  //           ligneFacture.produit.target = produit;
  //           ligneFacture.facture.target = facture;
  //           facture.lignesFacture.add(ligneFacture);
  //         }
  //       }
  //
  //       client.factures.add(facture);
  //     }
  //
  //     return client;
  //   });
  //   clientBox.putMany(clients);
  //
  //   // Créer des factures sans clients
  //   final numberOfFacturesSansClient =
  //       faker.randomGenerator.integer(10, min: 1);
  //   List<Facture> facturesSansClient =
  //       List.generate(numberOfFacturesSansClient, (index) {
  //     final facture = Facture(
  //       qr: faker.randomGenerator.integer(999999).toString(),
  //       impayer: faker.randomGenerator.decimal(min: 0, scale: 2),
  //       date: faker.date.dateTime(minYear: 2010, maxYear: 2024),
  //       createdBy: 0,
  //       updatedBy: 0,
  //       deletedBy: 0,
  //     );
  //
  //     // Créer des lignes de facture
  //     final numberOfLignes = faker.randomGenerator.integer(5, min: 1);
  //     for (int j = 0; j < numberOfLignes; j++) {
  //       // Get a random product from the produitBox
  //       final randomProductId =
  //           faker.randomGenerator.integer(produitBox.count()) + 1;
  //       final produit = produitBox.get(randomProductId);
  //       final ligneFacture = LigneFacture(
  //         quantite: faker.randomGenerator.decimal(min: 1, scale: 10),
  //         prixUnitaire: produit!.prixVente,
  //       );
  //       ligneFacture.produit.target = produit;
  //       ligneFacture.facture.target = facture;
  //       facture.lignesFacture.add(ligneFacture);
  //     }
  //
  //     return facture;
  //   });
  //   factureBox.putMany(facturesSansClient);
  // }

  Future<void> deleteDatabase() async {
    final directory = await getApplicationDocumentsDirectory();
    print(directory);
    final path = join(directory.path, 'objectbox');
    print(path);
    final dir = Directory(path);
    print(dir);
    // if (await dir.exists()) {
    //   await dir.delete(recursive: true);
    // }
    produitBox.removeAll();
    fournisseurBox.removeAll();
    clientBox.removeAll();
    factureBox.removeAll();
    ligneFacture.removeAll();
    //await deleteDatabase();
    await init();
  }

  Future<void> cleanQrCodes() async {
    final produits = produitBox.getAll();

    for (var produit in produits) {
      if (produit.qr != null) {
        final trimmedQr = produit.qr!.trim();

        if (produit.qr != trimmedQr) {
          produit.qr = trimmedQr;
          produitBox.put(produit);
        }
      }
    }
  }
}
