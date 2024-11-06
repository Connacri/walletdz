import 'dart:io';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:lottie/lottie.dart';
import 'package:string_extensions/string_extensions.dart';
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
import '../Utils/winMobile.dart';

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
  final _formKeyApp = GlobalKey<FormState>();
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
  String _produitNom = '';
  String _produitDesignation = '';
  String _produitImage = '';
  String _produitQr = '';
  double _produitStock = 0.0;
  double stockGlobale = 0.0; // Déclaration de la variable
  double stockTemp = 0;
  double _produitPV = 0.0;

  DateTime selectedDate = DateTime.now();
  final List<String> _qrCodesTemp = [];
  List<Fournisseur> _selectedFournisseurs = [];

  Fournisseur? _selectedFournisseur;
  Fournisseur? _currentFournisseur;
  Approvisionnement? _currentApprovisionnement;
  List<Approvisionnement> _approvisionnementTemporaire = [];
  bool _isFinded = false;
  bool _searchQr = true;
  bool _isFirstFieldRempli = false;
  bool _showDescription = false;
  bool _showAppro = false;
  bool _isEditing = false;
  bool _isLoadingSauv = false;

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
    final code = _serialController.text.replaceAll(' ', '');

    // Vérifie si le champ est vide en premier lieu pour éviter des opérations inutiles.
    if (code.isEmpty && _qrCodesTemp.isEmpty
        // || _serialController.text == ''
        /*|| code == _lastScannedCode*/) {
      _clearAllFields();

      // return;
    }

    if (_searchQr) {
      //_updateProductInfo(code);
      _productInfo(code);
    }
  }

  void _checkFirstField() {
    // _serialController.text.isEmpty
    //     ? _approvisionnementTemporaire.clear()
    //     : null; /////// A VOIRE
    setState(() {
      _isFirstFieldRempli = _serialController.text.trim().isNotEmpty;
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
        _tempProduitId = produit.id.toString();
        _nomController.text = produit.nom;
        _descriptionController.text = produit.description ?? '';
        //   _prixAchatController.text = produit.prixAchat.toStringAsFixed(2);
        _prixVenteController.text = produit.prixVente.toStringAsFixed(2);
        _stockController.text = produit.stock.toStringAsFixed(2);
        // _minimStockController.text = produit.minimStock!.toStringAsFixed(2);
        stockTemp = double.parse(produit.stock.toStringAsFixed(2));
        // _datePeremptionController.text =
        //     produit.datePeremption!.format('yMMMMd', 'fr_FR');
        _alertPeremptionController.text = produit.alertPeremption.toString();
        //_selectedFournisseurs = List.from(produit.fournisseurs);
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
        // _image = null;
      }
    }
  }

  Future<void> _productInfo(String code) async {
    final provider = Provider.of<CommerceProvider>(context, listen: false);
    final produit = await provider.getProduitByQr(code);

    if (produit != null) {
      // Calculer le stock total des approvisionnements pour ce produit
      double stockTemp = produit.calculerStockTotal();
      print('Stock total pour le produit ${produit.nom} : $stockTemp');
    }

    if (produit != null) {
      setState(() {
        _tempProduitId = produit.id.toString();
        _produitNom = produit.nom;
        _produitDesignation = produit.description ?? '';
        _produitPV = produit.prixVente;
        _produitStock = produit.stock;
        _produitQr = produit.qr!;
        _produitImage = produit.image!;
        _isFinded = true;
        //_image = null;
      });
    } else {
      _tempProduitId = '';
      _produitNom = '';
      _produitDesignation = '';
      _produitPV = 0.0;
      _produitStock = 0.0;
      _produitImage = '';
      _isFinded = false;
      // _image = null;
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
    // Nettoyer les FocusNodes
    _focusNodeNom.dispose();
    _focusNodePV.dispose();
    _focusNodeStock.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final produitProvider =
        Provider.of<CommerceProvider>(context, listen: false);
    return SafeArea(
      maintainBottomViewPadding: true,
      child: LayoutBuilder(
        builder: (context, constraints) {
          if (constraints.maxWidth < 600) {
            // Mobile layout
            return SafeArea(
              child: Scaffold(
                  resizeToAvoidBottomInset: true,
                  appBar: AppBar(
                    actions: [
                      WinMobile(),
                      buildButton_Edit_Add(context, produitProvider, _isFinded),
                      SizedBox(width: 50)
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
                      WinMobile(),
                      buildButton_Edit_Add(context, produitProvider, _isFinded),
                      SizedBox(width: 50)
                    ],
                  ),
                  body: Form(
                    key: _formKey,
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Container(
                          constraints: BoxConstraints(
                            maxWidth: 400, // largeur maximale de 200 pixels
                            // maxHeight: 100, // hauteur maximale de 100 pixels
                          ),
                          child: TabletLayout()),
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
                      WinMobile(),
                      buildButton_Edit_Add(context, produitProvider, _isFinded),
                      SizedBox(width: 50)
                    ],
                  ),
                  body: Form(
                    key: _formKey,
                    child: Container(
                      constraints: BoxConstraints(
                        maxWidth: 400, // largeur maximale de 200 pixels
                        //maxHeight: 100, // hauteur maximale de 100 pixels
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: DesktopLayout(),
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
    final String fallbackImage =
        'https://source.unsplash.com/random/1920x1080/?wallpaper,landscape';
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            _searchQr == true
                ? _tempProduitId.isNotEmpty
                    ? Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                        child: Card(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 8),
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: ListTile(
                                hoverColor: Colors.transparent,
                                splashColor: Colors.transparent,
                                focusColor: Colors.transparent,
                                selectedColor: Colors.transparent,
                                dense: true,
                                contentPadding: EdgeInsets.zero,
                                onTap: () {
                                  _updateProductInfo(_serialController.text);
                                },
                                leading: CircleAvatar(
                                    backgroundImage: CachedNetworkImageProvider(
                                  _produitImage,
                                  errorListener: (Object error) {
                                    setState(() {
                                      _produitImage =
                                          fallbackImage; // Remplacer par l'image de secours
                                    });
                                  },
                                  // Pour Web
                                )),
                                title: Text('${_produitNom.capitalize}',
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                        fontSize: 15, color: Colors.black54)),
                                trailing: Text(
                                  '${_produitPV.toStringAsFixed(2)}',
                                  style: TextStyle(fontSize: 20),
                                ),
                              ),
                            ),
                          ),
                        ),
                      )
                    : Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: ListTile(
                          title: Text(
                            'L\'ID du Produit n\'a pas encore été créer'
                                .capitalize,
                            style:
                                TextStyle(fontSize: 15, color: Colors.black54),
                          ),
                        ),
                      )
                : Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: ListTile(
                      title: Text(
                        'Nouveau ID du produit sera créer'.capitalize,
                        style: TextStyle(fontSize: 15, color: Colors.black54),
                      ),
                    ),
                  ),
            //id
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
                              ? 'Recherche par Codes-barres Activé'.capitalize
                              : 'Recherche par Codes-barres Désactivé'
                                  .capitalize,
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
                enabled: !_isLoadingSauv,
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
                    child: buildColumnPicSuppliers(largeur, context),
                  )
                : Container(), // photo
            _isFirstFieldRempli || _qrCodesTemp.isNotEmpty
                ? Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: TextFormField(
                      enabled: !_isLoadingSauv,
                      controller: _nomController,
                      textAlign: TextAlign.center,
                      keyboardType: TextInputType.text,
                      textInputAction: TextInputAction.next, // Action "Suivant"
                      onFieldSubmitted: (_) {
                        _focusNodePV.requestFocus(); // Passe au champ 2
                      },
                      // onChanged: (value) {
                      //   // Force la validation à chaque changement
                      //   _formKey.currentState?.validate();
                      // },
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
                            enabled: !_isLoadingSauv,

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
                              enabled: !_isLoadingSauv,

                              controller: _prixVenteController,
                              textAlign: TextAlign.center,
                              textInputAction:
                                  TextInputAction.next, // Action "Suivant"
                              onFieldSubmitted: (_) {
                                _focusNodeStock
                                    .requestFocus(); // Passe au champ 2
                              },
                              // onChanged: (value) {
                              //   // Force la validation à chaque changement
                              //   _formKey.currentState?.validate();
                              // },
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
                                  decimal: true, signed: true),

                              inputFormatters: [
                                FilteringTextInputFormatter.allow(
                                    RegExp(r'^\d+\.?\d{0,2}')),
                              ],
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
                                return null;
                              },
                            ),
                          ),
                        ), // prix de vente
                        _showAppro
                            ? Container()
                            : Expanded(
                                child: TextFormField(
                                  enabled: !_isLoadingSauv,
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
                                      borderRadius: BorderRadius.circular(8.0),
                                      borderSide: BorderSide
                                          .none, // Supprime le contour
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
                                  keyboardType: TextInputType.numberWithOptions(
                                      decimal: true, signed: true),
                                  inputFormatters: [
                                    FilteringTextInputFormatter.allow(
                                        RegExp(r'^\d+\.?\d{0,2}')),
                                  ],
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return 'Veuillez entrer le stock';
                                    }
                                    return null;
                                  },
                                ),
                              ),
                        // stock alert
                      ],
                    ),
                  )
                : Container(),

            ///********************************************************************** 1
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: !_showAppro
                  ? _isFirstFieldRempli || _qrCodesTemp.isNotEmpty
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
                      child: Form(
                        key: _formKeyApp,
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
                                      enabled: !_isLoadingSauv,
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
                                ), //prix d'achat
                                !_showAppro
                                    ? Container()
                                    : Expanded(
                                        child: TextFormField(
                                          enabled: !_isLoadingSauv,
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
                                            contentPadding: EdgeInsets.all(15),
                                          ),
                                          keyboardType:
                                              TextInputType.numberWithOptions(
                                                  decimal: true, signed: true),
                                          inputFormatters: [
                                            FilteringTextInputFormatter.allow(
                                                RegExp(r'^\d+\.?\d{0,2}')),
                                          ],
                                          validator: (value) {
                                            if (value == null ||
                                                value.isEmpty) {
                                              return 'Veuillez entrer le stock';
                                            }
                                            return null;
                                          },
                                        ),
                                      ),
                              ],
                            ), // stock
                            Flexible(
                              flex: 2,
                              child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: TextFormField(
                                  enabled: !_isLoadingSauv,
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
                                      borderSide: BorderSide
                                          .none, // Supprime le contour
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
                                                foregroundColor:
                                                    Theme.of(context)
                                                        .colorScheme
                                                        .primary,
                                                backgroundColor:
                                                    Theme.of(context)
                                                        .colorScheme
                                                        .onPrimary,
                                                shape: RoundedRectangleBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          15.0),
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
                                    color: _isEditing
                                        ? Colors.blue
                                        : Colors.green),
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
                                              padding:
                                                  const EdgeInsets.all(8.0),
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
                                                      ? fournisseur.nom.trim()
                                                      : 'Fournisseur Inconnu',
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                  style: TextStyle(
                                                      fontSize: 15,
                                                      fontWeight:
                                                          FontWeight.bold),
                                                ),
                                                approvisionnement
                                                            .datePeremption !=
                                                        null
                                                    ? Text(
                                                        'Expire le : ${DateFormat('dd/MM/yyyy').format(approvisionnement.datePeremption!)}',
                                                        style: TextStyle(
                                                          fontSize: 12,
                                                        ),
                                                      )
                                                    : Container(),
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
                                                  '${approvisionnement.prixAchat!.toStringAsFixed(2)}',
                                                  style:
                                                      TextStyle(fontSize: 20),
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
            ),
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
      _selectedFournisseurs.clear();
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
////////////////////////////////////////////////////////////////////////////////////////////////////////
// Étape 1 : Validation et Préparation des Données

  Future<bool> _validateForm() async {
    final isValid = await _formKey.currentState?.validate() ?? false;
    return isValid;
  }

  Future<String> _prepareImageUrl() async {
    if (_image != null) {
      return await uploadImageToSupabase(_image!, _existingImageUrl);
    } else if (_existingImageUrl?.isNotEmpty ?? false) {
      return _existingImageUrl!;
    }
    return '';
  }

  void _addQrCodeIfNotExists() {
    final code = _serialController.text.trim();
    if (code.isNotEmpty && !_qrCodesTemp.contains(code)) {
      _qrCodesTemp.add(code);
    }
  }

//Étape 2 : Construction et Sauvegarde du Produit

  Produit _createProduit(String imageUrl) {
    return Produit(
      qr: _qrCodesTemp.toSet().toList().join(','),
      image: imageUrl,
      nom: _nomController.text,
      description: _descriptionController.text,
      prixVente: double.parse(_prixVenteController.text),
      qtyPartiel: double.parse(_qtyPartielController.text),
      pricePartielVente: double.parse(_pricePartielVenteController.text),
      derniereModification: DateTime.now(),
    )..crud.target = Crud(
        createdBy: 1,
        updatedBy: 1,
        deletedBy: 1,
        dateCreation: DateTime.now(),
        derniereModification: DateTime.now(),
      );
  }

  void _assignApprovisionnementsToProduit(Produit produit) {
    for (int i = 0; i < _approvisionnementTemporaire.length; i++) {
      final approvisionnement = _approvisionnementTemporaire[i];
      approvisionnement.produit.target = produit;
      if (i < _selectedFournisseurs.length) {
        approvisionnement.fournisseur.target = _selectedFournisseurs[i];
      }
      approvisionnement.crud.target = Crud(
        createdBy: 1,
        updatedBy: 1,
        deletedBy: 1,
        dateCreation: DateTime.now(),
        derniereModification: DateTime.now(),
      );
    }
  }

//Étape 3 : Gestion des Erreurs et du Retour UI

  void _showSnackBar(BuildContext context, String message, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: color,
      ),
    );
  }

// Étape 4 :Combinaison des Étapes

  IconButton buildButton_Edit_Add(
    BuildContext context,
    CommerceProvider produitProvider,
    bool isFinded,
  ) {
    return IconButton(
      onPressed: () async {
        if (!mounted) return;

        // Validation du formulaire
        if (!await _validateForm()) return;

        // Vérifier si le produit existe déjà avant d'afficher le ProgressDialog
        final existingProduct =
            await produitProvider.getProduitByQr(_serialController.text);
        if (existingProduct != null) {
          print('Produit existant détecté');
          showExistingProductDialog(context, _serialController.text,
              existingProduct, produitProvider);
          _showSnackBar(context, 'Produit déjà existant', Colors.orange);
          return; // Arrêter ici si le produit existe déjà
        }

        // Affichage du ProgressDialog uniquement pour un produit non existant
        setState(() => _isLoadingSauv = true);
        // showDialog(
        //   context: context,
        //   barrierDismissible: false,
        //   builder: (context) => const ProgressDialog(),
        // );

        try {
          final imageUrl = await _prepareImageUrl();
          _addQrCodeIfNotExists();

          final produit = _createProduit(imageUrl);


          if (_prixAchatController.text.isNotEmpty && _stockController.text.isNotEmpty ){
            saveApprovisionnement();
            print('saveApprovisionnement');
          }
          _assignApprovisionnementsToProduit(produit);
            // Sauvegarde du nouveau produit
            produitProvider.ajouterProduit(
                produit, _selectedFournisseurs, _approvisionnementTemporaire);
          _formKey.currentState?.save();
          setState(() => _isLoadingSauv = false);
          _showSnackBar(context, 'Produit ajouté avec succès', Colors.green);

          Navigator.pop(context); // Ferme la page du formulaire
        } catch (e) {
          _showSnackBar(
              context, 'Erreur lors de la sauvegarde : $e', Colors.red);
        } finally {
          if (mounted) {
            setState(() => _isLoadingSauv = false);
            //Navigator.pop(context); // Ferme le ProgressDialog
          }
        }
      },
      icon: _isLoadingSauv
          ? const CircularProgressIndicator(
              strokeWidth: 2,
              valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),
            )
          : Icon(isFinded && _serialController.text == _produitQr
              ? Icons.edit
              : Icons.check),
    );
  }

////////////////////////////////////////////////////////////////////////////////////////////////////////
  IconButton buildButton_Edit_Add1(
      BuildContext context, CommerceProvider produitProvider, bool isFinded) {
    return IconButton(
      onPressed: () async {
        if (!mounted) return;

        // Validation préalable
        final isValid = await _formKey.currentState!.validate();
        if (!isValid) return;

        bool isContextValid = true;
        // Affichage du dialog de progression
        BuildContext dialogContext = context;

        _isFinded
            ? null
            : showDialog(
                context: context,
                barrierDismissible: false,
                builder: (context) => const ProgressDialog(),
              );

        setState(() => _isLoadingSauv = true);

        try {
          final existingProduct =
              await produitProvider.getProduitByQr(_serialController.text);

          // Validation préalable
          final isValid = await _formKey.currentState!.validate();
          if (!isValid) return;

          // Initialisation de l'URL de l'image
          String imageUrl = '';

          // Gestion de l'image du produit
          if (_image != null) {
            imageUrl = await uploadImageToSupabase(_image!, _existingImageUrl);
          } else if (_existingImageUrl != null &&
              _existingImageUrl!.isNotEmpty) {
            imageUrl = _existingImageUrl!;
          }

          // Gestion du code QR
          final code = _serialController.text.trim();
          if (code.isNotEmpty && !_isFinded && !_qrCodesTemp.contains(code)) {
            _qrCodesTemp.add(code);
          }

          // Initialisation du produit
          final produit = Produit(
            qr: _qrCodesTemp.toSet().toList().join(','),
            image: imageUrl,
            nom: _nomController.text,
            description: _descriptionController.text,
            prixVente: double.parse(_prixVenteController.text),
            qtyPartiel: double.parse(_qtyPartielController.text),
            pricePartielVente: double.parse(_pricePartielVenteController.text),
            derniereModification: DateTime.now(),
          )..crud.target = Crud(
              createdBy: 1,
              updatedBy: 1,
              deletedBy: 1,
              dateCreation: DateTime.now(),
              derniereModification: DateTime.now(),
            );

          // Gestion des approvisionnements
          for (int i = 0; i < _approvisionnementTemporaire.length; i++) {
            if (!isContextValid) break;
            final approvisionnement = _approvisionnementTemporaire[i];
            approvisionnement.produit.target = produit;
            if (i < _selectedFournisseurs.length) {
              approvisionnement.fournisseur.target = _selectedFournisseurs[i];
            }
            approvisionnement.crud.target = Crud(
              createdBy: 1,
              updatedBy: 1,
              deletedBy: 1,
              dateCreation: DateTime.now(),
              derniereModification: DateTime.now(),
            );
          }

          // Sauvegarde ou mise à jour du produit
          if (existingProduct == null) {
            produitProvider.ajouterProduit(
                produit, _selectedFournisseurs, _approvisionnementTemporaire);
            if (isContextValid) {
              _formKey.currentState?.save();

              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Produit ajouté avec succès'),
                  backgroundColor: Colors.green,
                ),
              );
            }
            Navigator.pop(context);
            setState(() => _isLoadingSauv = false);
            // Fermeture du dialog de progression
            if (isContextValid && Navigator.canPop(dialogContext)) {
              Navigator.pop(dialogContext);
            }
          } else {
            if (isContextValid && !isFinded) {
              _addQRCodeFromText();
              setState(() => _isLoadingSauv = false);
              // Fermeture du dialog de progression
              if (isContextValid && Navigator.canPop(dialogContext)) {
                Navigator.pop(dialogContext);
              }
              return;
            }
          }
        } catch (e) {
          if (isContextValid) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Erreur lors de la sauvegarde : $e'),
                backgroundColor: Colors.red,
              ),
            );
          }
        } finally {
          // if (mounted) {
          setState(() => _isLoadingSauv = false);
          // }
        }
      },
      icon: _isLoadingSauv
          ? const CircularProgressIndicator(
              strokeWidth: 2,
              valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),
            )
          : Icon(
              isFinded && _serialController.text == _produitQr
                  ? Icons.edit
                  : Icons.check,
            ),
    );
  }

  IconButton buildButton_Edit_Add0(
      BuildContext context, CommerceProvider produitProvider, bool isFinded) {
    return IconButton(
      onPressed: () async {
        if (!mounted) return;

        // Afficher le dialog de progression
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (BuildContext context) {
            return Dialog(
              backgroundColor: Colors.black.withOpacity(0.5),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircularProgressIndicator(),
                    SizedBox(height: 16),
                    Text(
                      "Sauvegarde en cours...",
                      style: TextStyle(color: Colors.white, fontSize: 16),
                    ),
                  ],
                ),
              ),
            );
          },
        );

        setState(() => _isLoadingSauv = true);

        try {
          final existingProduct =
              await produitProvider.getProduitByQr(_serialController.text);

          if (_formKey.currentState!.validate()) {
            String imageUrl = '';

            // Gestion de l'image du produit
            if (_image != null) {
              imageUrl =
                  await uploadImageToSupabase(_image!, _existingImageUrl);
            } else if (_existingImageUrl != null &&
                _existingImageUrl!.isNotEmpty) {
              imageUrl = _existingImageUrl!;
            }

            final code = _serialController.text.trim();
            if (code.isNotEmpty) _qrCodesTemp.add(code);

            // Initialisation du produit
            final produit = Produit(
              qr: _qrCodesTemp.toSet().toList().join(',').toString(),
              image: imageUrl,
              nom: _nomController.text,
              description: _descriptionController.text,
              prixVente: double.parse(_prixVenteController.text),
              qtyPartiel: double.parse(_qtyPartielController.text),
              pricePartielVente:
                  double.parse(_pricePartielVenteController.text),
              derniereModification: DateTime.now(),
            )..crud.target = Crud(
                createdBy: 1,
                updatedBy: 1,
                deletedBy: 1,
                dateCreation: DateTime.now(),
                derniereModification: DateTime.now(),
              );

            // Gestion des approvisionnements
            for (int i = 0; i < _approvisionnementTemporaire.length; i++) {
              final approvisionnement = _approvisionnementTemporaire[i];
              approvisionnement.produit.target = produit;
              if (i < _selectedFournisseurs.length) {
                approvisionnement.fournisseur.target = _selectedFournisseurs[i];
              }
              approvisionnement.crud.target = Crud(
                createdBy: 1,
                updatedBy: 1,
                deletedBy: 1,
                dateCreation: DateTime.now(),
                derniereModification: DateTime.now(),
              );
            }

            if (existingProduct == null) {
              produitProvider.ajouterProduit(
                  produit, _selectedFournisseurs, _approvisionnementTemporaire);
              print('Nouveau produit ajouté');
              _formKey.currentState!.save();
            } else {
              _addQRCodeFromText();
              print('Produit déjà existant');
            }
          }
        } catch (e) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Erreur lors de la sauvegarde du produit : $e'),
              backgroundColor: Colors.red,
            ),
          );
        } finally {
          if (Navigator.of(context).canPop()) {
            Navigator.of(context).pop(); // Ferme le dialog de progression
          }
          setState(() => _isLoadingSauv = false);
        }
      },
      icon: _isLoadingSauv
          ? CircularProgressIndicator()
          : Icon(
              isFinded && _serialController.text == _produitQr
                  ? Icons.edit
                  : Icons.check,
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

    // if (code.isNotEmpty && !_qrCodesTemp.contains(code)) {
    //   setState(() {
    //     _serialController.text = code;
    //     _qrCodesTemp.add(code); // Ajout du QR code à la liste temporaire
    //     _searchQr = false;
    //   });
    //   // Rediriger le focus vers le TextFormField après l'ajout
    //   FocusScope.of(context).requestFocus(_serialFocusNode);
    //   final provider = Provider.of<CommerceProvider>(context, listen: false);
    //   //final produit = await provider.getProduitById(int.parse(code));
    //   final produit = await provider.getProduitByQr(code);
    //   if (produit == null) {
    //     if (code.isNotEmpty && !_qrCodesTemp.contains(code)) {
    //       setState(() {
    //         _qrCodesTemp.add(code);
    //         _serialController.clear();
    //         _searchQr = false;
    //       });
    //     } else {
    //       _serialController.clear();
    //     }
    //     FocusScope.of(context).requestFocus(_serialFocusNode);
    //   }
    //   // if (produit != null) {
    //   //   setState(() {
    //   //     _tempProduitId = produit.id.toString() ?? '';
    //   //     _nomController.text = produit.nom;
    //   //     _descriptionController.text = produit.description ?? '';
    //   //     // _prixAchatController.text = produit.prixAchat.toStringAsFixed(2);
    //   //     _prixVenteController.text = produit.prixVente.toStringAsFixed(2);
    //   //     _stockController.text = produit.stock.toStringAsFixed(2);
    //   //     stockTemp = double.parse(produit.stock.toStringAsFixed(2));
    //   //     _minimStockController.text = produit.minimStock!.toStringAsFixed(2);
    //   //     _alertPeremptionController.text = produit.alertPeremption.toString();
    //   //     // _datePeremptionController.text = produit
    //   //     //     .approvisionnements.first.datePeremption!
    //   //     //     .format('yMMMMd', 'fr_FR');
    //   //     //_selectedFournisseurs = List.from(produit.fournisseurs);
    //   //     _existingImageUrl = produit.image;
    //   //     _isFinded = true;
    //   //     _image = null;
    //   //     // Ajouter le QR code scanné à la liste
    //   //     produit.addQrCode(code); // Ajoute le QR code scanné à la liste
    //   //   });
    //   // } else {
    //   //   setState(() {
    //   //     _tempProduitId = '';
    //   //     _nomController.clear();
    //   //     _descriptionController.clear();
    //   //     _prixAchatController.clear();
    //   //     stockTemp = 0.0;
    //   //     _alertPeremptionController.clear();
    //   //     _prixVenteController.clear();
    //   //     _stockController.clear();
    //   //     _selectedFournisseurs.clear();
    //   //     _datePeremptionController.clear();
    //   //     _minimStockController.clear();
    //   //     _existingImageUrl = '';
    //   //     _isFinded = false;
    //   //     _image = null;
    //   //   });
    //   //   // Si un nouveau produit doit être créé, tu peux créer un objet Produit temporaire
    //   //   Produit newProduit = Produit(
    //   //     nom: _nomController.text,
    //   //     prixVente: double.parse(_prixVenteController.text),
    //   //     minimStock: double.parse(_minimStockController.text),
    //   //     alertPeremption: int.parse(_alertPeremptionController.text),
    //   //     derniereModification: DateTime.now(),
    //   //   );
    //   //
    //   //   // Ajoute le QR code scanné à ce nouveau produit
    //   //   newProduit.addQrCode(code);
    //   // }
    // }
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

  // Méthode séparée pour afficher le dialogue
  void showExistingProductDialog(BuildContext context, String code,
      Produit produit, CommerceProvider provider) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        // Récupérer la largeur et la hauteur de l'écran
        final screenWidth = MediaQuery.of(context).size.width;
        final screenHeight = MediaQuery.of(context).size.height;
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(20)),
          ),
          titlePadding: EdgeInsets.all(0),
          contentPadding: EdgeInsets.all(20),
          insetPadding: EdgeInsets.symmetric(horizontal: 40.0, vertical: 24.0),
          title: Padding(
            padding: const EdgeInsets.all(0),
            child: Column(
              children: [
                Center(
                  child: produit.image != null
                      ? ClipRRect(
                          borderRadius: BorderRadius.circular(8.0),
                          child: AspectRatio(
                            aspectRatio: 1, // Conserve un ratio 1:1
                            child: CachedNetworkImage(
                              imageUrl: produit.image!,
                              fit: BoxFit
                                  .cover, // Remplit l'espace sans déformation
                              width: screenWidth *
                                  0.6, // 60% de la largeur de l'écran
                              height: screenHeight *
                                  0.6, // 60% de la largeur pour garder le ratio
                              placeholder: (context, url) => Center(
                                child:
                                    CircularProgressIndicator(), // Indicateur de chargement
                              ),
                              errorWidget: (context, url, error) => Center(
                                child: Lottie.asset(
                                  'assets/lotties/1 (8).json', // Chemin vers ton fichier Lottie
                                  width: screenWidth *
                                      0.2, // Ajuste la taille de l'erreur à 30%
                                  height: screenWidth * 0.2,
                                ),
                              ),
                            ),
                          ),
                        )
                      : Container(), // Affiche un container vide si pas d'image
                ),
                Text(
                  'Dernière Modification : ${produit.derniereModification.format('yMMMMd', 'fr_FR')}',
                  style: TextStyle(
                    fontSize: 12,
                  ),
                ),
                Center(
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: RichText(
                      text: TextSpan(
                        text: 'BarCode'.toUpperCase(),
                        style: TextStyle(
                          color: Theme.of(context).brightness == Brightness.dark
                              ? Colors
                                  .white // Couleur du texte pour le thème sombre
                              : Colors
                                  .black, // Couleur du texte pour le thème clair
                          fontSize: 20,
                          fontFamily: 'Oswald',
                        ),
                        children: <TextSpan>[
                          TextSpan(
                            text: ' ${code} '.toUpperCase(),
                            style: TextStyle(
                              fontFamily: 'Oswald',
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          TextSpan(
                            text: ' est déjà associé au '.toUpperCase(),
                            style: TextStyle(
                              fontFamily: 'Oswald',
                              fontSize: 20,
                            ),
                          ),
                          TextSpan(
                            text: '${produit.nom}'.toUpperCase(),
                            style: TextStyle(
                              fontFamily: 'Oswald',
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          content: SingleChildScrollView(
            child: SizedBox(
              width: 200, // Largeur fixe du dialogue
              // height: 300,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (produit.description != null &&
                      produit.description!.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4.0),
                      child: Text(
                        'Description : ${produit.description}',
                        overflow: TextOverflow.ellipsis,
                        textAlign: TextAlign.justify,
                        style: TextStyle(
                          fontSize: 18,
                        ),
                      ),
                    ),
                  Text(
                    'Prix de vente : ${produit.prixVente.toStringAsFixed(2)} DA',
                    style: TextStyle(
                      fontSize: 18,
                    ),
                  ),
                  Text(
                    'Stock : ${produit.stock.toStringAsFixed(2)}',
                    style: TextStyle(
                      fontSize: 18,
                    ),
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              style: TextButton.styleFrom(foregroundColor: Colors.red),
              child: Text('Supprimer le code'),
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

  Container buildColumnPicSuppliers(double largeur, BuildContext context) {
    return Container(
      child: Center(
        child: _image == null
            ? Stack(
                alignment: Alignment.center,
                children: [
                  _existingImageUrl != null && _existingImageUrl!.isNotEmpty
                      ? Container(
                          width: largeur,
                          height:
                              Platform.isAndroid || Platform.isIOS ? 150 : 300,
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
                          // width: largeur,
                          // height:
                          //     Platform.isAndroid || Platform.isIOS ? 150 : 300,
                          // decoration: BoxDecoration(
                          //   borderRadius:
                          //       BorderRadius.circular(8.0), // Bords arrondis
                          //   border: Border.all(
                          //     color: Colors.grey, // Couleur de la bordure
                          //     width: 1.0, // Épaisseur de la bordure
                          //   ),
                          // ),
                          ),
                  !_isLoadingSauv
                      ? IconButton(
                          onPressed: _pickImage,
                          icon: Icon(
                            Icons.add_a_photo,
                            color: Colors.blue,
                          ),
                        )
                      : Container(),
                ],
              )
            : Container(
                width: largeur,
                height: Platform.isAndroid || Platform.isIOS ? 150 : 300,
                child: InkWell(
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

    if (source != null && mounted) {
      // Vérification ajoutée ici
      final pickedFile = await ImagePicker().pickImage(
        source: source,
        maxHeight: 720, // Hauteur réduite pour les écrans mobiles
        maxWidth: 1280, // Largeur ajustée
        imageQuality:
            50, // Augmentation légère de la qualité pour un meilleur rendu
      );

      if (pickedFile != null && mounted) {
        setState(() {
          _image = File(pickedFile.path);
          _produitImage = '';
          _existingImageUrl = '';
        });
      }
    }
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
          approvisionnement.prixAchat!.toStringAsFixed(2);
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
    if (_formKeyApp.currentState!.validate()) {
      final quantite = double.parse(_stockController.text);
      final prixAchat = double.parse(_prixAchatController.text);
      // final datePeremption = DateFormat('dd MMMM yyyy', 'fr_FR')
      //     .parse(_datePeremptionController.text);
      // Initialisation de datePeremption en vérifiant si le champ est vide
      DateTime? datePeremption;
      if (_datePeremptionController.text.isNotEmpty) {
        try {
          datePeremption = DateFormat('dd MMMM yyyy', 'fr_FR')
              .parse(_datePeremptionController.text);
        } catch (e) {
          print("Erreur lors du parsing de la date : $e");
          // Gérer le cas d'erreur, par exemple en affichant un message
          return;
        }
      }
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

class ProgressDialog extends StatelessWidget {
  const ProgressDialog({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor:
          Colors.black.withOpacity(DialogConstants.opacityBackground),
      child: Padding(
        padding: const EdgeInsets.all(DialogConstants.padding),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: const [
            CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
            ),
            SizedBox(height: DialogConstants.padding),
            Text(
              DialogConstants.savingMessage,
              style: TextStyle(
                  color: Colors.white, fontSize: DialogConstants.fontSize),
            ),
          ],
        ),
      ),
    );
  }
}

class DialogConstants {
  static const double opacityBackground = 0.5;
  static const double padding = 16.0;
  static const double fontSize = 16.0;
  static const String savingMessage = "Sauvegarde en cours...";
}
