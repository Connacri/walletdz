import 'package:dart_date/dart_date.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl/intl.dart';
import 'package:lottie/lottie.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'dart:io';
import 'package:path/path.dart' as path;
import '../Entity.dart';
import '../MyProviders.dart';
import '../Utils/QRViewExample.dart';
import '../Utils/country_flags.dart';
import '../Utils/mobile_scanner/barcode_scanner_simple.dart';
import 'AddFournisseurFormFromProduit.dart';
import 'FournisseurListScreen.dart';
import 'dart:io' show Platform;
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../Utils/mobile_scanner/barcode_scanner_window.dart';

class add_Produit extends StatefulWidget {
  final Fournisseur? specifiquefournisseur;

  add_Produit({Key? key, this.qrCode, this.specifiquefournisseur})
      : super(key: key);
  final String? qrCode;

  @override
  State<add_Produit> createState() => _add_ProduitState();
}

class _add_ProduitState extends State<add_Produit> {
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

  List<Fournisseur> _selectedFournisseurs = [];
  List<Approvisionnement> approvisionnements = [];
  List<Approvisionnement> _approvisionnementTemporaire = [];

  Approvisionnement? _currentApprovisionnement;
  bool _isEditing = false;
  File? _image;
  String? _existingImageUrl;
  String _tempProduitId = '';
  bool _isFirstFieldFilled = false;
  bool _editQr = true;
  DateTime selectedDate = DateTime.now();
  String _lastScannedCode = '';
  bool _isFinded = false;
  double stockTemp = 0;
  bool _showDescription = false;
  bool _showAppro = false;
  double stockGlobale = 0.0; // Déclaration de la variable
  bool _showAllFournisseurs = false;

  @override
  void initState() {
    super.initState();
    _serialController.text = widget.qrCode ?? '';
    _serialController.addListener(_onSerialChanged);
    _serialController.addListener(_checkFirstField);

    // Initialize with specific supplier if provided
    if (widget.specifiquefournisseur != null) {
      _selectedFournisseurs = [widget.specifiquefournisseur!];
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

    super.dispose();
  }

  void _onSelectedFournisseursChanged(List<Fournisseur> fournisseurs) {
    setState(() {
      _selectedFournisseurs = fournisseurs;
    });
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

  Future<void> _scanQRCode() async {
    final code = await Navigator.of(context).push<String>(
      MaterialPageRoute(
        builder: (context) => BarcodeScannerWithScanWindow(), //QRViewExample(),
      ),
    );
    if (code != null) {
      setState(() {
        _serialController.text = code;
      });

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
      }
    }
  }

  Future<void> _showAddQuantityDialog() async {
    int currentValue = int.tryParse(_stockController.text) ?? 0;
    int newQuantity = currentValue;

    return showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Ajouter une quantité'),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text('Quantité actuelle : $currentValue'),
                const SizedBox(height: 16.0),
                TextField(
                  controller: TextEditingController(),
                  keyboardType: TextInputType.number,
                  onChanged: (value) {
                    newQuantity = int.tryParse(value) ?? 0;
                  },
                ),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Annuler'),
              onPressed: () {
                // _stockController.text = widget.produit!.stock.toString();
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text('Ajouter'),
              onPressed: () {
                _stockController.text = (currentValue + newQuantity).toString();
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  void _onSerialChanged() {
    final code = _serialController.text;

    // Vérifie si le champ est vide en premier lieu pour éviter des opérations inutiles.
    if (code.isEmpty
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

  Future<void> _updateProductInfo(String code) async {
    final provider = Provider.of<CommerceProvider>(context, listen: false);
    final produit = await provider.getProduitByQr(code);
    //.getProduitById(int.parse(code));

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
        _existingImageUrl = '';
        _isFinded = false;
        _image = null;
      }
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

  // Future<void> ajouterProduitToSupabase(Produit produit) async {
  //   final supabase = Supabase.instance.client;
  //   final response = await supabase.from('produit').insert({
  //     'qr': produit.qr,
  //     'image': produit.image,
  //     'nom': produit.nom,
  //     'description': produit.description,
  //     'prixachat': produit.prixAchat,
  //     'prixvente': produit.prixVente,
  //     'stock': produit.stock,
  //     'stockupdate': produit.stockUpdate?.toIso8601String(),
  //     'stockinit': produit.stockinit,
  //     'minimstock': produit.minimStock,
  //   });
  //   if (response == null) {
  //     print('Erreur: la réponse est null');
  //     return;
  //   }
  //   if (response.error == null) {
  //     print('Produit ajouté à Supabase avec succès');
  //   } else {
  //     print(
  //         'Erreur lors de l\'ajout du produit à Supabase: ${response.error!.message}');
  //   }
  // }
  //
  // Future<void> updateProduitToSupabase(int id, Produit produit) async {
  //   final supabase = Supabase.instance.client;
  //   final response = await supabase.from('produit').update({
  //     'qr': produit.qr,
  //     'image': produit.image,
  //     'nom': produit.nom,
  //     'description': produit.description,
  //     'prixachat': produit.prixAchat,
  //     'prixvente': produit.prixVente,
  //     'stock': produit.stock,
  //     'stockupdate': produit.stockUpdate?.toIso8601String(),
  //     'stockinit': produit.stockinit,
  //     'minimstock': produit.minimStock,
  //   }).eq('id', id);
  //   if (response == null) {
  //     print('Erreur: la réponse est null');
  //     return;
  //   }
  //   if (response.error == null) {
  //     print('Produit mis à jour dans Supabase avec succès');
  //   } else {
  //     print(
  //         'Erreur lors de la mise à jour du produit dans Supabase: ${response.error!.message}');
  //   }
  // }
  void ajouterApprovisionnementTemporaire(Approvisionnement approvisionnement) {
    setState(() {
      _approvisionnementTemporaire.add(approvisionnement);
    });
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

// Méthode pour enregistrer l'approvisionnement (ajouter ou mettre à jour)
  void saveApprovisionnement() {
    final quantite = double.parse(_stockController.text);
    final prixAchat = double.parse(_prixAchatController.text);
    final datePeremption = DateFormat('dd MMMM yyyy', 'fr_FR')
        .parse(_datePeremptionController.text);

    if (_isEditing && _currentApprovisionnement != null) {
      // Mise à jour de l'approvisionnement existant
      setState(() {
        _currentApprovisionnement!.quantite = quantite;
        _currentApprovisionnement!.prixAchat = prixAchat;
        _currentApprovisionnement!.datePeremption = datePeremption;

        // Reset des champs
        _currentApprovisionnement = null;
        _isEditing = false;
        _stockController.clear();
        _prixAchatController.clear();
        _datePeremptionController.clear();
      });
    } else {
      // Ajouter un nouvel approvisionnement
      Approvisionnement nouveauApprovisionnement = Approvisionnement(
        quantite: quantite,
        prixAchat: prixAchat,
        datePeremption: datePeremption,
      );
      ajouterApprovisionnementTemporaire(nouveauApprovisionnement);
      _stockController.clear();
      _prixAchatController.clear();
      _datePeremptionController.clear();
    }
    mettreAJourStockGlobal(); // Met à jour le stock global
  }

  void supprimerApprovisionnementTemporaire(
      Approvisionnement approvisionnement) {
    setState(() {
      _approvisionnementTemporaire.remove(approvisionnement);
    });

    // Vous pouvez appeler setState() si vous utilisez un StatefulWidget
    // pour mettre à jour l'interface utilisateur.
  }

  void startEditing(Approvisionnement approvisionnement) {
    setState(() {
      _currentApprovisionnement = approvisionnement;
      _stockController.text = approvisionnement.quantite.toString();
      _prixAchatController.text = approvisionnement.prixAchat.toString();
      _datePeremptionController.text = DateFormat('dd MMMM yyyy', 'fr_FR')
          .format(approvisionnement.datePeremption!);
      _isEditing = true;
    });
  }

  IconButton buildButton_Edit_Add(
      BuildContext context, CommerceProvider produitProvider, _isFinded) {
    return IconButton(
      onPressed: () async {
        final dateFormat = DateFormat('dd MMM yyyy', 'fr');
        // final datePeremption =
        //     dateFormat.parseLoose(_datePeremptionController.text);
        final produitDejaExist =
            await produitProvider.getProduitByQr(_serialController.text);
        if (_formKey.currentState!.validate()) {
          String imageUrl = '';
//******************************************************************************//
          if (produitDejaExist != null &&
              widget.specifiquefournisseur == null) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  'QR / Code Barre Produit existe déja !',
                  style: TextStyle(color: Colors.white),
                ),
                backgroundColor: Colors.red,
              ),
            );
            print('hadi produitDejaExist != null 111111111111111111');
          } else {
            if (_image != null) {
              imageUrl =
                  await uploadImageToSupabase(_image!, _existingImageUrl);
            } else if (_existingImageUrl != null &&
                _existingImageUrl!.isNotEmpty) {
              imageUrl = _existingImageUrl!;
            }
            print('hadi produitDejaExist == null 2222222222222222222');
            print(_tempProduitId);
          }
////////////////////////////////////////////////////////////////////////////////
          if (mounted) {
            final produit = Produit(
              qr: _serialController.text,
              image: imageUrl,
              nom: _nomController.text,
              description: _descriptionController.text,
              // prixAchat: double.parse(_prixAchatController.text),
              prixVente: double.parse(_prixVenteController.text),
              //stock: double.parse(_stockController.text),
              alertPeremption: int.parse(_alertPeremptionController.text),
              minimStock: double.parse(_minimStockController.text),
            )..crud.target = Crud(
                createdBy: 0,
                updatedBy: 0,
                deletedBy: 0,
                dateCreation: DateTime.now(),
                derniereModification: DateTime.now(),
                dateDeleting: null,
              );

            if (widget.specifiquefournisseur == null) {
              if (produitDejaExist != null) {
                return;
              } else {
                produitProvider.ajouterProduit(
                  produit,
                  _selectedFournisseurs,
                  approvisionnements,
                );
                // await ajouterProduitToSupabase(
                //     produit);
                print('Nouveau produit ajouté');
                print(produit);
              }
            } else {
              if (produitDejaExist != null) {
                // Mise à jour d'un produit existant
                // produitProvider.updateProduitById(
                //     int.parse(_tempProduitId), produit,
                //     fournisseurs: [
                //       ..._selectedFournisseurs,
                //       ...[widget.specifiquefournisseur!]
                //     ]);
                // await updateProduitToSupabase(int.parse(_tempProduitId),
                //     produit);
                print('Produit existant mis à jour');
              } else {
                produitProvider.ajouterProduit(
                    produit,
                    [
                      ..._selectedFournisseurs,
                      ...[widget.specifiquefournisseur!],
                    ],
                    approvisionnements);
                // await ajouterProduitToSupabase(produit);
                print('Nouveau produit ajouté');
              }
            }

            _formKey.currentState!.save();
            produitDejaExist != null ? null : Navigator.of(context).pop();
          }
        }
      },
      icon: Icon(
        _isFinded ? Icons.edit : Icons.check,
      ),
    );
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

  @override
  Widget build(BuildContext context) {
    final produitProvider =
        Provider.of<CommerceProvider>(context, listen: false);
    double largeur;
    return LayoutBuilder(
        builder: (BuildContext context, BoxConstraints constraints) {
      if (constraints.maxWidth > 750) {
        largeur = MediaQuery.of(context).size.width / 3;
        return Scaffold(
          appBar: buildAppBar(context, produitProvider),
          body: Form(
            key: _formKey,
            child: SingleChildScrollView(
              padding: EdgeInsets.symmetric(
                horizontal: 15,
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(child: buildColumnForm(largeur)),
                  Expanded(child: buildColumnPicSuplyers(largeur, context)),
                ],
              ),
            ),
          ),
        );
      } else if (constraints.maxWidth < 750 && constraints.maxWidth > 320) {
        largeur = MediaQuery.of(context).size.width;
        return Scaffold(
          appBar: buildAppBar(context, produitProvider),
          body: Form(
            key: _formKey,
            child: SingleChildScrollView(
                padding: EdgeInsets.symmetric(
                  horizontal: 15,
                ),
                child: Column(
                  children: [
                    buildColumnForm(largeur),
                    buildColumnPicSuplyers(largeur, context),
                  ],
                )),
          ),
        );
      } else {
        return Scaffold(
          body: Center(
            child: Lottie.asset('assets/lotties/1 (88).json'),
          ),
        );
      }
    });
  }
  // @override
  // Widget build(BuildContext context) {
  //   final produitProvider =
  //       Provider.of<CommerceProvider>(context, listen: false);
  //   final double largeur;
  //   if (kIsWeb || Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
  //     // Pour le web
  //     largeur = MediaQuery.of(context).size.width / 3;
  //   } else if (Platform.isAndroid || Platform.isIOS) {
  //     // Pour Android et iOS
  //     largeur = MediaQuery.of(context).size.width;
  //   } else {
  //     // Pour les autres plateformes (Desktop)
  //     largeur = MediaQuery.of(context).size.width / 3;
  //   }
  //   return Scaffold(
  //     appBar: buildAppBar(context, produitProvider),
  //     body: Form(
  //       key: _formKey,
  //       child: SingleChildScrollView(
  //         padding: EdgeInsets.symmetric(
  //           horizontal: 15,
  //         ),
  //         child: Platform.isAndroid || Platform.isIOS
  //             ? Column(
  //                 children: [
  //                   buildColumnForm(largeur),
  //                   buildColumnPicSuplyers(largeur, context),
  //                 ],
  //               )
  //             : Row(
  //                 crossAxisAlignment: CrossAxisAlignment.start,
  //                 children: [
  //                   Expanded(child: buildColumnForm(largeur)),
  //                   Expanded(child: buildColumnPicSuplyers(largeur, context)),
  //                 ],
  //               ),
  //       ),
  //     ),
  //   );
  // }

  Column buildColumnForm(double largeur) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
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
              width: largeur,
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
                  Text(
                    _editQr
                        ? 'Recherche par Code QR Activé'
                        : 'Recherche par Code QR Désactivé',
                  ),
                ],
              )),
        ), //switch recherche auto
        _serialController.text.isNotEmpty
            ? FlagDetector(
                barcode: _serialController
                    .text) // Afficher FlagDetector avec le code-barres
            : FlagDetector(
                barcode: _serialController
                    .text), // Ne rien afficher si le champ est vide
        SizedBox(height: 15),
        Container(
          width: largeur,
          child: TextFormField(
            controller: _serialController,
            textAlign: TextAlign.center,
            decoration: InputDecoration(
              labelText: 'Code Barre / QrCode',
              prefixIcon: _isFirstFieldFilled == true
                  ? IconButton(
                      icon: Icon(Icons.clear),
                      onPressed: _clearAllFields,
                      tooltip: 'Effacer tous les champs',
                    )
                  : null,
              suffixIcon: Platform.isIOS || Platform.isAndroid
                  ? IconButton(
                      icon: Icon(Icons.qr_code_scanner),
                      onPressed: _scanQRCode,
                    )
                  : null,
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
          ),
        ), //serial qrcode
        SizedBox(height: 10),
        Container(
          width: largeur,
          child: TextFormField(
            enabled: _isFirstFieldFilled,
            controller: _nomController,
            textAlign: TextAlign.center,
            keyboardType: TextInputType.text,
            decoration: InputDecoration(
              fillColor: _isFirstFieldFilled ? Colors.green.shade100 : null,
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
        SizedBox(height: !_showDescription ? 0 : 10),
        !_showDescription
            ? Container()
            : Stack(
                alignment: Alignment.topRight,
                children: [
                  Container(
                    width: largeur,
                    child: TextFormField(
                      enabled: _isFirstFieldFilled,
                      controller: _descriptionController,
                      maxLines: 5,
                      keyboardType: TextInputType.text,
                      decoration: InputDecoration(
                        hintText: 'Déscription',
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
        SizedBox(height: 10),
        Container(
          width: -5 + largeur / 2,
          child: TextFormField(
            enabled: _isFirstFieldFilled,
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
        ), // prix de vente
        SizedBox(
          height: 10,
        ),

        ///**********************************************************************
        !_showAppro
            ? _isFirstFieldFilled
                ? IconButton(
                    icon: Icon(Icons.keyboard_arrow_down),
                    onPressed: () {
                      setState(() {
                        _showAppro = true;
                      });
                    },
                  )
                // TextButton(
                //             onPressed: () {
                //               setState(() {
                //                 _showAppro = true;
                //               });
                //             },
                //             child: Text('Approvisionnement'),
                //           )
                : Container()
            // IconButton(
            //         icon: Icon(Icons.add, color: Colors.red),
            //         onPressed: () {
            //           setState(() {
            //             _showAppro = true;
            //           });
            //         },
            //       )
            : Container(
                padding:
                    EdgeInsets.all(10.0), // Espacement à l'intérieur du cadre
                decoration: BoxDecoration(
                  //      color: Colors.grey, // Couleur de fond
                  borderRadius: BorderRadius.circular(8.0), // Bords arrondis
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

                    // Padding(
                    //   padding: const EdgeInsets.all(10.0),
                    //   child: Container(
                    //     width: largeur,
                    //     child: Row(
                    //       children: [
                    //         Expanded(
                    //           child: TextFormField(
                    //             enabled: _isFirstFieldFilled,
                    //             controller: _minimStockController,
                    //             textAlign: TextAlign.center,
                    //             decoration: InputDecoration(
                    //               labelText: 'Stock Alert',
                    //
                    //               border: OutlineInputBorder(
                    //                 borderRadius: BorderRadius.circular(8.0),
                    //                 borderSide:
                    //                     BorderSide.none, // Supprime le contour
                    //               ),
                    //               enabledBorder: OutlineInputBorder(
                    //                 borderRadius: BorderRadius.circular(8.0),
                    //                 borderSide: BorderSide
                    //                     .none, // Supprime le contour en état normal
                    //               ),
                    //               focusedBorder: OutlineInputBorder(
                    //                 borderRadius: BorderRadius.circular(8.0),
                    //                 borderSide: BorderSide
                    //                     .none, // Supprime le contour en état focus
                    //               ),
                    //               //border: InputBorder.none,
                    //               filled: true,
                    //               contentPadding: EdgeInsets.all(15),
                    //             ),
                    //             keyboardType: TextInputType.number,
                    //             validator: (value) {
                    //               if (value == null || value.isEmpty) {
                    //                 return 'Veuillez entrer le Stock Minimal';
                    //               }
                    //               return null;
                    //             },
                    //           ),
                    //         ), // stock alert
                    //         SizedBox(width: 10),
                    //         Expanded(
                    //           child: TextFormField(
                    //             enabled: _isFirstFieldFilled,
                    //             controller: _alertPeremptionController,
                    //             textAlign: TextAlign.center,
                    //             decoration: InputDecoration(
                    //               labelText: 'Alert Péremption',
                    //               border: OutlineInputBorder(
                    //                 borderRadius: BorderRadius.circular(8.0),
                    //                 borderSide:
                    //                     BorderSide.none, // Supprime le contour
                    //               ),
                    //               enabledBorder: OutlineInputBorder(
                    //                 borderRadius: BorderRadius.circular(8.0),
                    //                 borderSide: BorderSide
                    //                     .none, // Supprime le contour en état normal
                    //               ),
                    //               focusedBorder: OutlineInputBorder(
                    //                 borderRadius: BorderRadius.circular(8.0),
                    //                 borderSide: BorderSide
                    //                     .none, // Supprime le contour en état focus
                    //               ),
                    //               //border: InputBorder.none,
                    //               filled: true,
                    //               contentPadding: EdgeInsets.all(15),
                    //             ),
                    //             // keyboardType: TextInputType.number,
                    //             //  validator: (value) {
                    //             //    if (value == null || value.isEmpty) {
                    //             //      return 'Veuillez entrer le prix d\'achat';
                    //             //    }
                    //             //    return null;
                    //             //  },
                    //             keyboardType: TextInputType.numberWithOptions(
                    //                 decimal: false),
                    //             inputFormatters: [
                    //               FilteringTextInputFormatter.allow(
                    //                   RegExp(r'^\d+\.?\d{0,2}')),
                    //             ],
                    //             // onChanged: (value) {
                    //             //   if (value.isNotEmpty) {
                    //             //     double? parsed = double.tryParse(value);
                    //             //     if (parsed != null) {
                    //             //       _prixAchatController.text = parsed.toStringAsFixed(2);
                    //             //       _prixAchatController.selection =
                    //             //           TextSelection.fromPosition(
                    //             //         TextPosition(
                    //             //             offset: _prixAchatController.text.length),
                    //             //       );
                    //             //     }
                    //             //   }
                    //             // },
                    //             validator: (value) {
                    //               if (value == null || value.isEmpty) {
                    //                 return 'Veuillez entrer Le nombre de jours pour alerter la date de peremption';
                    //               }
                    //               // if (double.tryParse(value) == null) {
                    //               //   return 'Veuillez entrer un prix valide';
                    //               // }
                    //               // return null;
                    //             },
                    //           ),
                    //         ),
                    //       ],
                    //     ),
                    //   ),
                    // ), //alert peremption
                    SizedBox(height: 10),
                    Container(
                      width: -5 + largeur / 2,
                      child: TextFormField(
                        enabled: _isFirstFieldFilled,
                        controller: _prixAchatController,
                        textAlign: TextAlign.center,
                        decoration: InputDecoration(
                          labelText: 'Prix d\'achat',
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
                            TextInputType.numberWithOptions(decimal: true),
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
                    ), //prix d'achat
                    SizedBox(height: 10),
                    Container(
                      width: largeur,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          _editQr == true
                              ? GestureDetector(
                                  onTap: () {
                                    _stockController.text =
                                        stockTemp.toString();
                                  },
                                  child: CircleAvatar(
                                    child: FittedBox(
                                        child: Padding(
                                      padding: const EdgeInsets.all(5.0),
                                      child:
                                          // Text(
                                          //   _stockController.text.toString(),
                                          // ),
                                          Text(
                                              '${stockGlobale.toStringAsFixed(2)}'),
                                    )),
                                  ),
                                )
                              : Container(),
                          // CircleAvatar(
                          //         child: Text(
                          //         ' ',
                          //       )),
                          SizedBox(
                            width: 10,
                          ),
                          Expanded(
                            flex: 5,
                            child: TextFormField(
                              enabled: _isFirstFieldFilled,
                              controller: _stockController,
                              textAlign: TextAlign.center,
                              decoration: InputDecoration(
                                labelText: 'Stock',
                                suffixIcon: Padding(
                                  padding: const EdgeInsets.all(4.0),
                                  child: IconButton(
                                      onPressed: _showAddQuantityDialog,
                                      icon: Icon(Icons.add)),
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
                                //border: InputBorder.none,
                                filled: true,
                                contentPadding: EdgeInsets.all(15),
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
                          SizedBox(
                            width: 10,
                          ),
                          Expanded(
                            flex: 3,
                            child: TextFormField(
                              enabled: _isFirstFieldFilled,
                              controller: _minimStockController,
                              textAlign: TextAlign.center,
                              decoration: InputDecoration(
                                labelText: 'Stock Alert',

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
                              keyboardType: TextInputType.number,
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Veuillez entrer le Stock Minimal';
                                }
                                return null;
                              },
                            ),
                          ), // stock alert
                        ],
                      ),
                    ),
                    // stock
                    SizedBox(height: 10),
                    Container(
                      width: largeur,
                      child: Row(
                        children: [
                          Expanded(
                            flex: 5,
                            child: TextFormField(
                              enabled: _isFirstFieldFilled,
                              controller: _datePeremptionController,
                              textAlign: TextAlign.center,
                              keyboardType: TextInputType.text,
                              decoration: InputDecoration(
                                fillColor: _isFirstFieldFilled
                                    ? Colors.yellow.shade200
                                    : null,
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
                          SizedBox(width: 10),
                          Expanded(
                            flex: 2,
                            child: TextFormField(
                              enabled: _isFirstFieldFilled,
                              controller: _alertPeremptionController,
                              textAlign: TextAlign.center,
                              decoration: InputDecoration(
                                labelText: 'Alert Péremption',
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
                              //  validator: (value) {
                              //    if (value == null || value.isEmpty) {
                              //      return 'Veuillez entrer le prix d\'achat';
                              //    }
                              //    return null;
                              //  },
                              keyboardType: TextInputType.numberWithOptions(
                                  decimal: false),
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
                    ),
                    // date de peremption
                    SizedBox(height: 10),
                    IconButton(
                      padding: EdgeInsets.all(10),
                      icon: Icon(_isEditing ? Icons.edit : Icons.send,
                          color: _isEditing ? Colors.blue : Colors.green),
                      onPressed: saveApprovisionnement,
                      //     () {
                      //   setState(() {
                      //     Approvisionnement nouveauApprovisionnement =
                      //         Approvisionnement(
                      //       quantite: double.parse(_stockController.text) ?? 0.0,
                      //       prixAchat:
                      //           double.parse(_prixAchatController.text) ?? 0.0,
                      //       datePeremption: DateFormat('dd MMMM yyyy', 'fr_FR')
                      //           .parse(_datePeremptionController
                      //               .text), // Utilisation de DateFormat
                      //     );
                      //     ajouterApprovisionnementTemporaire(
                      //         nouveauApprovisionnement);
                      //     // Mettre à jour le stock global
                      //
                      //     stockGlobale += nouveauApprovisionnement.quantite;
                      //     _stockController.clear();
                      //     _prixAchatController.clear();
                      //     _datePeremptionController.clear();
                      //   });
                      // },
                    ),
                    // ElevatedButton(
                    //   onPressed: saveApprovisionnement,
                    //   child: Text(_isEditing ? 'Mettre à jour' : 'Ajouter'),
                    // ),
                    Container(
                      width: largeur,
                      child: Wrap(
                        spacing: 8.0,
                        runSpacing: 4.0,
                        children: [
                          // Affiche les trois premiers fournisseurs
                          ..._selectedFournisseurs.take(3).map((fournisseur) {
                            return widget.specifiquefournisseur != null
                                ? Card(
                                    elevation: 2,
                                    child: Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: Text(fournisseur.nom),
                                    ),
                                  )
                                : Chip(
                                    label: Text(fournisseur.nom),
                                    onDeleted: () {
                                      setState(() {
                                        _selectedFournisseurs
                                            .remove(fournisseur);
                                      });
                                    },
                                  );
                          }).toList(),

                          // Si l'option est activée, afficher le reste des fournisseurs
                          if (_showAllFournisseurs)
                            ..._selectedFournisseurs.skip(3).map((fournisseur) {
                              return widget.specifiquefournisseur != null
                                  ? Card(
                                      elevation: 2,
                                      child: Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: Text(fournisseur.nom),
                                      ),
                                    )
                                  : Chip(
                                      label: Text(fournisseur.nom),
                                      onDeleted: () {
                                        setState(() {
                                          _selectedFournisseurs
                                              .remove(fournisseur);
                                        });
                                      },
                                    );
                            }).toList(),

                          // Si plus de 3 fournisseurs, afficher un bouton "plus"
                          if (_selectedFournisseurs.length > 3)
                            GestureDetector(
                              onTap: () {
                                setState(() {
                                  // Développer la liste pour afficher tous les fournisseurs
                                  _showAllFournisseurs = !_showAllFournisseurs;
                                });
                              },
                              child: RawChip(
                                padding: EdgeInsets.all(7),
                                label: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(!_showAllFournisseurs
                                        ? "+ ${_selectedFournisseurs.length - 3}"
                                        : "Réduire"),
                                    Icon(
                                      !_showAllFournisseurs
                                          ? Icons.expand_more
                                          : Icons.expand_less,
                                      size: 20,
                                    ),
                                  ],
                                ),
                              ),
                            ),

                          // Icône pour ajouter un fournisseur (toujours la dernière)
                          widget.specifiquefournisseur == null
                              ? IconButton(
                                  icon: Icon(Icons.add),
                                  onPressed: () async {
                                    final result =
                                        await Navigator.of(context).push(
                                      MaterialPageRoute(
                                        builder: (context) =>
                                            FournisseurSelectionScreen(
                                          selectedFournisseurs:
                                              _selectedFournisseurs,
                                          onSelectedFournisseursChanged:
                                              _onSelectedFournisseursChanged,
                                        ),
                                      ),
                                    );
                                    if (result != null) {
                                      setState(() {
                                        _selectedFournisseurs = result;
                                      });
                                    }
                                  },
                                )
                              : Container(),
                        ],
                      ),
                    ),
                    Flexible(
                      child: Container(
                        width: largeur,
                        child: ListView.builder(
                          shrinkWrap: true,
                          physics: NeverScrollableScrollPhysics(),
                          itemCount: _approvisionnementTemporaire
                              .length, // Utilisation de la liste temporaire
                          itemBuilder: (context, index) {
                            final approvisionnement =
                                _approvisionnementTemporaire[index];
                            return Card(
                              child: ListTile(
                                  onTap: () {
                                    // Démarrer l'édition de cet approvisionnement
                                    startEditing(approvisionnement);
                                  },
                                  dense: true,
                                  leading: FittedBox(
                                      child: Text(
                                    '${approvisionnement.quantite.toStringAsFixed(2)}',
                                    style: TextStyle(fontSize: 15),
                                  )),
                                  trailing: Container(
                                    width: 100,
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.end,
                                      children: [
                                        FittedBox(
                                          child: Text(
                                            '${approvisionnement.prixAchat.toStringAsFixed(2)}',
                                            style: TextStyle(fontSize: 15),
                                          ),
                                        ),
                                        IconButton(
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
                                                  approvisionnement.quantite;
                                            });

                                            // Si vous utilisez un StatefulWidget, pensez à appeler setState()
                                          },
                                        ),
                                      ],
                                    ),
                                  ),
                                  title: Text(
                                    approvisionnement.datePeremption != null
                                        ? 'Date de péremption: ${DateFormat('dd/MM/yyyy').format(approvisionnement.datePeremption!)}'
                                        : 'Date de péremption non spécifiée',
                                    style: TextStyle(fontSize: 15),
                                  )),
                            );
                          },
                        ),
                      ),
                    ),
                  ],
                ),
              ),

        SizedBox(height: 20),
      ],
    );
  }

  Column buildColumnPicSuplyers(double largeur, BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Platform.isAndroid || Platform.isIOS
            ? SizedBox()
            : SizedBox(
                height: 70,
              ),
        _isFirstFieldFilled
            ? Center(
                child: Container(
                  width: largeur,
                  height: Platform.isAndroid || Platform.isIOS ? 150 : 300,
                  child: _image == null
                      ? Stack(
                          alignment: Alignment.center,
                          children: [
                            _existingImageUrl != null &&
                                    _existingImageUrl!.isNotEmpty
                                ? Image.network(
                                    _existingImageUrl!,
                                    fit: BoxFit.cover,
                                  )
                                : Text(''),
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
                              Image.file(
                                _image!,
                                fit: BoxFit.cover,
                              ),
                              Icon(
                                Icons.delete,
                                color: Colors.red,
                              ),
                            ],
                          ),
                        ),
                ),
              )
            : Container(),
        SizedBox(height: 20),
        _isFirstFieldFilled
            ? Row(
                children: [
                  Expanded(
                    child: Wrap(
                      spacing: 8.0,
                      runSpacing: 4.0,
                      children: _selectedFournisseurs.map((fournisseur) {
                        return widget.specifiquefournisseur != null
                            ? Card(
                                elevation: 2,
                                child: Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Text(fournisseur.nom),
                                ),
                              )
                            : Chip(
                                label: Text(fournisseur.nom),
                                onDeleted: () {
                                  setState(() {
                                    _selectedFournisseurs.remove(fournisseur);
                                  });
                                },
                              );
                      }).toList(),
                    ),
                  ),
                  widget.specifiquefournisseur == null
                      ? IconButton(
                          icon: Icon(Icons.add),
                          onPressed: () async {
                            final result = await Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (context) =>
                                    FournisseurSelectionScreen(
                                  selectedFournisseurs: _selectedFournisseurs,
                                  onSelectedFournisseursChanged:
                                      _onSelectedFournisseursChanged,
                                ),
                              ),
                            );
                            if (result != null) {
                              setState(() {
                                _selectedFournisseurs = result;
                              });
                            }
                          },
                        )
                      : Container(),
                ],
              )
            : Container(),
        SizedBox(height: 20),
        //buildButton_Edit_Add(context, produitProvider, _isFinded),
        SizedBox(
          height: 50,
        ),
      ],
    );
  }

  AppBar buildAppBar(BuildContext context, CommerceProvider produitProvider) {
    return AppBar(
      title: FittedBox(
        child: Text(widget.specifiquefournisseur == null
            ? ('Ajouter un Nouveau Produit')
            : 'Ajouter Produit ${'à \n' + widget.specifiquefournisseur!.nom}'),
      ),
      actions: [
        IconButton(
          icon: Icon(Icons.clear_all),
          onPressed: _clearAllFields,
          tooltip: 'Effacer tous les champs',
        ),
        buildButton_Edit_Add(context, produitProvider, _isFinded),
      ],
    );
  }
}
