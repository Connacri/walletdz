import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:dart_date/dart_date.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:path/path.dart' as path;
import '../Entity.dart';
import '../MyProviders.dart';
import '../Utils/country_flags.dart';
import '../Utils/mobile_scanner/barcode_scanner_window.dart';

class addProduct2 extends StatefulWidget {
  const addProduct2({super.key});

  @override
  State<addProduct2> createState() => _addProduct2State();
}

class _addProduct2State extends State<addProduct2> {
  @override
  Widget build(BuildContext context) {
    return ResponsiveLayout2();
  }
}

class ResponsiveLayout2 extends StatefulWidget {
  const ResponsiveLayout2({super.key});

  @override
  State<ResponsiveLayout2> createState() => _ResponsiveLayout2State();
}

class _ResponsiveLayout2State extends State<ResponsiveLayout2> {
  final _formKey = GlobalKey<FormState>();
  final _nomController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _prixAchatController = TextEditingController();
  final _prixVenteController = TextEditingController();
  final _stockController = TextEditingController();
  final _serialController = TextEditingController();
  final _datePeremptionController = TextEditingController();
  final _minimStockController = TextEditingController(text: '5');
  final _alertPeremptionController = TextEditingController(text: '2');
  final _qtyPartielController = TextEditingController(text: '1');
  final _pricePartielVenteController = TextEditingController(text: '1');

  final FocusNode _serialFocusNode = FocusNode();
  final FocusNode _focusNodeNom = FocusNode();
  final FocusNode _focusNodePV = FocusNode();
  final FocusNode _focusNodeStock = FocusNode();

  File? _image;
  String? _existingImageUrl;
  String _tempProduitId = '';
  double stockTemp = 0;
  final List<String> _qrCodesTemp = [];
  List<Fournisseur> _selectedFournisseurs = [];
  List<Approvisionnement> _approvisionnementTemporaire = [];
  bool _isFinded = false;
  bool _searchQr = true;
  bool _isFirstFieldRempli = false;
  bool _showDescription = false;

  @override
  void initState() {
    super.initState();
    _serialController.addListener(_onSerialChanged);
    _serialController.addListener(_checkFirstField);
    _clearAllFields();

    _qrCodesTemp.clear();
    _selectedFournisseurs.clear();
    _approvisionnementTemporaire.clear();
    _showDescription = false;
    _isFirstFieldRempli = false;
    _isFinded = false;
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

    if (_searchQr) {
      _updateProductInfo(code);
    }
  }

  void _checkFirstField() {
    // _serialController.text.isEmpty
    //     ? _approvisionnementTemporaire.clear()
    //     : null; /////// A VOIRE
    setState(() {
      _isFirstFieldRempli = _serialController.text.isNotEmpty;
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
        _minimStockController.text = produit.minimStock!.toStringAsFixed(2);
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
    } else {
      if (_tempProduitId.isNotEmpty) {
        _tempProduitId = '';
        _nomController.clear();
        _descriptionController.clear();
        stockTemp = 0.0;
        _prixAchatController.clear();
        _prixVenteController.clear();
        _stockController.clear();
        _selectedFournisseurs.clear();
        _datePeremptionController.clear();
        _minimStockController.clear();
        _alertPeremptionController.clear();
        _approvisionnementTemporaire.clear();
        _existingImageUrl = '';
        _isFinded = false;
        _image = null;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final produitProvider =
        Provider.of<CommerceProvider>(context, listen: false);
    return SafeArea(
      child: LayoutBuilder(
        builder: (context, constraints) {
          if (constraints.maxWidth < 600) {
            // Mobile layout
            return SafeArea(
              child: Scaffold(
                  resizeToAvoidBottomInset: true,
                  appBar: AppBar(
                    actions: [
                      buildButton_Edit_Add(context, produitProvider, _isFinded)
                    ],
                  ),
                  body: Form(
                    key: _formKey,
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: MobileLayout(),
                    ),
                  )),
            );
          } else if (constraints.maxWidth < 1200) {
            // Tablet layout
            return SafeArea(
              child: Scaffold(
                  resizeToAvoidBottomInset: true,
                  appBar: AppBar(
                    actions: [
                      buildButton_Edit_Add(context, produitProvider, _isFinded)
                    ],
                  ),
                  body: Form(
                    key: _formKey,
                    child: Center(
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Container(
                            constraints: BoxConstraints(
                              maxWidth: 400, // largeur maximale de 200 pixels
                              // maxHeight: 100,  // hauteur maximale de 100 pixels
                            ),
                            child: TabletLayout()),
                      ),
                    ),
                  )),
            );
          } else {
            // Desktop layout
            return SafeArea(
              child: Scaffold(
                  resizeToAvoidBottomInset: true,
                  appBar: AppBar(
                    actions: [
                      buildButton_Edit_Add(context, produitProvider, _isFinded)
                    ],
                  ),
                  body: Form(
                    key: _formKey,
                    child: Center(
                      child: Container(
                        constraints: BoxConstraints(
                          maxWidth: 400, // largeur maximale de 200 pixels
                          // maxHeight: 100,  // hauteur maximale de 100 pixels
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: DesktopLayout(),
                        ),
                      ),
                    ),
                  )),
            );
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
        //Expanded(child: _buildColumn()),
      ],
    );
  }

  Row DesktopLayout() {
    return Row(
      children: [
        Expanded(child: _buildColumn()),
        // Expanded(child: _buildColumn()),
      ],
    );
  }

  SingleChildScrollView _buildColumn() {
    var largeur = MediaQuery.of(context).size.width;
    final produitProvider =
        Provider.of<CommerceProvider>(context, listen: false);
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            Container(
              height: 30,
              child: _searchQr == true
                  ? _tempProduitId.isNotEmpty
                      ? Text('ID : ${_tempProduitId}',
                          style: TextStyle(fontSize: 15, color: Colors.black54))
                      : Text(
                          'L\'ID du Produit n\'a pas encore été créer',
                          style: TextStyle(fontSize: 15, color: Colors.black54),
                        )
                  : Text(
                      'Nouveau ID du produit sera créer',
                      style: TextStyle(fontSize: 15, color: Colors.black54),
                    ),
            ), //id
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Container(
                height: 30,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Transform.scale(
                      scale:
                          0.8, // Ajustez cette valeur pour modifier la taille (1.0 est la taille par défaut)
                      child: Switch(
                        value: _searchQr,
                        onChanged: (bool newValue) {
                          setState(() {
                            _searchQr = newValue;
                          });
                        },
                      ),
                    ),
                    SizedBox(width: 10),
                    Expanded(
                      child: FittedBox(
                        child: Text(
                          _searchQr
                              ? 'Recherche par Codes-barres Activé'
                              : 'Recherche par Codes-barres Désactivé',
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ), //switch recherche auto
            _isFirstFieldRempli || _qrCodesTemp.isNotEmpty
                ? Padding(
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
                  )
                : Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Container(
                      height: 30,
                      width: 50,
                    ),
                  ), // Flag
            Padding(
              padding: const EdgeInsets.fromLTRB(8, 8, 8, 8),
              child: TextFormField(
                controller: _serialController,
                focusNode:
                    _serialFocusNode, // Attache FocusNode au TextFormField
                textAlign: TextAlign.center,
                decoration: InputDecoration(
                  labelText: 'Code Barre / QrCode',
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
            _isFirstFieldRempli || _qrCodesTemp.isNotEmpty
                ? Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: buildColumnPicSuppliers(largeur, context),
                  )
                : Container(), // photo
            _qrCodesTemp.isEmpty
                ? Container()
                : Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Wrap(
                      spacing: 8.0, // Espacement horizontal entre les Chips
                      runSpacing: 7.0, // Espacement vertical entre les Chips
                      children: [
                        if (_qrCodesTemp.isNotEmpty)
                          Chip(
                            padding: EdgeInsets.zero,
                            backgroundColor:
                                Theme.of(context).brightness == Brightness.dark
                                    ? Colors.blueAccent.withOpacity(
                                        0.2) // Couleur pour le thème sombre
                                    : Colors.blueAccent.withOpacity(
                                        0.6), // Couleur pour le thème clair
                            visualDensity: VisualDensity(vertical: -1),
                            label: Text(
                              '${_qrCodesTemp.length}',
                              style: TextStyle(
                                color: Theme.of(context).brightness ==
                                        Brightness.dark
                                    ? Colors
                                        .white // Couleur du texte pour le thème sombre
                                    : Colors
                                        .black, // Couleur du texte pour le thème clair
                              ),
                            ),
                          ),
                        ..._qrCodesTemp.map(
                          (code) => Chip(
                            padding: EdgeInsets.zero,
                            backgroundColor:
                                Theme.of(context).brightness == Brightness.dark
                                    ? Colors.blueAccent.withOpacity(
                                        0.2) // Couleur pour le thème sombre
                                    : Colors.blueAccent.withOpacity(
                                        0.6), // Couleur pour le thème clair
                            shape: RoundedRectangleBorder(
                              borderRadius:
                                  BorderRadius.circular(20.0), // Coins arrondis
                            ),
                            avatar: Align(
                              alignment: Alignment
                                  .center, // Centre l'avatar verticalement
                              child: CircularFlagDetector(
                                barcode: code,
                                size: 25, // Adjust the size as needed
                              ),
                            ),
                            visualDensity: VisualDensity(
                                vertical:
                                    -1), // Ajustement vertical pour recentrer le contenu
                            label: Text(
                              code,
                              style: TextStyle(
                                color: Theme.of(context).brightness ==
                                        Brightness.dark
                                    ? Colors
                                        .white // Couleur du texte pour le thème sombre
                                    : Colors
                                        .black, // Couleur du texte pour le thème clair
                              ),
                            ), // Affiche le QR code dans le Chip
                            deleteIcon: Icon(Icons.delete, color: Colors.red),

                            onDeleted: () {
                              setState(() {
                                _qrCodesTemp.remove(
                                    code); // Supprime le QR code sélectionné
                              });
                            },
                          ),
                        ),
                      ],
                    ),
                  ), // wrap qrcode
            _isFirstFieldRempli || _qrCodesTemp.isNotEmpty
                ? Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: TextFormField(
                      //enabled: _isFirstFieldRempli || _qrCodesTemp.isNotEmpty,
                      controller: _nomController,
                      textAlign: TextAlign.center,
                      keyboardType: TextInputType.text,
                      textInputAction: TextInputAction.next, // Action "Suivant"
                      onFieldSubmitted: (_) {
                        _focusNodePV.requestFocus(); // Passe au champ 2
                      },
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
                        prefixIcon: _isFirstFieldRempli
                            ? IconButton(
                                icon: Icon(Icons.clear),
                                onPressed: () {
                                  _clearAllFields();
                                },
                                tooltip: 'Effacer tous les champs',
                              )
                            : null,
                        labelText: 'Nom Du Produit',
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
                  )
                : Container(), // nom
            Container(
              child: !_showDescription
                  ? Container()
                  : Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Stack(
                        alignment: Alignment.topRight,
                        children: [
                          TextFormField(
                            controller: _descriptionController,
                            maxLines: 5,
                            keyboardType: TextInputType.text,
                            textInputAction:
                                TextInputAction.next, // Action "Suivant"
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
                                Icons.arrow_upward,
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
            _isFirstFieldRempli || _qrCodesTemp.isNotEmpty
                ? Container(
                    width: largeur,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: TextFormField(
                              enabled: _isFirstFieldRempli ||
                                  _qrCodesTemp.isNotEmpty,
                              controller: _prixVenteController,
                              textAlign: TextAlign.center,
                              textInputAction:
                                  TextInputAction.next, // Action "Suivant"
                              onFieldSubmitted: (_) {
                                _focusNodeStock
                                    .requestFocus(); // Passe au champ 2
                              },
                              decoration: InputDecoration(
                                labelText: 'Prix de vente',
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
                              keyboardType: TextInputType.numberWithOptions(
                                  decimal: true),
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

                        // stock alert
                      ],
                    ),
                  )
                : Container(),
            SizedBox(
              height: 50,
            )
          ],
        ),
      ),
    );
  }

  void _clearAllFields() {
    setState(() {
      _tempProduitId = '';
      //_serialController.clear();
      stockTemp = 0.0;
      _nomController.clear();
      _descriptionController.clear();
      _prixAchatController.clear();
      _prixVenteController.clear();
      _stockController.clear();
      _minimStockController.clear();
      //_selectedFournisseurs.clear();
      // _datePeremptionController.clear();
      _alertPeremptionController.clear();
      _existingImageUrl = '';
      //_isFirstFieldFilled = false;
      _image = null;
      _approvisionnementTemporaire.clear();
    });
  }

  Future<String> uploadImageToSupabase(File image, String? oldImageUrl) async {
    final String bucket = 'products';
    final supabase = Supabase.instance.client;
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final fileName =
        '${_prixVenteController.text}${_stockController.text}$timestamp${path.extension(image.path)}';

    try {
      await supabase.storage.from(bucket).upload(fileName, image);

      final imageUrl = supabase.storage.from(bucket).getPublicUrl(fileName);
      if (oldImageUrl != null && oldImageUrl.isNotEmpty) {
        final oldFileName = Uri.parse(oldImageUrl).pathSegments.last;
        await supabase.storage.from(bucket).remove([oldFileName]);
      }

      return imageUrl;
    } catch (e) {
      print('Erreur lors du téléchargement de l\'image : $e');
      return '';
    }
  }

  IconButton buildButton_Edit_Add(
      BuildContext context, CommerceProvider produitProvider, bool _isFinded) {
    return IconButton(
      onPressed: () async {
        final produitDejaExist =
            await produitProvider.getProduitByQr(_serialController.text);

        if (_formKey.currentState!.validate()) {
          String imageUrl = '';

          // Gestion de l'image du produit
          if (_image != null) {
            imageUrl = await uploadImageToSupabase(_image!, _existingImageUrl);
          } else if (_existingImageUrl != null &&
              _existingImageUrl!.isNotEmpty) {
            imageUrl = _existingImageUrl!;
          }

          final code = _serialController.text.trim();
          code.isEmpty || code == '' ? null : _qrCodesTemp.add(code);
          // Création du produit
          final produit = Produit(
            qr: _qrCodesTemp.toSet().toList().join(',').toString(),
            image: imageUrl,
            nom: _nomController.text,
            description: _descriptionController.text,
            prixVente: double.parse(_prixVenteController.text),
            qtyPartiel: double.parse(_qtyPartielController.text),
            pricePartielVente: double.parse(_pricePartielVenteController.text),
            // alertPeremption: int.parse(_alertPeremptionController.text),
            // minimStock: double.parse(_minimStockController.text),
            derniereModification: DateTime.now(),
          )..crud.target = Crud(
              createdBy: 1,
              updatedBy: 1,
              deletedBy: 1,
              dateCreation: DateTime.now(),
              derniereModification: DateTime.now(),
              dateDeleting: null,
            );

          // Ajout des approvisionnements depuis _approvisionnementTemporaire
          for (int i = 0; i < _approvisionnementTemporaire.length; i++) {
            var approvisionnement = _approvisionnementTemporaire[i];

            // Associer le produit à chaque approvisionnement
            approvisionnement.produit.target = produit;

            // Associer le fournisseur correspondant à chaque approvisionnement
            if (i < _selectedFournisseurs.length) {
              approvisionnement.fournisseur.target = _selectedFournisseurs[i];
            }

            // Ajouter les données Crud pour chaque approvisionnement
            approvisionnement.crud.target = Crud(
              createdBy: 1,
              updatedBy: 1,
              deletedBy: 1,
              dateCreation: DateTime.now(),
              derniereModification: DateTime.now(),
            );
          }

          // Vérification si un produit existe déjà
          if (produitDejaExist == null) {
            // Nouveau produit
            produitProvider.ajouterProduit(
                produit, _selectedFournisseurs, _approvisionnementTemporaire);
            print('Nouveau produit ajouté');

            _formKey.currentState!.save();
            Navigator.of(context).pop();
          } else {
            _addQRCodeFromText();
            print('Produit deja existe');
          }
        }
      },
      icon: Icon(
        _isFinded ? Icons.edit : Icons.check,
      ),
    );
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
    if (produit != null) {
      showExistingProductDialog(context, code, produit, provider);
    }
    // Rediriger le focus vers le TextFormField après l'ajout
    FocusScope.of(context).requestFocus(_serialFocusNode);

    if (code.isNotEmpty && !_qrCodesTemp.contains(code)) {
      setState(() {
        _serialController.text = code;
        _qrCodesTemp.add(code); // Ajout du QR code à la liste temporaire
        _searchQr = false;
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
          _minimStockController.text = produit.minimStock!.toStringAsFixed(2);
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

  // Méthode séparée pour afficher le dialogue
  void showExistingProductDialog(BuildContext context, String code,
      Produit produit, CommerceProvider provider) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(20)),
          ),
          titlePadding: EdgeInsets.all(0),
          contentPadding: EdgeInsets.all(20),
          title: Padding(
            padding: const EdgeInsets.all(28.0),
            child: FittedBox(
              child: Text(
                'Code ${code}\ndéjà utilisé',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                  fontFamily: 'Oswald',
                ),
              ),
            ),
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: RichText(
                    text: TextSpan(
                      text: 'Le Code Bar ${code}'.toUpperCase(),
                      style: TextStyle(
                        color: Colors.blueGrey,
                        fontSize: 20,
                        fontFamily: 'Oswald',
                      ),
                      children: <TextSpan>[
                        TextSpan(
                          text: ' est déjà associé au : '.toUpperCase(),
                          style: TextStyle(
                            fontFamily: 'Oswald',
                            color: Colors.black54,
                            fontSize: 20,
                          ),
                        ),
                        TextSpan(
                          text: '${produit.nom}'.toUpperCase(),
                          style: TextStyle(
                            color: Colors.green,
                            fontFamily: 'Oswald',
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                SizedBox(height: 10),
                if (produit.description != null &&
                    produit.description!.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4.0),
                    child: Text(
                      'Description : ${produit.description}',
                      textAlign: TextAlign.justify,
                      style: TextStyle(fontSize: 18, color: Colors.black87),
                    ),
                  ),
                Text(
                  'Prix de vente : ${produit.prixVente.toStringAsFixed(2)} DA',
                  style: TextStyle(fontSize: 18, color: Colors.black54),
                ),
                Text(
                  'Stock : ${produit.stock.toStringAsFixed(2)}',
                  style: TextStyle(fontSize: 18, color: Colors.black54),
                ),
                Text(
                  'Dernière Modification : ${produit.derniereModification.format('yMMMMd', 'fr_FR')}',
                  style: TextStyle(fontSize: 15, color: Colors.black54),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Center(
                    child: produit.image != null
                        ? ClipRRect(
                            borderRadius: BorderRadius.circular(8.0),
                            child: AspectRatio(
                              aspectRatio: 1,
                              child: CachedNetworkImage(
                                imageUrl: produit.image!,
                                fit: BoxFit.cover,
                                placeholder: (context, url) => Center(
                                  child: CircularProgressIndicator(),
                                ),
                                errorWidget: (context, url, error) =>
                                    Icon(Icons.error, color: Colors.red),
                              ),
                            ),
                          )
                        : Container(),
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              style: TextButton.styleFrom(foregroundColor: Colors.red),
              child: Text('Supprimer le QR code'),
              onPressed: () async {
                await provider.removeQRCodeFromProduit(produit.id, code);
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text('OK', style: TextStyle(color: Colors.blue)),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

// Votre méthode _addQRCodeFromText modifiée
  void _addQRCodeFromText() async {
    final code = _serialController.text.trim();
    final provider = Provider.of<CommerceProvider>(context, listen: false);
    final produit = await provider.getProduitByQr(code);

    if (produit != null) {
      showExistingProductDialog(context, code, produit, provider);
    }

    if (produit == null) {
      if (code.isNotEmpty && !_qrCodesTemp.contains(code)) {
        setState(() {
          _qrCodesTemp.add(code);
          _serialController.clear();
          _searchQr = false;
        });
      } else {
        _serialController.clear();
      }
      FocusScope.of(context).requestFocus(_serialFocusNode);
    }
  }
  // Ajouter manuellement un QR code via le TextFormField et la touche "Entrée"
//   void _addQRCodeFromText() async {
//     final code = _serialController.text.trim();
//     final provider = Provider.of<CommerceProvider>(context, listen: false);
//     final produit = await provider.getProduitByQr(code);
//     //   print(produit!.qr);
// // Afficher une alerte avec les détails du produit existant
//     if (produit != null)
//       showDialog(
//         context: context,
//         builder: (BuildContext context) {
//           return AlertDialog(
//             shape: RoundedRectangleBorder(
//               borderRadius: BorderRadius.all(Radius.circular(20)),
//             ),
//             titlePadding: EdgeInsets.all(0),
//             contentPadding: EdgeInsets.all(20),
//             title: Padding(
//               padding: const EdgeInsets.all(28.0),
//               child: FittedBox(
//                 child: Text(
//                   'Code ${code}\ndéjà utilisé',
//                   textAlign: TextAlign.center,
//                   style: TextStyle(
//                     fontSize: 24,
//                     fontWeight: FontWeight.bold,
//                     color: Colors.black87,
//                     fontFamily: 'Oswald',
//                   ),
//                 ),
//               ),
//             ),
//             content: SingleChildScrollView(
//               // Permet de faire défiler si le contenu déborde
//               child: Column(
//                 mainAxisSize: MainAxisSize.min,
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   Center(
//                     child: RichText(
//                       text: TextSpan(
//                         text: 'Le Code Bar ${code}'.toUpperCase(),
//                         style: TextStyle(
//                           color: Colors.blueGrey,
//                           fontSize: 20,
//                           fontFamily: 'Oswald',
//                         ),
//                         children: <TextSpan>[
//                           TextSpan(
//                             text: ' est déjà associé au : '.toUpperCase(),
//                             style: TextStyle(
//                               fontFamily: 'Oswald',
//                               color: Colors.black54,
//                               fontSize: 20,
//                             ),
//                           ),
//                           TextSpan(
//                             text: '${produit.nom}'.toUpperCase(),
//                             style: TextStyle(
//                               color: Colors.green,
//                               fontFamily: 'Oswald',
//                               fontSize: 20,
//                               fontWeight: FontWeight
//                                   .bold, // Pour mettre en valeur le nom du produit
//                             ),
//                           ),
//                         ],
//                       ),
//                     ),
//                   ),
//                   SizedBox(height: 10),
//                   if (produit.description != null &&
//                       produit.description!
//                           .isNotEmpty) // Utilisation de l'opérateur de contrôle nul
//                     Padding(
//                       padding: const EdgeInsets.symmetric(vertical: 4.0),
//                       child: Text(
//                         'Description : ${produit.description}',
//                         textAlign: TextAlign.justify,
//                         style: TextStyle(fontSize: 18, color: Colors.black87),
//                       ),
//                     ),
//                   Text(
//                     'Prix de vente : ${produit.prixVente.toStringAsFixed(2)} DA',
//                     style: TextStyle(fontSize: 18, color: Colors.black54),
//                   ),
//                   Text(
//                     'Stock : ${produit.stock.toStringAsFixed(2)}',
//                     style: TextStyle(fontSize: 18, color: Colors.black54),
//                   ),
//                   Text(
//                     'Dernière Modification : ${produit.derniereModification.format('yMMMMd', 'fr_FR')}',
//                     style: TextStyle(fontSize: 15, color: Colors.black54),
//                   ),
//                   Padding(
//                     padding: const EdgeInsets.all(8.0),
//                     child: Center(
//                       child: produit.image != null
//                           ? ClipRRect(
//                               borderRadius: BorderRadius.circular(8.0),
//                               child: AspectRatio(
//                                 aspectRatio: 1,
//                                 child: CachedNetworkImage(
//                                   imageUrl: produit.image!,
//                                   fit: BoxFit.cover,
//                                   placeholder: (context, url) => Center(
//                                     child: CircularProgressIndicator(),
//                                   ),
//                                   errorWidget: (context, url, error) =>
//                                       Icon(Icons.error, color: Colors.red),
//                                 ),
//                               ),
//                             )
//                           : Container(),
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//             actions: [
//               TextButton(
//                 style: TextButton.styleFrom(
//                     foregroundColor:
//                         Colors.red), // Couleur rouge pour "Supprimer"
//                 child: Text('Supprimer le QR code'),
//                 onPressed: () async {
//                   // Supprimer le QR code de la liste des QR codes du produit
//                   await provider.removeQRCodeFromProduit(produit.id, code);
//                   Navigator.of(context).pop(); // Fermer le dialog
//                 },
//               ),
//               TextButton(
//                 child: Text('OK',
//                     style: TextStyle(
//                         color: Colors.blue)), // Couleur bleue pour "OK"
//                 onPressed: () {
//                   Navigator.of(context).pop(); // Fermer le dialog
//                 },
//               ),
//             ],
//           );
//         },
//       );
//
//     if (produit == null) if (code.isNotEmpty && !_qrCodesTemp.contains(code)) {
//       setState(() {
//         _qrCodesTemp.add(code); // Ajouter le QR code dans la liste temporaire
//         _serialController.clear(); // Effacer le champ de texte après l'ajout
//         _searchQr = false;
//       });
//     } else {
//       _serialController.clear(); // Effacer le champ de texte après l'ajout
//     }
//     // Rediriger le focus vers le TextFormField après l'ajout
//     FocusScope.of(context).requestFocus(_serialFocusNode);
//   }

  Container buildColumnPicSuppliers(double largeur, BuildContext context) {
    return Container(
      child: Center(
        child: Container(
          width: largeur,
          height: Platform.isAndroid || Platform.isIOS ? 150 : 300,
          child: _image == null
              ? Stack(
                  alignment: Alignment.center,
                  children: [
                    _existingImageUrl != null && _existingImageUrl!.isNotEmpty
                        ? Container(
                            decoration: BoxDecoration(
                              borderRadius:
                                  BorderRadius.circular(8.0), // Bords arrondis
                              border: Border.all(
                                color: Colors.grey, // Couleur de la bordure
                                width: 1.0, // Épaisseur de la bordure
                              ),
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(8.0),
                              child: CachedNetworkImage(
                                imageUrl: _existingImageUrl!,
                                fit: BoxFit.cover, // Remplir le container
                                width: double.infinity, // Remplir en largeur
                                height: double.infinity, // Remplir en hauteur
                                placeholder: (context, url) => Center(
                                  child:
                                      CircularProgressIndicator(), // Indicateur de chargement
                                ),
                                errorWidget: (context, url, error) =>
                                    Container(), // Widget en cas d'erreur
                              ),
                            ),
                          )
                        : Container(
                            decoration: BoxDecoration(
                              borderRadius:
                                  BorderRadius.circular(8.0), // Bords arrondis
                              border: Border.all(
                                color: Colors.grey, // Couleur de la bordure
                                width: 1.0, // Épaisseur de la bordure
                              ),
                            ),
                          ),
                    IconButton(
                      onPressed: _pickImage,
                      icon: Icon(
                        Icons.add_a_photo,
                        color: Colors.blue,
                      ),
                    ),
                  ],
                )
              : InkWell(
                  onTap: () {
                    setState(() {
                      _image = null;
                    });
                  },
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8.0),
                        child: Image.file(
                          _image!,
                          fit: BoxFit.cover, // Remplir le container
                          width: double.infinity, // Remplir en largeur
                          height: double.infinity, // Remplir en hauteur
                        ),
                      ),
                      Icon(
                        Icons.delete,
                        color: Colors.red,
                      ),
                    ],
                  ),
                ),
        ),
      ),
    );
  }

  Future<void> _pickImage() async {
    final ImageSource? source = Platform.isAndroid || Platform.isIOS
        ? await showDialog<ImageSource>(
            context: context,
            builder: (BuildContext context) {
              return SimpleDialog(
                title: const Text('Choisir une source'),
                children: <Widget>[
                  SimpleDialogOption(
                    padding: EdgeInsets.all(15),
                    onPressed: () {
                      Navigator.pop(context, ImageSource.gallery);
                    },
                    child: Row(
                      children: [
                        Icon(Icons.photo),
                        SizedBox(
                          width: 5,
                        ),
                        const Text('Galerie'),
                      ],
                    ),
                  ),
                  // Platform.isAndroid || Platform.isIOS
                  //     ?
                  SimpleDialogOption(
                    padding: EdgeInsets.all(15),
                    onPressed: () {
                      Navigator.pop(context, ImageSource.camera);
                    },
                    child: Row(
                      children: [
                        Icon(Icons.camera_alt),
                        SizedBox(
                          width: 5,
                        ),
                        const Text('Caméra'),
                      ],
                    ),
                  )
                  // : Container()
                  ,
                ],
              );
            },
          )
        : ImageSource.gallery;

    if (source != null) {
      final pickedFile = await ImagePicker().pickImage(
        source: source,
        maxHeight: 1080,
        maxWidth: 1920,
        imageQuality: 40,
      );

      if (pickedFile != null) {
        setState(() {
          _image = File(pickedFile.path);
        });
      }
    }
  }
}
