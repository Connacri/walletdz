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

  List<Produit> _produits = [];
  List<Fournisseur> _fournisseurs = [];
  List<Client> _clients = [];
  int _currentPage = 0;
  final int _pageSize = 100;
  bool _hasMoreProduits = true;
  bool _isLoading = false;

  List<Produit> get produits => _produits;
  bool get hasMoreProduits => _hasMoreProduits;
  List<Fournisseur> get fournisseurs => _fournisseurs;
  bool get isLoading => _isLoading;
  List<Client> get clients => _clients;

  CommerceProvider(this._objectBox) {
    chargerProduits();
    _chargerFournisseurs();
    getClientsFromBox();
  }

  Future<void> chargerProduits({bool reset = false}) async {
    if (_isLoading) return; // Empêche les appels multiples simultanés
    _isLoading = true;
    notifyListeners();
    if (reset) {
      _currentPage = 0;
      produits.clear();
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

      _produits.addAll(newProduits);
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

  // Produit? findProduitByQrOrId(String code) {
  //   // Rechercher le produit par QR ou ID
  //   return _produits.firstWhere(
  //     (produit) => produit.qr == code || produit.id.toString() == code,
  //     orElse: () => Produit(
  //       nom: 'Produit inconnu',
  //       prixAchat: 0.0,
  //       prixVente: 0.0,
  //       stock: 0.0,
  //       minimStock: 0.0,
  //       createdBy: 0,
  //       updatedBy: 0,
  //       deletedBy: 0,
  //       derniereModification: DateTime.now(),
  //       stockinit: 0.0,
  //     ),
  //   );
  // }

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
    final index = _produits.indexWhere((p) => p.id == productId);
    if (index != -1) {
      _produits[index].stock = newStock;
      _objectBox.produitBox.put(_produits[index]);
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

  int getTotalClientsCount() {
    return _objectBox.clientBox.count();
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
        createdBy: 0,
        updatedBy: 0,
        deletedBy: 0,
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
  final ObjectBox _objectBox;
  Facture _facture = Facture(
    date: DateTime.now(),
    qr: '',
    createdBy: 0,
    updatedBy: 0,
    deletedBy: 0,
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
      dateCreation: dateCreation,
      derniereModification: derniereModification,
      createdBy: 0,
      updatedBy: 0,
      deletedBy: 0,
    );
    _objectBox.clientBox.put(newClient);
    selectClient(newClient);
  }

  void createAnonymousClientIfNeeded() {
    if (_selectedClient == null) {
      final anonymousClient = Client(
        qr: 'ANONYMOUS_${DateTime.now().millisecondsSinceEpoch}',
        nom:
            'ANONYMOUS_Client du ${_facture.date.day}/${_facture.date.month}/${_facture.date.year}',
        phone: '',
        adresse: '',
        description: 'Client créé automatiquement',
        dateCreation: DateTime.now(),
        derniereModification: DateTime.now(),
        createdBy: 0,
        updatedBy: 0,
        deletedBy: 0,
      );
      _objectBox.clientBox.put(anonymousClient);
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
      // Mise à jour du montant impayé du client
      // _selectedClient?.impayer = (_selectedClient?.impayer ?? 0) + totalAmount;

      // Sauvegarder le client mis à jour
      _objectBox.clientBox.put(_selectedClient!);
      // Associer le client à la facture
      _facture.client.target = _selectedClient;
    }

    // Génération du QR code et sauvegarde de la facture
    _facture.qr = await generateQRCode('${_facture.id} ${_facture.date}');

    // Sauvegarder la facture
    _objectBox.factureBox.put(_facture);

    // // Sauvegarde des lignes de facture
    // for (var ligne in _facture.lignesFacture) {
    //   _objectBox.ligneFacture.put(ligne);
    // }
// Sauvegarde des lignes de facture et mise à jour des produits associés
    for (var ligne in _facture.lignesFacture) {
      final produit = ligne.produit.target;

      if (produit != null) {
        // Mettre à jour le stock du produit en fonction de la quantité vendue
        produit.stock -= ligne.quantite;

        // Mettre à jour la date de modification du produit
        produit.derniereModification = DateTime.now();

        // Sauvegarder le produit mis à jour
        _objectBox.produitBox.put(produit);
        commerceProvider.updateProduit(produit);
        // Notifier le `ClientProvider` de la mise à jour du produit
        // Vous devez injecter le `ClientProvider` ou le notifier via une méthode appropriée
        // Exemple : clientProvider.updateProduit(produit);
      }

      // Sauvegarder la ligne de facture
      _objectBox.ligneFacture.put(ligne);
    }
    // Réinitialisation de la facture et du client sélectionné
    _facture = Facture(
      date: DateTime.now(),
      qr: '',
      createdBy: 0,
      updatedBy: 0,
      deletedBy: 0,
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
      createdBy: 0,
      updatedBy: 0,
      deletedBy: 0,
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
