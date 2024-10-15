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
  DateTime derniereModification;

  final crud = ToOne<Crud>();
  User({
    this.id = 0,
    this.photo,
    required this.username,
    required this.password,
    this.phone,
    required this.email,
    required this.role,
    required this.derniereModification,
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
      derniereModification: json['derniereModification'] != null
          ? DateTime.fromMillisecondsSinceEpoch(json['derniereModification'])
          : DateTime.now(),
    );
  }
}

@Entity()
class QrCode {
  @Id()
  int id;
  String serial;
  String? type;

  QrCode({
    this.id = 0,
    required this.serial,
    this.type,
  });

  factory QrCode.fromJson(Map<String, dynamic> json) {
    return QrCode(
      id: json['id'] ?? 0,
      serial: json['serial'] ?? '',
      type: json['type'],
    );
  }
}

@Entity()
class Produit {
  int id;
  @Unique()
  @Index() // Indexation du QR pour une recherche rapide
  String? qr; // Stocker les QR codes comme une chaîne avec des séparateurs
  String? image;
  String nom;
  String? description;
  double prixVente;
  double? qtyPartiel;
  double? pricePartielVente;
  double? minimStock;
  int? alertPeremption;
  @Property(type: PropertyType.date)
  DateTime derniereModification;

  @Backlink()
  final approvisionnements = ToMany<Approvisionnement>();
  // Correction : renommage de la relation ToMany<QrCode>

  final qrcodes = ToMany<QrCode>();
  final crud = ToOne<Crud>();

  Produit({
    this.id = 0,
    this.qr,
    this.image,
    required this.nom,
    this.description,
    required this.prixVente,
    this.qtyPartiel,
    this.pricePartielVente,
    this.minimStock,
    this.alertPeremption,
    required this.derniereModification,
  });
  // // Getters pour calculer les valeurs dynamiques
  // double get prixAchat => approvisionnements.isNotEmpty
  //     ? approvisionnements.map((a) => a.prixAchat).reduce((a, b) => a + b) /
  //         approvisionnements.length
  //     : 0;
// Getter pour récupérer les QR codes sous forme de liste
  List<String> get qrCodeList {
    return qr != null && qr!.isNotEmpty ? qr!.split(',') : [];
  }

  // Setter pour mettre à jour les QR codes
  set qrCodeList(List<String> codes) {
    qr = codes.join(',');
  }

  // // Getter pour récupérer la liste des QR codes sous forme de liste
  // List<String> get qrCodeList {
  //   return qr != null && qr!.isNotEmpty ? List<String>.from(json.decode(qr!)) : [];
  // }
  //
  // // Setter pour mettre à jour les QR codes dans le format JSON
  // set qrCodeList(List<String> codes) {
  //   qr = json.encode(codes);
  // }
  // Méthode pour ajouter un QR code à la liste existante
  void addQrCode(String code) {
    List<String> codes = qrCodeList;
    codes.add(code);
    qrCodeList = codes; // Met à jour la chaîne JSON avec la nouvelle liste
  }

  double get stock => approvisionnements.fold(0, (sum, a) => sum + a.quantite);
// Méthode pour calculer le stock total à partir des approvisionnements
  double calculerStockTotal() {
    // Si la liste des approvisionnements est vide, retourne 0
    if (approvisionnements.isEmpty) {
      return 0.0;
    }

    // Utilise fold() pour calculer la somme des quantités d'approvisionnement
    double stockTotal = approvisionnements.fold(0.0, (total, appro) {
      return total + appro.quantite;
    });

    return stockTotal;
  }

  factory Produit.fromJson(Map<String, dynamic> json) {
    return Produit(
      id: json['id'] ?? 0,
      qr: json['qr'],
      image: json['image'],
      nom: json['nom'] ?? '',
      description: json['description'] ?? '',
      prixVente: (json['prixVente'] ?? 0).toDouble(),
      qtyPartiel: (json['qtyPartiel'] ?? 0).toDouble(),
      pricePartielVente: (json['pricePartielVente'] ?? 0.0).toDouble(),
      minimStock: (json['minimStock'] ?? 0).toDouble(),
      alertPeremption: (json['alertPeremption'] ?? 0).toInt(),
      derniereModification: json['derniereModification'] != null
          ? DateTime.fromMillisecondsSinceEpoch(json['derniereModification'])
          : DateTime.now(),
    );
  }
}

@Entity()
class Approvisionnement {
  int id;
  double quantite;

  double? prixAchat;
  DateTime? derniereModification;

  @Property(type: PropertyType.date)
  DateTime? datePeremption;

  final produit = ToOne<Produit>();

  // Relation vers l'entité Fournisseur
  final fournisseur = ToOne<Fournisseur>();
  final crud = ToOne<Crud>();

  Approvisionnement({
    this.id = 0,
    required this.quantite,
    this.prixAchat,
    this.datePeremption,
    this.derniereModification,
  });

  factory Approvisionnement.fromJson(Map<String, dynamic> json) {
    return Approvisionnement(
      id: json['id'] ?? 0,
      quantite: (json['quantite'] ?? 0).toDouble(),
      prixAchat: (json['prixAchat'] ?? 0).toDouble(),
      datePeremption: json['datePeremption'] != null
          ? DateTime.parse(json['datePeremption'])
          : null,
      derniereModification: json['derniereModification'] != null
          ? DateTime.fromMillisecondsSinceEpoch(json['derniereModification'])
          : DateTime.now(),
    );
  }
}

@Entity()
class Crud {
  int id;
  int? createdBy;
  int updatedBy;
  int? deletedBy;

  @Property(type: PropertyType.date)
  DateTime? dateCreation;

  @Property(type: PropertyType.date)
  DateTime derniereModification;

  @Property(type: PropertyType.date)
  DateTime? dateDeleting;

  Crud({
    this.id = 0,
    this.createdBy,
    required this.updatedBy,
    this.deletedBy,
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
class Fournisseur {
  int id;
  @Unique()
  String? qr;
  String nom;
  String? phone;
  String? adresse;
  DateTime derniereModification;

  final crud = ToOne<Crud>();

  @Backlink()
  final approvisionnements = ToMany<Approvisionnement>();

  Fournisseur({
    this.id = 0,
    this.qr,
    required this.nom,
    this.phone,
    this.adresse,
    required this.derniereModification,
  });
  factory Fournisseur.fromJson(Map<String, dynamic> json) {
    return Fournisseur(
      id: json['id'] ?? 0,
      qr: json['qr'],
      nom: json['nom'] ?? '',
      phone: json['phone'],
      adresse: json['adresse'],
      derniereModification: json['derniereModification'] != null
          ? DateTime.fromMillisecondsSinceEpoch(json['derniereModification'])
          : DateTime.now(),
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
  DateTime derniereModification;

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
    required this.derniereModification,
  });
  factory Client.fromJson(Map<String, dynamic> json) {
    return Client(
      id: json['id'] ?? 0,
      qr: json['qr'] ?? '',
      nom: json['nom'] ?? '',
      phone: json['phone'] ?? '',
      adresse: json['adresse'] ?? '',
      description: json['description'] ?? '',
      derniereModification: json['derniereModification'] != null
          ? DateTime.fromMillisecondsSinceEpoch(json['derniereModification'])
          : DateTime.now(),
    );
  }
}

@Entity()
class Facture {
  int id;
  String qr;
  double? impayer;
  DateTime derniereModification;

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
    required this.derniereModification,
  });
  factory Facture.fromJson(Map<String, dynamic> json) {
    return Facture(
      id: json['id'] ?? 0,
      qr: json['qr'] ?? '',
      impayer: (json['impayer'] ?? 0).toDouble(),
      date: DateTime.parse(json['date']),
      derniereModification: json['derniereModification'] != null
          ? DateTime.fromMillisecondsSinceEpoch(json['derniereModification'])
          : DateTime.now(),
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
  DateTime derniereModification;

  LigneFacture({
    this.id = 0,
    required this.quantite,
    required this.prixUnitaire,
    required this.derniereModification,
  });
  factory LigneFacture.fromJson(Map<String, dynamic> json) {
    return LigneFacture(
      id: json['id'] ?? 0,
      quantite: (json['quantite'] ?? 0).toDouble(),
      prixUnitaire: (json['prixUnitaire'] ?? 0).toDouble(),
      derniereModification: json['derniereModification'] != null
          ? DateTime.fromMillisecondsSinceEpoch(json['derniereModification'])
          : DateTime.now(),
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
  DateTime derniereModification;

  final crud = ToOne<Crud>();

  DeletedProduct({
    required this.name,
    required this.description,
    required this.price,
    required this.quantity,
    required this.delaisPeremption,
    required this.derniereModification,
  });
  factory DeletedProduct.fromJson(Map<String, dynamic> json) {
    return DeletedProduct(
      name: json['name'] ?? '',
      description: json['description'] ?? '',
      price: (json['price'] ?? 0).toDouble(),
      quantity: (json['quantity'] ?? 0).toInt(),
      delaisPeremption: (json['delaisPeremption']).toInt(),
      derniereModification: json['derniereModification'] != null
          ? DateTime.fromMillisecondsSinceEpoch(json['derniereModification'])
          : DateTime.now(),
    );
  }
}
