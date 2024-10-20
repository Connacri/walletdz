import 'dart:io';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:dart_date/dart_date.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:path/path.dart' as path;
import '../Entity.dart';
import '../MyProviders.dart';
import '../Utils/country_flags.dart';
import '../Utils/mobile_scanner/barcode_scanner_window.dart';
import 'AddFournisseurFormFromProduit.dart';
import 'package:flutter/gestures.dart';
//import 'package:vibration/vibration.dart';

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
  Fournisseur? _currentFournisseur;
  Fournisseur? _selectedFournisseur;
  String _lastScannedCode = '';
  DateTime selectedDate = DateTime.now();
  Approvisionnement? _currentApprovisionnement;
  String _tempProduitId = '';
  double stockGlobale = 0.0; // Déclaration de la variable
  double stockTemp = 0;
  bool _showDescription = false;
  bool _isFirstFieldFilled = false;
  bool _isFinded = false;
  bool _isDetail = false;
  bool _isAlertShow = false;
  bool _isEditing = false;
  bool _editQr = true;
  bool _showAppro = false;
  bool _showAllFournisseurs = false;
  List<Fournisseur> _selectedFournisseurs = [];
  List<Approvisionnement> _approvisionnementTemporaire = [];

  final List<String> _qrCodesTemp =
      []; // Liste temporaire pour stocker les QR codes

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
    _isFirstFieldFilled = false;
    _isFinded = false;
    _isDetail = false;
    _isAlertShow = false;
    _isEditing = false;
    _editQr = true;
    _showAppro = false;
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
      // if (await Vibration.hasVibrator()) {
      //   Vibration.vibrate();
      // }
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Code QR déjà utilisé'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment:
                  CrossAxisAlignment.start, // Alignement des widgets à gauche
              children: [
                Text(
                  'Le code ${code} est déjà associé au produit suivant :',
                  textAlign: TextAlign.start, // Alignement du texte à gauche
                ),
                SizedBox(height: 10),
                Text(
                  'Nom : ${produit.nom}',
                  textAlign: TextAlign.start,
                ),
                Text(
                  'Description : ${produit.description ?? "Pas de description"}',
                  textAlign: TextAlign.start,
                ),
                Text(
                  'Prix de vente : ${produit.prixVente.toStringAsFixed(2)} DA',
                  textAlign: TextAlign.start,
                ),
                Text(
                  'Stock : ${produit.stock.toStringAsFixed(2)}',
                  textAlign: TextAlign.start,
                ),
                Text(
                  'Last Edit : ${produit.derniereModification.format('yMMMMd', 'fr_FR')}',
                  textAlign: TextAlign.start,
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Center(
                    child: produit.image != null
                        ? ClipRRect(
                            borderRadius: BorderRadius.circular(
                                8.0), // Optionnel : pour arrondir les coins
                            child: AspectRatio(
                              aspectRatio:
                                  1, // Ratio 1:1 pour forcer l'image à être carrée
                              child: CachedNetworkImage(
                                imageUrl: produit.image!,
                                fit: BoxFit.cover, // Centrer l'image
                                placeholder: (context, url) => Center(
                                  child:
                                      CircularProgressIndicator(), // Indicateur de chargement
                                ),
                                errorWidget: (context, url, error) =>
                                    Icon(Icons.error), // Widget en cas d'erreur
                              ),
                            ),
                          )
                        : Container(),
                  ),
                ),
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
              crossAxisAlignment:
                  CrossAxisAlignment.start, // Alignement des widgets à gauche
              children: [
                Text(
                  'Le code QR est déjà associé au produit suivant :',
                  textAlign: TextAlign.start, // Alignement du texte à gauche
                ),
                SizedBox(height: 10),
                Text(
                  'Nom : ${produit.nom}',
                  textAlign: TextAlign.start,
                ),
                Text(
                  'Description : ${produit.description ?? "Pas de description"}',
                  textAlign: TextAlign.start,
                ),
                Text(
                  'Prix de vente : ${produit.prixVente.toStringAsFixed(2)} DA',
                  textAlign: TextAlign.start,
                ),
                Text(
                  'Stock : ${produit.stock.toStringAsFixed(2)}',
                  textAlign: TextAlign.start,
                ),
                Text(
                  'Last Edit : ${produit.derniereModification.format('yMMMMd', 'fr_FR')}',
                  textAlign: TextAlign.start,
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Center(
                    child: produit.image != null
                        ? ClipRRect(
                            borderRadius: BorderRadius.circular(
                                8.0), // Optionnel : pour arrondir les coins
                            child: AspectRatio(
                              aspectRatio:
                                  1, // Ratio 1:1 pour forcer l'image à être carrée
                              child: CachedNetworkImage(
                                imageUrl: produit.image!,
                                fit: BoxFit.cover, // Centrer l'image
                                placeholder: (context, url) => Center(
                                  child:
                                      CircularProgressIndicator(), // Indicateur de chargement
                                ),
                                errorWidget: (context, url, error) =>
                                    Icon(Icons.error), // Widget en cas d'erreur
                              ),
                            ),
                          )
                        : Container(),
                  ),
                ),
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
    // _serialController.text.isEmpty
    //     ? _approvisionnementTemporaire.clear()
    //     : null; /////// A VOIRE
    setState(() {
      _isFirstFieldFilled = _serialController.text.isNotEmpty;
    });
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
        _isDetail = true;
        _isAlertShow = true;
        _showAppro = true;
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
            qr: _qrCodesTemp.join(',').toString(),
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
          } else {
            print('Produit deja existe');
          }

          _formKey.currentState!.save();
          Navigator.of(context).pop();
        }
      },
      icon: Icon(
        _isFinded ? Icons.edit : Icons.check,
      ),
    );
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
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: TabletLayout(),
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
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: DesktopLayout(),
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
            _isFirstFieldFilled || _qrCodesTemp.isNotEmpty
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
            _isFirstFieldFilled || _qrCodesTemp.isNotEmpty
                ? Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: buildColumnPicSuplyers(largeur, context),
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
                            label:
                                Text(code), // Affiche le QR code dans le Chip
                            deleteIcon: Icon(Icons.delete, color: Colors.red),
                            onDeleted: () {
                              setState(() {
                                _qrCodesTemp.remove(
                                    code); // Supprime le QR code sélectionné
                              });
                            },
                          );
                        }),
                      ],
                    ),
                  ),
            _isFirstFieldFilled || _qrCodesTemp.isNotEmpty
                ? Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: TextFormField(
                      enabled: _isFirstFieldFilled || _qrCodesTemp.isNotEmpty,
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
                        prefixIcon: _isFirstFieldFilled
                            ? IconButton(
                                icon: Icon(Icons.clear),
                                onPressed: () {
                                  _clearAllFields();
                                  _editQr = false;
                                  _isAlertShow = false;
                                  _isDetail = false;
                                  _showAppro = false;
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
                            enabled:
                                _isFirstFieldFilled || _qrCodesTemp.isNotEmpty,
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
            _isFirstFieldFilled || _qrCodesTemp.isNotEmpty
                ? Container(
                    width: largeur,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: TextFormField(
                              enabled: _isFirstFieldFilled ||
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
                        _showAppro
                            ? Container()
                            : Expanded(
                                child: Padding(
                                  padding: const EdgeInsets.all(8.0),
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
                              ),

                        // stock alert
                      ],
                    ),
                  )
                : Container(),
            _isFirstFieldFilled || _qrCodesTemp.isNotEmpty
                ? !_isAlertShow
                    ? Center(
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: RichText(
                            text: TextSpan(
                              text: 'Ajouter Alert',
                              style: Theme.of(context).textTheme.labelMedium,
                              recognizer: TapGestureRecognizer()
                                ..onTap = () {
                                  setState(() {
                                    _isAlertShow = !_isAlertShow;
                                  });
                                },
                            ),
                          ),
                        ),
                      )
                    : Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Container(
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
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Center(
                                child: Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: RichText(
                                    text: TextSpan(
                                      text: 'Alert',
                                      style: Theme.of(context)
                                          .textTheme
                                          .labelSmall,
                                      recognizer: TapGestureRecognizer()
                                        ..onTap = () {
                                          setState(() {
                                            _isAlertShow = !_isAlertShow;
                                          });
                                        },
                                    ),
                                  ),
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Row(
                                  children: [
                                    Expanded(
                                      child: TextFormField(
                                        enabled: _isFirstFieldFilled ||
                                            _qrCodesTemp.isNotEmpty,
                                        controller: _minimStockController,
                                        textAlign: TextAlign.center,
                                        decoration: InputDecoration(
                                          labelText: 'Stock',

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
                                      child: TextFormField(
                                        enabled: _isFirstFieldFilled ||
                                            _qrCodesTemp.isNotEmpty,
                                        controller: _alertPeremptionController,
                                        textAlign: TextAlign.center,
                                        decoration: InputDecoration(
                                          labelText: 'Expiration',
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
                            ],
                          ),
                        ),
                      )
                : Container(), // alert stock row
            _isFirstFieldFilled || _qrCodesTemp.isNotEmpty
                ? !_isDetail
                    ? Center(
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: RichText(
                            text: TextSpan(
                              text: 'Si Votre produit se Vend en Unité Détails',
                              style: Theme.of(context).textTheme.labelLarge,
                              recognizer: TapGestureRecognizer()
                                ..onTap = () {
                                  setState(() {
                                    _isDetail = !_isDetail;
                                  });
                                },
                            ),
                          ),
                        ),
                      )
                    : Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Container(
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
                            children: [
                              Center(
                                child: Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: RichText(
                                    text: TextSpan(
                                      text: 'Combien d\'Unité dans ce produit',
                                      style:
                                          Theme.of(context).textTheme.bodyLarge,
                                      recognizer: TapGestureRecognizer()
                                        ..onTap = () {
                                          setState(() {
                                            _isDetail = !_isDetail;
                                          });
                                        },
                                    ),
                                  ),
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Row(
                                  children: [
                                    Expanded(
                                      child: TextFormField(
                                        enabled: _isFirstFieldFilled ||
                                            _qrCodesTemp.isNotEmpty,
                                        controller: _qtyPartielController,
                                        textAlign: TextAlign.center,
                                        decoration: InputDecoration(
                                          labelText: 'Partiel Quantité',

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
                                        keyboardType: TextInputType.number,
                                        validator: (value) {
                                          if (value == null || value.isEmpty) {
                                            return 'Veuillez entrer le nombre de detail';
                                          }
                                          return null;
                                        },
                                      ),
                                    ), // stock alert
                                    SizedBox(width: 10),
                                    Expanded(
                                      child: TextFormField(
                                        enabled: _isFirstFieldFilled ||
                                            _qrCodesTemp.isNotEmpty,
                                        controller:
                                            _pricePartielVenteController,
                                        textAlign: TextAlign.center,
                                        decoration: InputDecoration(
                                          labelText: 'Detail Price',
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
                                            return 'Veuillez entrer Le Prix de detail';
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
                            ],
                          ),
                        ),
                      )
                : Container(), // Detail row

            ///********************************************************************** 1
            _qrCodesTemp.isEmpty
                ? Padding(
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
                                    !_showAppro
                                        ? Container()
                                        : Expanded(
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
                                                      BorderRadius.circular(
                                                          8.0),
                                                  borderSide: BorderSide
                                                      .none, // Supprime le contour
                                                ),
                                                enabledBorder:
                                                    OutlineInputBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          8.0),
                                                  borderSide: BorderSide
                                                      .none, // Supprime le contour en état normal
                                                ),
                                                focusedBorder:
                                                    OutlineInputBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          8.0),
                                                  borderSide: BorderSide
                                                      .none, // Supprime le contour en état focus
                                                ),
                                                //border: InputBorder.none,
                                                filled: true,
                                                contentPadding:
                                                    EdgeInsets.all(15),
                                              ),
                                              keyboardType:
                                                  TextInputType.number,
                                              // validator: (value) {
                                              //   if (value == null || value.isEmpty) {
                                              //     return 'Veuillez entrer le stock';
                                              //   }
                                              //   return null;
                                              // },
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
                                                  style:
                                                      ElevatedButton.styleFrom(
                                                    foregroundColor:
                                                        Theme.of(context)
                                                            .colorScheme
                                                            .primary,
                                                    backgroundColor:
                                                        Theme.of(context)
                                                            .colorScheme
                                                            .onPrimary,
                                                    shape:
                                                        RoundedRectangleBorder(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              15.0),
                                                    ),
                                                  ),
                                                  onPressed: () async {
                                                    final result =
                                                        await Navigator.of(
                                                                context)
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
                                    icon: Icon(
                                        _isEditing ? Icons.edit : Icons.send,
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
                                        final fournisseur = approvisionnement
                                            .fournisseur.target;

                                        return Card(
                                            child: InkWell(
                                          onTap: () {
                                            // Démarrer l'édition de cet approvisionnement
                                            startEditing(approvisionnement);
                                          },
                                          borderRadius:
                                              BorderRadius.circular(15),
                                          child: Row(
                                            children: [
                                              Expanded(
                                                flex: 3,
                                                child: Padding(
                                                  padding:
                                                      const EdgeInsets.all(8.0),
                                                  child: Text(
                                                    '${approvisionnement.quantite.toStringAsFixed(approvisionnement.quantite.truncateToDouble() == approvisionnement.quantite ? 0 : 2)}',
                                                    style:
                                                        TextStyle(fontSize: 20),
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
                                                      overflow:
                                                          TextOverflow.ellipsis,
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
                                                    padding:
                                                        const EdgeInsets.only(
                                                            left: 8),
                                                    child: Text(
                                                      '${approvisionnement.prixAchat!.toStringAsFixed(2)}',
                                                      style: TextStyle(
                                                          fontSize: 20),
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
                  )
                : Container(),
          ],
        ),
      ),
    );
  }

  Container buildColumnPicSuplyers(double largeur, BuildContext context) {
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
