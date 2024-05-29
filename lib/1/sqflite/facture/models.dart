class DetailFacture {
  final int id;
  final int factureId;
  final int produitId;
  final int quantite;
  final double prixUnitaire;

  DetailFacture({
    required this.id,
    required this.factureId,
    required this.produitId,
    required this.quantite,
    required this.prixUnitaire,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'facture_id': factureId,
      'produit_id': produitId,
      'quantite': quantite,
      'prix_unitaire': prixUnitaire,
    };
  }

  factory DetailFacture.fromMap(Map<String, dynamic> map) {
    return DetailFacture(
      id: map['id'],
      factureId: map['facture_id'],
      produitId: map['produit_id'],
      quantite: map['quantite'],
      prixUnitaire: map['prix_unitaire'],
    );
  }
}

class Facture {
  final int? id;
  final int clientId;
  final DateTime date;

  Facture({
    this.id,
    required this.clientId,
    required this.date,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'client_id': clientId,
      'date': date.toIso8601String(),
    };
  }

  factory Facture.fromMap(Map<String, dynamic> map) {
    return Facture(
      id: map['id'],
      clientId: map['client_id'],
      date: DateTime.parse(map['date']),
    );
  }
}

class Produit {
  final int? id;
  final String nom;
  final String description;
  final double prix;
  final int quantiteEnStock;
  final int fournisseurId;
  final DateTime creeA;

  Produit({
    this.id,
    required this.nom,
    required this.description,
    required this.prix,
    required this.quantiteEnStock,
    required this.fournisseurId,
    required this.creeA,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'nom': nom,
      'description': description,
      'prix': prix,
      'quantite_en_stock': quantiteEnStock,
      'fournisseur_id': fournisseurId,
      'cree_a': creeA.toIso8601String(),
    };
  }

  factory Produit.fromMap(Map<String, dynamic> map) {
    return Produit(
      id: map['id'],
      nom: map['nom'],
      description: map['description'],
      prix: map['prix'],
      quantiteEnStock: map['quantite_en_stock'],
      fournisseurId: map['fournisseur_id'],
      creeA: DateTime.parse(map['cree_a']),
    );
  }
}

class Client {
  final int? id;
  final String nom;
  final String adresse;
  final String telephone;
  final String email;
  final DateTime creeA;

  Client({
    this.id,
    required this.nom,
    required this.adresse,
    required this.telephone,
    required this.email,
    required this.creeA,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'nom': nom,
      'adresse': adresse,
      'telephone': telephone,
      'email': email,
      'cree_a': creeA.toIso8601String(),
    };
  }

  factory Client.fromMap(Map<String, dynamic> map) {
    return Client(
      id: map['id'],
      nom: map['nom'],
      adresse: map['adresse'],
      telephone: map['telephone'],
      email: map['email'],
      creeA: DateTime.parse(map['cree_a']),
    );
  }
}

class Fournisseur {
  final int? id;
  final String nom;
  final String adresse;
  final String telephone;
  final String email;
  final DateTime cree_a;

  Fournisseur({
    this.id,
    required this.nom,
    required this.adresse,
    required this.telephone,
    required this.email,
    required this.cree_a,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'nom': nom,
      'adresse': adresse,
      'telephone': telephone,
      'email': email,
      'cree_a': cree_a.toIso8601String(),
    };
  }

  factory Fournisseur.fromMap(Map<String, dynamic> map) {
    return Fournisseur(
      id: map['id'],
      nom: map['nom'],
      adresse: map['adresse'],
      telephone: map['telephone'],
      email: map['email'],
      cree_a: DateTime.parse(map['cree_a']),
    );
  }
}

class FactureAvecClient {
  final int id;
  final idClient;
  final String nomClient;
  final DateTime date;
  final List<ProduitFacture> produits;

  FactureAvecClient({
    required this.id,
    required this.idClient,
    required this.nomClient,
    required this.date,
    required this.produits,
  });
}

class ProduitFacture {
  final int produitId;
  final String nomProduit;
  final int quantite;
  final double prixUnitaire;

  ProduitFacture({
    required this.produitId,
    required this.nomProduit,
    required this.quantite,
    required this.prixUnitaire,
  });
}
