import 'dart:async';

import 'package:flutter/material.dart';
import 'Entity.dart';
import 'classeObjectBox.dart';

// class ProduitProvider extends ChangeNotifier {
//   final ObjectBox _objectBox;
//   List<Produit> _produits = [];
//
//   List<Produit> get produits => _produits;
//
//   ProduitProvider(this._objectBox) {
//     _chargerProduits();
//   }
//
//   void _chargerProduits() {
//     _produits = _objectBox.produitBox.getAll();
//     for (var produit in _produits) {
//       produit.fournisseurs; // Accède aux fournisseurs pour les charger
//     }
//     notifyListeners();
//   }
//
//   void ajouterProduit(Produit produit, List<Fournisseur> fournisseurs) {
//     // Ajouter chaque fournisseur à la base de données s'il n'existe pas déjà
//     for (var fournisseur in fournisseurs) {
//       if (!_objectBox.fournisseurBox.contains(fournisseur.id)) {
//         _objectBox.fournisseurBox.put(fournisseur);
//       }
//     }
//
//     // Mettre à jour les relations du produit
//     produit.fournisseurs.clear();
//     produit.fournisseurs.addAll(fournisseurs);
//
//     // Ajouter le produit à la base de données
//     _objectBox.produitBox.put(produit);
//
//     _chargerProduits();
//   }
//
//   void updateProduit(Produit produit) {
//     _objectBox.produitBox.put(produit);
//     _chargerProduits();
//     notifyListeners();
//   }
//
//   void supprimerProduit(Produit produit) {
//     _objectBox.produitBox.remove(produit.id);
//     _chargerProduits();
//   }
//
//   void supprimerFournisseurDeProduit(Produit produit, Fournisseur fournisseur) {
//     produit.fournisseurs.remove(fournisseur);
//     _objectBox.produitBox.put(produit);
//     _chargerProduits();
//   }
// }

class ProduitProvider extends ChangeNotifier {
  final ObjectBox _objectBox;
  List<Produit> _produits = [];

  ProduitProvider(this._objectBox) {
    _chargerProduits();
  }

  List<Produit> get produits => _produits;

  void _chargerProduits() {
    _produits = _objectBox.produitBox.getAll();
    notifyListeners();
  }

  Produit? getProduitById(int id) {
    return _objectBox.produitBox.get(id);
  }

  void ajouterProduit(Produit produit, List<Fournisseur> fournisseurs) {
    _ajouterOuMettreAJourFournisseurs(fournisseurs);
    produit.fournisseurs.addAll(fournisseurs);
    _objectBox.produitBox.put(produit);
    _chargerProduits();
    notifyListeners();
  }

  void updateProduit(Produit produit) {
    _objectBox.produitBox.put(produit);
    _chargerProduits();
    notifyListeners();
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
      notifyListeners();
    }
  }

  void ajouterFournisseursAProduit(
      int produitId, List<Fournisseur> fournisseurs) {
    final produit = getProduitById(produitId);
    if (produit != null) {
      _ajouterOuMettreAJourFournisseurs(fournisseurs);
      produit.fournisseurs.addAll(fournisseurs);
      _objectBox.produitBox.put(produit);
      _chargerProduits();
      notifyListeners();
    }
  }

  void supprimerProduit(Produit produit) {
    _objectBox.produitBox.remove(produit.id);
    _chargerProduits();
    notifyListeners();
  }

  void supprimerFournisseurDeProduit(Produit produit, Fournisseur fournisseur) {
    produit.fournisseurs.remove(fournisseur);
    _objectBox.produitBox.put(produit);
    _chargerProduits();
    notifyListeners();
  }

  void addFournisseurToProduit(Produit produit, Fournisseur fournisseur) {
    if (!produit.fournisseurs.contains(fournisseur)) {
      produit.fournisseurs.add(fournisseur);
      _objectBox.produitBox
          .put(produit); // Mettre à jour le produit dans la base de données
      _chargerProduits(); // Rafraîchir la liste des produits si nécessaire
      notifyListeners();
    }
  }

  void _ajouterOuMettreAJourFournisseurs(List<Fournisseur> fournisseurs) {
    for (var fournisseur in fournisseurs) {
      if (!_objectBox.fournisseurBox.contains(fournisseur.id)) {
        _objectBox.fournisseurBox.put(fournisseur);
      } else {
        _objectBox.fournisseurBox.put(fournisseur);
      }
    }
  }
}

class FournisseurProvider extends ChangeNotifier {
  final ObjectBox _objectBox;

  List<Fournisseur> _fournisseurs = [];

  List<Fournisseur> get fournisseurs => _fournisseurs;

  FournisseurProvider(this._objectBox) {
    _chargerFournisseurs();
  }

  void _chargerFournisseurs() {
    _fournisseurs = _objectBox.fournisseurBox.getAll().toList();
    notifyListeners();
  }

  void addFournisseur(Fournisseur fournisseur) {
    _objectBox.fournisseurBox.put(fournisseur);
    _chargerFournisseurs();
  }

  void updateFournisseur(int id, Fournisseur updatedFournisseur) {
    var fournisseurIndex = _fournisseurs.indexWhere((f) => f.id == id);
    if (fournisseurIndex != -1) {
      updatedFournisseur.id = id;
      _objectBox.fournisseurBox.put(updatedFournisseur);
      _fournisseurs[fournisseurIndex] = updatedFournisseur;
      notifyListeners();
    }
  }

  void supprimerFournisseur(Fournisseur fournisseur) {
    _objectBox.fournisseurBox.remove(fournisseur.id);
    _chargerFournisseurs();
  }

  List<Produit> getProduitsByFournisseur(Fournisseur fournisseur) {
    return fournisseur.produits.toList();
  }
}
