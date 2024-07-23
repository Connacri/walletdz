import 'dart:io';
import 'dart:isolate';
import 'dart:math';
import 'package:faker/faker.dart';
import 'package:objectbox/objectbox.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import '../../objectbox.g.dart';
import 'Entity.dart';

class ObjectBox {
  // late final Store store;
  // late final Box<Produit> produitBox;
  // late final Box<Fournisseur> fournisseurBox;
  //
  // static final ObjectBox _singleton = ObjectBox._internal();
  //
  // factory ObjectBox() {
  //   return _singleton;
  // }
  // final random = Random();
  // ObjectBox._internal();
  //
  // Future<void> init() async {
  //   final dir = await getApplicationDocumentsDirectory();
  //   if (!Store.isOpen('${dir.path}/objectbox')) {
  //     store = await openStore(directory: '${dir.path}/objectbox');
  //     produitBox = Box<Produit>(store);
  //     fournisseurBox = Box<Fournisseur>(store);
  //   }
  // }
  //
  // void close() {
  //   store.close();
  // }
  late final Store store;
  late final Box<Produit> produitBox;
  late final Box<Fournisseur> fournisseurBox;

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
    }
  }

  void close() {
    store.close();
  }

  void fillWithFakeData(/*int count, int fourInt*/) {
    final faker = Faker();
    int count = 20;
    int fourInt = 5;
    // Créer des fournisseurs
    List<Fournisseur> fournisseurs = List.generate(fourInt, (index) {
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
    List<Produit> produits = List.generate(count, (indx) {
      Produit produit = Produit(
        image: 'https://picsum.photos/200/300?random=${indx}',
        nom: faker.food.dish(),
        prixAchat: faker.randomGenerator.decimal(min: 60, scale: 20),
        prixVente: faker.randomGenerator.decimal(min: 500, scale: 50),
        stock: faker.randomGenerator.integer(100, min: 1),
        description: faker.lorem.sentence(),
        qr: (indx + 1)
            .toString(), // faker.randomGenerator.integer(count).toString(),
        datePeremption: faker.date.dateTimeBetween(DateTime.now(),
            DateTime(2024, 31, 8)), //.dateTime(minYear: 2025, maxYear: 2030),
        dateCreation: faker.date.dateTime(minYear: 2010, maxYear: 2024),
        derniereModification:
            faker.date.dateTime(minYear: 2000, maxYear: DateTime.now().year),
        stockinit: faker.randomGenerator.integer(100, min: 1),
        stockUpdate:
            faker.date.dateTime(minYear: 2000, maxYear: DateTime.now().year),
        minimStock: faker.randomGenerator.integer(5, min: 1),
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
