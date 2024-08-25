import 'package:objectbox/objectbox.dart';

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
  String? qr;
  String? image;
  String nom;
  String? description;
  String? origine;
  double prixAchat;
  double prixVente;
  double stock;
  double minimStock;
  double stockinit;
  int createdBy;
  int updatedBy;
  int deletedBy;

  @Property(type: PropertyType.date)
  DateTime? dateCreation;

  @Property(type: PropertyType.date)
  DateTime? datePeremption;

  @Property(type: PropertyType.date)
  DateTime? stockUpdate;

  @Property(type: PropertyType.date)
  DateTime derniereModification;

  @Backlink()
  final fournisseurs = ToMany<Fournisseur>();

  Produit({
    this.id = 0,
    this.qr,
    this.image,
    required this.nom,
    this.description,
    this.origine,
    required this.prixAchat,
    required this.prixVente,
    required this.stock,
    required this.minimStock,
    required this.createdBy,
    required this.updatedBy,
    required this.deletedBy,
    this.dateCreation,
    this.datePeremption,
    this.stockUpdate,
    required this.derniereModification,
    required this.stockinit,
  });
  factory Produit.fromJson(Map<String, dynamic> json) {
    return Produit(
      id: json['id'] ?? 0,
      qr: json['qr'],
      image: json['image'],
      nom: json['nom'] ?? '',
      description: json['description'] ?? '',
      origine: json['origine'] ?? '',
      prixAchat: (json['prixAchat'] ?? 0).toDouble(),
      prixVente: (json['prixVente'] ?? 0).toDouble(),
      stock: (json['stock'] ?? 0).toDouble(),
      minimStock: (json['minimStock'] ?? 0).toDouble(),
      createdBy: (json['createdBy']).toInt(),
      updatedBy: (json['updatedBy']).toInt(),
      deletedBy: (json['deletedBy']).toInt(),
      stockinit: (json['stockInit'] ?? 0).toDouble(),
      dateCreation: json['dateCreation'] != null
          ? DateTime.parse(json['dateCreation'])
          : null,
      datePeremption: json['datePeremption'] != null
          ? DateTime.parse(json['datePeremption'])
          : null,
      stockUpdate: json['stockUpdate'] != null
          ? DateTime.parse(json['stockUpdate'])
          : null,
      derniereModification: DateTime.parse(
          json['derniereModification'] //?? DateTime.now().toIso8601String()
          ),
    );
  }
}

@Entity()
class Fournisseur {
  int id;
  String? qr;
  String nom;
  String? phone;
  String? adresse;
  int createdBy;
  int updatedBy;
  int deletedBy;

  @Property(type: PropertyType.date)
  DateTime dateCreation;

  @Property(type: PropertyType.date)
  DateTime? derniereModification;

  final produits = ToMany<Produit>();

  Fournisseur({
    this.id = 0,
    this.qr,
    required this.nom,
    this.phone,
    this.adresse,
    required this.createdBy,
    required this.updatedBy,
    required this.deletedBy,
    required this.dateCreation,
    required this.derniereModification,
  });
  factory Fournisseur.fromJson(Map<String, dynamic> json) {
    return Fournisseur(
      id: json['id'] ?? 0,
      qr: json['qr'],
      nom: json['nom'] ?? '',
      phone: json['phone'],
      adresse: json['adresse'],
      createdBy: (json['createdBy']).toInt(),
      updatedBy: (json['updatedBy']).toInt(),
      deletedBy: (json['deletedBy']).toInt(),
      dateCreation: DateTime.parse(json['dateCreation']),
      derniereModification: DateTime.parse(
          json['derniereModification'] ?? DateTime.now().toIso8601String()),
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
  String description;
  int createdBy;
  int updatedBy;
  int deletedBy;
  @Property(type: PropertyType.date)
  DateTime? dateCreation;

  @Property(type: PropertyType.date)
  DateTime? derniereModification;

  @Backlink()
  final factures = ToMany<Facture>();

  Client({
    this.id = 0,
    required this.qr,
    required this.nom,
    required this.phone,
    required this.adresse,
    required this.description,
    required this.createdBy,
    required this.updatedBy,
    required this.deletedBy,
    this.dateCreation,
    this.derniereModification,
  });
  factory Client.fromJson(Map<String, dynamic> json) {
    return Client(
      id: json['id'] ?? 0,
      qr: json['qr'] ?? '',
      nom: json['nom'] ?? '',
      phone: json['phone'] ?? '',
      adresse: json['adresse'] ?? '',
      description: json['description'] ?? '',
      createdBy: (json['createdBy']).toInt(),
      updatedBy: (json['updatedBy']).toInt(),
      deletedBy: (json['deletedBy']).toInt(),
      dateCreation: json['dateCreation'] != null
          ? DateTime.parse(json['dateCreation'])
          : null,
      derniereModification: json['derniereModification'] != null
          ? DateTime.parse(json['derniereModification'])
          : null,
    );
  }
}

@Entity()
class Facture {
  int id;
  String qr;
  double? impayer;
  int createdBy;
  int updatedBy;
  int deletedBy;
  @Property(type: PropertyType.date)
  DateTime date;

  final client = ToOne<Client>();

  @Backlink()
  final lignesFacture = ToMany<LigneFacture>();

  Facture({
    this.id = 0,
    required this.date,
    required this.qr,
    required this.impayer,
    required this.createdBy,
    required this.updatedBy,
    required this.deletedBy,
  });
  factory Facture.fromJson(Map<String, dynamic> json) {
    return Facture(
      id: json['id'] ?? 0,
      qr: json['qr'] ?? '',
      impayer: (json['impayer'] ?? 0).toDouble(),
      date: DateTime.parse(json['date']),
      createdBy: (json['createdBy']).toInt(),
      updatedBy: (json['updatedBy']).toInt(),
      deletedBy: (json['deletedBy']).toInt(),
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

  int createdBy;
  int updatedBy;
  int deletedBy;
  DateTime deletedAt;

  DeletedProduct({
    required this.name,
    required this.description,
    required this.price,
    required this.quantity,
    required this.deletedAt,
    required this.createdBy,
    required this.updatedBy,
    required this.deletedBy,
  });
  factory DeletedProduct.fromJson(Map<String, dynamic> json) {
    return DeletedProduct(
      name: json['name'] ?? '',
      description: json['description'] ?? '',
      price: (json['price'] ?? 0).toDouble(),
      quantity: (json['quantity'] ?? 0).toInt(),
      deletedAt: DateTime.parse(json['deletedAt']),
      createdBy: (json['createdBy']).toInt(),
      updatedBy: (json['updatedBy']).toInt(),
      deletedBy: (json['deletedBy']).toInt(),
    );
  }
}
