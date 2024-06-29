import 'dart:math';
import 'package:flutter/material.dart';
import 'package:faker/faker.dart';
import '../../objectbox.g.dart';
import 'Entity.dart';
import 'classeObjectBox.dart';

class CommerceProvider extends ChangeNotifier {
  final ObjectBox _objectBox;
  List<Produit> _produits = [];
  List<Produit> _produitsP = [];
  List<Fournisseur> _fournisseurs = [];
  int _currentPage = 0;
  final int _pageSize = 20;
  bool _hasMoreProduits = true;

  CommerceProvider(this._objectBox) {
    _chargerProduits();
    _chargerProduits2();
    _chargerFournisseurs();
  }

  List<Produit> get produits => _produits;
  List<Produit> get produitsP => _produitsP;
  bool get hasMoreProduits => _hasMoreProduits;
  List<Fournisseur> get fournisseurs => _fournisseurs;

  // Méthodes pour charger les produits et fournisseurs
  void _chargerProduits() {
    _produits = _objectBox.produitBox.getAll().toList();
    notifyListeners();
  }

  Future<void> _chargerProduits2() async {
    final query = _objectBox.produitBox.query()
      ..order(Produit_.id, flags: Order.descending);
    final allProduits = query.build().find();

    final startIndex = _currentPage * _pageSize;
    final endIndex = startIndex + _pageSize;

    if (startIndex >= allProduits.length) {
      _hasMoreProduits = false;
    } else {
      final newProduits = allProduits.sublist(startIndex,
          endIndex > allProduits.length ? allProduits.length : endIndex);
      _produitsP.addAll(newProduits);
      _currentPage++;
      _hasMoreProduits = endIndex < allProduits.length;
    }
    notifyListeners();
  }

  Future<void> loadMoreProduits() async {
    if (_hasMoreProduits) {
      await _chargerProduits2();
    }
  }

  void resetProduits() {
    _produitsP.clear();
    _currentPage = 0;
    _hasMoreProduits = true;
    _chargerProduits2();
  }

  void _chargerFournisseurs() {
    _fournisseurs = _objectBox.fournisseurBox.getAll().reversed.toList();
    notifyListeners();
  }

  // Méthodes pour les produits
  Produit? getProduitById(int id) {
    return _objectBox.produitBox.get(id);
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
    _chargerProduits();
    _chargerFournisseurs();
    notifyListeners();
  }

  void updateProduit(Produit produit) {
    _objectBox.produitBox.put(produit);
    _chargerProduits();
  }

  void updateProduitById(int id, Produit updatedProduit,
      {List<Fournisseur>? fournisseurs}) {
    final produit = getProduitById(id);
    if (produit != null) {
      produit.nom = updatedProduit.nom;
      produit.description = updatedProduit.description;
      produit.prixAchat = updatedProduit.prixAchat;
      produit.prixVente = updatedProduit.prixVente;
      produit.stock = updatedProduit.stock;
      produit.qr = updatedProduit.qr;
      produit.image = updatedProduit.image;

      if (fournisseurs != null) {
        _ajouterOuMettreAJourFournisseurs(fournisseurs);
        produit.fournisseurs.clear();
        produit.fournisseurs.addAll(fournisseurs);
      }

      _objectBox.produitBox.put(produit);
      _chargerProduits();
      _chargerFournisseurs();
      notifyListeners();
    }
  }

  void supprimerProduit(Produit produit) {
    _objectBox.produitBox.remove(produit.id);
    _chargerProduits();
    _chargerFournisseurs();
    notifyListeners();
  }

  // Méthodes pour les fournisseurs
  // Fournisseur? getFournisseurById(int id) {
  //   return _objectBox.fournisseurBox.get(id);
  // }

  void addFournisseur(Fournisseur fournisseur) {
    _objectBox.fournisseurBox.put(fournisseur);
    _chargerProduits();
    _chargerFournisseurs();
    notifyListeners();
  }

  void updateFournisseur(int id, Fournisseur updatedFournisseur) {
    var fournisseurIndex = _fournisseurs.indexWhere((f) => f.id == id);
    if (fournisseurIndex != -1) {
      updatedFournisseur.id = id;
      _objectBox.fournisseurBox.put(updatedFournisseur);
      _fournisseurs[fournisseurIndex] = updatedFournisseur;
      _chargerProduits();
      _chargerFournisseurs();
      notifyListeners();
    }
  }

  void supprimerFournisseur(Fournisseur fournisseur) {
    _objectBox.fournisseurBox.remove(fournisseur.id);
    _chargerProduits();
    _chargerFournisseurs();
    notifyListeners();
  }

  void ajouterFournisseurAvecProduits(
      Fournisseur fournisseur, List<Produit> produits) {
    _ajouterOuMettreAJourProduits(produits);
    fournisseur.produits.addAll(produits);
    _objectBox.fournisseurBox.put(fournisseur);
    _chargerProduits();
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
        stock: faker.randomGenerator.integer(100, min: 1),
        description: faker.lorem.sentence(),
        qr: faker.randomGenerator.integer(999999).toString(),
        // datePeremption:
        //     faker.date.dateTime(minYear: 2010, maxYear: DateTime.now().year),
        // dateCreation: faker.date.dateTime(minYear: 2010, maxYear: 2024),
        // derniereModification:
        //     faker.date.dateTime(minYear: 2000, maxYear: DateTime.now().year),
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
}
