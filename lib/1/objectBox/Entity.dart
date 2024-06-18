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
  int stock;

  @Backlink()
  final fournisseurs = ToMany<Fournisseur>();

  Produit(
      {this.id = 0,
      this.qr,
      this.image,
      required this.nom,
      this.description,
      required this.prixAchat,
      required this.prixVente,
      required this.stock});
}

@Entity()
class Fournisseur {
  int id;
  String? qr;
  String nom;
  String? phone;
  String? adresse;

  final produits = ToMany<Produit>();

  Fournisseur(
      {this.id = 0, this.qr, required this.nom, this.phone, this.adresse});
}

// @Entity()
// class ProduitFournisseur {
//   int id;
//   final produit = ToOne<Produit>();
//   final fournisseur = ToOne<Fournisseur>();
//
//   ProduitFournisseur({
//     this.id = 0,
//     required ToOne<Produit> produit,
//     required ToOne<Fournisseur> fournisseur,
//   });
// }
//
// @Entity()
// class Client {
//   int id;
//   String qr;
//   String nom;
//   String phone;
//   String adresse;
//   String description;
//   double impayer;
//
//   @Backlink()
//   final factures = ToMany<Facture>();
//
//   Client(
//       {this.id = 0,
//       required this.qr,
//       required this.nom,
//       required this.phone,
//       required this.adresse,
//       required this.description,
//       required this.impayer});
// }
//
// @Entity()
// class Facture {
//   int id;
//   String qr;
//   DateTime date;
//   final client = ToOne<Client>();
//
//   @Backlink()
//   final lignes = ToMany<Produit>();
//
//   Facture({
//     this.id = 0,
//     required this.date,
//     required this.qr,
//   });
// }

// @Entity()
// class LigneFacture {
//   int id;
//   final produit = ToOne<Produit>();
//   final facture = ToOne<Facture>();
//   int quantite;
//   double prixUnitaire;
//
//   LigneFacture(
//       {this.id = 0, required this.quantite, required this.prixUnitaire});
// }
