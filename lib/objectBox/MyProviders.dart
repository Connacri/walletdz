import 'dart:math';
import 'package:flutter/material.dart';
import 'package:faker/faker.dart';
import '../objectBox/pages/ProduitListSupabase.dart';
import '../../objectbox.g.dart';
import 'Entity.dart';
import 'classeObjectBox.dart';
import 'package:objectbox/objectbox.dart';

class CommerceProvider extends ChangeNotifier {
  final ObjectBox _objectBox;
  // List<Produit> _produits = [];
  List<Produit> _produitsP = [];
  List<Fournisseur> _fournisseurs = [];
  int _currentPage = 0;
  final int _pageSize = 100;
  bool _hasMoreProduits = true;
  bool _isLoading = false;

  // List<Produit> get produits => _produits;
  List<Produit> get produitsP => _produitsP;
  bool get hasMoreProduits => _hasMoreProduits;
  List<Fournisseur> get fournisseurs => _fournisseurs;
  bool get isLoading => _isLoading;

  CommerceProvider(this._objectBox) {
    chargerProduits();
    _chargerFournisseurs();
  }

  Future<void> chargerProduits({bool reset = false}) async {
    if (_isLoading) return; // Empêche les appels multiples simultanés
    _isLoading = true;
    notifyListeners();
    if (reset) {
      _currentPage = 0;
      produitsP.clear();
    }

    final query = _objectBox.produitBox.query()
      ..order(Produit_.id, flags: Order.descending);

    final allProduits = await query.build().find();

    final startIndex = _currentPage * _pageSize;
    final endIndex = startIndex + _pageSize;

    if (startIndex >= allProduits.length) {
      _hasMoreProduits = false;
    } else {
      final newProduits = allProduits.sublist(
        startIndex,
        endIndex > allProduits.length ? allProduits.length : endIndex,
      );

      _produitsP.addAll(newProduits);
      _currentPage++;
      _hasMoreProduits = endIndex < allProduits.length;
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<List<Produit>> rechercherProduits(String query,
      {int limit = 20}) async {
    final queryLower = query.toLowerCase();
    final idQuery = int.tryParse(query);
    final qBuilder = _objectBox.produitBox.query(idQuery != null
        ? Produit_.id.equals(idQuery) |
            Produit_.nom.contains(queryLower, caseSensitive: false)
        : Produit_.nom.contains(queryLower, caseSensitive: false));
    return qBuilder.build().find();
  }

  void resetProduits() {
    _produitsP.clear();
    _currentPage = 0;
    _hasMoreProduits = true;

    chargerProduits(reset: true);
  }

  void _chargerFournisseurs() {
    _fournisseurs = _objectBox.fournisseurBox.getAll().reversed.toList();
    notifyListeners();
  }

  // Méthodes pour les produits
  Produit? getProduitById(int id) {
    return _objectBox.produitBox.get(id);
  }

  Future<Produit?> getProduitByQr(String qrCode) async {
    final query = _objectBox.produitBox.query(Produit_.qr.equals(qrCode));
    final produits = await query.build().find();

    if (produits.isNotEmpty) {
      return produits.first;
    } else {
      return null;
    }
  }

  List<Produit> getProduitsForFournisseur(Fournisseur fournisseur) {
    // Récupérer les données directement depuis la base de données
    return _objectBox.fournisseurBox
            .get(fournisseur.id)
            ?.produits
            .reversed
            .toList() ??
        [];
  }

  void ajouterProduit(Produit produit, List<Fournisseur> fournisseurs) {
    _ajouterOuMettreAJourFournisseurs(fournisseurs);
    produit.fournisseurs.addAll(fournisseurs);
    _objectBox.produitBox.put(produit);
    chargerProduits(reset: true);
    _chargerFournisseurs();
  }

  void updateProduit(Produit produit) {
    _objectBox.produitBox.put(produit);
    chargerProduits(reset: true);
  }

  void updateProductStock(int productId, double newStock) {
    final index = _produitsP.indexWhere((p) => p.id == productId);
    if (index != -1) {
      _produitsP[index].stock = newStock;
      _objectBox.produitBox.put(_produitsP[index]);
      notifyListeners();
    }
  }

  void updateProduitById(int id, Produit updatedProduit,
      {List<Fournisseur>? fournisseurs}) {
    final produit = getProduitById(id);
    if (produit != null) {
      produit
        ..nom = updatedProduit.nom
        ..description = updatedProduit.description
        ..prixAchat = updatedProduit.prixAchat
        ..prixVente = updatedProduit.prixVente
        ..stock = updatedProduit.stock
        ..qr = updatedProduit.qr
        ..image = updatedProduit.image
        ..minimStock = updatedProduit.minimStock
        // ..dateCreation = updatedProduit.dateCreation
        ..datePeremption = updatedProduit.datePeremption
        ..stockUpdate = updatedProduit.stockUpdate
        ..derniereModification = updatedProduit.derniereModification
        ..stockinit = updatedProduit.stockinit;

      if (fournisseurs != null) {
        _ajouterOuMettreAJourFournisseurs(fournisseurs);
        produit.fournisseurs.clear();
        produit.fournisseurs.addAll(fournisseurs);
      }

      _objectBox.produitBox.put(produit);
      chargerProduits(reset: true);
      _chargerFournisseurs();
      notifyListeners();
    }
  }

  void supprimerProduit(Produit produit) {
    _objectBox.produitBox.remove(produit.id);
    chargerProduits(reset: true);
    _chargerFournisseurs();
  }

  int getTotalProduits() {
    return _objectBox.produitBox.count();
  }

  List<Produit> getProduitsBetweenPrices(double minPrice, double maxPrice) {
    final query = _objectBox.produitBox
        .query(Produit_.prixVente.between(minPrice, maxPrice));
    return query.build().find();
  }

  Map<String, dynamic> getProduitsLowStock(qtt) {
    final query = _objectBox.produitBox.query(Produit_.stock.lessOrEqual(qtt));
    final lowStockProduits = query.build().find();

    return //lowStockProduits.length;
        {
      'count': lowStockProduits.length,
      'produits': lowStockProduits,
    };
  }

//////////////////////////////////// Fournisseur ///////////////////////////////////////////

  void addFournisseur(Fournisseur fournisseur) {
    _objectBox.fournisseurBox.put(fournisseur);
    chargerProduits(reset: true);
    _chargerFournisseurs();
    notifyListeners();
  }

  void updateFournisseur(int id, Fournisseur updatedFournisseur) {
    var fournisseurIndex = _fournisseurs.indexWhere((f) => f.id == id);
    if (fournisseurIndex != -1) {
      updatedFournisseur.id = id;
      _objectBox.fournisseurBox.put(updatedFournisseur);
      _fournisseurs[fournisseurIndex] = updatedFournisseur;
      chargerProduits(reset: true);
      _chargerFournisseurs();
      notifyListeners();
    }
  }

  void supprimerFournisseur(Fournisseur fournisseur) {
    _objectBox.fournisseurBox.remove(fournisseur.id);
    chargerProduits(reset: true);
    _chargerFournisseurs();
    notifyListeners();
  }

  void ajouterFournisseurAvecProduits(
      Fournisseur fournisseur, List<Produit> produits) {
    _ajouterOuMettreAJourProduits(produits);
    fournisseur.produits.addAll(produits);
    _objectBox.fournisseurBox.put(fournisseur);
    chargerProduits(reset: true);
    _chargerFournisseurs();
    notifyListeners();
  }

  void ajouterProduitsAleatoiresPourFournisseur(
      Fournisseur fournisseur, int nombreProduits) {
    final faker = Faker();

    List<Produit> produits = List.generate(nombreProduits, (index) {
      return Produit(
        id: 0,
        image: 'https://picsum.photos/200/300?random=${Random().nextInt(1000)}',
        nom: faker.food.dish(),
        prixAchat: faker.randomGenerator.decimal(min: 10),
        prixVente: faker.randomGenerator.decimal(min: 50),
        stock: faker.randomGenerator.decimal(min: 100, scale: 15),
        description: faker.lorem.sentence(),
        qr: faker.randomGenerator.integer(999999).toString(),
        datePeremption:
            faker.date.dateTime(minYear: 2010, maxYear: DateTime.now().year),
        dateCreation: faker.date.dateTime(minYear: 2010, maxYear: 2024),
        derniereModification:
            faker.date.dateTime(minYear: 2000, maxYear: DateTime.now().year),
        stockUpdate:
            faker.date.dateTime(minYear: 2000, maxYear: DateTime.now().year),
        stockinit: faker.randomGenerator.decimal(min: 200),
        minimStock: faker.randomGenerator.decimal(min: 1, scale: 2),
      );
    });

    fournisseur.produits.addAll(produits);
    _objectBox.fournisseurBox.put(fournisseur);

    notifyListeners();
  }

  // Méthodes utilitaires privées
  void _ajouterOuMettreAJourFournisseurs(List<Fournisseur> fournisseurs) {
    for (var fournisseur in fournisseurs) {
      _objectBox.fournisseurBox.put(fournisseur);
    }
  }

  void _ajouterOuMettreAJourProduits(List<Produit> produits) {
    for (var produit in produits) {
      _objectBox.produitBox.put(produit);
    }
  }

  void ajouterProduitsExistantsAuFournisseur(
      Fournisseur fournisseur, List<Produit> produits) {
    for (var produit in produits) {
      if (!fournisseur.produits.contains(produit)) {
        fournisseur.produits.add(produit);
        produit.fournisseurs.add(fournisseur);
      }
    }
    _objectBox.fournisseurBox.put(fournisseur);
    _objectBox.produitBox.putMany(produits);
    chargerProduits(reset: true);
    _chargerFournisseurs();
    notifyListeners();
  }

  void supprimerProduitDuFournisseur(Fournisseur fournisseur, Produit produit) {
    // print('Tentative de suppression du produit du fournisseur');
    // print('Fournisseur: ${fournisseur.nom}, Produit: ${produit.nom}');

    try {
      // Charger les instances actuelles de la base de données
      Fournisseur? fournisseurActuel =
          _objectBox.fournisseurBox.get(fournisseur.id);
      Produit? produitActuel = _objectBox.produitBox.get(produit.id);

      if (fournisseurActuel == null) {
        //  print('Fournisseur non trouvé dans la base de données.');
        return;
      }
      if (produitActuel == null) {
        // print('Produit non trouvé dans la base de données.');
        return;
      }

      _objectBox.store.runInTransaction(TxMode.write, () {
        // Vérifier si le produit est dans la liste des produits du fournisseur et vice versa
        bool produitDansFournisseur =
            fournisseurActuel.produits.any((p) => p.id == produitActuel.id);
        bool fournisseurDansProduit =
            produitActuel.fournisseurs.any((f) => f.id == fournisseurActuel.id);

        if (produitDansFournisseur && fournisseurDansProduit) {
          // print(
          //     'Produit trouvé dans le fournisseur et fournisseur trouvé dans le produit.');

          // Supprimer les relations
          fournisseurActuel.produits
              .removeWhere((p) => p.id == produitActuel.id);
          produitActuel.fournisseurs
              .removeWhere((f) => f.id == fournisseurActuel.id);
          // print(fournisseurActuel.produits);
          // print(produitActuel.fournisseurs);

          //  print('Relations supprimées. Mise à jour des objets.');

          // Mise à jour dans la base de données
          _objectBox.fournisseurBox.put(fournisseurActuel);
          // print('Fournisseur mis à jour dans la base de données.');
        } else {
          // print(
          //     'Le produit n\'est pas dans la liste du fournisseur ou le fournisseur n\'est pas dans la liste du produit.');
        }
      });

      // Rechargement des données en dehors de la transaction
      //  print('Rechargement des produits et des fournisseurs.');
      chargerProduits(reset: true);
      _chargerFournisseurs();
      notifyListeners();
      //  print('Notifications envoyées aux auditeurs.');
    } catch (e) {
      print('Erreur lors de la suppression du produit du fournisseur : $e');
    }
  }

  void supprimerFournisseurDuProduit(Produit produit, Fournisseur fournisseur) {
    try {
      // Charger les instances actuelles de la base de données
      Produit? produitActuel = _objectBox.produitBox.get(produit.id);
      Fournisseur? fournisseurActuel =
          _objectBox.fournisseurBox.get(fournisseur.id);

      if (produitActuel == null) {
        //  print('Fournisseur non trouvé dans la base de données.');
        return;
      }
      if (fournisseurActuel == null) {
        // print('Produit non trouvé dans la base de données.');
        return;
      }

      _objectBox.store.runInTransaction(TxMode.write, () {
        // Vérifier si le produit est dans la liste des produits du fournisseur et vice versa
        bool produitDansFournisseur =
            fournisseurActuel.produits.any((p) => p.id == produitActuel.id);
        bool fournisseurDansProduit =
            produitActuel.fournisseurs.any((f) => f.id == fournisseurActuel.id);

        if (produitDansFournisseur && fournisseurDansProduit) {
          // print(
          //     'Produit trouvé dans le fournisseur et fournisseur trouvé dans le produit.');

          // Supprimer les relations
          fournisseurActuel.produits
              .removeWhere((p) => p.id == produitActuel.id);
          produitActuel.fournisseurs
              .removeWhere((f) => f.id == fournisseurActuel.id);
          // print(fournisseurActuel.produits);
          // print(produitActuel.fournisseurs);

          //  print('Relations supprimées. Mise à jour des objets.');

          // Mise à jour dans la base de données
          _objectBox.fournisseurBox.put(fournisseurActuel);
          // print('Fournisseur mis à jour dans la base de données.');
        } else {
          // print(
          //     'Le produit n\'est pas dans la liste du fournisseur ou le fournisseur n\'est pas dans la liste du produit.');
        }
      });

      // Rechargement des données en dehors de la transaction
      //  print('Rechargement des produits et des fournisseurs.');
      chargerProduits(reset: true);
      _chargerFournisseurs();
      notifyListeners();
      //  print('Notifications envoyées aux auditeurs.');
    } catch (e) {
      print('Erreur lors de la suppression du produit du fournisseur : $e');
    }
  }
}

class CartProvider with ChangeNotifier {
  Facture _facture = Facture(date: DateTime.now(), qr: '');

  Facture get facture => _facture;

  void addToCart(Produit produit) {
    final index = _facture.lignesFacture
        .indexWhere((item) => item.produit.target!.id == produit.id);
    if (index != -1) {
      _facture.lignesFacture[index].quantite += 1;
    } else {
      final ligneFacture = LigneFacture(
        quantite: 1,
        prixUnitaire: produit.prixVente,
      );
      ligneFacture.produit.target = produit;
      _facture.lignesFacture.add(ligneFacture);
    }
    notifyListeners();
  }

  void removeFromCart(Produit produit) {
    final index = _facture.lignesFacture
        .indexWhere((item) => item.produit.target!.id == produit.id);
    if (index != -1) {
      if (_facture.lignesFacture[index].quantite > 1) {
        _facture.lignesFacture[index].quantite -= 1;
      } else {
        _facture.lignesFacture.removeAt(index);
      }
    }
    notifyListeners();
  }

  double get totalAmount {
    return _facture.lignesFacture
        .fold(0, (sum, item) => sum + item.prixUnitaire * item.quantite);
  }

  void saveFacture() {
    final box = ObjectBox().factureBox;
    box.put(_facture);
    _facture = Facture(date: DateTime.now(), qr: '');
    notifyListeners();
  }

  void clearCart() {
    _facture = Facture(date: DateTime.now(), qr: '');
    notifyListeners();
  }
}
