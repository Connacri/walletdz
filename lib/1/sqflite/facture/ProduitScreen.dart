import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:provider/provider.dart';

import 'ProduitProvider.dart';

class ProduitScreen extends StatefulWidget {
  @override
  State<ProduitScreen> createState() => _ProduitScreenState();
}

class _ProduitScreenState extends State<ProduitScreen> {
  @override
  void initState() {
    super.initState();
    // Appel de fetchFournisseurs lors de la création de l'écran
    Provider.of<ProduitProvider>(context, listen: false).fetchProduits();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Produits'),
      ),
      body: Consumer<ProduitProvider>(
        builder: (context, produitProvider, child) {
          return produitProvider.produits.isNotEmpty
              ? ListView.builder(
                  itemCount: produitProvider.produits.length,
                  itemBuilder: (context, index) {
                    final produit = produitProvider.produits[index];
                    return ListTile(
                      title: Text(produit.nom),
                      subtitle: Text(produit.description),
                      trailing: Text(produit.prix.toStringAsFixed(2)),
                      onTap: () {
                        // Afficher les détails du produit
                      },
                    );
                  },
                )
              : Center(
                  child: Lottie.asset(
                    "assets/lotties/1 (83).json",
                    fit: BoxFit.contain,
                  ),
                  //Text('Aucun produit disponible'),
                );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Ajouter un nouveau produit
        },
        child: Icon(Icons.add),
      ),
    );
  }
}
