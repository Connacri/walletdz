import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../objectbox.g.dart';
import '../Entity.dart';
import '../MyProviders.dart';
import '../Utils/QRViewExample.dart';
import '../classeObjectBox.dart';
import 'ClientListScreen.dart';
import 'ProduitListScreen.dart';
import 'dart:io' show Platform;
import 'package:flutter/foundation.dart' show kIsWeb;

class FacturePage extends StatefulWidget {
  @override
  State<FacturePage> createState() => _FacturePageState();
}

class _FacturePageState extends State<FacturePage> {
  Client? _selectedClient;
  @override
  Widget build(BuildContext context) {
    final commerceProvider = Provider.of<CommerceProvider>(context);
    final cartProvider = Provider.of<CartProvider>(context);
    final clientProvider = Provider.of<ClientProvider>(context);

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
          ElevatedButton(
            onPressed: () async {
              await Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (ctx) => ClientSelectionPage(),
                ),
              );
            },
            child: Text('Sélectionner un Client'),
          ),
          ElevatedButton(
            onPressed: () async {
              Client? newClient = await showModalBottomSheet<Client>(
                context: context,
                isScrollControlled:
                    true, // Permet de redimensionner en fonction de la hauteur du contenu
                builder: (context) => AddClientForm(),
              );

              if (newClient != null) {
                setState(() {
                  _selectedClient = newClient;
                });
                cartProvider.setSelectedClient(newClient);
              } else {
                print(
                    "Le client n'a pas été créé ou l'opération a été annulée.");
              }
            },
            child: Text('Créer un Client'),
          ),
          kIsWeb ||
                  Platform.isWindows ||
                  Platform.isLinux ||
                  Platform.isFuchsia ||
                  Platform.isIOS
              ? Container()
              : IconButton(
                  icon: Icon(Icons.qr_code_scanner),
                  onPressed: () async {
                    final result = await Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => QRViewExample()),
                    );
                    if (result != null) {
                      final produit =
                          await commerceProvider.getProduitByQr(result);
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
                        try {
                          await cartProvider.saveFacture();
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Facture sauvegardée!')),
                          );
                        } catch (e) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Erreur: ${e.toString()}')),
                          );
                        }
                      },
                      child: Text('Sauvegarder la facture'),
                    )
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
                        Text('qr: ${client.qr}'),
                        Text('Nombre de factures : ${client.factures.length}'),
                      ],
                    )
                  : Text('Aucun client sélectionné'),
            ),
          ],
        ),
      ),
    );
  }
}

class ClientSelectionPage extends StatefulWidget {
  @override
  _ClientSelectionPageState createState() => _ClientSelectionPageState();
}

class _ClientSelectionPageState extends State<ClientSelectionPage> {
  String _searchQuery = '';
  List<Client> _filteredClients = [];

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _filteredClients = Provider.of<CommerceProvider>(context).clients;
  }

  void _filterClients(String query) {
    setState(() {
      _searchQuery = query;
      _filteredClients = Provider.of<CommerceProvider>(context)
          .clients
          .where((client) =>
              client.nom.toLowerCase().contains(query.toLowerCase()) ||
              client.phone.contains(query))
          .toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Sélectionner un client'),
      ),
      body: Container(
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

class FacturesListPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Consumer<CartProvider>(builder: (context, cartProvider, child) {
      final factures = cartProvider.factures.reversed.toList();
      return Scaffold(
        appBar: AppBar(
          title: Text('Liste des Factures'),
          actions: [
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.grey[300],
                disabledBackgroundColor: Colors.grey[300],
                disabledForegroundColor: Colors.grey[600],
              ),
              child: Text('Delete all'),
              onPressed: () async {
                await cartProvider.deleteAllFactures();

                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Liste de Factures Vider avec succès!'),
                    backgroundColor: Colors.red,
                  ),
                );
              },
            ),
            SizedBox(
              width: 50,
            ),
          ],
        ),
        body: factures.isEmpty
            ? Center(child: Text('Aucune facture trouvée'))
            : ListView.builder(
                itemCount: factures.length,
                itemBuilder: (context, index) {
                  final facture = factures[index];
                  final client = facture.client.target;
                  return ListTile(
                    leading: CircleAvatar(
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text('${facture.id}'),
                      ),
                    ),
                    title: Text(
                      'Invoice ${client?.nom ?? 'Unknown'}',
                    ),
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
