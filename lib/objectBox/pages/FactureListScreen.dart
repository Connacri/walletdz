import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../objectbox.g.dart';
import '../Entity.dart';
import '../MyProviders.dart';
import '../Utils/QRViewExample.dart';
import '../classeObjectBox.dart';
import 'ProduitListScreen.dart';

class FacturePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final commerceProvider = Provider.of<CommerceProvider>(context);
    return Scaffold(
      appBar: AppBar(
        title: Text('Facture'),
        actions: [
          IconButton(
            icon: Icon(Icons.search),
            onPressed: () {
              showSearch(
                  context: context,
                  delegate: ProduitSearchDelegateMain(commerceProvider));
            },
          ),
          IconButton(
            icon: Icon(Icons.qr_code_scanner),
            onPressed: () async {
              final result = await Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => QRViewExample()),
              );
              if (result != null) {
                final produit = await commerceProvider.getProduitByQr(result);
                if (produit != null) {
                  Provider.of<CartProvider>(context, listen: false)
                      .addToCart(produit);
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Produit introuvable!'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              }
            },
          ),
          SizedBox(
            width: 100,
          )
        ],
      ),
      body: Consumer<CartProvider>(
        builder: (context, cartProvider, child) {
          final items = cartProvider.facture.lignesFacture;
          final totalAmount = cartProvider.totalAmount;
          final tva = totalAmount * 0.19; // TVA à 19%

          return Column(
            children: [
              Expanded(
                child: ListView.builder(
                  itemCount: items.length,
                  itemBuilder: (context, index) {
                    final ligneFacture = items[index];
                    final produit = ligneFacture.produit.target!;
                    return ListTile(
                      title: Text(produit.nom),
                      subtitle: Text(
                          'Prix: ${ligneFacture.prixUnitaire.toStringAsFixed(2)} DZD\nQuantité: ${ligneFacture.quantite}'),
                      trailing: IconButton(
                        icon: Icon(Icons.remove_shopping_cart),
                        onPressed: () {
                          cartProvider.removeFromCart(produit);
                        },
                      ),
                    );
                  },
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Total: ${totalAmount.toStringAsFixed(2)} DZD'),
                    Text('TVA (19%): ${tva.toStringAsFixed(2)} DZD'),
                    Text(
                        'Total TTC: ${(totalAmount + tva).toStringAsFixed(2)} DZD'),
                    SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: () {
                        cartProvider.saveFacture();
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Facture sauvegardée!')),
                        );
                      },
                      child: Text('Sauvegarder la facture'),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class FacturesListPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final factureBox = ObjectBox().factureBox;
    final List<Facture> factures = factureBox.getAll();

    return Scaffold(
      appBar: AppBar(
        title: Text('Liste des Factures'),
      ),
      body: factures.isEmpty
          ? Center(child: Text('Aucune facture trouvée'))
          : ListView.builder(
              itemCount: factures.length,
              itemBuilder: (context, index) {
                final facture = factures[index];
                return ListTile(
                  title: Text('Facture ${facture.id} - ${facture.date}'),
                  subtitle: Text(
                      'Total: ${_calculateTotal(facture).toStringAsFixed(2)} DZD'),
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) =>
                            FactureDetailPage(facture: facture),
                      ),
                    );
                  },
                );
              },
            ),
    );
  }

  double _calculateTotal(Facture facture) {
    return facture.lignesFacture
        .fold(0, (sum, item) => sum + item.prixUnitaire * item.quantite);
  }
}

class FactureDetailPage extends StatelessWidget {
  final Facture facture;

  FactureDetailPage({required this.facture});

  @override
  Widget build(BuildContext context) {
    final lignesFacture = facture.lignesFacture;

    return Scaffold(
      appBar: AppBar(
        title: Text('Détails de la Facture ${facture.id}'),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: lignesFacture.length,
              itemBuilder: (context, index) {
                final ligneFacture = lignesFacture[index];
                final produit = ligneFacture.produit.target!;
                return ListTile(
                  title: Text(produit.nom),
                  subtitle: Text(
                      'Prix: ${ligneFacture.prixUnitaire.toStringAsFixed(2)} DZD\nQuantité: ${ligneFacture.quantite}'),
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Total: ${_calculateTotal().toStringAsFixed(2)} DZD'),
                Text('TVA (19%): ${_calculateTVA().toStringAsFixed(2)} DZD'),
                Text(
                    'Total TTC: ${(_calculateTotal() + _calculateTVA()).toStringAsFixed(2)} DZD'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  double _calculateTotal() {
    return facture.lignesFacture
        .fold(0, (sum, item) => sum + item.prixUnitaire * item.quantite);
  }

  double _calculateTVA() {
    return _calculateTotal() * 0.19;
  }
}
