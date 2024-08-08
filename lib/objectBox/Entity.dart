import 'package:objectbox/objectbox.dart';

@Entity()
class Produit {
  int id;
  String? qr;
  String? image;
  String nom;
  String? description;
  double prixAchat;
  double prixVente;
  double stock;
  double minimStock;
  double stockinit;

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
    required this.prixAchat,
    required this.prixVente,
    required this.stock,
    required this.minimStock,
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
      description: json['description'],
      prixAchat: (json['prixachat'] ?? 0).toDouble(),
      prixVente: (json['prixvente'] ?? 0).toDouble(),
      stock: (json['stock'] ?? 0).toDouble(),
      minimStock: (json['minimstock'] ?? 0).toDouble(),
      stockinit: (json['stockinit'] ?? 0).toDouble(),
      dateCreation: json['datecreation'] != null
          ? DateTime.parse(json['datecreation'])
          : null,
      datePeremption: json['dateperemption'] != null
          ? DateTime.parse(json['dateperemption'])
          : null,
      stockUpdate: json['stockupdate'] != null
          ? DateTime.parse(json['stockupdate'])
          : null,
      derniereModification: DateTime.parse(
          json['dernieremodification'] //?? DateTime.now().toIso8601String()
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
      dateCreation: DateTime.parse(json['datecreation']),
      derniereModification: DateTime.parse(
          json['dernieremodification'] ?? DateTime.now().toIso8601String()),
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
  double? impayer;
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
    this.impayer,
    this.dateCreation,
    this.derniereModification,
  });
}

@Entity()
class Facture {
  int id;
  String qr;

  @Property(type: PropertyType.date)
  DateTime date;

  final client = ToOne<Client>();

  @Backlink()
  final lignesFacture = ToMany<LigneFacture>();

  Facture({
    this.id = 0,
    required this.date,
    required this.qr,
  });
}

@Entity()
class LigneFacture {
  int id;
  final produit = ToOne<Produit>();
  final facture = ToOne<Facture>();
  int quantite;
  double prixUnitaire;

  LigneFacture({
    this.id = 0,
    required this.quantite,
    required this.prixUnitaire,
  });
}
