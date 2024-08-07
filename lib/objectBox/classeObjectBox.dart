import 'dart:io';
import 'dart:isolate';
import 'dart:math';
import 'package:faker/faker.dart';
import 'package:flutter/material.dart';
import 'package:objectbox/objectbox.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import '../../objectbox.g.dart';
import 'Entity.dart';

class ObjectBox {
  late final Store store;
  late final Box<Produit> produitBox;
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
      produitBox = Box<Produit>(store);
      fournisseurBox = Box<Fournisseur>(store);
      factureBox = Box<Facture>(store);
      ligneFacture = Box<LigneFacture>(store);
      clientBox = Box<Client>(store);
    }
  }

  void close() {
    store.close();
  }

  // void fillWithFakeData(int count, int fourInt) {
  //   final faker = Faker();
  //
  //   // Créer des fournisseurs
  //   List<Fournisseur> fournisseurs = List.generate(fourInt, (index) {
  //     return Fournisseur(
  //       nom: faker.company.name(),
  //       phone: faker.phoneNumber.us(),
  //       adresse: faker.address.streetAddress(),
  //       qr: faker.randomGenerator.integer(999999).toString(),
  //       dateCreation: faker.date.dateTime(minYear: 2010, maxYear: 2024),
  //       derniereModification:
  //           faker.date.dateTime(minYear: 2000, maxYear: DateTime.now().year),
  //     );
  //   });
  //   fournisseurBox.putMany(fournisseurs);
  //
  //   // Créer des produits et les associer à des fournisseurs
  //   List<Produit> produits = List.generate(count, (indx) {
  //     Produit produit = Produit(
  //       image: 'https://picsum.photos/200/300?random=${indx}',
  //       nom: faker.food.dish(),
  //       prixAchat: faker.randomGenerator.decimal(min: 60, scale: 20),
  //       prixVente: faker.randomGenerator.decimal(min: 500, scale: 50),
  //       stock: faker.randomGenerator.decimal(min: 100, scale: 15),
  //       description: faker.lorem.sentence(),
  //       qr: (indx + 1)
  //           .toString(), // faker.randomGenerator.integer(count).toString(),
  //       datePeremption: faker.date.dateTimeBetween(DateTime.now(),
  //           DateTime(2024, 31, 8)), //.dateTime(minYear: 2025, maxYear: 2030),
  //       dateCreation: faker.date.dateTime(minYear: 2010, maxYear: 2024),
  //       derniereModification:
  //           faker.date.dateTime(minYear: 2000, maxYear: DateTime.now().year),
  //       stockUpdate:
  //           faker.date.dateTime(minYear: 2000, maxYear: DateTime.now().year),
  //       stockinit: faker.randomGenerator.decimal(min: 200),
  //       minimStock: faker.randomGenerator.decimal(min: 1, scale: 2),
  //     );
  //
  //     // Associer entre 1 et 10 fournisseurs aléatoires au produit
  //     int numberOfFournisseurs = faker.randomGenerator.integer(10, min: 1);
  //     for (int i = 0; i < numberOfFournisseurs; i++) {
  //       int randomIndex = faker.randomGenerator.integer(fournisseurs.length);
  //       produit.fournisseurs.add(fournisseurs[randomIndex]);
  //     }
  //
  //     return produit;
  //   });
  //   produitBox.putMany(produits);
  // }

  void fillWithFakeData(
      int clientCount, int fournisseurCount, int produitCount) {
    final faker = Faker();

    // Créer des fournisseurs
    List<Fournisseur> fournisseurs = List.generate(fournisseurCount, (index) {
      return Fournisseur(
        nom: faker.company.name(),
        phone: faker.phoneNumber.us(),
        adresse: faker.address.streetAddress(),
        qr: faker.randomGenerator.integer(999999).toString(),
        dateCreation: faker.date.dateTime(minYear: 2010, maxYear: 2024),
        derniereModification:
            faker.date.dateTime(minYear: 2000, maxYear: DateTime.now().year),
      );
    });
    fournisseurBox.putMany(fournisseurs);

    // Créer des produits et les associer à des fournisseurs
    List<Produit> produits = List.generate(produitCount, (indx) {
      Produit produit = Produit(
        image: 'https://picsum.photos/200/300?random=${indx}',
        nom: faker.food.dish(),
        prixAchat: faker.randomGenerator.decimal(min: 60, scale: 2),
        prixVente: faker.randomGenerator.decimal(min: 500, scale: 2),
        stock: faker.randomGenerator.decimal(min: 100, scale: 2),
        description: faker.lorem.sentence(),
        qr: (indx + 1).toString(),
        datePeremption:
            faker.date.dateTimeBetween(DateTime.now(), DateTime(2024, 12, 31)),
        dateCreation: faker.date.dateTime(minYear: 2010, maxYear: 2024),
        derniereModification:
            faker.date.dateTime(minYear: 2000, maxYear: DateTime.now().year),
        stockUpdate:
            faker.date.dateTime(minYear: 2000, maxYear: DateTime.now().year),
        stockinit: faker.randomGenerator.decimal(min: 200),
        minimStock: faker.randomGenerator.decimal(min: 1, scale: 2),
      );

      // Associer entre 1 et 10 fournisseurs aléatoires au produit
      int numberOfFournisseurs = faker.randomGenerator.integer(10, min: 1);
      for (int i = 0; i < numberOfFournisseurs; i++) {
        int randomIndex = faker.randomGenerator.integer(fournisseurs.length);
        produit.fournisseurs.add(fournisseurs[randomIndex]);
      }

      return produit;
    });
    produitBox.putMany(produits);

    // Créer des clients et les associer à des factures
    List<Client> clients = List.generate(clientCount, (index) {
      final client = Client(
        qr: faker.randomGenerator.integer(999999).toString(),
        nom: faker.person.name(),
        phone: faker.phoneNumber.us(),
        adresse: faker.address.streetAddress(),
        description: faker.lorem.sentence(),
        impayer: faker.randomGenerator.decimal(min: 0, scale: 2),
        dateCreation: faker.date.dateTime(minYear: 2010, maxYear: 2024),
        derniereModification:
            faker.date.dateTime(minYear: 2000, maxYear: DateTime.now().year),
      );

      // Créer un nombre aléatoire de factures pour chaque client
      final numberOfFactures = faker.randomGenerator.integer(50);
      for (int i = 0; i < numberOfFactures; i++) {
        final facture = Facture(
          qr: faker.randomGenerator.integer(999999).toString(),
          date: faker.date.dateTime(minYear: 2010, maxYear: 2024),
        );

        // Créer des lignes de facture
        final numberOfLignes = faker.randomGenerator.integer(5, min: 1);
        for (int j = 0; j < numberOfLignes; j++) {
          final produit =
              produits[faker.randomGenerator.integer(produits.length)];
          final ligneFacture = LigneFacture(
            quantite: faker.randomGenerator.integer(10, min: 1),
            prixUnitaire: produit.prixVente,
          );
          ligneFacture.produit.target = produit;
          ligneFacture.facture.target = facture;
          facture.lignesFacture.add(ligneFacture);
        }

        client.factures.add(facture);
      }

      return client;
    });
    clientBox.putMany(clients);

    // Créer des factures sans clients
    final numberOfFacturesSansClient =
        faker.randomGenerator.integer(10, min: 1);
    List<Facture> facturesSansClient =
        List.generate(numberOfFacturesSansClient, (index) {
      final facture = Facture(
        qr: faker.randomGenerator.integer(999999).toString(),
        date: faker.date.dateTime(minYear: 2010, maxYear: 2024),
      );

      // Créer des lignes de facture
      final numberOfLignes = faker.randomGenerator.integer(5, min: 1);
      for (int j = 0; j < numberOfLignes; j++) {
        final produit =
            produits[faker.randomGenerator.integer(produits.length)];
        final ligneFacture = LigneFacture(
          quantite: faker.randomGenerator.integer(10, min: 1),
          prixUnitaire: produit.prixVente,
        );
        ligneFacture.produit.target = produit;
        ligneFacture.facture.target = facture;
        facture.lignesFacture.add(ligneFacture);
      }

      return facture;
    });
    factureBox.putMany(facturesSansClient);
  }

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
    // await deleteDatabase();
    await init();
  }
}
