import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:objectbox/src/relations/to_many.dart';
import 'package:provider/provider.dart';
import '../Entity.dart';
import '../MyProviders.dart';
import '../Utils/QRViewExample.dart';
import 'ClientListScreen.dart';
import 'ProduitListScreen.dart';
import 'dart:io' show Platform;
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/services.dart';
import 'add_Produit.dart';

class FacturePage extends StatefulWidget {
  @override
  State<FacturePage> createState() => _FacturePageState();
}

class _FacturePageState extends State<FacturePage> {
  Client? _selectedClient;
  String _barcodeBuffer = '';
  late FocusNode _invisibleFocusNode;
  bool _isEditingImpayer = false;
  double _localImpayer =
      0.0; // Nouvelle variable pour stocker l'impayé localement

  // Ajouter un TextEditingController pour gérer l'impayé
  final TextEditingController _impayerController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _invisibleFocusNode = FocusNode();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _invisibleFocusNode.requestFocus();
    });
    // // Initialiser le champ impayé avec la valeur actuelle
    // _impayerController.text = Provider.of<CartProvider>(context, listen: false)
    //         .facture
    //         .impayer
    //         ?.toStringAsFixed(2) ??
    //     '0.00';
    Future.microtask(() {
      final cartProvider = Provider.of<CartProvider>(context, listen: false);
      _localImpayer = cartProvider.facture.impayer ?? 0.00;
      _impayerController.text = _localImpayer.toStringAsFixed(2);
    });
  }

  @override
  void dispose() {
    _invisibleFocusNode.dispose();
    _impayerController.dispose(); // Ne pas oublier de disposer le contrôleur
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final commerceProvider = Provider.of<CommerceProvider>(context);
    final cartProvider = Provider.of<CartProvider>(context);
    final clientProvider = Provider.of<ClientProvider>(context);

    return Scaffold(
      appBar: buildAppBar(context, commerceProvider, cartProvider),
      body: Consumer<CartProvider>(builder: (context, cartProvider, child) {
        final items = cartProvider.facture.lignesFacture;
        final totalAmount = cartProvider.totalAmount;
        final tva = totalAmount * 0.19; // TVA à 19%
        final impayer = cartProvider.facture.impayer ?? 0.0;

        return RawKeyboardListener(
            focusNode: _invisibleFocusNode,
            onKey: (RawKeyEvent event) {
              if (event is RawKeyDownEvent) {
                if (event.logicalKey == LogicalKeyboardKey.enter) {
                  _processBarcode(
                      context,
                      commerceProvider,
                      cartProvider,
                      double.parse(_barcodeBuffer),
                      cartProvider.facture.lignesFacture);
                } else {
                  _barcodeBuffer += event.character ?? '';
                }
              }
            },
            child: buildColumn(context, cartProvider, items, totalAmount, tva,
                impayer, _isEditingImpayer, commerceProvider));
      }),
    );
  }

  AppBar buildAppBar(BuildContext context, CommerceProvider commerceProvider,
      CartProvider cartProvider) {
    return AppBar(
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
          icon: Icon(Icons.account_circle),
          onPressed: () async {
            await Navigator.of(context).push(
              MaterialPageRoute(
                builder: (ctx) => ClientSelectionPage(),
              ),
            );
          },
        ),
        IconButton(
          icon: Icon(Icons.account_circle_outlined),
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
              print("Le client n'a pas été créé ou l'opération a été annulée.");
            }
          },
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
        kIsWeb ||
                Platform.isWindows ||
                Platform.isLinux ||
                Platform.isFuchsia ||
                Platform.isIOS
            ? SizedBox(width: 100)
            : SizedBox(width: 0),
      ],
    );
  }

  Column buildColumn(
      BuildContext context,
      CartProvider cartProvider,
      ToMany<LigneFacture> items,
      double totalAmount,
      double tva,
      double impayer,
      bool _isEditingImpayer,
      CommerceProvider commerceProvider) {
    return Column(
      children: [
        _buildClientInfo(context, cartProvider),
        Expanded(
          child: ListView.builder(
            itemCount: items.length,
            itemBuilder: (context, index) {
              final ligneFacture = items[index];
              final produit = ligneFacture.produit.target!;
              final TextEditingController _quantiteController =
                  TextEditingController(
                      text: ligneFacture.quantite.toStringAsFixed(2));
              final TextEditingController _prixController =
                  TextEditingController(
                      text: ligneFacture.prixUnitaire.toStringAsFixed(2));
              return Card(
                child: ListTile(
                  title: Text('Qr: ${produit.qr} ${produit.nom}'),
                  subtitle: Text(
                      '${ligneFacture.prixUnitaire.toStringAsFixed(2)} DZD * ${ligneFacture.quantite} = ${(ligneFacture.prixUnitaire * ligneFacture.quantite).toStringAsFixed(2)} DZD'),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: Icon(Icons.edit),
                        onPressed: () async {
                          _showEditQuantityDialog(context, ligneFacture,
                              _quantiteController, _prixController);
                        },
                      ),
                      IconButton(
                        icon: Icon(
                          Icons.delete,
                          color: Colors.red,
                        ),
                        onPressed: () {
                          cartProvider.removeFromCart(produit);
                        },
                      ),
                    ],
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
              // TextFormField(
              //   controller: _impayerController,
              //   keyboardType: TextInputType.number,
              //   decoration: InputDecoration(
              //     labelText: 'Impayer',
              //     border: OutlineInputBorder(),
              //     suffixText: 'DZD',
              //   ),
              //   onChanged: (value) {
              //     // Mettre à jour la variable impayer en temps réel
              //     setState(() {
              //       impayer = double.tryParse(value) ?? 0.0;
              //     });
              //   },
              // ),
              // Row(
              //   mainAxisAlignment: MainAxisAlignment.spaceBetween,
              //   children: [
              //     Expanded(
              //       child: _isEditingImpayer
              //           ? TextFormField(
              //               controller: _impayerController,
              //               keyboardType: TextInputType.number,
              //               decoration: InputDecoration(
              //                 labelText: 'Impayer',
              //                 border: OutlineInputBorder(),
              //                 suffixText: 'DZD',
              //               ),
              //               onChanged: (value) {
              //                 setState(() {
              //                   impayer = double.tryParse(value) ?? 0.0;
              //                 });
              //               },
              //               autofocus:
              //                   true, // Ajout pour forcer le focus sur le TextFormField
              //             )
              //           : Text(
              //               'Impayer: ${impayer.toStringAsFixed(2)} DZD',
              //               style: TextStyle(fontSize: 16),
              //             ),
              //     ),
              //     IconButton(
              //       icon: Icon(
              //         _isEditingImpayer ? Icons.check : Icons.edit,
              //         color: _isEditingImpayer ? Colors.green : Colors.blue,
              //       ),
              //       onPressed: () {
              //         setState(() {
              //           if (_isEditingImpayer) {
              //             // Si on termine l'édition, on met à jour l'impayer
              //             impayer =
              //                 double.tryParse(_impayerController.text) ?? 0.0;
              //           } else {
              //             // Lors du début de l'édition, pré-remplir le TextFormField avec la valeur actuelle
              //             _impayerController.text = impayer.toString();
              //           }
              //           _isEditingImpayer = !_isEditingImpayer;
              //         });
              //       },
              //     ),
              //   ],
              // ),
              _buildImpayerRow(impayer),
              SizedBox(height: 10),
              Text('Total: ${totalAmount.toStringAsFixed(2)} DZD'),
              Text('TVA (19%): ${tva.toStringAsFixed(2)} DZD'),
              Text('Total TTC: ${(totalAmount + tva).toStringAsFixed(2)} DZD'),
              Card(
                color: Colors.green,
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    'Montant à Payé: ${(totalAmount + tva - impayer).toStringAsFixed(2)} DZD',
                    style: TextStyle(fontSize: 20, color: Colors.white),
                  ),
                ),
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: () async {
                  cartProvider.facture.impayer = _localImpayer;
                  // // Mettre à jour l'impayé dans le CartProvider avant de sauvegarder
                  // cartProvider.facture.impayer =
                  //     double.tryParse(_impayerController.text) ?? 0.0;

                  try {
                    await cartProvider.saveFacture(commerceProvider);
                    _localImpayer = 0.0;
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
              ),
            ],
          ),
        ),
        SizedBox(height: 50)
      ],
    );
  }

  // Méthode extraite pour construire la ligne "Impayer"
  Widget _buildImpayerRow(double impayer) {
    return StatefulBuilder(
      builder: (BuildContext context, StateSetter setState) {
        return Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: _isEditingImpayer
                  ? TextFormField(
                      controller: _impayerController,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        labelText: 'Impayer',
                        border: OutlineInputBorder(),
                        suffixText: 'DZD',
                      ),
                      onChanged: (value) {
                        setState(() {
                          _localImpayer = double.tryParse(value) ?? 0.0;
                        });
                      },
                      autofocus: true,
                    )
                  : Text(
                      'Impayer: ${_localImpayer.toStringAsFixed(2)} DZD',
                      style: TextStyle(fontSize: 16),
                    ),
            ),
            IconButton(
              icon: Icon(
                _isEditingImpayer ? Icons.check : Icons.edit,
                color: _isEditingImpayer ? Colors.green : Colors.blue,
              ),
              onPressed: () {
                setState(() {
                  if (_isEditingImpayer) {
                    _localImpayer =
                        double.tryParse(_impayerController.text) ?? 0.0;
                  } else {
                    _impayerController.text = _localImpayer.toStringAsFixed(2);
                  }
                  _isEditingImpayer = !_isEditingImpayer;
                });
              },
            ),
          ],
        );
      },
    );
  }

  void _processBarcode(BuildContext context, CommerceProvider commerceProvider,
      CartProvider cartProvider, double enteredQuantity, ligneFacture) async {
    if (_barcodeBuffer.isNotEmpty) {
      final produit = await commerceProvider.getProduitByQr(_barcodeBuffer);
      if (produit == null) {
        _navigateToAddProductPage(context, commerceProvider, cartProvider);
      } else {
        if (enteredQuantity > 0 ||
            enteredQuantity <= ligneFacture.produit.target!.stock) {
          cartProvider.addToCart(produit);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Produit ajouté : ${produit.nom}'),
              backgroundColor: Colors.green,
              showCloseIcon: true,
              duration: _snackBarDisplayDuration(),
            ),
          );
        } else {
          SnackBar(
            content: Text(
                'La quantité doit être entre 0 et ${ligneFacture.produit.target!.stock}'),
            backgroundColor: Colors.green,
          );
        }
      }
      _barcodeBuffer = '';
    }
  }

  void _navigateToAddProductPage(BuildContext context,
      CommerceProvider commerceProvider, CartProvider cartProvider) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => add_Produit(qrCode: _barcodeBuffer),
      ),
    );

    if (result != null && result is Produit) {
      cartProvider.addToCart(result);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Nouveau produit ajouté : ${result.nom}'),
          backgroundColor: Colors.green,
        ),
      );
    }
  }

  Widget _buildClientInfo(BuildContext context, CartProvider cartProvider) {
    final client = cartProvider.selectedClient;
    return Card(
      margin: EdgeInsets.all(8),
      child: InkWell(
        onTap: () {
          client != null
              ? Navigator.of(context).push(MaterialPageRoute(
                  builder: (ctx) => ClientDetailsPage(
                    client: client,
                  ),
                ))
              : null;
        },
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
                          Text(
                              'Nombre de factures : ${client.factures.length}'),
                        ],
                      )
                    : Text('Aucun client sélectionné'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showEditQuantityDialog(
      BuildContext context,
      LigneFacture ligneFacture,
      TextEditingController _quantiteController,
      TextEditingController _prixController) {
    final _formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(
            'Modifier la quantité pour ${ligneFacture.produit.target!.nom}\nReste En Stock  ${ligneFacture.produit.target!.stock.toStringAsFixed(ligneFacture.produit.target!.stock.truncateToDouble() == ligneFacture.produit.target!.stock ? 0 : 2)}',
            textAlign: TextAlign.center,
          ),
          content: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: _quantiteController,
                  keyboardType: TextInputType.number,
                  textAlign: TextAlign.center,
                  decoration: InputDecoration(
                    labelText: 'Quantité',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8.0),
                      borderSide: BorderSide.none, // Supprime le contour
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8.0),
                      borderSide:
                          BorderSide.none, // Supprime le contour en état normal
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8.0),
                      borderSide:
                          BorderSide.none, // Supprime le contour en état focus
                    ),
                    //border: InputBorder.none,
                    filled: true,
                    contentPadding: EdgeInsets.all(15),
                  ),
                  autovalidateMode: AutovalidateMode.onUserInteraction,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Veuillez entrer une quantité';
                    }
                    final double? enteredQuantity = double.tryParse(value);
                    if (enteredQuantity == null) {
                      return 'Veuillez entrer un nombre valide';
                    }
                    if (enteredQuantity <= 0)
                      return 'La quantité doit être Superieur à 0.0';

                    if (enteredQuantity > ligneFacture.produit.target!.stock) {
                      return 'La quantité doit être entre 0.0 et ${ligneFacture.produit.target!.stock.toStringAsFixed(2)}';
                    }
                    return null;
                  },
                ),
                SizedBox(
                  height: 10,
                ),
                TextFormField(
                  controller: _prixController,
                  keyboardType: TextInputType.number,
                  textAlign: TextAlign.center,
                  decoration: InputDecoration(
                    labelText: 'Prix',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8.0),
                      borderSide: BorderSide.none, // Supprime le contour
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8.0),
                      borderSide:
                          BorderSide.none, // Supprime le contour en état normal
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8.0),
                      borderSide:
                          BorderSide.none, // Supprime le contour en état focus
                    ),
                    //border: InputBorder.none,
                    filled: true,
                    contentPadding: EdgeInsets.all(15),
                  ),
                  autovalidateMode: AutovalidateMode.onUserInteraction,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Veuillez entrer une Prix';
                    }
                    final double? enteredPrice = double.tryParse(value);
                    if (enteredPrice == null) {
                      return 'Veuillez entrer un nombre valide';
                    }
                    if (enteredPrice < 0 ||
                        enteredPrice > ligneFacture.produit.target!.prixVente) {
                      return 'La Prix doit être entre ${ligneFacture.produit.target!.prixAchat.toStringAsFixed(3)} et ${ligneFacture.produit.target!.prixVente.toStringAsFixed(3)}';
                    }
                    return null;
                  },
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Annuler'),
            ),
            ElevatedButton(
              onPressed: () {
                if (_formKey.currentState?.validate() ?? false) {
                  final double newQuantity =
                      double.parse(_quantiteController.text);
                  final double newPrice = double.parse(_prixController.text);
                  ligneFacture.quantite = newQuantity;
                  ligneFacture.prixUnitaire = newPrice;
                  setState(() {});
                  Navigator.of(context).pop();
                }
              },
              child: Text('Enregistrer'),
            ),
          ],
        );
      },
    );
  }

  Duration _snackBarDisplayDuration() {
    return Duration(seconds: 1); // Afficher la SnackBar pendant 1 secondes
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
      _filteredClients = Provider.of<ClientProvider>(context, listen: false)
          .clients
          .where((client) =>
              client.nom.toLowerCase().contains(query.toLowerCase()) ||
              client.id.toString().contains(query) ||
              client.qr.contains(query))
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
                    title: Text(client.id.toString() + '  ' + client.nom),
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

class FacturesListPage extends StatefulWidget {
  @override
  State<FacturesListPage> createState() => _FacturesListPageState();
}

class _FacturesListPageState extends State<FacturesListPage> {
  DateTime? _startDate;

  DateTime? _endDate;

  Map<String, dynamic> _totals = {
    'totalTTC': 0.0,
    'totalImpayes': 0.0,
    'totalTVA': 0.0
  };

  // Fonction pour sélectionner la date de début
  Future<void> _selectStartDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _startDate ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (picked != null && picked != _startDate) {
      setState(() {
        _startDate = picked;
      });
    }
  }

  // Fonction pour sélectionner la date de fin
  Future<void> _selectEndDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _endDate ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (picked != null && picked != _endDate) {
      setState(() {
        _endDate = picked;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final commerceProvider = Provider.of<CommerceProvider>(context);
    return Consumer<CartProvider>(builder: (context, cartProvider, child) {
      final factures = cartProvider.factures.reversed.toList();

      // Fonction pour calculer les totaux
      void _calculateTotals() {
        if (_startDate != null && _endDate != null) {
          setState(() {
            _totals =
                cartProvider.calculateTotalsForInterval(_startDate!, _endDate!);
          });
        }
      }

      return Scaffold(
        appBar: AppBar(
          title: Consumer<CartProvider>(
            builder: (context, cartProvider, child) {
              return Text('${cartProvider.factureCount} Factures');
            },
          ),
          actions: [
            IconButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.grey[300],
                disabledBackgroundColor: Colors.grey[300],
                disabledForegroundColor: Colors.grey[600],
              ),
              icon: Icon(Icons.clear_all_outlined),
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
            : Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            TextButton(
                              onPressed: () => _selectStartDate(context),
                              child: Text(
                                _startDate == null
                                    ? 'Sélectionner la date de début'
                                    : 'Date de début : ${DateFormat.yMd().format(_startDate!)}',
                              ),
                            ),
                            TextButton(
                              onPressed: () => _selectEndDate(context),
                              child: Text(
                                _endDate == null
                                    ? 'Sélectionner la date de fin'
                                    : 'Date de fin : ${DateFormat.yMd().format(_endDate!)}',
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 10),
                        ElevatedButton(
                          onPressed: _calculateTotals,
                          child: Text('Calculer les totaux'),
                        ),
                        SizedBox(height: 010),
                        if (_startDate != null && _endDate != null)
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                  'Total TTC: ${_totals['totalTTC'].toStringAsFixed(2)} DZD'),
                              Text(
                                  'Total Impayés: ${_totals['totalImpayes'].toStringAsFixed(2)} DZD'),
                              Text(
                                  'Total TVA: ${_totals['totalTVA'].toStringAsFixed(2)} DZD'),
                            ],
                          ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: ListView.builder(
                      itemCount: factures.length,
                      itemBuilder: (context, index) {
                        final facture = factures[index];
                        final client = facture.client.target;
                        return ListTile(
                          leading: CircleAvatar(
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: FittedBox(child: Text('${facture.id}')),
                            ),
                          ),
                          title: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Invoice ${client?.nom ?? 'Unknown'}',
                              ),
                              facture.impayer == null || facture.impayer == 0
                                  ? Container()
                                  : Text('Impayer : ${facture.impayer}',
                                      style: TextStyle(
                                          color: Colors.redAccent,
                                          fontSize: 12)),
                            ],
                          ),
                          subtitle: Text(
                            '${facture.date}',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight
                                  .w300, /*fontStyle: FontStyle.italic*/
                            ),
                          ),
                          onLongPress: () {
                            Provider.of<CartProvider>(context, listen: false)
                                .deleteFacture(facture);
                          },
                          onTap: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (context) => new FactureDetailPage(
                                  facture: facture,
                                  cartProvider: cartProvider,
                                  commerceProvider: commerceProvider,
                                ),
                              ),
                            );
                          },
                          trailing: Text(
                            '${(_calculateTotal(facture) * 1.19).toStringAsFixed(2)} DZD',
                            style: TextStyle(fontSize: 20),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
      );
    });
  }

  double _calculateTotal(Facture facture) {
    return facture.lignesFacture
        .fold(0, (sum, item) => sum + item.prixUnitaire * item.quantite);
  }
}

class FactureDetailPage extends StatefulWidget {
  final Facture facture;

  final CartProvider cartProvider;
  final CommerceProvider commerceProvider;

  FactureDetailPage({
    required this.facture,
    required this.cartProvider,
    required this.commerceProvider,
  });

  @override
  State<FactureDetailPage> createState() => _FactureDetailPageState();
}

class _FactureDetailPageState extends State<FactureDetailPage> {
  @override
  Widget build(BuildContext context) {
    final lignesFacture = widget.facture.lignesFacture;
    final client = widget.facture.client.target;
    return Scaffold(
      appBar: AppBar(
        title: Text('Détails de la Facture ${widget.facture.id}'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: GestureDetector(
              onTap: () {
                client != null
                    ? Navigator.of(context).push(MaterialPageRoute(
                        builder: (ctx) => ClientDetailsPage(
                          client: client,
                        ),
                      ))
                    : null;
              },
              child: Row(
                children: [
                  Expanded(
                    child: Card(
                      child: Padding(
                        padding: const EdgeInsets.all(18.0),
                        child: client != null
                            ? Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Client: ${client.nom}',
                                    style: TextStyle(
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold),
                                  ),
                                  SizedBox(
                                    width: 20,
                                  ),
                                  Text('Téléphone: ${client.phone}'),
                                  Text('Adresse: ${client.adresse}'),
                                  SizedBox(
                                    width: 20,
                                  ),
                                  Text('qr: ${client.qr}'),
                                  Text(
                                      'Nombre de factures : ${client.factures.length}'),
                                ],
                              )
                            : Text('Aucun client sélectionné'),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              scrollDirection: Axis.vertical,
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: DataTable(
                  columns: const [
                    DataColumn(label: Text('ID')),
                    DataColumn(label: Text('Nom du Produit')),
                    DataColumn(label: Text('Prix Unitaire')),
                    DataColumn(label: Text('Quantité')),
                    DataColumn(label: Text('Total')),
                    DataColumn(label: Text('Actions')),
                  ],
                  rows: lignesFacture.map((ligneFacture) {
                    final produit = ligneFacture.produit.target!;
                    return DataRow(cells: [
                      DataCell(Text(produit.id.toString())),
                      DataCell(Text(produit.nom)),
                      DataCell(Text(
                          '${ligneFacture.prixUnitaire.toStringAsFixed(2)} DZD')),
                      DataCell(Text(ligneFacture.quantite.toString())),
                      DataCell(Text(
                        '${(ligneFacture.prixUnitaire * ligneFacture.quantite).toStringAsFixed(2)} DZD',
                      )),
                      DataCell(
                        Row(
                          children: [
                            IconButton(
                              icon: Icon(Icons.edit),
                              onPressed: () {
                                _showEditDialog(context, ligneFacture);
                              },
                            ),
                            IconButton(
                              icon: Icon(
                                Icons.delete,
                                color: Colors.red,
                              ),
                              onPressed: () {
                                _showEditDialog(context, ligneFacture);
                              },
                            ),
                          ],
                        ),
                      ),
                    ]);
                  }).toList(),
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Total: ${_calculateTotal().toStringAsFixed(2)} DZD',
                  style: TextStyle(color: Colors.green),
                ),
                Text('TVA (19%): ${_calculateTVA().toStringAsFixed(2)} DZD'),
                Text(
                    'Total TTC: ${(_calculateTotal() + _calculateTVA()).toStringAsFixed(2)} DZD'),
                Text(
                  'Impayer: ${widget.facture.impayer!.toStringAsFixed(2)} DZD',
                  style: TextStyle(color: Colors.redAccent),
                ),
              ],
            ),
          ),
          ElevatedButton(
            onPressed: () async {
              try {
                await widget.cartProvider.saveFacture(widget.commerceProvider);
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
          ),
          SizedBox(height: 40)
        ],
      ),
    );
  }

  double _calculateTotal() {
    return widget.facture.lignesFacture
        .fold(0, (sum, item) => sum + item.prixUnitaire * item.quantite);
  }

  double _calculateTVA() {
    return _calculateTotal() * 0.19;
  }

  void _showEditDialog(BuildContext context, LigneFacture ligneFacture) {
    TextEditingController _quantiteController = TextEditingController(
      text: ligneFacture.quantite.toString(),
    );

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Modifier la quantité'),
          content: TextField(
            controller: _quantiteController,
            keyboardType: TextInputType.number,
            decoration: InputDecoration(labelText: 'Quantité'),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Annuler'),
            ),
            TextButton(
              onPressed: () {
                double newQuantite =
                    double.tryParse(_quantiteController.text) ?? 0.0;
                if (newQuantite > 0) {
                  ligneFacture.quantite = newQuantite;
                  setState(() {});
                }
                Navigator.of(context).pop();
              },
              child: Text('Enregistrer'),
            ),
          ],
        );
      },
    );
  }
}
