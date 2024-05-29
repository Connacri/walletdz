// import 'package:flutter/material.dart';
// import 'package:provider/provider.dart';
//
// import 'FournisseurProvider.dart';
//
// class FournisseurScreen extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text('Fournisseurs'),
//       ),
//       body: Consumer<FournisseurProvider>(
//         builder: (context, fournisseurProvider, child) {
//           return ListView.builder(
//             itemCount: fournisseurProvider.fournisseurs.length,
//             itemBuilder: (context, index) {
//               final fournisseur = fournisseurProvider.fournisseurs[index];
//               return ListTile(
//                 title: Text(fournisseur.nom),
//                 subtitle: Text(fournisseur.adresse),
//                 onTap: () {
//                   // Afficher les détails du fournisseur
//                 },
//               );
//             },
//           );
//         },
//       ),
//       floatingActionButton: FloatingActionButton(
//         onPressed: () {
//           // Ajouter un nouveau fournisseur
//         },
//         child: Icon(Icons.add),
//       ),
//     );
//   }
// }

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'FournisseurProvider.dart';

class FournisseurScreen extends StatefulWidget {
  @override
  _FournisseurScreenState createState() => _FournisseurScreenState();
}

class _FournisseurScreenState extends State<FournisseurScreen> {
  @override
  void initState() {
    super.initState();
    // Appel de fetchFournisseurs lors de la création de l'écran
    Provider.of<FournisseurProvider>(context, listen: false)
        .fetchFournisseurs();
  }

  @override
  Widget build(BuildContext context) {
    // Construire l'écran en utilisant les fournisseurs récupérés
    return Scaffold(
      appBar: AppBar(
        title: Text('Fournisseurs'),
      ),
      body: Consumer<FournisseurProvider>(
        builder: (context, fournisseurProvider, child) {
          return ListView.builder(
            itemCount: fournisseurProvider.fournisseurs.length,
            itemBuilder: (context, index) {
              final fournisseur = fournisseurProvider.fournisseurs[index];
              return ListTile(
                title: Text(fournisseur.nom),
                subtitle: Text(fournisseur.adresse),
                onTap: () {
                  // Afficher les détails du fournisseur
                },
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Ajouter un nouveau fournisseur
        },
        child: Icon(Icons.add),
      ),
    );
  }
}
