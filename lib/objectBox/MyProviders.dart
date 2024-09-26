import 'dart:async';
import 'dart:io';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:faker/faker.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import '../objectBox/pages/ProduitListSupabase.dart';
import '../../objectbox.g.dart';
import 'Entity.dart';
import 'classeObjectBox.dart';
import 'package:objectbox/objectbox.dart';
import 'dart:isolate';

class CommerceProvider extends ChangeNotifier {
  final ObjectBox _objectBox;

  List<Produit> _produits = [];
  List<Fournisseur> _fournisseurs = [];
  List<Approvisionnement> _approvisionnements = [];
  List<Approvisionnement> _approvisionnementTemporaire = [];
  List<Client> _clients = [];
  int _currentPage = 0;
  final int _pageSize = 100;
  bool _hasMoreProduits = true;
  bool _isLoading = false;

  List<Produit> get produits => _produits;
  List<Approvisionnement> get approvisionnements => _approvisionnements;
  List<Approvisionnement> get approvisionnementTemporaire =>
      _approvisionnementTemporaire;

  bool get hasMoreProduits => _hasMoreProduits;
  List<Fournisseur> get fournisseurs => _fournisseurs;
  bool get isLoading => _isLoading;
  List<Client> get clients => _clients;

  CommerceProvider(this._objectBox) {
    chargerProduits();
    _chargerFournisseurs();
    getClientsFromBox();
  }

  // Future<void> chargerProduits({bool reset = false}) async {
  //   // Empêche les appels multiples simultanés
  //   if (_isLoading) return;
  //   _isLoading = true;
  //   notifyListeners();
  //   // Réinitialiser la pagination si nécessaire
  //   if (reset) {
  //     _currentPage = 0;
  //     produits.clear();
  //   }
  //   // Créer la requête pour récupérer les produits triés par ID descendant
  //   final query = _objectBox.produitBox.query()
  //     ..order(Produit_.id, flags: Order.descending);
  //   // Récupérer tous les produits (ou appliquer la pagination selon le besoin)
  //   final allProduits = await query.build().find();
  //   // Gérer la pagination
  //   final startIndex = _currentPage * _pageSize;
  //   final endIndex = startIndex + _pageSize;
  //
  //   if (startIndex >= allProduits.length) {
  //     _hasMoreProduits = false;
  //   } else {
  //     // Sous-liste des nouveaux produits à ajouter
  //     final newProduits = allProduits.sublist(
  //       startIndex,
  //       endIndex > allProduits.length ? allProduits.length : endIndex,
  //     );
  //
  //     // Ajouter les nouveaux produits avec approvisionnements au fournisseur de produits
  //     _produits.addAll(newProduits);
  //     _currentPage++;
  //     _hasMoreProduits = endIndex < allProduits.length;
  //   }
  //
  //   _isLoading = false;
  //   notifyListeners();
  // }
  Future<void> chargerProduits({bool reset = false}) async {
    // Empêche les appels multiples simultanés
    if (_isLoading) return;
    _isLoading = true;
    notifyListeners();

    // Réinitialiser la pagination si nécessaire
    if (reset) {
      _currentPage = 0;
      produits.clear();
    }

    // Créer la requête pour récupérer les produits triés par ID descendant
    final query = _objectBox.produitBox.query()
      ..order(Produit_.id, flags: Order.descending);

    // Récupérer tous les produits
    final allProduits = await query.build().find();

    // Gérer la pagination
    final startIndex = _currentPage * _pageSize;
    final endIndex = startIndex + _pageSize;

    if (startIndex >= allProduits.length) {
      _hasMoreProduits = false;
    } else {
      // Sous-liste des nouveaux produits à ajouter
      final newProduits = allProduits.sublist(
        startIndex,
        endIndex > allProduits.length ? allProduits.length : endIndex,
      );

      // Ajouter les nouveaux produits sans restructurer
      produits.addAll(newProduits);
      _currentPage++;
      _hasMoreProduits = endIndex < allProduits.length;
    }

    _isLoading = false;
    notifyListeners();
  }

  void getClientsFromBox() {
    final box = ObjectBox().clientBox; // Utilisez le singleton ObjectBox
    _clients = box.getAll();
    notifyListeners();
  }

  Future<List<Produit>> rechercherProduits(String query,
      {int limit = 20}) async {
    final queryLower = query.toLowerCase();
    final idQuery = int.tryParse(query);
    final qrQuery = query;

    final qBuilder = _objectBox.produitBox.query(qrQuery !=
            null // la recherche se fait par id et moi je le veux pas qrcode
        ? Produit_.qr.equals(qrQuery) |
            Produit_.nom.contains(queryLower, caseSensitive: false) |
            Produit_.qr.contains(queryLower, caseSensitive: false)
        : Produit_.nom.contains(queryLower, caseSensitive: false));
    // Inverser l'ordre des résultats
    final results = qBuilder.build().find();
    return results.reversed.toList();
  }

  void resetProduits() {
    _produits.clear();
    _currentPage = 0;
    _hasMoreProduits = true;

    chargerProduits(reset: true);
  }

  void _chargerFournisseurs() {
    _fournisseurs = _objectBox.fournisseurBox.getAll().reversed.toList();
    notifyListeners();
  }

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

  List<Produit?> getProduitsForFournisseur(Fournisseur fournisseur) {
    // Récupérer le fournisseur à partir de l'ID
    final fournisseurBox = _objectBox.fournisseurBox.get(fournisseur.id);

    if (fournisseurBox == null) {
      return [];
    }

    // Récupérer tous les approvisionnements du fournisseur
    final approvisionnements = fournisseurBox.approvisionnements;

    // Extraire les produits uniques associés aux approvisionnements
    final produits = approvisionnements
        .map((approvisionnement) => approvisionnement.produit.target)
        .where((produit) => produit != null) // Filtrer les produits non-nuls
        .toSet() // Supprimer les doublons
        .toList();

    return produits.reversed.toList();
  }

  void ajouterProduit(
    Produit produit,
    List<Fournisseur> fournisseurs,
    List<Approvisionnement> approvisionnements,
  ) {
    // Mettre à jour ou ajouter les fournisseurs
    _ajouterOuMettreAJourFournisseurs(fournisseurs);

    // Lier Crud au produit
    // produit.crud.target = crudProduit;

    // Ajouter ou mettre à jour les approvisionnements
    //_objectBox.crud.put(crudProduit);
    final produitId = _objectBox.produitBox.put(produit);

    // Enregistrer chaque approvisionnement temporaire
    final boxApprovisionnement = _objectBox.approvisionnementBox;
    final boxFournisseur = _objectBox.fournisseurBox;
    final boxCrudApprovisionnement = _objectBox.crud;

    for (var approvisionnementTemp in _approvisionnementTemporaire) {
      // a. Vérifier ou créer le fournisseur
      Fournisseur fournisseur = _fournisseurs.firstWhere(
        (f) =>
            f.nom.toLowerCase() ==
            approvisionnementTemp.fournisseur.target!.nom.toLowerCase(),
        orElse: () =>
            Fournisseur(nom: approvisionnementTemp.fournisseur.target!.nom),
      );

      if (fournisseur.id == 0) {
        // Nouveau fournisseur, l'enregistrer
        boxFournisseur.put(fournisseur);
        _fournisseurs.add(fournisseur);
      } else {
        // Si le fournisseur existe déjà, le récupérer de la boîte
        fournisseur = _objectBox.fournisseurBox.get(fournisseur.id)!;
      }

      // b. Enregistrer le Crud pour l'approvisionnement
      // boxCrudApprovisionnement.put(crudProduit);

      // c. Créer l'instance de l'approvisionnement
      Approvisionnement approvisionnement = Approvisionnement(
        quantite: approvisionnementTemp.quantite,
        prixAchat: approvisionnementTemp.prixAchat,
        datePeremption: approvisionnementTemp.datePeremption,
      );

      // Lier les relations
      // approvisionnement.crud.target = crudProduit;
      approvisionnement.fournisseur.target = fournisseur;
      approvisionnement.produit.targetId = produitId;

      // d. Enregistrer l'approvisionnement
      boxApprovisionnement.put(approvisionnement);
    }

    // Enregistrer les approvisionnements fournis
    for (var approvisionnement in approvisionnements) {
      if (!_approvisionnements.contains(approvisionnement)) {
        // Vérifier les doublons
        approvisionnement.produit.target = produit;
        _objectBox.approvisionnementBox.put(approvisionnement);
      }
    }

    // Sauvegarder le produit avec les relations
    _objectBox.produitBox.put(produit);

    // Recharger les produits et les fournisseurs après mise à jour
    chargerProduits(reset: true);
    _chargerFournisseurs();
  }

  // void ajouterProduit(Produit produit, List<Fournisseur> fournisseurs,
  //     List<Approvisionnement> approvisionnements, ) {
  //   // Mettre à jour ou ajouter les fournisseurs
  //   _ajouterOuMettreAJourFournisseurs(fournisseurs);
  //
  //   // Associer les fournisseurs au produit
  //   produit.fournisseurs
  //       .clear(); // Clear existing relations to avoid duplicates
  //   produit.fournisseurs.addAll(fournisseurs);
  //
  //   // Ajouter ou mettre à jour les approvisionnements
  //
  //   for (var approvisionnement in approvisionnements) {
  //     if (!_approvisionnements.contains(approvisionnement)) {
  //       // Vérifier les doublons
  //       approvisionnement.produit.target = produit;
  //       _objectBox.approvisionnementBox.put(approvisionnement);
  //     }
  //   }
  //   // Associer l'entité Crud au produit pour gérer les métadonnées
  //   // produit.crud.target = crud;
  //
  //   // Sauvegarder le produit avec les relations
  //   _objectBox.produitBox.put(produit);
  //
  //   // Recharger les produits et les fournisseurs après mise à jour
  //   chargerProduits(reset: true);
  //   _chargerFournisseurs();
  // }

  void updateProduit(Produit produit) {
    _objectBox.produitBox.put(produit);
    chargerProduits(reset: true);
  }

  // void updateProductStock(int productId, double newStock) {
  //   final index = _produits.indexWhere((p) => p.id == productId);
  //   if (index != -1) {
  //     _produits[index].stock = newStock;
  //     _objectBox.produitBox.put(_produits[index]);
  //     notifyListeners();
  //   }
  // }
  //
  // void updateProduitById(int id, Produit updatedProduit,
  //     {List<Fournisseur>? fournisseurs}) {
  //   final produit = getProduitById(id);
  //   if (produit != null) {
  //     produit
  //       ..nom = updatedProduit.nom
  //       ..description = updatedProduit.description
  //       ..prixAchat = updatedProduit.prixAchat
  //       ..prixVente = updatedProduit.prixVente
  //       ..stock = updatedProduit.stock
  //       ..qr = updatedProduit.qr
  //       ..image = updatedProduit.image
  //       ..minimStock = updatedProduit.minimStock
  //       // ..dateCreation = updatedProduit.dateCreation
  //       ..stockUpdate = updatedProduit.stockUpdate
  //       ..stockinit = updatedProduit.stockinit;
  //
  //     if (fournisseurs != null) {
  //       _ajouterOuMettreAJourFournisseurs(fournisseurs);
  //       produit.fournisseurs.clear();
  //       produit.fournisseurs.addAll(fournisseurs);
  //     }
  //
  //     _objectBox.produitBox.put(produit);
  //     chargerProduits(reset: true);
  //     _chargerFournisseurs();
  //     notifyListeners();
  //   }
  // }

  void supprimerProduit(Produit produit) {
    _objectBox.produitBox.remove(produit.id);
    chargerProduits(reset: true);
    _chargerFournisseurs();
  }

  int getTotalProduits() {
    return _objectBox.produitBox.count();
  }

  int getTotalClientsCount() {
    return _objectBox.clientBox.count();
  }

  List<Produit> getProduitsBetweenPrices(double minPrice, double maxPrice) {
    final query = _objectBox.produitBox
        .query(Produit_.prixVente.between(minPrice, maxPrice));
    return query.build().find();
  }

  // Map<String, dynamic> getProduitsLowStock(qtt) {
  //   final query = _objectBox.produitBox.query(Produit_.stock.lessOrEqual(qtt));
  //   final lowStockProduits = query.build().find();
  //
  //   return //lowStockProduits.length;
  //       {
  //     'count': lowStockProduits.length,
  //     'produits': lowStockProduits,
  //   };
  // }

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

  void ajouterFournisseurAvecProduits(Fournisseur fournisseur,
      List<Produit> produits, List<double> quantites, List<double> prixAchats) {
    // Assurer que les quantités et les prix d'achat sont fournis pour chaque produit
    if (produits.length != quantites.length ||
        produits.length != prixAchats.length) {
      throw ArgumentError(
          "Les listes de produits, quantités et prix d'achat doivent avoir la même longueur.");
    }

    // Ajouter ou mettre à jour les produits
    _ajouterOuMettreAJourProduits(produits);

    // Associer chaque produit avec le fournisseur via un approvisionnement
    for (int i = 0; i < produits.length; i++) {
      Approvisionnement approvisionnement = Approvisionnement(
        quantite: quantites[i],
        prixAchat: prixAchats[i],
        datePeremption:
            null, // Ajouter si tu as besoin de gérer la date de péremption
      );

      // Définir les relations produit et fournisseur
      approvisionnement.produit.target = produits[i];
      approvisionnement.fournisseur.target = fournisseur;

      // Ajouter l'approvisionnement dans la base de données
      _objectBox.approvisionnementBox.put(approvisionnement);
    }

    // Sauvegarder le fournisseur dans la base de données
    _objectBox.fournisseurBox.put(fournisseur);

    // Rafraîchir les listes de produits et fournisseurs
    chargerProduits(reset: true);
    _chargerFournisseurs();

    // Notifier les auditeurs
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
        description: faker.lorem.sentence(),
        qr: faker.randomGenerator.integer(999999).toString(),
        prixVente: faker.randomGenerator.decimal(min: 50),
        minimStock: faker.randomGenerator.decimal(min: 1, scale: 2),
        alertPeremption: Random().nextInt(10),
      );
    });

    // Ajouter les produits et créer des approvisionnements pour chaque produit
    for (Produit produit in produits) {
      Approvisionnement approvisionnement = Approvisionnement(
        quantite: faker.randomGenerator.decimal(min: 100, scale: 15),
        prixAchat: faker.randomGenerator.decimal(min: 10),
        datePeremption: faker.date.dateTime(minYear: 2025),
      );

      // Définir les relations entre l'approvisionnement, le produit et le fournisseur
      approvisionnement.produit.target = produit;
      approvisionnement.fournisseur.target = fournisseur;

      // Ajouter l'approvisionnement à la base de données
      _objectBox.approvisionnementBox.put(approvisionnement);
    }

    // Sauvegarder le fournisseur et les produits associés
    _objectBox.fournisseurBox.put(fournisseur);

    // Notifier les auditeurs que les données ont été mises à jour
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
      // Vérifier si l'approvisionnement existe déjà pour ce produit
      bool existe = fournisseur.approvisionnements
          .any((a) => a.produit.target == produit);

      if (!existe) {
        // Créer un nouvel approvisionnement pour ce produit
        Approvisionnement approvisionnement = Approvisionnement(
          quantite: 0, // Définir la quantité initiale
          prixAchat: 0, // Ajuster le prix d'achat si nécessaire
          datePeremption: null, // Définir la date de péremption si nécessaire
        );

        // Établir les relations
        approvisionnement.produit.target = produit;
        approvisionnement.fournisseur.target = fournisseur;

        // Ajouter l'approvisionnement au fournisseur
        fournisseur.approvisionnements.add(approvisionnement);
      }
    }

    // Sauvegarder le fournisseur et les produits associés
    _objectBox.fournisseurBox.put(fournisseur);
    _objectBox.produitBox.putMany(produits);

    // Charger les produits et les fournisseurs
    chargerProduits(reset: true);
    _chargerFournisseurs();
    notifyListeners();
  }

  void supprimerProduitDuFournisseur(Fournisseur fournisseur, Produit produit) {
    try {
      // Charger les instances actuelles de la base de données
      Fournisseur? fournisseurActuel =
          _objectBox.fournisseurBox.get(fournisseur.id);
      Produit? produitActuel = _objectBox.produitBox.get(produit.id);

      if (fournisseurActuel == null) {
        print('Fournisseur non trouvé dans la base de données.');
        return;
      }
      if (produitActuel == null) {
        print('Produit non trouvé dans la base de données.');
        return;
      }

      _objectBox.store.runInTransaction(TxMode.write, () {
        // Vérifier si l'approvisionnement existe pour ce produit et ce fournisseur
        bool approvisionnementExiste = fournisseurActuel.approvisionnements
            .any((a) => a.produit.target == produitActuel);

        if (approvisionnementExiste) {
          // Supprimer l'approvisionnement du fournisseur
          fournisseurActuel.approvisionnements
              .removeWhere((a) => a.produit.target == produitActuel);

          // Mise à jour dans la base de données
          _objectBox.fournisseurBox.put(fournisseurActuel);
          _objectBox.produitBox
              .put(produitActuel); // Mettre à jour le produit si nécessaire
        } else {
          print(
              'L\'approvisionnement n\'existe pas pour ce produit et ce fournisseur.');
        }
      });

      // Rechargement des données en dehors de la transaction
      chargerProduits(reset: true);
      _chargerFournisseurs();
      notifyListeners();
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
        print('Produit non trouvé dans la base de données.');
        return;
      }
      if (fournisseurActuel == null) {
        print('Fournisseur non trouvé dans la base de données.');
        return;
      }

      _objectBox.store.runInTransaction(TxMode.write, () {
        // Vérifier si l'approvisionnement existe pour ce produit et ce fournisseur
        bool approvisionnementExiste = fournisseurActuel.approvisionnements
            .any((a) => a.produit.target == produitActuel);

        if (approvisionnementExiste) {
          // Supprimer l'approvisionnement du fournisseur
          fournisseurActuel.approvisionnements
              .removeWhere((a) => a.produit.target == produitActuel);

          // Mise à jour dans la base de données
          _objectBox.fournisseurBox.put(fournisseurActuel);
        } else {
          print(
              'L\'approvisionnement n\'existe pas pour ce produit et ce fournisseur.');
        }
      });

      // Rechargement des données en dehors de la transaction
      chargerProduits(reset: true);
      _chargerFournisseurs();
      notifyListeners();
    } catch (e) {
      print('Erreur lors de la suppression du fournisseur du produit : $e');
    }
  }
}

class CartProvider with ChangeNotifier {
  final ObjectBox _objectBox;
  Facture _facture = Facture(
    date: DateTime.now(),
    qr: '',
    impayer: 0.0,
  );
  Client? _selectedClient;
  List<Facture> _factures = [];
  Produit? produit;

  Facture get facture => _facture;
  Client? get selectedClient => _selectedClient;
  List<Facture> get factures => _factures;
  int get factureCount => _factures.length;

  CartProvider(this._objectBox) {
    fetchFactures();
  }

  void fetchFactures() {
    _factures = _objectBox.factureBox.getAll();
    notifyListeners();
  }

  void setSelectedClient(Client client) {
    _selectedClient = client;
    notifyListeners();
  }

  void selectClient(Client client) {
    _selectedClient = client;
    _facture.client.target = client;
    notifyListeners();
  }

  void resetClient() {
    _selectedClient = null;
    notifyListeners();
  }

  Future<void> createAndSelectClient(
      String nom,
      String phone,
      String adresse,
      String description,
      DateTime dateCreation,
      DateTime derniereModification) async {
    final newClient = Client(
      qr: await generateQRCode('${_selectedClient!.id}'),
      nom: nom,
      phone: phone,
      adresse: adresse,
      description: description,
    );
    _objectBox.clientBox.put(newClient);
    selectClient(newClient);
  }

  // void createAnonymousClientIfNeeded() {
  //   if (_selectedClient == null) {
  //     final anonymousClient = Client(
  //       qr: 'ANONYMOUS_${DateTime.now().millisecondsSinceEpoch}',
  //       nom:
  //           'ANONYMOUS_Client du ${_facture.date.day}/${_facture.date.month}/${_facture.date.year}',
  //       phone: '',
  //       adresse: '',
  //       description: 'Client créé automatiquement',
  //       dateCreation: DateTime.now(),
  //       derniereModification: DateTime.now(),
  //       createdBy: 0,
  //       updatedBy: 0,
  //       deletedBy: 0,
  //     );
  //     _objectBox.clientBox.put(anonymousClient);
  //     selectClient(anonymousClient);
  //   }
  // }
  void createAnonymousClientIfNeeded() {
    if (_selectedClient == null) {
      // Création de l'entité Crud pour le client anonyme
      final crud = Crud(
        createdBy: 0, // Id utilisateur anonyme
        updatedBy: 0,
        deletedBy: 0,
        dateCreation: DateTime.now(),
        derniereModification: DateTime.now(),
        dateDeleting: null,
      );

      // Création du client anonyme
      final anonymousClient = Client(
        qr: 'ANONYMOUS_${DateTime.now().millisecondsSinceEpoch}',
        nom:
            'ANONYMOUS_Client du ${_facture.date.day}/${_facture.date.month}/${_facture.date.year}',
        phone: '',
        adresse: '',
        description: 'Client créé automatiquement',
      );

      // Associer l'entité Crud au client
      anonymousClient.crud.target = crud;

      // Sauvegarder le client avec l'entité Crud
      _objectBox.clientBox.put(anonymousClient);

      // Sélectionner le client anonyme comme client courant
      selectClient(anonymousClient);
    }
  }

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
      ligneFacture.facture.target = _facture;
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

  Map<String, dynamic> calculateTotalsForInterval(
      DateTime startDate, DateTime endDate) {
    double totalTTC = 0.0;
    double totalImpayes = 0.0;
    double totalTVA = 0.0;
    const double tvaRate = 0.19; // Taux de TVA (20% par exemple)

    // Récupérer les factures depuis ObjectBox au moment de l'appel de la méthode
    List<Facture> facturesDansIntervalle =
        _objectBox.factureBox.getAll().where((facture) {
      return (facture.date.isAfter(startDate) &&
              facture.date.isBefore(endDate)) ||
          facture.date.isAtSameMomentAs(startDate) ||
          facture.date.isAtSameMomentAs(endDate);
    }).toList();

    // Calculer les totaux pour chaque facture dans l'intervalle
    for (var facture in facturesDansIntervalle) {
      double montantHT = facture.lignesFacture.fold(0.0, (sum, ligne) {
        return sum + (ligne.prixUnitaire * ligne.quantite);
      });

      double tva = montantHT * tvaRate;
      double montantTTC = montantHT + tva;

      totalTTC += montantTTC;
      totalTVA += tva;

      // Ajouter le montant impayé
      totalImpayes += facture.impayer ?? 0.0;
    }

    // Retourner les résultats sous forme de map
    return {
      'totalTTC': totalTTC,
      'totalImpayes': totalImpayes,
      'totalTVA': totalTVA,
    };
  }

  Future<void> saveFacture(CommerceProvider commerceProvider) async {
    // Vérifier si un client est sélectionné
    if (_selectedClient != null) {
      // Sauvegarder le client mis à jour
      _objectBox.clientBox.put(_selectedClient!);
      // Associer le client à la facture
      _facture.client.target = _selectedClient;
    }

    // Génération du QR code et sauvegarde de la facture
    _facture.qr = await generateQRCode('${_facture.id} ${_facture.date}');

    // Sauvegarder la facture
    _objectBox.factureBox.put(_facture);

    // Sauvegarde des lignes de facture et mise à jour des produits associés
    for (var ligne in _facture.lignesFacture) {
      final produit = ligne.produit.target;

      if (produit != null) {
        // Mettre à jour le stock du produit en fonction de la quantité vendue
        double newStock =
            produit.stock - ligne.quantite; // Utilisez le getter ici

        // Sauvegarder le produit mis à jour
        _objectBox.produitBox.put(produit);
        commerceProvider.updateProduit(produit);
      }

      // Sauvegarder la ligne de facture
      _objectBox.ligneFacture.put(ligne);
    }

    // Réinitialisation de la facture et du client sélectionné
    _facture = Facture(
      date: DateTime.now(),
      qr: '',
      impayer: 0.0,
    );
    _selectedClient = null;

    notifyListeners();

    // Rafraîchir la liste des factures
    fetchFactures();
  }

  void clearCart() {
    _facture = Facture(
      date: DateTime.now(),
      qr: '',
      impayer: 0.0,
    );
    _selectedClient = null;
    notifyListeners();
  }

  Future<String> generateQRCode(gRGenerated) async {
    // Implémentez la logique de génération du QR code ici
    // Par exemple, vous pourriez utiliser un package comme 'qr' pour générer le code
    // et le convertir en chaîne de caractères
    // await Future.delayed(
    //     Duration(milliseconds: 100)); // Simuler une opération asynchrone
    return //"QR_${_objectBox.random.nextInt(1000000)}";
        "QR_${gRGenerated}";
  }

  Future<void> deleteFacture(Facture facture) async {
    _objectBox.factureBox.remove(facture.id);
    notifyListeners();
    fetchFactures();
  }

  Future<void> updateFacture(Facture updatedFacture) async {
    _objectBox.factureBox.put(updatedFacture);
    notifyListeners();
    fetchFactures();
  }

  Future<void> deleteAllFactures() async {
    final box = _objectBox.factureBox;
    box.removeAll();
    fetchFactures();
  }
}

class ClientProvider with ChangeNotifier {
  final ObjectBox _objectBox;
  List<Client> _clients = [];

  List<Client> get clients => _clients;
  int get clientCount => _clients.length;

  ClientProvider(this._objectBox) {
    getClientsFromBox();
  }

  void getClientsFromBox() {
    final box = _objectBox.clientBox;
    _clients = box.getAll();
    notifyListeners();
  }

  Future<void> addClient(Client client) async {
    _objectBox.clientBox.put(client);
    getClientsFromBox();
    notifyListeners();
  }

  Future<void> updateClient(Client client) async {
    _objectBox.clientBox.put(client);
    getClientsFromBox();
    notifyListeners();
  }

  Future<void> deleteClient(Client client) async {
    _objectBox.clientBox.remove(client.id);
    getClientsFromBox();
    notifyListeners();
  }

  List<Facture> getFacturesForClient(Client client) {
    // Utiliser ObjectBox pour récupérer les factures associées au client
    final facturesQuery =
        _objectBox.factureBox.query(Facture_.client.equals(client.id)).build();
    final factures = facturesQuery.find();
    facturesQuery.close();
    return factures;
  }

  Future<void> deleteAllClients() async {
    final box = _objectBox.clientBox;
    box.removeAll();
    getClientsFromBox();
    notifyListeners();
  }
}

class FakeDataGenerator extends ChangeNotifier {
  bool _isGenerating = false;
  bool get isGenerating => _isGenerating;

  Future<void> generateFakeData(
      BuildContext context,
      ObjectBox objectBox,
      int users,
      int clients,
      int suppliers,
      int products,
      int approvisionnements) async {
    if (_isGenerating) return;

    _isGenerating = true;
    notifyListeners();

    try {
      await Isolate.run(() => objectBox.fillWithFakeData(
          users, clients, suppliers, products, approvisionnements));

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Données factices ajoutées avec succès !')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text('Erreur lors de la génération des données : $e')),
      );
    } finally {
      _isGenerating = false;
      notifyListeners();
    }
  }
}

class AdProvider extends ChangeNotifier {
  static const int maxFailedLoadAttempts = 3;

  InterstitialAd? _interstitialAd;
  int _numInterstitialLoadAttempts = 0;

  RewardedInterstitialAd? _rewardedInterstitialAd;
  int _numRewardedInterstitialLoadAttempts = 0;

  RewardedAd? _rewardedAd;
  int _numRewardedLoadAttempts = 0;

  bool _isInterstitialAdReady = false;
  bool _isRewardedAdReady = false;
  bool _isRewardedInterstitialAdReady = true;

  bool get isInterstitialAdReady => _isInterstitialAdReady;
  bool get isRewardedAdReady => _isRewardedAdReady;
  bool get isRewardedInterstitialAdReady => _isRewardedInterstitialAdReady;

  AdProvider() {
    _createInterstitialAd();
    _createRewardedAd();
    _createRewardedInterstitialAd();
  }

  // Utilisez cette méthode pour créer une AdRequest sans paramètres spécifiques
  static AdRequest get request => AdRequest();

  void _createInterstitialAd() {
    InterstitialAd.load(
      adUnitId: Platform.isAndroid
          ? 'ca-app-pub-2282149611905342/9541682865'
          : 'ca-app-pub-2282149611905342/9541682865',
      request: request,
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (InterstitialAd ad) {
          _interstitialAd = ad;
          _numInterstitialLoadAttempts = 0;
          _isInterstitialAdReady = true;
          ad.setImmersiveMode(true);
          notifyListeners();
        },
        onAdFailedToLoad: (LoadAdError error) {
          _numInterstitialLoadAttempts += 1;
          _interstitialAd = null;
          _isInterstitialAdReady = false;
          if (_numInterstitialLoadAttempts < maxFailedLoadAttempts) {
            _createInterstitialAd();
          }
          notifyListeners();
        },
      ),
    );
  }

  void showInterstitialAd() {
    if (_interstitialAd == null) {
      return;
    }
    _interstitialAd!.fullScreenContentCallback = FullScreenContentCallback(
      onAdDismissedFullScreenContent: (InterstitialAd ad) {
        ad.dispose();
        _createInterstitialAd();
      },
      onAdFailedToShowFullScreenContent: (InterstitialAd ad, AdError error) {
        ad.dispose();
        _createInterstitialAd();
      },
    );
    _interstitialAd!.show();
    _interstitialAd = null;
    _isInterstitialAdReady = false;
    notifyListeners();
  }

  void _createRewardedInterstitialAd() {
    RewardedInterstitialAd.load(
      adUnitId: Platform.isAndroid
          ? 'ca-app-pub-2282149611905342/7845457819'
          : 'ca-app-pub-2282149611905342/7845457819',
      request: request,
      rewardedInterstitialAdLoadCallback: RewardedInterstitialAdLoadCallback(
        onAdLoaded: (RewardedInterstitialAd ad) {
          _rewardedInterstitialAd = ad;
          _numRewardedInterstitialLoadAttempts = 0;
          _isRewardedInterstitialAdReady = true;
          ad.setImmersiveMode(true);
          notifyListeners();
        },
        onAdFailedToLoad: (LoadAdError error) {
          _numRewardedInterstitialLoadAttempts += 1;
          _rewardedInterstitialAd = null;
          _isRewardedInterstitialAdReady = false;
          if (_numRewardedInterstitialLoadAttempts < maxFailedLoadAttempts) {
            _createRewardedInterstitialAd();
          }
          notifyListeners();
        },
      ),
    );
  }

  void _createRewardedAd() {
    RewardedAd.load(
      adUnitId: Platform.isAndroid
          ? 'ca-app-pub-2282149611905342/1761000427'
          : 'ca-app-pub-2282149611905342/1761000427',
      request: request,
      rewardedAdLoadCallback: RewardedAdLoadCallback(
        onAdLoaded: (RewardedAd ad) {
          _rewardedAd = ad;
          _numRewardedLoadAttempts = 0;
          _isRewardedAdReady = true;
          notifyListeners();
        },
        onAdFailedToLoad: (LoadAdError error) {
          _rewardedAd = null;
          _numRewardedLoadAttempts += 1;
          _isRewardedAdReady = false;
          if (_numRewardedLoadAttempts < maxFailedLoadAttempts) {
            _createRewardedAd();
          }
          notifyListeners();
        },
      ),
    );
  }

  Future<bool> showRewardedAd() async {
    if (_rewardedAd == null) {
      return false;
    }

    final completer = Completer<bool>();

    _rewardedAd!.fullScreenContentCallback = FullScreenContentCallback(
      onAdDismissedFullScreenContent: (RewardedAd ad) {
        ad.dispose();
        _createRewardedAd();
        completer.complete(false);
      },
      onAdFailedToShowFullScreenContent: (RewardedAd ad, AdError error) {
        ad.dispose();
        _createRewardedAd();
        completer.complete(false);
      },
    );

    _rewardedAd!.setImmersiveMode(true);
    await _rewardedAd!.show(
      onUserEarnedReward: (AdWithoutView ad, RewardItem reward) {
        completer.complete(true);
      },
    );
    _rewardedAd = null;
    _isRewardedAdReady = false;
    notifyListeners();

    return completer.future;
  }
}
