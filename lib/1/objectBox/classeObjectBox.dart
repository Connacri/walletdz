import 'dart:io';
import 'dart:math';
import 'package:faker/faker.dart';
import 'package:objectbox/objectbox.dart';
import 'package:path/path.dart';
import 'package:walletdz/objectbox.g.dart';
import 'package:path_provider/path_provider.dart';
import 'Entity.dart';

class ObjectBox {
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

  // void fillWithFakeData(int count) {
  //   final faker = Faker();
  //
  //   // Créer des fournisseurs
  //   List<Fournisseur> fournisseurs = List.generate(count, (index) {
  //     return Fournisseur(
  //       nom: faker.company.name(),
  //       phone: faker.phoneNumber.us(),
  //       adresse: faker.address.streetAddress(),
  //       qr: faker.randomGenerator.integer(999999).toString(),
  //     );
  //   });
  //   fournisseurBox.putMany(fournisseurs);
  //
  //   // Créer des produits et les associer à des fournisseurs
  //   List<Produit> produits = List.generate(count, (index) {
  //     Produit produit = Produit(
  //       image: 'https://picsum.photos/200/300?random=${index}',
  //       nom: faker.food.dish(),
  //       prixAchat: faker.randomGenerator.decimal(min: 10),
  //       prixVente: faker.randomGenerator.decimal(min: 50),
  //       stock: faker.randomGenerator.integer(100, min: 1),
  //       description: faker.lorem.sentence(),
  //       qr: faker.randomGenerator.integer(999999).toString(),
  //     );
  //
  //     // Associer un fournisseur aléatoire au produit
  //     int randomIndex = faker.randomGenerator.integer(fournisseurs.length);
  //     produit.fournisseurs.add(fournisseurs[randomIndex]);
  //
  //     return produit;
  //   });
  //   produitBox.putMany(produits);
  // }
  void fillWithFakeData(int count) {
    final faker = Faker();

    // Créer des fournisseurs
    List<Fournisseur> fournisseurs = List.generate(count, (index) {
      return Fournisseur(
        nom: faker.company.name(),
        phone: faker.phoneNumber.us(),
        adresse: faker.address.streetAddress(),
        qr: faker.randomGenerator.integer(999999).toString(),
      );
    });
    fournisseurBox.putMany(fournisseurs);

    // Créer des produits et les associer à des fournisseurs
    List<Produit> produits = List.generate(count, (index) {
      Produit produit = Produit(
        image: 'https://picsum.photos/200/300?random=${index}',
        nom: faker.food.dish(),
        prixAchat: faker.randomGenerator.decimal(min: 10),
        prixVente: faker.randomGenerator.decimal(min: 50),
        stock: faker.randomGenerator.integer(100, min: 1),
        description: faker.lorem.sentence(),
        qr: faker.randomGenerator.integer(999999).toString(),
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

  // Future<void> resetDatabase() async {
  //   produitBox.removeAll();
  //   fournisseurBox.removeAll();
  //   await deleteDatabase();
  //   await init();
  // }

  Future<void> deleteDatabase() async {
    // final directory = await getApplicationDocumentsDirectory();
    // final path = join(directory.path, 'objectbox');
    // final dir = Directory(path);
    // print(directory);
    // print(path);
    // print(dir);
    produitBox.removeAll();
    fournisseurBox.removeAll();
    await deleteDatabase();
    await init();
    // if (await dir.exists()) {
    //   await dir.delete(recursive: true);
    // }
  }
}
