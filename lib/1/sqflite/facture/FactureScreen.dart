import 'package:flutter/material.dart';
import 'package:http/http.dart';
import 'package:provider/provider.dart';

import 'DetailFactureScreen.dart';
import 'FactureProvider.dart';
//
// class FactureScreen extends StatefulWidget {
//   @override
//   State<FactureScreen> createState() => _FactureScreenState();
// }
//
// class _FactureScreenState extends State<FactureScreen> {
//   @override
//   void initState() {
//     super.initState();
//     // Appel de fetchFactures lors de la création de l'écran
//     WidgetsBinding.instance.addPostFrameCallback((_) {
//       Provider.of<FactureProvider>(context, listen: false).fetchFactures();
//     });
//
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text('Factures'),
//       ),
//       body: Consumer<FactureProvider>(
//         builder: (context, factureProvider, child) {
//           return ListView.builder(
//             itemCount: factureProvider.factures.length,
//             itemBuilder: (context, index) {
//               final facture = factureProvider.factures[index];
//               // final client = factureProvider.clients[index];
//
//               return ListTile(
//                 title: Text('Facture ${facture['id']}'),
//                 subtitle: Text('Client Name: ${facture['clients_nom']}'),
//                 onTap: () {
//                   Navigator.of(context).push(MaterialPageRoute(
//                     builder: (ctx) => DetailFactureScreen(
//                       factureId: facture['id'],
//                     ),
//                   ));
//                 },
//               );
//             },
//           );
//         },
//       ),
//       floatingActionButton: FloatingActionButton(
//         onPressed: () {
//           // Ajouter une nouvelle facture
//         },
//         child: Icon(Icons.add),
//       ),
//     );
//   }
// }

class FactureScreen extends StatefulWidget {
  @override
  State<FactureScreen> createState() => _FactureScreenState();
}

class _FactureScreenState extends State<FactureScreen> {
  @override
  void initState() {
    super.initState();
    // Récupérer les factures avec les noms des clients au chargement du widget
    Provider.of<FactureProvider>(context, listen: false)
        .obtenirFacturesAvecClients();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Consumer<FactureProvider>(
        builder: (context, factureProvider, child) {
          return ListView.builder(
            itemCount: factureProvider.factures.length,
            itemBuilder: (context, index) {
              final facture = factureProvider.factures[index];
              double total = 0.0;
              for (var produit in facture.produits) {
                double montant = produit.quantite * produit.prixUnitaire;
                total += montant;
              }
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ListTile(
                    onTap: () {
                      Navigator.of(context).push(MaterialPageRoute(
                        builder: (ctx) => DetailFactureScreen(
                          factureId: facture.id,
                          idClient: facture.idClient,
                          nomClient: facture.nomClient,
                        ),
                      ));
                    },
                    leading: CircleAvatar(
                      child: Text('${facture.id}'),
                    ),
                    title: Text(
                      '${facture.nomClient}',
                      overflow: TextOverflow.ellipsis,
                    ),
                    subtitle: Text('${facture.date}'),
                    trailing: Text(
                      '${total.toStringAsFixed(2)}',
                      style: TextStyle(fontSize: 20),
                    ),
                  ),
                  // Divider(),
                  // ListView.builder(
                  //   shrinkWrap: true,
                  //   physics: NeverScrollableScrollPhysics(),
                  //   itemCount: facture.produits.length,
                  //   itemBuilder: (context, produitIndex) {
                  //     final produit = facture.produits[produitIndex];
                  //     double montant = produit.quantite * produit.prixUnitaire;
                  //     total += montant;
                  //     print(total);
                  //     return ListTile(
                  //         title: Text(produit.nomProduit),
                  //         subtitle: Row(
                  //           mainAxisAlignment: MainAxisAlignment.start,
                  //           children: [
                  //             Text(
                  //                 'U: ${produit.prixUnitaire.toStringAsFixed(2)}'),
                  //             SizedBox(
                  //               width: 10,
                  //             ),
                  //             Text('Qty: ${produit.quantite}'),
                  //           ],
                  //         ),
                  //         trailing: Text(
                  //           '${(produit.quantite * produit.prixUnitaire).toStringAsFixed(2)}',
                  //           style: TextStyle(fontSize: 20),
                  //         ));
                  //   },
                  // ),
                ],
              );
            },
          );
        },
      ),
    );
  }
}
