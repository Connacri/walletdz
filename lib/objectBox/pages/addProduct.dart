import 'dart:io';

import 'package:dart_date/dart_date.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../Entity.dart';
import '../MyProviders.dart';
import '../Utils/country_flags.dart';
import '../Utils/mobile_scanner/barcode_scanner_window.dart';
import 'AddFournisseurFormFromProduit.dart';

class addProduct extends StatefulWidget {
  const addProduct({super.key});

  @override
  State<addProduct> createState() => _addProductState();
}

class _addProductState extends State<addProduct> {
  @override
  Widget build(BuildContext context) {
    return ResponsiveLayout();
  }
}

class MyHomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Responsive Layout'),
      ),
      body: ResponsiveLayout(),
    );
  }
}

class ResponsiveLayout extends StatefulWidget {
  ResponsiveLayout({super.key});

  @override
  State<ResponsiveLayout> createState() => _ResponsiveLayoutState();
}

class _ResponsiveLayoutState extends State<ResponsiveLayout> {
  final _formKey = GlobalKey<FormState>();

  final _nomController = TextEditingController();

  final _descriptionController = TextEditingController();

  final _prixAchatController = TextEditingController();

  final _prixVenteController = TextEditingController();

  final _stockController = TextEditingController();

  final _serialController = TextEditingController();

  final _datePeremptionController = TextEditingController();

  final _minimStockController = TextEditingController();

  final _alertPeremptionController = TextEditingController();

  final FocusNode _serialFocusNode =
      FocusNode(); // FocusNode pour garder le curseur dans le TextFormField

  File? _image;
  String? _existingImageUrl;
  bool _isFirstFieldFilled = false;
  String _tempProduitId = '';
  double stockTemp = 0;
  bool _showDescription = false;
  bool _isFinded = false;
  String _lastScannedCode = '';
  DateTime selectedDate = DateTime.now();
  Approvisionnement? _currentApprovisionnement;
  bool _isEditing = false;
  bool _editQr = true;
  bool _showAppro = false;
  bool _showAllFournisseurs = false;
  List<Fournisseur> _selectedFournisseurs = [];
  List<Approvisionnement> _approvisionnementTemporaire = [];
  Fournisseur? _currentFournisseur;
  Fournisseur? _selectedFournisseur;
  final List<String> _qrCodesTemp =
      []; // Liste temporaire pour stocker les QR codes
  double stockGlobale = 0.0; // Déclaration de la variable

  @override
  void initState() {
    super.initState();
    _serialController.addListener(_onSerialChanged);
    _serialController.addListener(_checkFirstField);
  }

  Future<void> _scanQRCode() async {
    // Simuler un scan de QR code pour tester
    final code = await Navigator.of(context).push<String>(
      MaterialPageRoute(
        builder: (context) => BarcodeScannerWithScanWindow(), //QRViewExample(),
      ),
    );
    final provider = Provider.of<CommerceProvider>(context, listen: false);
    final produit = await provider.getProduitByQr(code!);
// Afficher une alerte avec les détails du produit existant
    if (produit != null)
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Code QR déjà utilisé'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('Le code QR est déjà associé au produit suivant :'),
                SizedBox(height: 10),
                Text('Nom : ${produit.nom}'),
                Text(
                    'Description : ${produit.description ?? "Pas de description"}'),
                Text(
                    'Prix de vente : ${produit.prixVente.toStringAsFixed(2)} DA'),
                Text('Stock : ${produit.stock.toStringAsFixed(2)}'),
                Text(
                    'Stock Minimum : ${produit.minimStock.toStringAsFixed(2)}'),
                produit.image != null
                    ? Image.network(produit.image!)
                    : Container(),
              ],
            ),
            actions: [
              TextButton(
                child: Text('OK'),
                onPressed: () {
                  Navigator.of(context).pop(); // Fermer le dialog
                },
              ),
            ],
          );
        },
      );
    // Rediriger le focus vers le TextFormField après l'ajout
    FocusScope.of(context).requestFocus(_serialFocusNode);

    if (code != null && code.isNotEmpty && !_qrCodesTemp.contains(code)) {
      setState(() {
        _serialController.text = code;
        _qrCodesTemp.add(code); // Ajout du QR code à la liste temporaire
        _editQr = false;
      });
      // Rediriger le focus vers le TextFormField après l'ajout
      FocusScope.of(context).requestFocus(_serialFocusNode);
      final provider = Provider.of<CommerceProvider>(context, listen: false);
      //final produit = await provider.getProduitById(int.parse(code));
      final produit = await provider.getProduitByQr(code);
      if (produit != null) {
        setState(() {
          _tempProduitId = produit.id.toString() ?? '';
          _nomController.text = produit.nom;
          _descriptionController.text = produit.description ?? '';
          // _prixAchatController.text = produit.prixAchat.toStringAsFixed(2);
          _prixVenteController.text = produit.prixVente.toStringAsFixed(2);
          _stockController.text = produit.stock.toStringAsFixed(2);
          stockTemp = double.parse(produit.stock.toStringAsFixed(2));
          _minimStockController.text = produit.minimStock.toStringAsFixed(2);
          _alertPeremptionController.text = produit.alertPeremption.toString();
          // _datePeremptionController.text = produit
          //     .approvisionnements.first.datePeremption!
          //     .format('yMMMMd', 'fr_FR');
          //_selectedFournisseurs = List.from(produit.fournisseurs);
          _existingImageUrl = produit.image;
          _isFinded = true;
          _image = null;
          // Ajouter le QR code scanné à la liste
          produit.addQrCode(code); // Ajoute le QR code scanné à la liste
        });
      } else {
        setState(() {
          _tempProduitId = '';
          _nomController.clear();
          _descriptionController.clear();
          _prixAchatController.clear();
          stockTemp = 0.0;
          _alertPeremptionController.clear();
          _prixVenteController.clear();
          _stockController.clear();
          _selectedFournisseurs.clear();
          _datePeremptionController.clear();
          _minimStockController.clear();
          _existingImageUrl = '';
          _isFinded = false;
          _image = null;
        });
        // Si un nouveau produit doit être créé, tu peux créer un objet Produit temporaire
        Produit newProduit = Produit(
          nom: _nomController.text,
          prixVente: double.parse(_prixVenteController.text),
          minimStock: double.parse(_minimStockController.text),
          alertPeremption: int.parse(_alertPeremptionController.text),
          derniereModification: DateTime.now(),
        );

        // Ajoute le QR code scanné à ce nouveau produit
        newProduit.addQrCode(code);
      }
    }
  }

  // Ajouter manuellement un QR code via le TextFormField et la touche "Entrée"
  void _addQRCodeFromText() async {
    final code = _serialController.text.trim();
    final provider = Provider.of<CommerceProvider>(context, listen: false);
    final produit = await provider.getProduitByQr(code);
// Afficher une alerte avec les détails du produit existant
    if (produit != null)
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Code QR déjà utilisé'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('Le code QR est déjà associé au produit suivant :'),
                SizedBox(height: 10),
                Text('Nom : ${produit.nom}'),
                Text(
                    'Description : ${produit.description ?? "Pas de description"}'),
                Text(
                    'Prix de vente : ${produit.prixVente.toStringAsFixed(2)} DA'),
                Text('Stock : ${produit.stock.toStringAsFixed(2)}'),
                Text(
                    'Stock Minimum : ${produit.minimStock.toStringAsFixed(2)}'),
                produit.image != null
                    ? Image.network(produit.image!)
                    : Container(),
              ],
            ),
            actions: [
              TextButton(
                child: Text('OK'),
                onPressed: () {
                  Navigator.of(context).pop(); // Fermer le dialog
                },
              ),
            ],
          );
        },
      );
    if (code.isNotEmpty && !_qrCodesTemp.contains(code)) {
      setState(() {
        _qrCodesTemp.add(code); // Ajouter le QR code dans la liste temporaire
        _serialController.clear(); // Effacer le champ de texte après l'ajout
        _editQr = false;
      });
    } else {
      _serialController.clear(); // Effacer le champ de texte après l'ajout
    }
    // Rediriger le focus vers le TextFormField après l'ajout
    FocusScope.of(context).requestFocus(_serialFocusNode);
  }

  void _onSerialChanged() {
    final code = _serialController.text;

    // Vérifie si le champ est vide en premier lieu pour éviter des opérations inutiles.
    if (code.isEmpty && _qrCodesTemp.isEmpty
        // || _serialController.text == ''
        /*|| code == _lastScannedCode*/) {
      _clearAllFields();

      // return;
    }

    _lastScannedCode = code;
    if (_editQr) {
      _updateProductInfo(code);
    }
  }

  void _checkFirstField() {
    //_serialController.text.isEmpty ? _clearAllFields() : null; /////// A VOIRE
    setState(() {
      _isFirstFieldFilled = _serialController.text.isNotEmpty;
    });
  }

  void _clearAllFields() {
    setState(() {
      _tempProduitId = '';
      _serialController.clear();
      stockTemp = 0.0;
      _nomController.clear();
      _descriptionController.clear();
      _prixAchatController.clear();
      _prixVenteController.clear();
      _stockController.clear();
      _minimStockController.clear();
      _selectedFournisseurs.clear();
      _datePeremptionController.clear();
      _alertPeremptionController.clear();
      _existingImageUrl = '';
      _isFirstFieldFilled = false;
      _image = null;
    });
  }

  Future<void> _updateProductInfo(String code) async {
    final provider = Provider.of<CommerceProvider>(context, listen: false);
    final produit = await provider.getProduitByQr(code);

    if (produit != null) {
      // Calculer le stock total des approvisionnements pour ce produit
      double stockTemp = produit.calculerStockTotal();
      print('Stock total pour le produit ${produit.nom} : $stockTemp');
    }

    if (produit != null) {
      setState(() {
        _tempProduitId = produit.id.toString() ?? '';
        _nomController.text = produit.nom;
        _descriptionController.text = produit.description ?? '';
        //   _prixAchatController.text = produit.prixAchat.toStringAsFixed(2);
        _prixVenteController.text = produit.prixVente.toStringAsFixed(2);
        _stockController.text = produit.stock.toStringAsFixed(2);
        _minimStockController.text = produit.minimStock.toStringAsFixed(2);
        stockTemp = double.parse(produit.stock.toStringAsFixed(2));
        // _datePeremptionController.text =
        //     produit.datePeremption!.format('yMMMMd', 'fr_FR');
        _alertPeremptionController.text = produit.alertPeremption.toString();
        // _selectedFournisseurs = List.from(produit.fournisseurs);
        _existingImageUrl = produit.image;
        _isFinded = true;
        _image = null;
        _approvisionnementTemporaire = produit.approvisionnements.toList();
      });
    }
    // else {
    //   if (_tempProduitId.isNotEmpty) {
    //     _tempProduitId = '';
    //     _nomController.clear();
    //     _descriptionController.clear();
    //     stockTemp = 0.0;
    //     _prixAchatController.clear();
    //     _prixVenteController.clear();
    //     _stockController.clear();
    //     _selectedFournisseurs.clear();
    //     _datePeremptionController.clear();
    //     _minimStockController.clear();
    //     _alertPeremptionController.clear();
    //     _existingImageUrl = '';
    //     _isFinded = false;
    //     _image = null;
    //   }
    // }
  }

  double calculerStockGlobal() {
    double totalStock = 0.0;

    for (var approvisionnement in _approvisionnementTemporaire) {
      totalStock += approvisionnement.quantite;
    }

    return totalStock;
  }

// Appeler la méthode pour calculer le stock global
  void mettreAJourStockGlobal() {
    setState(() {
      stockGlobale = calculerStockGlobal();
    });
  }

  void startEditing(Approvisionnement approvisionnement) {
    setState(() {
      _currentApprovisionnement = approvisionnement;
      _stockController.text = approvisionnement.quantite.toStringAsFixed(2);
      _prixAchatController.text =
          approvisionnement.prixAchat.toStringAsFixed(2);
      _datePeremptionController.text = DateFormat('dd MMMM yyyy', 'fr_FR')
          .format(approvisionnement.datePeremption!);

      // Récupérer le fournisseur associé à l'approvisionnement
      _currentFournisseur = approvisionnement.fournisseur
          .target; // Assurez-vous que c'est correct selon votre architecture
      _selectedFournisseur = _currentFournisseur;
      _isEditing = true;
    });
  }

  void supprimerApprovisionnementTemporaire(
      Approvisionnement approvisionnement) {
    setState(() {
      _approvisionnementTemporaire.remove(approvisionnement);
    });

    // Vous pouvez appeler setState() si vous utilisez un StatefulWidget
    // pour mettre à jour l'interface utilisateur.
  }

  void ajouterApprovisionnementTemporaire(Approvisionnement approvisionnement) {
    setState(() {
      _approvisionnementTemporaire.add(approvisionnement);
    });
  }

// Méthode pour gérer le changement de fournisseur
  void _onSelectedFournisseurChanged(Fournisseur fournisseur) {
    setState(() {
      _currentFournisseur = fournisseur; // Mise à jour de la variable correcte
    });
  }

  void saveApprovisionnement() {
    if (_formKey.currentState!.validate()) {
      final quantite = double.parse(_stockController.text);
      final prixAchat = double.parse(_prixAchatController.text);
      final datePeremption = DateFormat('dd MMMM yyyy', 'fr_FR')
          .parse(_datePeremptionController.text);

      // Vérifiez si nous sommes en mode édition et que l'approvisionnement est sélectionné
      if (_isEditing && _currentApprovisionnement != null) {
        // Trouver l'index de l'approvisionnement dans la liste temporaire
        final int index = _approvisionnementTemporaire.indexWhere(
            (approvisionnement) =>
                approvisionnement == _currentApprovisionnement);

        if (index != -1) {
          // Mettre à jour les valeurs de l'approvisionnement existant
          setState(() {
            _currentApprovisionnement!.quantite = quantite;
            _currentApprovisionnement!.prixAchat = prixAchat;
            _currentApprovisionnement!.datePeremption = datePeremption;

            // Vérifier si un fournisseur est sélectionné avant de l'assigner
            if (_selectedFournisseur != null) {
              _currentApprovisionnement!.fournisseur.target =
                  _selectedFournisseur;
            } else {
              _currentApprovisionnement!.fournisseur.target = null;
            }

            _currentApprovisionnement!.derniereModification = DateTime.now();

            // Remplacer l'approvisionnement dans la liste
            _approvisionnementTemporaire[index] = _currentApprovisionnement!;

            // Réinitialiser les champs après la modification
            _stockController.clear();
            _prixAchatController.clear();
            _datePeremptionController.clear();
            _currentFournisseur = null;
            _selectedFournisseur = null;
            _isEditing = false; // Désactiver le mode édition
          });
        } else {
          print("Erreur : Approvisionnement non trouvé dans la liste.");
        }
      } else {
        // Si ce n'est pas une modification, créer un nouvel approvisionnement
        Approvisionnement nouveauApprovisionnement = Approvisionnement(
          quantite: quantite,
          prixAchat: prixAchat,
          datePeremption: datePeremption,
          derniereModification: DateTime.now(),
        );

        // Assigner le fournisseur sélectionné, ou laisser null si non sélectionné
        if (_currentFournisseur != null) {
          nouveauApprovisionnement.fournisseur.target = _currentFournisseur;
        } else if (_selectedFournisseur != null) {
          nouveauApprovisionnement.fournisseur.target = _selectedFournisseur;
        } else {
          nouveauApprovisionnement.fournisseur.target = null;
        }

        // Ajouter le nouvel approvisionnement à la liste temporaire
        setState(() {
          _approvisionnementTemporaire.add(nouveauApprovisionnement);

          // Réinitialiser les champs après l'ajout
          _stockController.clear();
          _prixAchatController.clear();
          _datePeremptionController.clear();
          _currentFournisseur = null;
          _selectedFournisseur = null;
          _isEditing = false;
        });
      }

      // Mettre à jour le stock global après modification ou ajout
      mettreAJourStockGlobal();
    }
  }

  @override
  void dispose() {
    _serialController.removeListener(_onSerialChanged);
    _serialController.removeListener(_checkFirstField);
    _serialController.dispose();
    _nomController.dispose();
    _descriptionController.dispose();
    _prixAchatController.dispose();
    _prixVenteController.dispose();
    _stockController.dispose();
    _alertPeremptionController.dispose();
    _datePeremptionController.dispose();
    _serialFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: LayoutBuilder(
        builder: (context, constraints) {
          if (constraints.maxWidth < 600) {
            // Mobile layout
            return Scaffold(
                resizeToAvoidBottomInset: true,
                appBar: AppBar(),
                body: Form(
                  key: _formKey,
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: MobileLayout(),
                  ),
                ));
          } else if (constraints.maxWidth < 1200) {
            // Tablet layout
            return Scaffold(
                appBar: AppBar(),
                body: Form(
                  key: _formKey,
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: TabletLayout(),
                  ),
                ));
          } else {
            // Desktop layout
            return Scaffold(
                appBar: AppBar(),
                body: Form(
                  key: _formKey,
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: DesktopLayout(),
                  ),
                ));
          }
        },
      ),
    );
  }

  Column MobileLayout() {
    return Column(
      children: [
        Expanded(child: _buildColumn()),
        // Expanded(child: Container()),
      ],
    );
  }

  Row TabletLayout() {
    return Row(
      children: [
        Expanded(child: _buildColumn()),
        Expanded(child: _buildColumn()),
      ],
    );
  }

  Row DesktopLayout() {
    return Row(
      children: [
        Expanded(child: _buildColumn()),
        Expanded(child: _buildColumn()),
      ],
    );
  }

  SingleChildScrollView _buildColumn() {
    var largeur = MediaQuery.of(context).size.width;
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            Container(
              height: 30,
              child: _editQr == true
                  ? _tempProduitId.isNotEmpty
                      ? Text('ID : ${_tempProduitId}',
                          style: TextStyle(
                            fontSize: 20,
                          ))
                      : Text(
                          'L\'ID du Produit n\'a pas encore été créer',
                          style: TextStyle(fontSize: 20),
                        )
                  : Text(
                      'Nouveau ID du produit sera créer',
                      style: TextStyle(fontSize: 20),
                    ),
            ), //id
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Container(
                height: 30,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Switch(
                      value: _editQr,
                      onChanged: (bool newValue) {
                        setState(() {
                          _editQr = newValue;
                        });
                      },
                    ),
                    SizedBox(width: 10),
                    Expanded(
                      child: FittedBox(
                        child: Text(
                          _editQr
                              ? 'Recherche par Code QR Activé'
                              : 'Recherche par Code QR Désactivé',
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ), //switch recherche auto
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: _serialController.text.isNotEmpty
                  ? FlagDetector(
                      barcode: _serialController.text,
                      height: 30,
                      width: 50,
                    ) // Afficher FlagDetector avec le code-barres
                  : FlagDetector(
                      barcode: _serialController.text,
                      height: 30,
                      width: 50,
                    ),
            ), // Flag
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: TextFormField(
                controller: _serialController,
                focusNode:
                    _serialFocusNode, // Attache FocusNode au TextFormField
                textAlign: TextAlign.center,
                decoration: InputDecoration(
                  labelText: 'Code Barre / QrCode',
                  prefixIcon: _isFirstFieldFilled
                      ? IconButton(
                          icon: Icon(Icons.clear),
                          onPressed: _clearAllFields,
                          tooltip: 'Effacer tous les champs',
                        )
                      : null,
                  suffixIcon: (Platform.isIOS || Platform.isAndroid)
                      ? IconButton(
                          icon: Icon(Icons.qr_code_scanner),
                          onPressed: _scanQRCode,
                        )
                      : null,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8.0),
                    borderSide: BorderSide.none,
                  ),
                  filled: true,
                  contentPadding: EdgeInsets.all(15),
                ),
                onFieldSubmitted: (value) {
                  _addQRCodeFromText(); // Appel lors de l'appui sur "Entrée"
                },
              ),
            ), // Serial Qr Code
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Wrap(
                spacing: 8.0, // Espacement horizontal entre les Chips
                runSpacing: 7.0, // Espacement vertical entre les Chips
                children: [
                  if (_qrCodesTemp.isNotEmpty)
                    Chip(
                      padding: EdgeInsets.zero,
                      backgroundColor: Colors.blueAccent.withOpacity(0.2),
                      label: Text(
                        '${_qrCodesTemp.length}',
                      ), // Affiche le QR code dans le Chip
                    ),
                  ..._qrCodesTemp.map((code) {
                    return Chip(
                      padding: EdgeInsets.zero,
                      backgroundColor: Colors.blueAccent.withOpacity(0.2),
                      shape: RoundedRectangleBorder(
                        borderRadius:
                            BorderRadius.circular(20.0), // Coins arrondis
                      ),
                      avatar: CircularFlagDetector(
                        barcode: code,
                        size: 25, // Adjust the size as needed
                      ),
                      label: Text(code), // Affiche le QR code dans le Chip
                      deleteIcon: Icon(Icons.delete, color: Colors.red),
                      onDeleted: () {
                        setState(() {
                          _qrCodesTemp
                              .remove(code); // Supprime le QR code sélectionné
                        });
                      },
                    );
                  }),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: TextFormField(
                enabled: _isFirstFieldFilled || _qrCodesTemp.isNotEmpty,
                controller: _nomController,
                textAlign: TextAlign.center,
                keyboardType: TextInputType.text,
                decoration: InputDecoration(
                  //  fillColor: _isFirstFieldFilled ? Colors.green.shade100 : null,
                  suffixIcon: !_showDescription
                      ? Padding(
                          padding: const EdgeInsets.all(4.0),
                          child: IconButton(
                              onPressed: () {
                                setState(() {
                                  _showDescription = true;
                                });
                              },
                              icon: Icon(Icons.arrow_downward_rounded)),
                        )
                      : null,
                  labelText: 'Nom Du Produit',
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
                  filled: true,
                  contentPadding: EdgeInsets.all(15),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Veuillez entrer un nom du Produit';
                  }
                  return null;
                },
              ),
            ), // nom
            Container(
              child: !_showDescription
                  ? Container()
                  : Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Stack(
                        alignment: Alignment.topRight,
                        children: [
                          TextFormField(
                            enabled:
                                _isFirstFieldFilled || _qrCodesTemp.isNotEmpty,
                            controller: _descriptionController,
                            maxLines: 5,
                            keyboardType: TextInputType.text,
                            decoration: InputDecoration(
                              hintText: 'Déscription',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8.0),
                                borderSide:
                                    BorderSide.none, // Supprime le contour
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8.0),
                                borderSide: BorderSide
                                    .none, // Supprime le contour en état normal
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8.0),
                                borderSide: BorderSide
                                    .none, // Supprime le contour en état focus
                              ),
                              filled: true,
                              contentPadding: EdgeInsets.all(15),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(4.0),
                            child: IconButton(
                              icon: Icon(
                                Icons.close,
                              ),
                              onPressed: () {
                                setState(() {
                                  _showDescription = false;
                                });
                              },
                              tooltip: 'Effacer tous les champs',
                            ),
                          ),
                        ],
                      ),
                    ),
            ), // description
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Container(
                child: TextFormField(
                  enabled: _isFirstFieldFilled || _qrCodesTemp.isNotEmpty,
                  controller: _prixVenteController,
                  textAlign: TextAlign.center,
                  decoration: InputDecoration(
                    labelText: 'Prix de vente',
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
                  // keyboardType: TextInputType.number,
                  // validator: (value) {
                  //   if (value == null || value.isEmpty) {
                  //     return 'Veuillez entrer le prix de vente';
                  //   }
                  //   return null;
                  // },
                  keyboardType: TextInputType.numberWithOptions(decimal: true),
                  // inputFormatters: [
                  //   FilteringTextInputFormatter.allow(
                  //       RegExp(r'^\d+\.?\d{0,2}')),
                  // ],
                  // onChanged: (value) {
                  //   if (value.isNotEmpty) {
                  //     double? parsed = double.tryParse(value);
                  //     if (parsed != null) {
                  //       _prixVenteController.text = parsed.toStringAsFixed(2);
                  //       _prixVenteController.selection =
                  //           TextSelection.fromPosition(
                  //         TextPosition(
                  //             offset: _prixVenteController.text.length),
                  //       );
                  //     }
                  //   }
                  // },
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Veuillez entrer le prix d\'achat';
                    }
                    // if (double.tryParse(value) == null) {
                    //   return 'Veuillez entrer un prix valide';
                    // }
                    // return null;
                  },
                ),
              ),
            ), // prix de vente
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                children: [
                  Expanded(
                    flex: 3,
                    child: TextFormField(
                      enabled: _isFirstFieldFilled || _qrCodesTemp.isNotEmpty,
                      controller: _minimStockController,
                      textAlign: TextAlign.center,
                      decoration: InputDecoration(
                        labelText: 'Stock Alert',

                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8.0),
                          borderSide: BorderSide.none, // Supprime le contour
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8.0),
                          borderSide: BorderSide
                              .none, // Supprime le contour en état normal
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8.0),
                          borderSide: BorderSide
                              .none, // Supprime le contour en état focus
                        ),
                        //border: InputBorder.none,
                        filled: true,
                        contentPadding: EdgeInsets.all(15),
                      ),
                      keyboardType: TextInputType.number,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Veuillez entrer le Stock Minimal';
                        }
                        return null;
                      },
                    ),
                  ), // stock alert
                  SizedBox(width: 10),
                  Expanded(
                    flex: 2,
                    child: TextFormField(
                      enabled: _isFirstFieldFilled || _qrCodesTemp.isNotEmpty,
                      controller: _alertPeremptionController,
                      textAlign: TextAlign.center,
                      decoration: InputDecoration(
                        labelText: 'Alert Péremption',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8.0),
                          borderSide: BorderSide.none, // Supprime le contour
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8.0),
                          borderSide: BorderSide
                              .none, // Supprime le contour en état normal
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8.0),
                          borderSide: BorderSide
                              .none, // Supprime le contour en état focus
                        ),
                        //border: InputBorder.none,
                        filled: true,
                        contentPadding: EdgeInsets.all(15),
                      ),
                      // keyboardType: TextInputType.number,
                      //  validator: (value) {
                      //    if (value == null || value.isEmpty) {
                      //      return 'Veuillez entrer le prix d\'achat';
                      //    }
                      //    return null;
                      //  },
                      keyboardType:
                          TextInputType.numberWithOptions(decimal: false),
                      inputFormatters: [
                        FilteringTextInputFormatter.allow(
                            RegExp(r'^\d+\.?\d{0,2}')),
                      ],
                      // onChanged: (value) {
                      //   if (value.isNotEmpty) {
                      //     double? parsed = double.tryParse(value);
                      //     if (parsed != null) {
                      //       _prixAchatController.text = parsed.toStringAsFixed(2);
                      //       _prixAchatController.selection =
                      //           TextSelection.fromPosition(
                      //         TextPosition(
                      //             offset: _prixAchatController.text.length),
                      //       );
                      //     }
                      //   }
                      // },
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Veuillez entrer Le nombre de jours pour alerter la date de peremption';
                        }
                        // if (double.tryParse(value) == null) {
                        //   return 'Veuillez entrer un prix valide';
                        // }
                        // return null;
                      },
                    ),
                  ),
                ],
              ),
            ), // alert stock

            ///**********************************************************************
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: !_showAppro
                  ? _isFirstFieldFilled || _qrCodesTemp.isNotEmpty
                      ? IconButton(
                          icon: Icon(Icons.keyboard_arrow_down),
                          onPressed: () {
                            setState(() {
                              _showAppro = true;
                            });
                          },
                        )
                      : Container()
                  : Container(
                      padding: EdgeInsets.all(
                          8.0), // Espacement à l'intérieur du cadre
                      decoration: BoxDecoration(
                        //      color: Colors.grey, // Couleur de fond
                        borderRadius:
                            BorderRadius.circular(8.0), // Bords arrondis
                        border: Border.all(
                          color: Colors.grey, // Couleur de la bordure
                          width: 1.0, // Épaisseur de la bordure
                        ),
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: Icon(Icons.keyboard_arrow_up),
                            onPressed: () {
                              setState(() {
                                _showAppro = false;
                              });
                            },
                          ),
                          Row(
                            children: [
                              Flexible(
                                child: Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: TextFormField(
                                    enabled: _isFirstFieldFilled ||
                                        _qrCodesTemp.isNotEmpty,
                                    controller: _prixAchatController,
                                    textAlign: TextAlign.center,
                                    decoration: InputDecoration(
                                      labelText: 'Prix d\'achat',
                                      border: OutlineInputBorder(
                                        borderRadius:
                                            BorderRadius.circular(8.0),
                                        borderSide: BorderSide
                                            .none, // Supprime le contour
                                      ),
                                      enabledBorder: OutlineInputBorder(
                                        borderRadius:
                                            BorderRadius.circular(8.0),
                                        borderSide: BorderSide
                                            .none, // Supprime le contour en état normal
                                      ),
                                      focusedBorder: OutlineInputBorder(
                                        borderRadius:
                                            BorderRadius.circular(8.0),
                                        borderSide: BorderSide
                                            .none, // Supprime le contour en état focus
                                      ),
                                      //border: InputBorder.none,
                                      filled: true,
                                      contentPadding: EdgeInsets.all(15),
                                    ),
                                    // keyboardType: TextInputType.number,
                                    //  validator: (value) {
                                    //    if (value == null || value.isEmpty) {
                                    //      return 'Veuillez entrer le prix d\'achat';
                                    //    }
                                    //    return null;
                                    //  },
                                    keyboardType:
                                        TextInputType.numberWithOptions(
                                            decimal: true),
                                    inputFormatters: [
                                      FilteringTextInputFormatter.allow(
                                          RegExp(r'^\d+\.?\d{0,2}')),
                                    ],
                                    // onChanged: (value) {
                                    //   if (value.isNotEmpty) {
                                    //     double? parsed = double.tryParse(value);
                                    //     if (parsed != null) {
                                    //       _prixAchatController.text = parsed.toStringAsFixed(2);
                                    //       _prixAchatController.selection =
                                    //           TextSelection.fromPosition(
                                    //         TextPosition(
                                    //             offset: _prixAchatController.text.length),
                                    //       );
                                    //     }
                                    //   }
                                    // },
                                    // validator: (value) {
                                    //   if (value == null || value.isEmpty) {
                                    //     return 'Veuillez entrer le prix d\'achat';
                                    //   }
                                    //   // if (double.tryParse(value) == null) {
                                    //   //   return 'Veuillez entrer un prix valide';
                                    //   // }
                                    //   // return null;
                                    // },
                                  ),
                                ),
                              ), //prix d'achat
                              Flexible(
                                child: Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Container(
                                    width: largeur,
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.start,
                                      children: [
                                        // _editQr == true
                                        //     ? GestureDetector(
                                        //         onTap: () {
                                        //           _stockController.text =
                                        //               stockTemp.toString();
                                        //         },
                                        //         child: CircleAvatar(
                                        //           child: FittedBox(
                                        //               child: Padding(
                                        //             padding:
                                        //                 const EdgeInsets.all(5.0),
                                        //             child:
                                        //                 // Text(
                                        //                 //   _stockController.text.toString(),
                                        //                 // ),
                                        //                 Text(
                                        //                     '${double.parse(_stockController.text).toStringAsFixed(2)}'),
                                        //           )),
                                        //         ),
                                        //       )
                                        //     : Container(),
                                        // SizedBox(
                                        //   width: 8,
                                        // ),
                                        Expanded(
                                          flex: 5,
                                          child: TextFormField(
                                            enabled: _isFirstFieldFilled ||
                                                _qrCodesTemp.isNotEmpty,
                                            controller: _stockController,
                                            textAlign: TextAlign.center,
                                            decoration: InputDecoration(
                                              labelText: 'Stock',
                                              // suffixIcon: Padding(
                                              //   padding: const EdgeInsets.all(4.0),
                                              //   child: IconButton(
                                              //       onPressed: _showAddQuantityDialog,
                                              //       icon: Icon(Icons.add)),
                                              // ),

                                              border: OutlineInputBorder(
                                                borderRadius:
                                                    BorderRadius.circular(8.0),
                                                borderSide: BorderSide
                                                    .none, // Supprime le contour
                                              ),
                                              enabledBorder: OutlineInputBorder(
                                                borderRadius:
                                                    BorderRadius.circular(8.0),
                                                borderSide: BorderSide
                                                    .none, // Supprime le contour en état normal
                                              ),
                                              focusedBorder: OutlineInputBorder(
                                                borderRadius:
                                                    BorderRadius.circular(8.0),
                                                borderSide: BorderSide
                                                    .none, // Supprime le contour en état focus
                                              ),
                                              //border: InputBorder.none,
                                              filled: true,
                                              contentPadding:
                                                  EdgeInsets.all(15),
                                            ),
                                            keyboardType: TextInputType.number,
                                            // validator: (value) {
                                            //   if (value == null || value.isEmpty) {
                                            //     return 'Veuillez entrer le stock';
                                            //   }
                                            //   return null;
                                            // },
                                          ),
                                        ),

                                        // stock alert
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ), // stock
                          Flexible(
                            flex: 2,
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: TextFormField(
                                enabled: _isFirstFieldFilled ||
                                    _qrCodesTemp.isNotEmpty,
                                controller: _datePeremptionController,
                                textAlign: TextAlign.center,
                                keyboardType: TextInputType.text,
                                decoration: InputDecoration(
                                  // fillColor: _isFirstFieldFilled
                                  //     ? Colors.yellow.shade200
                                  //     : null,
                                  labelText: 'Date de Péremption',
                                  suffixIcon: IconButton(
                                    icon: const Icon(Icons.date_range),
                                    onPressed: () async {
                                      final DateTime? dateTimePerem =
                                          await showDatePicker(
                                        context: context,
                                        initialDate: selectedDate,
                                        firstDate: DateTime(2000),
                                        lastDate: DateTime(2200),
                                      );
                                      if (dateTimePerem != null) {
                                        setState(() {
                                          selectedDate = dateTimePerem;
                                          _datePeremptionController.text =
                                              dateTimePerem.format(
                                                  'yMMMMd', 'fr_FR');
                                        });
                                      }
                                    },
                                  ),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(8.0),
                                    borderSide:
                                        BorderSide.none, // Supprime le contour
                                  ),
                                  enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(8.0),
                                    borderSide: BorderSide
                                        .none, // Supprime le contour en état normal
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(8.0),
                                    borderSide: BorderSide
                                        .none, // Supprime le contour en état focus
                                  ),
                                  filled: true,
                                  contentPadding: EdgeInsets.all(15),
                                ),
                                // validator: (value) {
                                //   if (value == null || value.isEmpty) {
                                //     return 'Veuillez entrer un nom du Produit';
                                //   }
                                //   return null;
                                // },
                              ),
                            ),
                          ),
                          Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Container(
                                width: largeur,
                                child: Wrap(
                                  spacing: 8.0,
                                  runSpacing: 4.0,
                                  children: [
                                    // Affiche le fournisseur sélectionné
                                    if (_selectedFournisseur !=
                                        null) // Afficher seulement si un fournisseur est sélectionné
                                      GestureDetector(
                                        onTap: () async {
                                          final result =
                                              await Navigator.of(context).push(
                                            MaterialPageRoute(
                                              builder: (context) =>
                                                  FournisseurSelectionScreen(
                                                selectedFournisseur:
                                                    _selectedFournisseur,
                                                onSelectedFournisseurChanged:
                                                    _onSelectedFournisseurChanged,
                                              ),
                                            ),
                                          );
                                          if (result != null) {
                                            setState(() {
                                              _selectedFournisseur =
                                                  result; // Mettre à jour le fournisseur sélectionné
                                            });
                                          }
                                        },
                                        child: Chip(
                                          label: Text(_selectedFournisseur!
                                              .nom), // Afficher le nom du fournisseur sélectionné
                                          onDeleted: () {
                                            setState(() {
                                              _selectedFournisseur =
                                                  null; // Réinitialiser la sélection
                                            });
                                          },
                                        ),
                                      ),

                                    // Icône pour ajouter un fournisseur (toujours la dernière)
                                    _selectedFournisseur == null
                                        ? TextButton(
                                            style: ElevatedButton.styleFrom(
                                              foregroundColor: Theme.of(context)
                                                  .colorScheme
                                                  .primary,
                                              backgroundColor: Theme.of(context)
                                                  .colorScheme
                                                  .onPrimary,
                                              shape: RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(15.0),
                                              ),
                                            ),
                                            onPressed: () async {
                                              final result =
                                                  await Navigator.of(context)
                                                      .push(
                                                MaterialPageRoute(
                                                  builder: (context) =>
                                                      FournisseurSelectionScreen(
                                                    selectedFournisseur:
                                                        _selectedFournisseur,
                                                    onSelectedFournisseurChanged:
                                                        _onSelectedFournisseurChanged,
                                                  ),
                                                ),
                                              );
                                              if (result != null) {
                                                setState(() {
                                                  _selectedFournisseur =
                                                      result; // Mettre à jour le fournisseur sélectionné
                                                });
                                              }
                                            },
                                            child: const Text(
                                                'Selectionné un Fournisseur'),
                                          )
                                        : Container(),
                                    // IconButton(
                                    //   icon: Icon(Icons.add),
                                    //   onPressed: () async {
                                    //     final result =
                                    //         await Navigator.of(context).push(
                                    //       MaterialPageRoute(
                                    //         builder: (context) =>
                                    //             FournisseurSelectionScreen(
                                    //           selectedFournisseur:
                                    //               _selectedFournisseur,
                                    //           onSelectedFournisseurChanged:
                                    //               _onSelectedFournisseurChanged,
                                    //         ),
                                    //       ),
                                    //     );
                                    //     if (result != null) {
                                    //       setState(() {
                                    //         _selectedFournisseur =
                                    //             result; // Mettre à jour le fournisseur sélectionné
                                    //       });
                                    //     }
                                    //   },
                                    // ),
                                  ],
                                ),
                              )),

                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: ElevatedButton.icon(
                              icon: Icon(_isEditing ? Icons.edit : Icons.send,
                                  color:
                                      _isEditing ? Colors.blue : Colors.green),
                              onPressed: saveApprovisionnement,
                              label: Text(_isEditing
                                  ? 'Modifier le Stock'
                                  : 'Ajouter ce Stock'),
                            ),
                          ), //Ajouter ce Stock
                          Flexible(
                            child: Container(
                              width: largeur,
                              child: ListView.builder(
                                shrinkWrap: true,
                                physics: NeverScrollableScrollPhysics(),
                                itemCount: _approvisionnementTemporaire
                                    .length, // Utilisation de la liste temporaire
                                itemBuilder: (context, index) {
                                  // Utilisation de la liste inversée pour afficher les derniers en haut
                                  final approvisionnement =
                                      _approvisionnementTemporaire
                                          .reversed // Inversion de la liste
                                          .toList()[index];

                                  // Récupérer le fournisseur associé à cet approvisionnement
                                  final fournisseur =
                                      approvisionnement.fournisseur.target;

                                  return Card(
                                      child: InkWell(
                                    onTap: () {
                                      // Démarrer l'édition de cet approvisionnement
                                      startEditing(approvisionnement);
                                    },
                                    borderRadius: BorderRadius.circular(15),
                                    child: Row(
                                      children: [
                                        Expanded(
                                          flex: 3,
                                          child: Padding(
                                            padding: const EdgeInsets.all(8.0),
                                            child: Text(
                                              '${approvisionnement.quantite.toStringAsFixed(approvisionnement.quantite.truncateToDouble() == approvisionnement.quantite ? 0 : 2)}',
                                              style: TextStyle(fontSize: 20),
                                            ),
                                          ),
                                        ),
                                        Expanded(
                                          flex: 6,
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                fournisseur != null
                                                    ? fournisseur.nom
                                                    : 'Fournisseur non spécifié',
                                                overflow: TextOverflow.ellipsis,
                                                style: TextStyle(
                                                    fontSize: 15,
                                                    fontWeight:
                                                        FontWeight.bold),
                                              ),
                                              Text(
                                                approvisionnement
                                                            .datePeremption !=
                                                        null
                                                    ? 'Expire le : ${DateFormat('dd/MM/yyyy').format(approvisionnement.datePeremption!)}'
                                                    : 'Date de Expiration non spécifiée',
                                                style: TextStyle(
                                                  fontSize: 12,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.end,
                                          children: [
                                            Padding(
                                              padding: const EdgeInsets.only(
                                                  left: 8),
                                              child: Text(
                                                '${approvisionnement.prixAchat.toStringAsFixed(2)}',
                                                style: TextStyle(fontSize: 20),
                                              ),
                                            ),
                                            IconButton(
                                              padding: EdgeInsets.zero,
                                              icon: Icon(
                                                Icons.delete,
                                                color: Colors.red,
                                                size: 15,
                                              ),
                                              onPressed: () {
                                                // Appeler la méthode pour supprimer l'approvisionnement
                                                setState(() {
                                                  supprimerApprovisionnementTemporaire(
                                                      approvisionnement);
                                                  stockGlobale -=
                                                      approvisionnement
                                                          .quantite;
                                                });
                                              },
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ));
                                },
                              ),
                            ),
                          ), //Liste des approvisionnements
                        ],
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

class FournisseurSelectionScreen extends StatefulWidget {
  final Fournisseur? selectedFournisseur; // Un seul fournisseur sélectionné
  final Function(Fournisseur)
      onSelectedFournisseurChanged; // Callback pour le changement

  const FournisseurSelectionScreen({
    Key? key,
    required this.selectedFournisseur,
    required this.onSelectedFournisseurChanged,
  }) : super(key: key);

  @override
  _FournisseurSelectionScreenState createState() =>
      _FournisseurSelectionScreenState();
}

class _FournisseurSelectionScreenState
    extends State<FournisseurSelectionScreen> {
  String _searchQuery = '';
  Fournisseur? _selectedFournisseur; // Pour stocker le fournisseur sélectionné

  @override
  void initState() {
    super.initState();
    _selectedFournisseur = widget.selectedFournisseur; // Initialisation
  }

  @override
  Widget build(BuildContext context) {
    final fournisseurProvider = Provider.of<CommerceProvider>(context);
    List<Fournisseur> filteredFournisseurs =
        fournisseurProvider.fournisseurs.where((fournisseur) {
      return fournisseur.nom.toLowerCase().contains(_searchQuery.toLowerCase());
    }).toList();

    return Scaffold(
      appBar: AppBar(
        title: Text('Sélectionner un Fournisseur'),
      ),
      body: Column(
        children: [
          TextField(
            decoration: InputDecoration(labelText: 'Rechercher'),
            onChanged: (value) {
              setState(() {
                _searchQuery = value;
              });
            },
          ),
          // ElevatedButton(
          //   onPressed: () {
          //     if (_selectedFournisseur != null) {
          //       widget.onSelectedFournisseurChanged(_selectedFournisseur!);
          //     }
          //     Navigator.of(context).pop();
          //   },
          //   child: Text('Sauvegarder Sélection'),
          // ),
          Expanded(
            child: ListView.builder(
              itemCount: filteredFournisseurs.length,
              itemBuilder: (context, index) {
                final fournisseur = filteredFournisseurs[index];
                final isSelected = _selectedFournisseur ==
                    fournisseur; // Vérifie si c'est le fournisseur sélectionné
                return ListTile(
                  title: Text(fournisseur.nom),
                  tileColor: isSelected
                      ? Colors.blue.withOpacity(0.2)
                      : null, // Met en surbrillance le fournisseur sélectionné
                  onTap: () {
                    // Met à jour le fournisseur sélectionné
                    _selectedFournisseur = fournisseur;

                    // Appelle la fonction de callback pour notifier l'écran parent
                    if (_selectedFournisseur != null) {
                      widget
                          .onSelectedFournisseurChanged(_selectedFournisseur!);
                    }

                    // Renvoie le fournisseur sélectionné et ferme l'écran
                    Navigator.of(context).pop(_selectedFournisseur);
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
