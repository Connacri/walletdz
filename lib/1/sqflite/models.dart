class Categorie {
  int? idCategorie;
  String name;

  Categorie({this.idCategorie, required this.name});

  Map<String, dynamic> toMap() {
    return {
      'id_categorie': idCategorie,
      'name': name,
    };
  }

  static Categorie fromMap(Map<String, dynamic> map) {
    return Categorie(
      idCategorie: map['id_categorie'],
      name: map['name'],
    );
  }
}

class Fournisseur {
  int? idFournisseur;
  String nom;
  String contact;

  Fournisseur({this.idFournisseur, required this.nom, required this.contact});

  Map<String, dynamic> toMap() {
    return {
      'id_fournisseur': idFournisseur,
      'nom': nom,
      'contact': contact,
    };
  }

  static Fournisseur fromMap(Map<String, dynamic> map) {
    return Fournisseur(
      idFournisseur: map['id_fournisseur'],
      nom: map['nom'],
      contact: map['contact'],
    );
  }
}

class Produit {
  int? idProduit;
  String name;
  double prixAchat;
  double prixVente;
  DateTime derniereModification;
  String photo;
  int idCategorie;

  Produit({
    this.idProduit,
    required this.name,
    required this.prixAchat,
    required this.prixVente,
    required this.derniereModification,
    required this.photo,
    required this.idCategorie,
  });

  Map<String, dynamic> toMap() {
    return {
      'id_produit': idProduit,
      'name': name,
      'prixAchat': prixAchat,
      'prixVente': prixVente,
      'derniereModification': derniereModification.toIso8601String(),
      'photo': photo,
      'id_categorie': idCategorie,
    };
  }

  static Produit fromMap(Map<String, dynamic> map) {
    return Produit(
      idProduit: map['id_produit'],
      name: map['name'],
      prixAchat: map['prixAchat'],
      prixVente: map['prixVente'],
      derniereModification: DateTime.parse(map['derniereModification']),
      photo: map['photo'],
      idCategorie: map['id_categorie'],
    );
  }
}

class FournisseurProduit {
  int idFournisseur;
  int idProduit;
  int quantity_produit;

  FournisseurProduit({
    required this.idFournisseur,
    required this.idProduit,
    required this.quantity_produit,
  });

  Map<String, dynamic> toMap() {
    return {
      'id_fournisseur': idFournisseur,
      'id_produit': idProduit,
      'quantity_produit': quantity_produit,
    };
  }

  static FournisseurProduit fromMap(Map<String, dynamic> map) {
    return FournisseurProduit(
      idFournisseur: map['id_fournisseur'],
      idProduit: map['id_produit'],
      quantity_produit: map['quantity_produit'],
    );
  }
}

class Client {
  int? idClient;
  String nom;
  String telephone;

  Client({this.idClient, required this.nom, required this.telephone});

  Map<String, dynamic> toMap() {
    return {
      'id_client': idClient,
      'nom': nom,
      'telephone': telephone,
    };
  }

  static Client fromMap(Map<String, dynamic> map) {
    return Client(
      idClient: map['id_client'],
      nom: map['nom'],
      telephone: map['telephone'],
    );
  }
}

class Facture {
  int? idFacture;
  String numero;
  DateTime date;
  int idClient;

  Facture({
    this.idFacture,
    required this.numero,
    required this.date,
    required this.idClient,
  });

  Map<String, dynamic> toMap() {
    return {
      'id_facture': idFacture,
      'numero': numero,
      'date': date.toIso8601String(),
      'id_client': idClient,
    };
  }

  static Facture fromMap(Map<String, dynamic> map) {
    return Facture(
      idFacture: map['id_facture'],
      numero: map['numero'],
      date: DateTime.parse(map['date']),
      idClient: map['id_client'],
    );
  }
}

class FactureProduit {
  int idFacture;
  int idProduit;
  double prixVente;
  int quantity;

  FactureProduit({
    required this.idFacture,
    required this.idProduit,
    required this.prixVente,
    required this.quantity,
  });

  Map<String, dynamic> toMap() {
    return {
      'id_facture': idFacture,
      'id_produit': idProduit,
      'prixVente': prixVente,
      'quantity': quantity,
    };
  }

  static FactureProduit fromMap(Map<String, dynamic> map) {
    return FactureProduit(
      idFacture: map['id_facture'],
      idProduit: map['id_produit'],
      prixVente: map['prixVente'],
      quantity: map['quantity'],
    );
  }
}
