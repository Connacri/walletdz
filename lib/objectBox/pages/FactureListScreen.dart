import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../objectbox.g.dart';
import '../Entity.dart';
import '../MyProviders.dart';
import '../Utils/QRViewExample.dart';
import '../classeObjectBox.dart';
import 'ProduitListScreen.dart';

// class FacturePage extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     final commerceProvider = Provider.of<CommerceProvider>(context);
//     return Scaffold(
//       appBar: AppBar(
//         title: Text('Facture'),
//         actions: [
//           IconButton(
//             icon: Icon(Icons.search),
//             onPressed: () {
//               showSearch(
//                   context: context,
//                   delegate: ProduitSearchDelegateMain(commerceProvider));
//             },
//           ),
//           IconButton(
//             icon: Icon(Icons.qr_code_scanner),
//             onPressed: () async {
//               final result = await Navigator.push(
//                 context,
//                 MaterialPageRoute(builder: (context) => QRViewExample()),
//               );
//               if (result != null) {
//                 final produit = await commerceProvider.getProduitByQr(result);
//                 if (produit != null) {
//                   Provider.of<CartProvider>(context, listen: false)
//                       .addToCart(produit);
//                 } else {
//                   ScaffoldMessenger.of(context).showSnackBar(
//                     SnackBar(
//                       content: Text('Produit introuvable!'),
//                       backgroundColor: Colors.red,
//                     ),
//                   );
//                 }
//               }
//             },
//           ),
//           SizedBox(
//             width: 100,
//           )
//         ],
//       ),
//       body: Consumer<CartProvider>(
//         builder: (context, cartProvider, child) {
//           final items = cartProvider.facture.lignesFacture;
//           final totalAmount = cartProvider.totalAmount;
//           final tva = totalAmount * 0.19; // TVA à 19%
//
//           return Column(
//             children: [
//               Expanded(
//                 child: ListView.builder(
//                   itemCount: items.length,
//                   itemBuilder: (context, index) {
//                     final ligneFacture = items[index];
//                     final produit = ligneFacture.produit.target!;
//                     return ListTile(
//                       title: Text('Prix: ${produit.nom} Qr: ${produit.qr}'),
//                       subtitle: Text(
//                           'Prix: ${ligneFacture.prixUnitaire.toStringAsFixed(2)} DZD\nQuantité: ${ligneFacture.quantite}'),
//                       trailing: IconButton(
//                         icon: Icon(Icons.remove_shopping_cart),
//                         onPressed: () {
//                           cartProvider.removeFromCart(produit);
//                         },
//                       ),
//                     );
//                   },
//                 ),
//               ),
//               Padding(
//                 padding: const EdgeInsets.all(16.0),
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     Text('Total: ${totalAmount.toStringAsFixed(2)} DZD'),
//                     Text('TVA (19%): ${tva.toStringAsFixed(2)} DZD'),
//                     Text(
//                         'Total TTC: ${(totalAmount + tva).toStringAsFixed(2)} DZD'),
//                     SizedBox(height: 20),
//                     ElevatedButton(
//                       onPressed: () {
//                         cartProvider.saveFacture();
//                         ScaffoldMessenger.of(context).showSnackBar(
//                           SnackBar(content: Text('Facture sauvegardée!')),
//                         );
//                       },
//                       child: Text('Sauvegarder la facture'),
//                     ),
//                   ],
//                 ),
//               ),
//               SizedBox(height: 50)
//             ],
//           );
//         },
//       ),
//     );
//   }
// }
class FacturePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final commerceProvider = Provider.of<CommerceProvider>(context);
    final cartProvider = Provider.of<CartProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: Text('Facture'),
        actions: [
          IconButton(
            icon: Icon(Icons.search),
            onPressed: () {
              showSearch(
                context: context,
                delegate: ProduitSearchDelegateMain(commerceProvider),
              );
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
          IconButton(
            icon: Icon(Icons.person_add),
            onPressed: () => _showClientDialog(context),
          ),
          SizedBox(width: 100),
        ],
      ),
      body: Consumer<CartProvider>(
        builder: (context, cartProvider, child) {
          final items = cartProvider.facture.lignesFacture;
          final totalAmount = cartProvider.totalAmount;
          final tva = totalAmount * 0.19; // TVA à 19%
          return Column(
            children: [
              _buildClientInfo(context, cartProvider),
              Expanded(
                child: ListView.builder(
                  itemCount: items.length,
                  itemBuilder: (context, index) {
                    final ligneFacture = items[index];
                    final produit = ligneFacture.produit.target!;
                    return Card(
                      child: ListTile(
                        title: Text('${produit.nom} Qr: ${produit.qr}'),
                        subtitle: Text(
                            'Prix: ${ligneFacture.prixUnitaire.toStringAsFixed(2)} DZD\nQuantité: ${ligneFacture.quantite}'),
                        trailing: IconButton(
                          icon: Icon(Icons.remove_shopping_cart),
                          onPressed: () {
                            cartProvider.removeFromCart(produit);
                          },
                        ),
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
                      onPressed: () async {
                        await cartProvider.saveFacture();
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Facture sauvegardée!')),
                        );
                      },
                      child: Text('Sauvegarder la facture'),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 50)
            ],
          );
        },
      ),
    );
  }

  Widget _buildClientInfo(BuildContext context, CartProvider cartProvider) {
    final client = cartProvider.selectedClient;
    return Card(
      margin: EdgeInsets.all(8),
      child: Padding(
        padding: EdgeInsets.all(8),
        child: Row(
          children: [
            Expanded(
              child: client != null
                  ? Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Client: ${client.nom}'),
                        Text('Téléphone: ${client.phone}'),
                        Text('Adresse: ${client.adresse}'),
                      ],
                    )
                  : Text('Aucun client sélectionné'),
            ),
            Center(
              child: ElevatedButton(
                onPressed: () => _createNewClient(context),
                child: Text('Créer un nouveau client'),
              ),
            ),
            ElevatedButton(
              onPressed: () => _showClientDialog(context),
              child: Text(client != null ? 'Changer' : 'Sélectionner'),
            ),
          ],
        ),
      ),
    );
  }

  void _showClientDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Sélectionner ou créer un client'),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                ElevatedButton(
                  child: Text('Sélectionner un client existant'),
                  onPressed: () {
                    Navigator.pop(context);
                    _selectExistingClient(context);
                  },
                ),
                ElevatedButton(
                  child: Text('Créer un nouveau client'),
                  onPressed: () {
                    Navigator.pop(context);
                    _createNewClient(context);
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _selectExistingClient(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return ClientSelectionDialog();
      },
    );
  }

  void _createNewClient(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return NewClientDialog();
      },
    );
  }
}

class ClientSelectionDialog extends StatefulWidget {
  @override
  _ClientSelectionDialogState createState() => _ClientSelectionDialogState();
}

class _ClientSelectionDialogState extends State<ClientSelectionDialog> {
  String _searchQuery = '';
  List<Client> _filteredClients = [];

  @override
  void initState() {
    super.initState();
    _filteredClients =
        Provider.of<CommerceProvider>(context, listen: false).clients;
  }

  void _filterClients(String query) {
    setState(() {
      _searchQuery = query;
      _filteredClients = Provider.of<CommerceProvider>(context, listen: false)
          .clients
          .where((client) =>
              client.nom.toLowerCase().contains(query.toLowerCase()) ||
              client.phone.contains(query))
          .toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Sélectionner un client'),
      content: Container(
        width: double.maxFinite,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              decoration: InputDecoration(
                labelText: 'Rechercher un client',
                prefixIcon: Icon(Icons.search),
              ),
              onChanged: _filterClients,
            ),
            Expanded(
              child: ListView.builder(
                itemCount: _filteredClients.length,
                itemBuilder: (context, index) {
                  final client = _filteredClients[index];
                  return ListTile(
                    title: Text(client.nom),
                    subtitle: Text(client.phone),
                    onTap: () {
                      Provider.of<CartProvider>(context, listen: false)
                          .selectClient(client);
                      Navigator.of(context).pop();
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class NewClientDialog extends StatefulWidget {
  @override
  _NewClientDialogState createState() => _NewClientDialogState();
}

class _NewClientDialogState extends State<NewClientDialog> {
  final _formKey = GlobalKey<FormState>();
  String nom = '', phone = '', adresse = '', description = '';

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Créer un nouveau client'),
      content: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                decoration: InputDecoration(labelText: 'Nom'),
                validator: (value) => value!.isEmpty ? 'Champ requis' : null,
                onSaved: (value) => nom = value!,
              ),
              TextFormField(
                decoration: InputDecoration(labelText: 'Téléphone'),
                validator: (value) => value!.isEmpty ? 'Champ requis' : null,
                onSaved: (value) => phone = value!,
              ),
              TextFormField(
                decoration: InputDecoration(labelText: 'Adresse'),
                validator: (value) => value!.isEmpty ? 'Champ requis' : null,
                onSaved: (value) => adresse = value!,
              ),
              TextFormField(
                decoration: InputDecoration(labelText: 'Description'),
                onSaved: (value) => description = value ?? '',
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          child: Text('Annuler'),
          onPressed: () => Navigator.of(context).pop(),
        ),
        ElevatedButton(
          child: Text('Créer'),
          onPressed: () {
            if (_formKey.currentState!.validate()) {
              _formKey.currentState!.save();
              Provider.of<CartProvider>(context, listen: false)
                  .createAndSelectClient(nom, phone, adresse, description);
              Navigator.of(context).pop();
            }
          },
        ),
      ],
    );
  }
}

class FacturesListPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Consumer<CartProvider>(builder: (context, cartProvider, child) {
      final factures = cartProvider.factures.reversed.toList();
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
                    leading: CircleAvatar(
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text('${facture.id}'),
                      ),
                    ),
                    title: Text('Client ${facture.client.target!.nom}'),
                    subtitle: Text('${facture.date}'),
                    onLongPress: () {
                      Provider.of<CartProvider>(context, listen: false)
                          .deleteFacture(facture);
                    },
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) =>
                              FactureDetailPage(facture: facture),
                        ),
                      );
                    },
                    trailing: Text(
                      '${_calculateTotal(facture).toStringAsFixed(2)} DZD',
                      style: TextStyle(fontSize: 20),
                    ),
                  );
                },
              ),
      );
    });
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
          SizedBox(height: 50)
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
