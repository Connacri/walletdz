import 'package:objectbox/objectbox.dart';

///toDo///
///delaisPeremption
///le produit peut avoir plusieurs qty et plusieurs prix et plusieur delaisPeremption

@Entity()
class User {
  @Id()
  int id;
  String? photo;
  String username;
  String password;
  String email;
  String? phone;
  String role;

  final crud = ToOne<Crud>();
  User({
    this.id = 0,
    this.photo,
    required this.username,
    required this.password,
    this.phone,
    required this.email,
    required this.role,
  });
  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] ?? 0,
      photo: json['photo'],
      username: json['username'] ?? '',
      password: json['password'] ?? '',
      email: json['email'] ?? '',
      phone: json['phone'],
      role: json['role'] ?? '',
    );
  }
}

@Entity()
class Produit {
  int id;
  @Unique()
  String? qr;
  String? image;
  String nom;
  String? description;
  double prixVente;
  double minimStock;
  int alertPeremption;

  @Backlink()
  final approvisionnements = ToMany<Approvisionnement>();

  final crud = ToOne<Crud>();

  Produit({
    this.id = 0,
    this.qr,
    this.image,
    required this.nom,
    this.description,
    required this.prixVente,
    required this.minimStock,
    required this.alertPeremption,
  });
  // // Getters pour calculer les valeurs dynamiques
  // double get prixAchat => approvisionnements.isNotEmpty
  //     ? approvisionnements.map((a) => a.prixAchat).reduce((a, b) => a + b) /
  //         approvisionnements.length
  //     : 0;

  double get stock => approvisionnements.fold(0, (sum, a) => sum + a.quantite);

  factory Produit.fromJson(Map<String, dynamic> json) {
    return Produit(
      id: json['id'] ?? 0,
      qr: json['qr'],
      image: json['image'],
      nom: json['nom'] ?? '',
      description: json['description'] ?? '',
      prixVente: (json['prixVente'] ?? 0).toDouble(),
      minimStock: (json['minimStock'] ?? 0).toDouble(),
      alertPeremption: (json['alertPeremption']).toInt(),
    );
  }
}

@Entity()
class Crud {
  int id;
  int createdBy;
  int updatedBy;
  int deletedBy;

  @Property(type: PropertyType.date)
  DateTime? dateCreation;

  @Property(type: PropertyType.date)
  DateTime derniereModification;

  @Property(type: PropertyType.date)
  DateTime? dateDeleting;

  Crud({
    this.id = 0,
    required this.createdBy,
    required this.updatedBy,
    required this.deletedBy,
    this.dateCreation,
    required this.derniereModification,
    this.dateDeleting,
  });
  factory Crud.fromJson(Map<String, dynamic> json) {
    return Crud(
      id: json['id'] ?? 0,
      createdBy: (json['createdBy']).toInt(),
      updatedBy: (json['updatedBy']).toInt(),
      deletedBy: (json['deletedBy']).toInt(),
      dateCreation: json['dateCreation'] != null
          ? DateTime.parse(json['dateCreation'])
          : null,
      dateDeleting: json['dateDeleting'] != null
          ? DateTime.parse(json['dateDeleting'])
          : null,
      derniereModification: DateTime.parse(
          json['derniereModification'] //?? DateTime.now().toIso8601String()
          ),
    );
  }
}

@Entity()
class Approvisionnement {
  int id;
  double quantite;
  double prixAchat;

  @Property(type: PropertyType.date)
  DateTime? datePeremption;

  final produit = ToOne<Produit>();
  final fournisseur = ToOne<Fournisseur>();
  final crud = ToOne<Crud>();

  Approvisionnement({
    this.id = 0,
    required this.quantite,
    required this.prixAchat,
    this.datePeremption,
  });

  factory Approvisionnement.fromJson(Map<String, dynamic> json) {
    return Approvisionnement(
      id: json['id'] ?? 0,
      quantite: (json['quantite'] ?? 0).toDouble(),
      prixAchat: (json['prixAchat'] ?? 0).toDouble(),
      datePeremption: json['datePeremption'] != null
          ? DateTime.parse(json['datePeremption'])
          : null,
    );
  }
}

@Entity()
class Fournisseur {
  int id;
  @Unique()
  String? qr;
  String nom;
  String? phone;
  String? adresse;

  final crud = ToOne<Crud>();

  @Backlink()
  final approvisionnements = ToMany<Approvisionnement>();

  Fournisseur({
    this.id = 0,
    this.qr,
    required this.nom,
    this.phone,
    this.adresse,
  });
  factory Fournisseur.fromJson(Map<String, dynamic> json) {
    return Fournisseur(
      id: json['id'] ?? 0,
      qr: json['qr'],
      nom: json['nom'] ?? '',
      phone: json['phone'],
      adresse: json['adresse'],
    );
  }
}

@Entity()
class Client {
  int id;
  String qr;
  String nom;
  String phone;
  String adresse;
  String? description;

  @Backlink()
  final factures = ToMany<Facture>();

  final crud = ToOne<Crud>();

  Client({
    this.id = 0,
    required this.qr,
    required this.nom,
    required this.phone,
    required this.adresse,
    this.description,
  });
  factory Client.fromJson(Map<String, dynamic> json) {
    return Client(
      id: json['id'] ?? 0,
      qr: json['qr'] ?? '',
      nom: json['nom'] ?? '',
      phone: json['phone'] ?? '',
      adresse: json['adresse'] ?? '',
      description: json['description'] ?? '',
    );
  }
}

@Entity()
class Facture {
  int id;
  String qr;
  double? impayer;

  @Property(type: PropertyType.date)
  DateTime date;

  final client = ToOne<Client>();
  final crud = ToOne<Crud>();
  @Backlink()
  final lignesFacture = ToMany<LigneFacture>();

  Facture({
    this.id = 0,
    required this.date,
    required this.qr,
    required this.impayer,
  });
  factory Facture.fromJson(Map<String, dynamic> json) {
    return Facture(
      id: json['id'] ?? 0,
      qr: json['qr'] ?? '',
      impayer: (json['impayer'] ?? 0).toDouble(),
      date: DateTime.parse(json['date']),
    );
  }
}

@Entity()
class LigneFacture {
  int id;
  final produit = ToOne<Produit>();
  final facture = ToOne<Facture>();
  double quantite;
  double prixUnitaire;

  LigneFacture({
    this.id = 0,
    required this.quantite,
    required this.prixUnitaire,
  });
  factory LigneFacture.fromJson(Map<String, dynamic> json) {
    return LigneFacture(
      id: json['id'] ?? 0,
      quantite: (json['quantite'] ?? 0).toDouble(),
      prixUnitaire: (json['prixUnitaire'] ?? 0).toDouble(),
    );
  }
}

@Entity()
class DeletedProduct {
  @Id()
  int id = 0;

  String name;
  String description;
  double price;
  int quantity;
  int delaisPeremption;

  final crud = ToOne<Crud>();

  DeletedProduct({
    required this.name,
    required this.description,
    required this.price,
    required this.quantity,
    required this.delaisPeremption,
  });
  factory DeletedProduct.fromJson(Map<String, dynamic> json) {
    return DeletedProduct(
      name: json['name'] ?? '',
      description: json['description'] ?? '',
      price: (json['price'] ?? 0).toDouble(),
      quantity: (json['quantity'] ?? 0).toInt(),
      delaisPeremption: (json['delaisPeremption']).toInt(),
    );
  }
}
