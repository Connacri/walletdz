import 'package:dart_date/dart_date.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'dart:io';
import 'package:path/path.dart' as path;
import '../Entity.dart';
import '../MyProviders.dart';
import '../Utils/QRViewExample.dart';
import 'FournisseurListScreen.dart';
import 'dart:io' show Platform;
import 'package:flutter/foundation.dart' show kIsWeb;

class add_Product extends StatefulWidget {
  final Fournisseur? specifiquefournisseur;

  add_Product({Key? key, this.qrCode, this.specifiquefournisseur})
      : super(key: key);
  final String? qrCode;

  @override
  State<add_Product> createState() => _add_ProductState();
}

class _add_ProductState extends State<add_Product> {
  final _formKey = GlobalKey<FormState>();
  final _nomController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _prixAchatController = TextEditingController();
  final _prixVenteController = TextEditingController();
  final _stockController = TextEditingController();
  final _serialController = TextEditingController();
  final _datePeremptionController = TextEditingController();
  final _dateCreationController = TextEditingController();
  final _derniereModificationController = TextEditingController();
  final _stockUpdateController = TextEditingController();
  final _stockinitController = TextEditingController();

  List<Fournisseur> _selectedFournisseurs = [];

  File? _image;
  String? _existingImageUrl;
  bool _isFirstFieldFilled = false;
  bool _isFinded = false;
  bool _editQr = true;
  String _tempProduitId = '';
  String _lastScannedCode =
      ''; // Nouvelle variable pour suivre le dernier code scanné

  DateTime selectedDate = DateTime.now();

  @override
  void initState() {
    super.initState();

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
    _datePeremptionController.dispose();
    _dateCreationController.dispose();
    _derniereModificationController.dispose();
    _stockUpdateController.dispose();
    _stockinitController.dispose();

    super.dispose();
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
        builder: (context) => QRViewExample(),
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
          _nomController.text = produit.nom;
          _descriptionController.text = produit.description!;
          _prixAchatController.text = produit.prixAchat.toStringAsFixed(2);
          _prixVenteController.text = produit.prixVente.toStringAsFixed(2);
          _stockController.text = produit.stock.toString();
          _datePeremptionController.text = produit.datePeremption.toString();
          _dateCreationController.text = produit.dateCreation.toString();
          _derniereModificationController.text =
              produit.derniereModification.toString();
          _stockUpdateController.text = produit.stockUpdate.toString();
          _stockinitController.text = produit.stockinit.toString();
        });
      } else {
        setState(() {
          // _serialController.text = code;
          _nomController.clear();
          _descriptionController.clear();
          _prixAchatController.clear();
          _prixVenteController.clear();
          _stockController.clear();
          _selectedFournisseurs.clear();
          _datePeremptionController.clear();
          _dateCreationController.clear();
          _derniereModificationController.clear();
          _stockUpdateController.clear();
          _stockinitController.clear();
          _existingImageUrl = '';
          _isFirstFieldFilled = false;
          _image = null;
        });
      }
    }
  }

  void _onSerialChanged() {
    final code = _serialController.text;

    // Vérifie si le champ est vide en premier lieu pour éviter des opérations inutiles.
    if (code.isEmpty || code == _lastScannedCode) {
      // _clearAllFields();

      return;
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
        _prixAchatController.text = produit.prixAchat.toStringAsFixed(2);
        _prixVenteController.text = produit.prixVente.toStringAsFixed(2);
        _stockController.text = produit.stock.toString();
        _datePeremptionController.text =
            produit.datePeremption.format('yMMMMd', 'fr_FR');
        _dateCreationController.text =
            produit.dateCreation.format('yMMMMd', 'fr_FR');
        _derniereModificationController.text =
            produit.derniereModification.format('yMMMMd', 'fr_FR');
        _stockUpdateController.text =
            produit.stockUpdate.format('yMMMMd', 'fr_FR');
        _stockinitController.text = produit.stockinit.toString();
        _selectedFournisseurs = List.from(produit.fournisseurs);
        _existingImageUrl = produit.image;
        _isFinded = true;
        _image = null;
      });
    } else {
      if (_tempProduitId.isNotEmpty) {
        _tempProduitId = '';
        _nomController.clear();
        _descriptionController.clear();
        _prixAchatController.clear();
        _prixVenteController.clear();
        _stockController.clear();
        _selectedFournisseurs.clear();
        _datePeremptionController.clear();
        _dateCreationController.clear();
        _derniereModificationController.clear();
        _stockUpdateController.clear();
        _stockinitController.clear();
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
      _nomController.clear();
      _descriptionController.clear();
      _prixAchatController.clear();
      _prixVenteController.clear();
      _stockController.clear();
      _selectedFournisseurs.clear();
      _datePeremptionController.clear();
      _dateCreationController.clear();
      _derniereModificationController.clear();
      _stockUpdateController.clear();
      _stockinitController.clear();
      _existingImageUrl = '';
      _isFirstFieldFilled = false;
      _image = null;
    });
  }

  void _onSelectedFournisseursChanged(List<Fournisseur> fournisseurs) {
    setState(() {
      _selectedFournisseurs = fournisseurs;
    });
  }

  IconButton buildButton_Edit_Add(
      BuildContext context, CommerceProvider produitProvider, _isFinded) {
    return IconButton(
      onPressed: () async {
        final dateFormat = DateFormat('dd MMM yyyy', 'fr');
        final datePeremption =
            dateFormat.parseLoose(_datePeremptionController.text);

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
              prixAchat: double.parse(_prixAchatController.text),
              prixVente: double.parse(_prixVenteController.text),
              stock: int.parse(_stockController.text),
              datePeremption: datePeremption,
              dateCreation: DateTime.now(),
              derniereModification: DateTime.now(),
              stockUpdate: DateTime.now(),
              stockinit: int.parse(_stockController.text),
            );

            if (widget.specifiquefournisseur == null) {
              if (produitDejaExist != null) {
                return;
              } else {
                produitProvider.ajouterProduit(produit, _selectedFournisseurs);
                print('Nouveau produit ajouté');
              }
            } else {
              if (produitDejaExist != null) {
                // Mise à jour d'un produit existant
                produitProvider.updateProduitById(
                    int.parse(_tempProduitId), produit,
                    fournisseurs: [
                      ..._selectedFournisseurs,
                      ...[widget.specifiquefournisseur!]
                    ]);

                print('Produit existant mis à jour');
              } else {
                produitProvider
                    .ajouterProduit(produit, [widget.specifiquefournisseur!]);
                print('Nouveau produit ajouté');
              }
            }

            // if (produitDejaExist != null) {
            //   return;
            // } else if (widget.specifiquefournisseur == null) {
            //   //add new
            //
            //   produitProvider.ajouterProduit(
            //       produit,
            //       // widget.specifiquefournisseur == null
            //       //     ?
            //       _selectedFournisseurs);
            //   print('Nouveau produit ajouté');
            // : [
            //     ..._selectedFournisseurs,
            //     ...[widget.specifiquefournisseur!]
            //   ]);
            //[widget.specifiquefournisseur!]);

            // [
            //   ..._selectedFournisseurs,
            //   ...[widget.specifiquefournisseur!]
            // ]
            // context
            //     .read<CommerceProvider>()
            //     .ajouterProduit(produit, _selectedFournisseurs);

            // _selectedFournisseurs.isEmpty
            //     ? [widget.specifiquefournisseur!]
            //     : _selectedFournisseurs);
            //
            //   print('Nouveau produit ajouté');
            // } else {
            //   // Mise à jour d'un produit existant
            //   produitProvider.updateProduitById(
            //       int.parse(_tempProduitId), produit,
            //       fournisseurs: [
            //         ..._selectedFournisseurs,
            //         ...[widget.specifiquefournisseur!]
            //       ]);
            //
            //   print('Produit existant mis à jour');
            // }
////////////////////////////////////////////////////////////////////////////////
//             if (produitDejaExist == null) {
//               if (widget.produit != null) {
//                 if (_serialController.text == produitDejaExist.qr)
//                   // Mise à jour d'un produit existant
//                   produitProvider.updateProduitById(widget.produit!.id, produit,
//                       fournisseurs: widget.specifiquefournisseur != null
//                           ? null
//                           : _selectedFournisseurs);
//
//                 print('Produit existant mis à jour');
//               } else if (_isFinded) {
//                 produitProvider.updateProduitById(
//                     int.parse(_tempProduitId), produit,
//                     fournisseurs: widget.specifiquefournisseur != null
//                         ? null
//                         : _selectedFournisseurs);
//
//                 print('Produit trouvé mis à jour');
//               } else {
//                 // Ajout d'un nouveau produit
//                 produitProvider.ajouterProduit(produit, _selectedFournisseurs);
//                 context.read<CommerceProvider>().ajouterProduit(
//                     produit,
//                     _selectedFournisseurs.isEmpty
//                         ? [widget.specifiquefournisseur!]
//                         : _selectedFournisseurs);
//
//                 print('Nouveau produit ajouté');
//               }
//             }
//             // else if (
//             // produitDejaExist.qr != _serialController) {
//             //
//             // }
//             else {
//               ScaffoldMessenger.of(context).showSnackBar(
//                 SnackBar(
//                   content: Text(
//                     'QR / Code Barre Produit existe déja !',
//                     style: TextStyle(color: Colors.white),
//                   ),
//                   backgroundColor: Colors.red,
//                 ),
//               );
//             }
            ///////////////////////////////////////////////////////////////////

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

  @override
  Widget build(BuildContext context) {
    final produitProvider =
        Provider.of<CommerceProvider>(context, listen: false);
    final double largeur;
    if (kIsWeb || Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
      // Pour le web
      largeur = MediaQuery.of(context).size.width / 3;
    } else if (Platform.isAndroid || Platform.isIOS) {
      // Pour Android et iOS
      largeur = MediaQuery.of(context).size.width;
    } else {
      // Pour les autres plateformes (Desktop)
      largeur = MediaQuery.of(context).size.width / 3;
    }
    return Scaffold(
      appBar: buildAppBar(context, produitProvider),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(
            horizontal: 15,
          ),
          child: Platform.isAndroid || Platform.isIOS
              ? Column(
                  children: [
                    buildColumnForm(largeur),
                    buildColumnPicSuplyers(largeur, context),
                  ],
                )
              : Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(child: buildColumnForm(largeur)),
                    Expanded(child: buildColumnPicSuplyers(largeur, context)),
                  ],
                ),
        ),
      ),
    );
  }

  Column buildColumnForm(double largeur) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        Container(
          height: 30,
          child: _tempProduitId.isNotEmpty
              ? Text('ID : ${_tempProduitId}',
                  style: TextStyle(
                    fontSize: 20,
                  ))
              : Text(
                  'L\'ID du Produit n\'a pas encore été créer',
                  style: TextStyle(fontSize: 20),
                ),
        ),
        Container(
          height: 30,
          child: _tempProduitId.isNotEmpty
              ? Row(
                  mainAxisAlignment: MainAxisAlignment.center,
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
                        style: TextStyle(
                          fontSize: 20,
                        )),
                  ],
                )
              : Text(
                  '', //'Creation d\'un Nouveau Produit',
                  style: TextStyle(fontSize: 20),
                ),
        ),
        SizedBox(height: 10),
        Container(
          width: largeur,
          child: TextFormField(
            //focusNode: FocusNode(),
            controller: _serialController,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 18,
            ),
            decoration: InputDecoration(
              hintStyle: TextStyle(color: Colors.black38),
              // labelText: 'Numéro de série',
              hintText: 'Code Barre / QrCode',

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
        ),
        SizedBox(height: 10),
        Container(
          width: largeur,
          child: TextFormField(
            enabled: _isFirstFieldFilled,
            controller: _nomController,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 18, color: Colors.black),
            keyboardType: TextInputType.text,
            decoration: InputDecoration(
              hintStyle: TextStyle(color: Colors.black38),
              fillColor: _isFirstFieldFilled ? Colors.green.shade100 : null,
              hintText: 'Nom Du Produit',
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
        ),
        SizedBox(height: 10),
        Container(
          width: largeur,
          child: TextFormField(
            enabled: _isFirstFieldFilled,
            controller: _descriptionController,
            textAlign: TextAlign.center,
            maxLines: 5, // Permet un nombre illimité de lignes

            style: const TextStyle(
              fontSize: 18,
            ),
            keyboardType: TextInputType.text,
            decoration: InputDecoration(
              hintStyle: TextStyle(color: Colors.black38),
              //fillColor: Colors.blue.shade50,

              hintText: 'Déscription',
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
          ),
        ),
        SizedBox(height: 10),
        // Container(
        //   width: largeur,
        //   child: TextFormField(
        //     enabled: _isFirstFieldFilled,
        //     controller: _dateCreationController,
        //     textAlign: TextAlign.center,
        //     style: const TextStyle(fontSize: 18, color: Colors.black),
        //     keyboardType: TextInputType.text,
        //     decoration: InputDecoration(
        //       hintStyle: TextStyle(color: Colors.black38),
        //       fillColor: _isFirstFieldFilled ? Colors.green.shade100 : null,
        //       hintText: 'Date de Création',
        //       border: OutlineInputBorder(
        //         borderRadius: BorderRadius.circular(8.0),
        //         borderSide: BorderSide.none, // Supprime le contour
        //       ),
        //       enabledBorder: OutlineInputBorder(
        //         borderRadius: BorderRadius.circular(8.0),
        //         borderSide:
        //             BorderSide.none, // Supprime le contour en état normal
        //       ),
        //       focusedBorder: OutlineInputBorder(
        //         borderRadius: BorderRadius.circular(8.0),
        //         borderSide:
        //             BorderSide.none, // Supprime le contour en état focus
        //       ),
        //       filled: true,
        //       contentPadding: EdgeInsets.all(15),
        //     ),
        //     validator: (value) {
        //       if (value == null || value.isEmpty) {
        //         return 'Veuillez entrer un nom du Produit';
        //       }
        //       return null;
        //     },
        //   ),
        // ),
        // SizedBox(height: 10),
        // Container(
        //   width: largeur,
        //   child: TextFormField(
        //     enabled: _isFirstFieldFilled,
        //     controller: _derniereModificationController,
        //     textAlign: TextAlign.center,
        //     style: const TextStyle(fontSize: 18, color: Colors.black),
        //     keyboardType: TextInputType.text,
        //     decoration: InputDecoration(
        //       hintStyle: TextStyle(color: Colors.black38),
        //       fillColor: _isFirstFieldFilled ? Colors.green.shade100 : null,
        //       hintText: 'Dernière Modification',
        //       border: OutlineInputBorder(
        //         borderRadius: BorderRadius.circular(8.0),
        //         borderSide: BorderSide.none, // Supprime le contour
        //       ),
        //       enabledBorder: OutlineInputBorder(
        //         borderRadius: BorderRadius.circular(8.0),
        //         borderSide:
        //             BorderSide.none, // Supprime le contour en état normal
        //       ),
        //       focusedBorder: OutlineInputBorder(
        //         borderRadius: BorderRadius.circular(8.0),
        //         borderSide:
        //             BorderSide.none, // Supprime le contour en état focus
        //       ),
        //       filled: true,
        //       contentPadding: EdgeInsets.all(15),
        //     ),
        //     validator: (value) {
        //       if (value == null || value.isEmpty) {
        //         return 'Veuillez entrer un nom du Produit';
        //       }
        //       return null;
        //     },
        //   ),
        // ),
        // SizedBox(height: 10),
        Container(
          width: largeur,
          child: TextFormField(
            enabled: _isFirstFieldFilled,
            controller: _datePeremptionController,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 18, color: Colors.black),
            keyboardType: TextInputType.text,
            decoration: InputDecoration(
              hintStyle: TextStyle(color: Colors.black38),
              fillColor: _isFirstFieldFilled ? Colors.green.shade100 : null,
              hintText: 'Date de Péremption',
              suffixIcon: IconButton(
                icon: const Icon(Icons.date_range),
                onPressed: () async {
                  final DateTime? dateTimePerem = await showDatePicker(
                    context: context,
                    initialDate: selectedDate,
                    firstDate: DateTime(2000),
                    lastDate: DateTime(2200),
                  );
                  if (dateTimePerem != null) {
                    setState(() {
                      selectedDate = dateTimePerem;
                      _datePeremptionController.text =
                          dateTimePerem.format('yMMMMd', 'fr_FR');
                    });
                  }
                },
              ),
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
        ),
        SizedBox(height: 10),
        // Container(
        //   width: largeur,
        //   child: TextFormField(
        //     enabled: _isFirstFieldFilled,
        //     controller: _stockUpdateController,
        //     textAlign: TextAlign.center,
        //     style: const TextStyle(fontSize: 18, color: Colors.black),
        //     keyboardType: TextInputType.text,
        //     decoration: InputDecoration(
        //       hintStyle: TextStyle(color: Colors.black38),
        //       fillColor: _isFirstFieldFilled ? Colors.green.shade100 : null,
        //       hintText: 'Date Update Stock',
        //       border: OutlineInputBorder(
        //         borderRadius: BorderRadius.circular(8.0),
        //         borderSide: BorderSide.none, // Supprime le contour
        //       ),
        //       enabledBorder: OutlineInputBorder(
        //         borderRadius: BorderRadius.circular(8.0),
        //         borderSide:
        //             BorderSide.none, // Supprime le contour en état normal
        //       ),
        //       focusedBorder: OutlineInputBorder(
        //         borderRadius: BorderRadius.circular(8.0),
        //         borderSide:
        //             BorderSide.none, // Supprime le contour en état focus
        //       ),
        //       filled: true,
        //       contentPadding: EdgeInsets.all(15),
        //     ),
        //     validator: (value) {
        //       if (value == null || value.isEmpty) {
        //         return 'Veuillez entrer un nom du Produit';
        //       }
        //       return null;
        //     },
        //   ),
        // ),
        // SizedBox(height: 10),
        // Container(
        //   width: largeur,
        //   child: TextFormField(
        //     enabled: _isFirstFieldFilled,
        //     controller: _stockinitController,
        //     textAlign: TextAlign.center,
        //     style: const TextStyle(fontSize: 18, color: Colors.black),
        //     keyboardType: TextInputType.text,
        //     decoration: InputDecoration(
        //       hintStyle: TextStyle(color: Colors.black38),
        //       fillColor: _isFirstFieldFilled ? Colors.green.shade100 : null,
        //       hintText: 'Stock Initial',
        //       border: OutlineInputBorder(
        //         borderRadius: BorderRadius.circular(8.0),
        //         borderSide: BorderSide.none, // Supprime le contour
        //       ),
        //       enabledBorder: OutlineInputBorder(
        //         borderRadius: BorderRadius.circular(8.0),
        //         borderSide:
        //             BorderSide.none, // Supprime le contour en état normal
        //       ),
        //       focusedBorder: OutlineInputBorder(
        //         borderRadius: BorderRadius.circular(8.0),
        //         borderSide:
        //             BorderSide.none, // Supprime le contour en état focus
        //       ),
        //       filled: true,
        //       contentPadding: EdgeInsets.all(15),
        //     ),
        //     validator: (value) {
        //       if (value == null || value.isEmpty) {
        //         return 'Veuillez entrer un nom du Produit';
        //       }
        //       return null;
        //     },
        //   ),
        // ),
        // SizedBox(height: 10),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: -5 + largeur / 2,
              child: TextFormField(
                enabled: _isFirstFieldFilled,
                controller: _prixAchatController,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 18,
                ),
                decoration: InputDecoration(
                  hintStyle: TextStyle(color: Colors.black38),
                  //fillColor: Colors.blue.shade50,
                  hintText: 'Prix d\'achat',

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
                //  validator: (value) {
                //    if (value == null || value.isEmpty) {
                //      return 'Veuillez entrer le prix d\'achat';
                //    }
                //    return null;
                //  },
                keyboardType: TextInputType.numberWithOptions(decimal: true),
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}')),
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
            SizedBox(width: 10),
            Container(
              width: -5 + largeur / 2,
              child: TextFormField(
                enabled: _isFirstFieldFilled,
                controller: _prixVenteController,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 18,
                ),
                decoration: InputDecoration(
                  hintStyle: TextStyle(color: Colors.black38),
                  //fillColor: Colors.blue.shade50,
                  hintText: 'Prix de vente',

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
          ],
        ),
        SizedBox(height: 10),
        Container(
          width: largeur,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              _editQr == true
                  ? GestureDetector(
                      onTap: () {
                        // _stockController.text =
                        //     produit.stock.toString();
                      },
                      child: CircleAvatar(
                          child: Text(
                        _stockController.text.toString(),
                      )),
                    )
                  : CircleAvatar(
                      child: Text(
                      ' ',
                    )),
              SizedBox(
                width: 10,
              ),
              Expanded(
                child: TextFormField(
                  enabled: _isFirstFieldFilled,
                  controller: _stockController,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 18,
                  ),
                  decoration: InputDecoration(
                    hintStyle: TextStyle(color: Colors.black38),
                    //fillColor: Colors.blue.shade50,
                    // prefixIcon: IconButton(
                    //   onPressed: _showAddQuantityDialog,
                    //   icon: const Icon(Icons.add),
                    // ),
                    hintText: 'Stock',
                    prefix: Text(
                      'Stock',
                    ),
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
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Veuillez entrer le stock';
                    }
                    return null;
                  },
                ),
              ),
              SizedBox(
                width: 10,
              ),
              CircleAvatar(
                child: IconButton(
                  onPressed: _showAddQuantityDialog,
                  icon: const Icon(Icons.add),
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
      title: Text(widget.specifiquefournisseur == null
          ? ('Ajouter un Nouveau Produit')
          : 'Ajouter Produit ${'à \n' + widget.specifiquefournisseur!.nom}'),
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

// class edit_Product extends StatefulWidget {
//   final Produit? produit;
//   final Fournisseur? specifiquefournisseur;
//
//   edit_Product(
//       {Key? key, this.produit, this.qrCode, this.specifiquefournisseur})
//       : super(key: key);
//   final String? qrCode;
//
//   @override
//   State<edit_Product> createState() => _edit_ProductState();
// }
//
// class _edit_ProductState extends State<edit_Product> {
//   final _formKey = GlobalKey<FormState>();
//   final _nomController = TextEditingController();
//   final _descriptionController = TextEditingController();
//   final _prixAchatController = TextEditingController();
//   final _prixVenteController = TextEditingController();
//   final _stockController = TextEditingController();
//   final _serialController = TextEditingController();
//   final _datePeremptionController = TextEditingController();
//   final _dateCreationController = TextEditingController();
//   final _derniereModificationController = TextEditingController();
//   final _stockUpdateController = TextEditingController();
//   final _stockinitController = TextEditingController();
//
//   List<Fournisseur> _selectedFournisseurs = [];
//
//   File? _image;
//   String? _existingImageUrl;
//   bool _isFirstFieldFilled = false;
//   bool _isFinded = false;
//
//   @override
//   void initState() {
//     super.initState();
//
//     _serialController.addListener(_onSerialChanged);
//     _serialController.addListener(_checkFirstField);
//
//     _serialController.text = widget.produit!.qr ?? '';
//     _nomController.text = widget.produit!.nom ?? '';
//     _descriptionController.text = widget.produit!.description ?? '';
//     _prixAchatController.text = widget.produit!.prixAchat.toStringAsFixed(2);
//     _prixVenteController.text = widget.produit!.prixVente.toStringAsFixed(2);
//     _stockController.text = widget.produit!.stock.toString();
//     _existingImageUrl = widget.produit!.image;
//     _datePeremptionController.text = widget.produit!.datePeremption.toString();
//     _dateCreationController.text = widget.produit!.dateCreation.toString();
//     _derniereModificationController.text =
//         widget.produit!.derniereModification.toString();
//     _stockUpdateController.text = widget.produit!.stockUpdate.toString();
//     _stockinitController.text = widget.produit!.stockinit.toString();
//     _selectedFournisseurs = List.from(widget.produit!.fournisseurs);
//
//     // Initialize with specific supplier if provided
//     if (widget.specifiquefournisseur != null) {
//       _selectedFournisseurs = [widget.specifiquefournisseur!];
//     }
//   }
//
//   @override
//   void dispose() {
//     _serialController.removeListener(_onSerialChanged);
//     _serialController.dispose();
//     _nomController.dispose();
//     _descriptionController.dispose();
//     _prixAchatController.dispose();
//     _prixVenteController.dispose();
//     _stockController.dispose();
//     _datePeremptionController.dispose();
//     _dateCreationController.dispose();
//     _derniereModificationController.dispose();
//     _stockUpdateController.dispose();
//     _stockinitController.dispose();
//
//     super.dispose();
//   }
//
//   Future<void> _pickImage() async {
//     final ImageSource? source = Platform.isAndroid || Platform.isIOS
//         ? await showDialog<ImageSource>(
//             context: context,
//             builder: (BuildContext context) {
//               return SimpleDialog(
//                 title: const Text('Choisir une source'),
//                 children: <Widget>[
//                   SimpleDialogOption(
//                     padding: EdgeInsets.all(15),
//                     onPressed: () {
//                       Navigator.pop(context, ImageSource.gallery);
//                     },
//                     child: Row(
//                       children: [
//                         Icon(Icons.photo),
//                         SizedBox(
//                           width: 5,
//                         ),
//                         const Text('Galerie'),
//                       ],
//                     ),
//                   ),
//                   // Platform.isAndroid || Platform.isIOS
//                   //     ?
//                   SimpleDialogOption(
//                     padding: EdgeInsets.all(15),
//                     onPressed: () {
//                       Navigator.pop(context, ImageSource.camera);
//                     },
//                     child: Row(
//                       children: [
//                         Icon(Icons.camera_alt),
//                         SizedBox(
//                           width: 5,
//                         ),
//                         const Text('Caméra'),
//                       ],
//                     ),
//                   )
//                   // : Container()
//                   ,
//                 ],
//               );
//             },
//           )
//         : ImageSource.gallery;
//
//     if (source != null) {
//       final pickedFile = await ImagePicker().pickImage(
//         source: source,
//         maxHeight: 1080,
//         maxWidth: 1920,
//         imageQuality: 40,
//       );
//
//       if (pickedFile != null) {
//         setState(() {
//           _image = File(pickedFile.path);
//         });
//       }
//     }
//   }
//
//   Future<void> _scanQRCode() async {
//     final code = await Navigator.of(context).push<String>(
//       MaterialPageRoute(
//         builder: (context) => QRViewExample(),
//       ),
//     );
//     if (code != null) {
//       setState(() {
//         _serialController.text = code;
//       });
//
//       final provider = Provider.of<CommerceProvider>(context, listen: false);
//       //final produit = await provider.getProduitById(int.parse(code));
//       final produit = await provider.getProduitByQr(code);
//       if (produit != null) {
//         setState(() {
//           _nomController.text = produit.nom;
//           _descriptionController.text = produit.description ?? '';
//           _prixAchatController.text = produit.prixAchat.toStringAsFixed(2);
//           _prixVenteController.text = produit.prixVente.toStringAsFixed(2);
//           _stockController.text = produit.stock.toString();
//           _datePeremptionController.text = produit.datePeremption.toString();
//           _dateCreationController.text = produit.dateCreation.toString();
//           _derniereModificationController.text =
//               produit.derniereModification.toString();
//           _stockUpdateController.text = produit.stockUpdate.toString();
//           _stockinitController.text = produit.stockinit.toString();
//         });
//       } else {
//         _clearAllFields();
//       }
//     }
//   }
//
//   Future<String> uploadImageToSupabase(File image, String? oldImageUrl) async {
//     final String bucket = 'products';
//     final supabase = Supabase.instance.client;
//     final timestamp = DateTime.now().millisecondsSinceEpoch;
//     final fileName =
//         '${_prixVenteController.text}${_stockController.text}$timestamp${path.extension(image.path)}';
//
//     try {
//       await supabase.storage.from(bucket).upload(fileName, image);
//
//       final imageUrl = supabase.storage.from(bucket).getPublicUrl(fileName);
//       if (oldImageUrl != null && oldImageUrl.isNotEmpty) {
//         final oldFileName = Uri.parse(oldImageUrl).pathSegments.last;
//         await supabase.storage.from(bucket).remove([oldFileName]);
//       }
//
//       return imageUrl;
//     } catch (e) {
//       print('Erreur lors du téléchargement de l\'image : $e');
//       return '';
//     }
//   }
//
//   void _onSerialChanged() {
//     final code = _serialController.text;
//
//     if (code.isEmpty) return;
//   }
//
//   Future<void> _updateProductInfo(String code) async {
//     final provider = Provider.of<CommerceProvider>(context, listen: false);
//     final produit = await provider.getProduitByQr(code);
//     //.getProduitById(int.parse(code));
//
//     if (produit != null) {
//       setState(() {
//         _nomController.text = produit.nom;
//         _descriptionController.text = produit.description ?? '';
//         _prixAchatController.text = produit.prixAchat.toStringAsFixed(2);
//         _prixVenteController.text = produit.prixVente.toStringAsFixed(2);
//         _stockController.text = produit.stock.toString();
//         _datePeremptionController.text = produit.datePeremption.toString();
//         _dateCreationController.text = produit.dateCreation.toString();
//         _derniereModificationController.text =
//             produit.derniereModification.toString();
//         _stockUpdateController.text = produit.stockUpdate.toString();
//         _stockinitController.text = produit.stockinit.toString();
//         _selectedFournisseurs = List.from(produit.fournisseurs);
//         _existingImageUrl = produit.image;
//         _isFinded = true;
//         _image = null;
//       });
//     } else {
//       _nomController.clear();
//       _descriptionController.clear();
//       _prixAchatController.clear();
//       _prixVenteController.clear();
//       _stockController.clear();
//       _selectedFournisseurs.clear();
//       _datePeremptionController.clear();
//       _dateCreationController.clear();
//       _derniereModificationController.clear();
//       _stockUpdateController.clear();
//       _stockinitController.clear();
//       _existingImageUrl = '';
//       _isFinded = false;
//       //_isFirstFieldFilled = false;
//       _image = null;
//     }
//     // print(_isFinded);
//   }
//
//   void _checkFirstField() {
//     setState(() {
//       _isFirstFieldFilled = true;
//     });
//   }
//
//   void _clearAllFields() {
//     setState(() {
//       _serialController.clear();
//       _nomController.clear();
//       _descriptionController.clear();
//       _prixAchatController.clear();
//       _prixVenteController.clear();
//       _stockController.clear();
//       _selectedFournisseurs.clear();
//       _datePeremptionController.clear();
//       _dateCreationController.clear();
//       _derniereModificationController.clear();
//       _stockUpdateController.clear();
//       _stockinitController.clear();
//       _existingImageUrl = '';
//
//       _isFirstFieldFilled = false;
//       _image = null;
//     });
//   }
//
//   void _onSelectedFournisseursChanged(List<Fournisseur> fournisseurs) {
//     setState(() {
//       _selectedFournisseurs = fournisseurs;
//     });
//   }
//
//   IconButton buildButton_Edit_Add(
//       BuildContext context, CommerceProvider produitProvider, _isFinded) {
//     return IconButton(
//       onPressed: () async {
//         final produitDejaExist =
//             await produitProvider.getProduitByQr(_serialController.text);
//         if (_formKey.currentState!.validate()) {
//           String imageUrl = '';
// //******************************************************************************//
//           if (produitDejaExist != null &&
//               _serialController.text != widget.produit!.qr) {
//             ScaffoldMessenger.of(context).showSnackBar(
//               SnackBar(
//                 content: Text(
//                   'QR / Code Barre Produit existe déja !',
//                   style: TextStyle(color: Colors.white),
//                 ),
//                 backgroundColor: Colors.red,
//               ),
//             );
//             print('hadi produitDejaExist != null 111111111111111111');
//           } else {
//             if (_image != null) {
//               imageUrl =
//                   await uploadImageToSupabase(_image!, _existingImageUrl);
//             } else if (_existingImageUrl != null &&
//                 _existingImageUrl!.isNotEmpty) {
//               imageUrl = _existingImageUrl!;
//             }
//             print('hadi produitDejaExist == null 2222222222222222222');
//           }
// ////////////////////////////////////////////////////////////////////////////////
//           if (mounted) {
//             final produit = Produit(
//               qr: _serialController.text,
//               image: imageUrl,
//               nom: _nomController.text,
//               description: _descriptionController.text,
//               prixAchat: double.parse(_prixAchatController.text),
//               prixVente: double.parse(_prixVenteController.text),
//               stock: int.parse(_stockController.text),
//               datePeremption: DateTime.parse(_datePeremptionController.text),
//               dateCreation: DateTime.parse(_dateCreationController.text),
//               derniereModification:
//                   DateTime.parse(_derniereModificationController.text),
//               stockUpdate: DateTime.parse(_stockUpdateController.text),
//               stockinit: int.parse(_stockinitController.text),
//             );
//             if (produitDejaExist != null &&
//                 _serialController.text != widget.produit!.qr) {
//               return;
//             } else if (widget.produit != null) {
//               //update
//
//               produitProvider.updateProduitById(widget.produit!.id, produit,
//                   fournisseurs: widget.specifiquefournisseur != null
//                       ? null
//                       : _selectedFournisseurs);
//
//               print('Produit existant mis à jour');
//             } else {
//               //add new
//               produitProvider.ajouterProduit(produit, _selectedFournisseurs);
//               context.read<CommerceProvider>().ajouterProduit(
//                   produit,
//                   _selectedFournisseurs.isEmpty
//                       ? [widget.specifiquefournisseur!]
//                       : _selectedFournisseurs);
//
//               print('Nouveau produit ajouté');
//             }
// ////////////////////////////////////////////////////////////////////////////////
// //             if (produitDejaExist == null) {
// //               if (widget.produit != null) {
// //                 if (_serialController.text == produitDejaExist.qr)
// //                   // Mise à jour d'un produit existant
// //                   produitProvider.updateProduitById(widget.produit!.id, produit,
// //                       fournisseurs: widget.specifiquefournisseur != null
// //                           ? null
// //                           : _selectedFournisseurs);
// //
// //                 print('Produit existant mis à jour');
// //               } else if (_isFinded) {
// //                 produitProvider.updateProduitById(
// //                     int.parse(_tempProduitId), produit,
// //                     fournisseurs: widget.specifiquefournisseur != null
// //                         ? null
// //                         : _selectedFournisseurs);
// //
// //                 print('Produit trouvé mis à jour');
// //               } else {
// //                 // Ajout d'un nouveau produit
// //                 produitProvider.ajouterProduit(produit, _selectedFournisseurs);
// //                 context.read<CommerceProvider>().ajouterProduit(
// //                     produit,
// //                     _selectedFournisseurs.isEmpty
// //                         ? [widget.specifiquefournisseur!]
// //                         : _selectedFournisseurs);
// //
// //                 print('Nouveau produit ajouté');
// //               }
// //             }
// //             // else if (
// //             // produitDejaExist.qr != _serialController) {
// //             //
// //             // }
// //             else {
// //               ScaffoldMessenger.of(context).showSnackBar(
// //                 SnackBar(
// //                   content: Text(
// //                     'QR / Code Barre Produit existe déja !',
// //                     style: TextStyle(color: Colors.white),
// //                   ),
// //                   backgroundColor: Colors.red,
// //                 ),
// //               );
// //             }
//             ///////////////////////////////////////////////////////////////////
//
//             _formKey.currentState!.save();
//             produitDejaExist != null &&
//                     _serialController.text != widget.produit!.qr
//                 ? null
//                 : Navigator.of(context).pop();
//           }
//         }
//       },
//       icon: Icon(
//         widget.produit != null
//             ? Icons.edit
//             : (_isFinded ? Icons.edit : Icons.check),
//         // child: Text(widget.produit != null
//         //     ? 'Modifier'
//         //     : (_isFinded ? 'Modifier' : 'Ajouter')
//       ),
//     );
//   }
//
//   Future<void> _showAddQuantityDialog() async {
//     int currentValue = int.tryParse(_stockController.text) ?? 0;
//     int newQuantity = currentValue;
//
//     return showDialog<void>(
//       context: context,
//       barrierDismissible: false, // user must tap button!
//       builder: (BuildContext context) {
//         return AlertDialog(
//           title: const Text('Ajouter une quantité'),
//           content: SingleChildScrollView(
//             child: ListBody(
//               children: <Widget>[
//                 Text('Quantité actuelle : $currentValue'),
//                 const SizedBox(height: 16.0),
//                 TextField(
//                   controller: TextEditingController(),
//                   keyboardType: TextInputType.number,
//                   onChanged: (value) {
//                     newQuantity = int.tryParse(value) ?? 0;
//                   },
//                 ),
//               ],
//             ),
//           ),
//           actions: <Widget>[
//             TextButton(
//               child: const Text('Annuler'),
//               onPressed: () {
//                 // _stockController.text = widget.produit!.stock.toString();
//                 Navigator.of(context).pop();
//               },
//             ),
//             TextButton(
//               child: const Text('Ajouter'),
//               onPressed: () {
//                 _stockController.text = (currentValue + newQuantity).toString();
//                 Navigator.of(context).pop();
//               },
//             ),
//           ],
//         );
//       },
//     );
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     final produitProvider =
//         Provider.of<CommerceProvider>(context, listen: false);
//     final double largeur;
//     if (kIsWeb || Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
//       // Pour le web
//       largeur = MediaQuery.of(context).size.width / 3;
//     } else if (Platform.isAndroid || Platform.isIOS) {
//       // Pour Android et iOS
//       largeur = MediaQuery.of(context).size.width;
//     } else {
//       // Pour les autres plateformes (Desktop)
//       largeur = MediaQuery.of(context).size.width / 3;
//     }
//     return Scaffold(
//       appBar: buildAppBar(context, produitProvider),
//       body: Form(
//         key: _formKey,
//         child: SingleChildScrollView(
//           padding: EdgeInsets.symmetric(
//             horizontal: 15,
//           ),
//           child: Platform.isAndroid || Platform.isIOS
//               ? Column(
//                   children: [
//                     buildColumnForm(largeur),
//                     buildColumnPicSuplyers(largeur, context),
//                   ],
//                 )
//               : Row(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     Expanded(child: buildColumnForm(largeur)),
//                     Expanded(child: buildColumnPicSuplyers(largeur, context)),
//                   ],
//                 ),
//         ),
//       ),
//     );
//   }
//
//   Column buildColumnForm(double largeur) {
//     return Column(
//       mainAxisAlignment: MainAxisAlignment.start,
//       children: [
//         Container(
//           height: 30,
//           child: widget.produit != null
//               ? Text(
//                   'ID : ${widget.produit!.id}',
//                   style: TextStyle(
//                     fontSize: 20,
//                   ),
//                 )
//               : _tempProduitId.isNotEmpty
//                   ? Text('ID : ${_tempProduitId}',
//                       style: TextStyle(
//                         fontSize: 20,
//                       ))
//                   : Text(
//                       'L\'ID du Produit n\'a pas encore été créer',
//                       style: TextStyle(fontSize: 20),
//                     ),
//         ),
//         Container(
//           height: 30,
//           child: _tempProduitId.isNotEmpty
//               ? widget.produit == null
//                   ? Row(
//                       mainAxisAlignment: MainAxisAlignment.center,
//                       children: [
//                         Switch(
//                           value: _editQr,
//                           onChanged: (bool newValue) {
//                             setState(() {
//                               _editQr = newValue;
//                             });
//                           },
//                         ),
//                         SizedBox(width: 10),
//                         Text(
//                             _editQr
//                                 ? 'Recherche par Code QR Activé'
//                                 : 'Recherche par Code QR Désactivé',
//                             style: TextStyle(
//                               fontSize: 20,
//                             )),
//                       ],
//                     )
//                   : Container()
//               : Text(
//                   '', //'Creation d\'un Nouveau Produit',
//                   style: TextStyle(fontSize: 20),
//                 ),
//         ),
//         SizedBox(height: 10),
//         Container(
//           width: largeur,
//           child: TextFormField(
//             //focusNode: FocusNode(),
//             controller: _serialController,
//             textAlign: TextAlign.center,
//             style: const TextStyle(
//               fontSize: 18,
//             ),
//             decoration: InputDecoration(
//               hintStyle: TextStyle(color: Colors.black38),
//               // labelText: 'Numéro de série',
//               hintText: 'Code Barre / QrCode',
//
//               prefixIcon: _isFirstFieldFilled != true
//                   ? IconButton(
//                       icon: Icon(Icons.clear),
//                       onPressed: _clearAllFields,
//                       tooltip: 'Effacer tous les champs',
//                     )
//                   : null,
//
//               suffixIcon: Platform.isIOS || Platform.isAndroid
//                   ? IconButton(
//                       icon: Icon(Icons.qr_code_scanner),
//                       onPressed: _scanQRCode,
//                     )
//                   : null,
//               border: OutlineInputBorder(
//                 borderRadius: BorderRadius.circular(8.0),
//                 borderSide: BorderSide.none, // Supprime le contour
//               ),
//               enabledBorder: OutlineInputBorder(
//                 borderRadius: BorderRadius.circular(8.0),
//                 borderSide:
//                     BorderSide.none, // Supprime le contour en état normal
//               ),
//               focusedBorder: OutlineInputBorder(
//                 borderRadius: BorderRadius.circular(8.0),
//                 borderSide:
//                     BorderSide.none, // Supprime le contour en état focus
//               ),
//               filled: true,
//               contentPadding: EdgeInsets.all(15),
//             ),
//           ),
//         ),
//         SizedBox(height: 10),
//         Container(
//           width: largeur,
//           child: TextFormField(
//             enabled: _isFirstFieldFilled,
//             controller: _nomController,
//             textAlign: TextAlign.center,
//             style: const TextStyle(fontSize: 18, color: Colors.black),
//             keyboardType: TextInputType.text,
//             decoration: InputDecoration(
//               hintStyle: TextStyle(color: Colors.black38),
//               fillColor: _isFirstFieldFilled ? Colors.green.shade100 : null,
//               hintText: 'Nom Du Produit',
//               border: OutlineInputBorder(
//                 borderRadius: BorderRadius.circular(8.0),
//                 borderSide: BorderSide.none, // Supprime le contour
//               ),
//               enabledBorder: OutlineInputBorder(
//                 borderRadius: BorderRadius.circular(8.0),
//                 borderSide:
//                     BorderSide.none, // Supprime le contour en état normal
//               ),
//               focusedBorder: OutlineInputBorder(
//                 borderRadius: BorderRadius.circular(8.0),
//                 borderSide:
//                     BorderSide.none, // Supprime le contour en état focus
//               ),
//               filled: true,
//               contentPadding: EdgeInsets.all(15),
//             ),
//             validator: (value) {
//               if (value == null || value.isEmpty) {
//                 return 'Veuillez entrer un nom du Produit';
//               }
//               return null;
//             },
//           ),
//         ),
//         SizedBox(height: 10),
//         Container(
//           width: largeur,
//           child: TextFormField(
//             enabled: _isFirstFieldFilled,
//             controller: _descriptionController,
//             textAlign: TextAlign.center,
//             maxLines: 5, // Permet un nombre illimité de lignes
//
//             style: const TextStyle(
//               fontSize: 18,
//             ),
//             keyboardType: TextInputType.text,
//             decoration: InputDecoration(
//               hintStyle: TextStyle(color: Colors.black38),
//               //fillColor: Colors.blue.shade50,
//
//               hintText: 'Déscription',
//               border: OutlineInputBorder(
//                 borderRadius: BorderRadius.circular(8.0),
//                 borderSide: BorderSide.none, // Supprime le contour
//               ),
//               enabledBorder: OutlineInputBorder(
//                 borderRadius: BorderRadius.circular(8.0),
//                 borderSide:
//                     BorderSide.none, // Supprime le contour en état normal
//               ),
//               focusedBorder: OutlineInputBorder(
//                 borderRadius: BorderRadius.circular(8.0),
//                 borderSide:
//                     BorderSide.none, // Supprime le contour en état focus
//               ),
//               //border: InputBorder.none,
//               filled: true,
//               contentPadding: EdgeInsets.all(15),
//             ),
//           ),
//         ),
//         SizedBox(height: 10),
//         Container(
//           width: largeur,
//           child: TextFormField(
//             enabled: _isFirstFieldFilled,
//             controller: _dateCreationController,
//             textAlign: TextAlign.center,
//             style: const TextStyle(fontSize: 18, color: Colors.black),
//             keyboardType: TextInputType.text,
//             decoration: InputDecoration(
//               hintStyle: TextStyle(color: Colors.black38),
//               fillColor: _isFirstFieldFilled ? Colors.green.shade100 : null,
//               hintText: 'Date de Création',
//               border: OutlineInputBorder(
//                 borderRadius: BorderRadius.circular(8.0),
//                 borderSide: BorderSide.none, // Supprime le contour
//               ),
//               enabledBorder: OutlineInputBorder(
//                 borderRadius: BorderRadius.circular(8.0),
//                 borderSide:
//                     BorderSide.none, // Supprime le contour en état normal
//               ),
//               focusedBorder: OutlineInputBorder(
//                 borderRadius: BorderRadius.circular(8.0),
//                 borderSide:
//                     BorderSide.none, // Supprime le contour en état focus
//               ),
//               filled: true,
//               contentPadding: EdgeInsets.all(15),
//             ),
//             validator: (value) {
//               if (value == null || value.isEmpty) {
//                 return 'Veuillez entrer un nom du Produit';
//               }
//               return null;
//             },
//           ),
//         ),
//         SizedBox(height: 10),
//         Container(
//           width: largeur,
//           child: TextFormField(
//             enabled: _isFirstFieldFilled,
//             controller: _derniereModificationController,
//             textAlign: TextAlign.center,
//             style: const TextStyle(fontSize: 18, color: Colors.black),
//             keyboardType: TextInputType.text,
//             decoration: InputDecoration(
//               hintStyle: TextStyle(color: Colors.black38),
//               fillColor: _isFirstFieldFilled ? Colors.green.shade100 : null,
//               hintText: 'Dernière Modification',
//               border: OutlineInputBorder(
//                 borderRadius: BorderRadius.circular(8.0),
//                 borderSide: BorderSide.none, // Supprime le contour
//               ),
//               enabledBorder: OutlineInputBorder(
//                 borderRadius: BorderRadius.circular(8.0),
//                 borderSide:
//                     BorderSide.none, // Supprime le contour en état normal
//               ),
//               focusedBorder: OutlineInputBorder(
//                 borderRadius: BorderRadius.circular(8.0),
//                 borderSide:
//                     BorderSide.none, // Supprime le contour en état focus
//               ),
//               filled: true,
//               contentPadding: EdgeInsets.all(15),
//             ),
//             validator: (value) {
//               if (value == null || value.isEmpty) {
//                 return 'Veuillez entrer un nom du Produit';
//               }
//               return null;
//             },
//           ),
//         ),
//         SizedBox(height: 10),
//         Container(
//           width: largeur,
//           child: TextFormField(
//             enabled: _isFirstFieldFilled,
//             controller: _datePeremptionController,
//             textAlign: TextAlign.center,
//             style: const TextStyle(fontSize: 18, color: Colors.black),
//             keyboardType: TextInputType.text,
//             decoration: InputDecoration(
//               hintStyle: TextStyle(color: Colors.black38),
//               fillColor: _isFirstFieldFilled ? Colors.green.shade100 : null,
//               hintText: 'Date de Péremption',
//               border: OutlineInputBorder(
//                 borderRadius: BorderRadius.circular(8.0),
//                 borderSide: BorderSide.none, // Supprime le contour
//               ),
//               enabledBorder: OutlineInputBorder(
//                 borderRadius: BorderRadius.circular(8.0),
//                 borderSide:
//                     BorderSide.none, // Supprime le contour en état normal
//               ),
//               focusedBorder: OutlineInputBorder(
//                 borderRadius: BorderRadius.circular(8.0),
//                 borderSide:
//                     BorderSide.none, // Supprime le contour en état focus
//               ),
//               filled: true,
//               contentPadding: EdgeInsets.all(15),
//             ),
//             validator: (value) {
//               if (value == null || value.isEmpty) {
//                 return 'Veuillez entrer un nom du Produit';
//               }
//               return null;
//             },
//           ),
//         ),
//         SizedBox(height: 10),
//         Container(
//           width: largeur,
//           child: TextFormField(
//             enabled: _isFirstFieldFilled,
//             controller: _stockUpdateController,
//             textAlign: TextAlign.center,
//             style: const TextStyle(fontSize: 18, color: Colors.black),
//             keyboardType: TextInputType.text,
//             decoration: InputDecoration(
//               hintStyle: TextStyle(color: Colors.black38),
//               fillColor: _isFirstFieldFilled ? Colors.green.shade100 : null,
//               hintText: 'Date Update Stock',
//               border: OutlineInputBorder(
//                 borderRadius: BorderRadius.circular(8.0),
//                 borderSide: BorderSide.none, // Supprime le contour
//               ),
//               enabledBorder: OutlineInputBorder(
//                 borderRadius: BorderRadius.circular(8.0),
//                 borderSide:
//                     BorderSide.none, // Supprime le contour en état normal
//               ),
//               focusedBorder: OutlineInputBorder(
//                 borderRadius: BorderRadius.circular(8.0),
//                 borderSide:
//                     BorderSide.none, // Supprime le contour en état focus
//               ),
//               filled: true,
//               contentPadding: EdgeInsets.all(15),
//             ),
//             validator: (value) {
//               if (value == null || value.isEmpty) {
//                 return 'Veuillez entrer un nom du Produit';
//               }
//               return null;
//             },
//           ),
//         ),
//         SizedBox(height: 10),
//         Container(
//           width: largeur,
//           child: TextFormField(
//             enabled: _isFirstFieldFilled,
//             controller: _stockinitController,
//             textAlign: TextAlign.center,
//             style: const TextStyle(fontSize: 18, color: Colors.black),
//             keyboardType: TextInputType.text,
//             decoration: InputDecoration(
//               hintStyle: TextStyle(color: Colors.black38),
//               fillColor: _isFirstFieldFilled ? Colors.green.shade100 : null,
//               hintText: 'Stock Initial',
//               border: OutlineInputBorder(
//                 borderRadius: BorderRadius.circular(8.0),
//                 borderSide: BorderSide.none, // Supprime le contour
//               ),
//               enabledBorder: OutlineInputBorder(
//                 borderRadius: BorderRadius.circular(8.0),
//                 borderSide:
//                     BorderSide.none, // Supprime le contour en état normal
//               ),
//               focusedBorder: OutlineInputBorder(
//                 borderRadius: BorderRadius.circular(8.0),
//                 borderSide:
//                     BorderSide.none, // Supprime le contour en état focus
//               ),
//               filled: true,
//               contentPadding: EdgeInsets.all(15),
//             ),
//             validator: (value) {
//               if (value == null || value.isEmpty) {
//                 return 'Veuillez entrer un nom du Produit';
//               }
//               return null;
//             },
//           ),
//         ),
//         SizedBox(height: 10),
//         Row(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             Container(
//               width: -5 + largeur / 2,
//               child: TextFormField(
//                 enabled: _isFirstFieldFilled,
//                 controller: _prixAchatController,
//                 textAlign: TextAlign.center,
//                 style: const TextStyle(
//                   fontSize: 18,
//                 ),
//                 decoration: InputDecoration(
//                   hintStyle: TextStyle(color: Colors.black38),
//                   //fillColor: Colors.blue.shade50,
//                   hintText: 'Prix d\'achat',
//
//                   border: OutlineInputBorder(
//                     borderRadius: BorderRadius.circular(8.0),
//                     borderSide: BorderSide.none, // Supprime le contour
//                   ),
//                   enabledBorder: OutlineInputBorder(
//                     borderRadius: BorderRadius.circular(8.0),
//                     borderSide:
//                         BorderSide.none, // Supprime le contour en état normal
//                   ),
//                   focusedBorder: OutlineInputBorder(
//                     borderRadius: BorderRadius.circular(8.0),
//                     borderSide:
//                         BorderSide.none, // Supprime le contour en état focus
//                   ),
//                   //border: InputBorder.none,
//                   filled: true,
//                   contentPadding: EdgeInsets.all(15),
//                 ),
//                 // keyboardType: TextInputType.number,
//                 //  validator: (value) {
//                 //    if (value == null || value.isEmpty) {
//                 //      return 'Veuillez entrer le prix d\'achat';
//                 //    }
//                 //    return null;
//                 //  },
//                 keyboardType: TextInputType.numberWithOptions(decimal: true),
//                 inputFormatters: [
//                   FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}')),
//                 ],
//                 // onChanged: (value) {
//                 //   if (value.isNotEmpty) {
//                 //     double? parsed = double.tryParse(value);
//                 //     if (parsed != null) {
//                 //       _prixAchatController.text = parsed.toStringAsFixed(2);
//                 //       _prixAchatController.selection =
//                 //           TextSelection.fromPosition(
//                 //         TextPosition(
//                 //             offset: _prixAchatController.text.length),
//                 //       );
//                 //     }
//                 //   }
//                 // },
//                 validator: (value) {
//                   if (value == null || value.isEmpty) {
//                     return 'Veuillez entrer le prix d\'achat';
//                   }
//                   // if (double.tryParse(value) == null) {
//                   //   return 'Veuillez entrer un prix valide';
//                   // }
//                   // return null;
//                 },
//               ),
//             ),
//             SizedBox(width: 10),
//             Container(
//               width: -5 + largeur / 2,
//               child: TextFormField(
//                 enabled: _isFirstFieldFilled,
//                 controller: _prixVenteController,
//                 textAlign: TextAlign.center,
//                 style: const TextStyle(
//                   fontSize: 18,
//                 ),
//                 decoration: InputDecoration(
//                   hintStyle: TextStyle(color: Colors.black38),
//                   //fillColor: Colors.blue.shade50,
//                   hintText: 'Prix de vente',
//
//                   border: OutlineInputBorder(
//                     borderRadius: BorderRadius.circular(8.0),
//                     borderSide: BorderSide.none, // Supprime le contour
//                   ),
//                   enabledBorder: OutlineInputBorder(
//                     borderRadius: BorderRadius.circular(8.0),
//                     borderSide:
//                         BorderSide.none, // Supprime le contour en état normal
//                   ),
//                   focusedBorder: OutlineInputBorder(
//                     borderRadius: BorderRadius.circular(8.0),
//                     borderSide:
//                         BorderSide.none, // Supprime le contour en état focus
//                   ),
//                   //border: InputBorder.none,
//                   filled: true,
//                   contentPadding: EdgeInsets.all(15),
//                 ),
//                 // keyboardType: TextInputType.number,
//                 // validator: (value) {
//                 //   if (value == null || value.isEmpty) {
//                 //     return 'Veuillez entrer le prix de vente';
//                 //   }
//                 //   return null;
//                 // },
//                 keyboardType: TextInputType.numberWithOptions(decimal: true),
//                 // inputFormatters: [
//                 //   FilteringTextInputFormatter.allow(
//                 //       RegExp(r'^\d+\.?\d{0,2}')),
//                 // ],
//                 // onChanged: (value) {
//                 //   if (value.isNotEmpty) {
//                 //     double? parsed = double.tryParse(value);
//                 //     if (parsed != null) {
//                 //       _prixVenteController.text = parsed.toStringAsFixed(2);
//                 //       _prixVenteController.selection =
//                 //           TextSelection.fromPosition(
//                 //         TextPosition(
//                 //             offset: _prixVenteController.text.length),
//                 //       );
//                 //     }
//                 //   }
//                 // },
//                 validator: (value) {
//                   if (value == null || value.isEmpty) {
//                     return 'Veuillez entrer le prix d\'achat';
//                   }
//                   // if (double.tryParse(value) == null) {
//                   //   return 'Veuillez entrer un prix valide';
//                   // }
//                   // return null;
//                 },
//               ),
//             ),
//           ],
//         ),
//         SizedBox(height: 10),
//         Container(
//           width: largeur,
//           child: Row(
//             mainAxisAlignment: MainAxisAlignment.start,
//             children: [
//               widget.produit == null
//                   ? _editQr == true
//                       ? GestureDetector(
//                           onTap: () {
//                             // _stockController.text =
//                             //     produit.stock.toString();
//                           },
//                           child: CircleAvatar(
//                               child: Text(
//                             _stockController.text.toString(),
//                           )),
//                         )
//                       : CircleAvatar(
//                           child: Text(
//                           ' ',
//                         ))
//                   : GestureDetector(
//                       onTap: () {
//                         _stockController.text =
//                             widget.produit!.stock.toString();
//                       },
//                       child: CircleAvatar(
//                           child: Text(
//                         widget.produit!.stock.toString() ?? '0',
//                       )),
//                     ),
//               SizedBox(
//                 width: 10,
//               ),
//               Expanded(
//                 child: TextFormField(
//                   enabled: _isFirstFieldFilled,
//                   controller: _stockController,
//                   textAlign: TextAlign.center,
//                   style: const TextStyle(
//                     fontSize: 18,
//                   ),
//                   decoration: InputDecoration(
//                     hintStyle: TextStyle(color: Colors.black38),
//                     //fillColor: Colors.blue.shade50,
//                     // prefixIcon: IconButton(
//                     //   onPressed: _showAddQuantityDialog,
//                     //   icon: const Icon(Icons.add),
//                     // ),
//                     hintText: 'Stock',
//                     prefix: Text(
//                       'Stock',
//                     ),
//                     border: OutlineInputBorder(
//                       borderRadius: BorderRadius.circular(8.0),
//                       borderSide: BorderSide.none, // Supprime le contour
//                     ),
//                     enabledBorder: OutlineInputBorder(
//                       borderRadius: BorderRadius.circular(8.0),
//                       borderSide:
//                           BorderSide.none, // Supprime le contour en état normal
//                     ),
//                     focusedBorder: OutlineInputBorder(
//                       borderRadius: BorderRadius.circular(8.0),
//                       borderSide:
//                           BorderSide.none, // Supprime le contour en état focus
//                     ),
//                     //border: InputBorder.none,
//                     filled: true,
//                     contentPadding: EdgeInsets.all(15),
//                   ),
//                   keyboardType: TextInputType.number,
//                   validator: (value) {
//                     if (value == null || value.isEmpty) {
//                       return 'Veuillez entrer le stock';
//                     }
//                     return null;
//                   },
//                 ),
//               ),
//               SizedBox(
//                 width: 10,
//               ),
//               CircleAvatar(
//                 child: IconButton(
//                   onPressed: _showAddQuantityDialog,
//                   icon: const Icon(Icons.add),
//                 ),
//               ),
//             ],
//           ),
//         ),
//         SizedBox(height: 20),
//       ],
//     );
//   }
//
//   Column buildColumnPicSuplyers(double largeur, BuildContext context) {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         Platform.isAndroid || Platform.isIOS
//             ? SizedBox()
//             : SizedBox(
//                 height: 70,
//               ),
//         _isFirstFieldFilled
//             ? Center(
//                 child: Container(
//                   width: largeur,
//                   height: Platform.isAndroid || Platform.isIOS ? 150 : 300,
//                   child: _image == null
//                       ? Stack(
//                           alignment: Alignment.center,
//                           children: [
//                             _existingImageUrl != null &&
//                                     _existingImageUrl!.isNotEmpty
//                                 ? Image.network(
//                                     _existingImageUrl!,
//                                     fit: BoxFit.cover,
//                                   )
//                                 : Text(''),
//                             IconButton(
//                               onPressed: _pickImage,
//                               icon: Icon(
//                                 Icons.add_a_photo,
//                                 color: Colors.blue,
//                               ),
//                             ),
//                           ],
//                         )
//                       : InkWell(
//                           onTap: () {
//                             setState(() {
//                               _image = null;
//                             });
//                           },
//                           child: Stack(
//                             alignment: Alignment.center,
//                             children: [
//                               Image.file(
//                                 _image!,
//                                 fit: BoxFit.cover,
//                               ),
//                               Icon(
//                                 Icons.delete,
//                                 color: Colors.red,
//                               ),
//                             ],
//                           ),
//                         ),
//                 ),
//               )
//             : Container(),
//         SizedBox(height: 20),
//         _isFirstFieldFilled
//             ? Row(
//                 children: [
//                   Expanded(
//                     child: Wrap(
//                       spacing: 8.0,
//                       runSpacing: 4.0,
//                       children: _selectedFournisseurs.map((fournisseur) {
//                         return widget.specifiquefournisseur != null
//                             ? Card(
//                                 elevation: 2,
//                                 child: Padding(
//                                   padding: const EdgeInsets.all(8.0),
//                                   child: Text(fournisseur.nom),
//                                 ),
//                               )
//                             : Chip(
//                                 label: Text(fournisseur.nom),
//                                 onDeleted: () {
//                                   setState(() {
//                                     _selectedFournisseurs.remove(fournisseur);
//                                   });
//                                 },
//                               );
//                       }).toList(),
//                     ),
//                   ),
//                   widget.specifiquefournisseur == null
//                       ? IconButton(
//                           icon: Icon(Icons.add),
//                           onPressed: () async {
//                             final result = await Navigator.of(context).push(
//                               MaterialPageRoute(
//                                 builder: (context) =>
//                                     FournisseurSelectionScreen(
//                                   selectedFournisseurs: _selectedFournisseurs,
//                                   produit: widget.produit,
//                                   onSelectedFournisseursChanged:
//                                       _onSelectedFournisseursChanged,
//                                 ),
//                               ),
//                             );
//                             if (result != null) {
//                               setState(() {
//                                 _selectedFournisseurs = result;
//                               });
//                             }
//                           },
//                         )
//                       : Container(),
//                 ],
//               )
//             : Container(),
//         SizedBox(height: 20),
//         //buildButton_Edit_Add(context, produitProvider, _isFinded),
//         SizedBox(
//           height: 50,
//         ),
//       ],
//     );
//   }
//
//   AppBar buildAppBar(BuildContext context, CommerceProvider produitProvider) {
//     return AppBar(
//       title: Text('Modifier ${widget.produit!.nom} '),
//       actions: [
//         IconButton(
//           icon: Icon(Icons.clear_all),
//           onPressed: _clearAllFields,
//           tooltip: 'Effacer tous les champs',
//         ),
//         buildButton_Edit_Add(context, produitProvider, _isFinded),
//       ],
//     );
//   }
// }

/////////////////////////////////////////////////////////////////////////////////

class AddFournisseurFormFromProduit extends StatefulWidget {
  final Produit produit;

  AddFournisseurFormFromProduit({Key? key, required this.produit})
      : super(key: key);
  @override
  _AddFournisseurFormFromProduitState createState() =>
      _AddFournisseurFormFromProduitState();
}

class _AddFournisseurFormFromProduitState
    extends State<AddFournisseurFormFromProduit> {
  final _formKey = GlobalKey<FormState>();
  final _nomController = TextEditingController();
  final _phoneController = TextEditingController();
  final _adresseController = TextEditingController();
  final _creationController = TextEditingController();
  final _derniereModificationController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Fournisseurs'),
        actions: [
          IconButton(
            icon: Icon(Icons.search),
            onPressed: () async {},
          ),
        ],
      ),
      body: Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context)
              .viewInsets
              .bottom, // Permet de remonter le BottomSheet lorsque le clavier apparaît
          left: 16,
          right: 16,
          top: 16,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Ajouter un Fournisseur',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            Form(
              key: _formKey,
              child: Column(
                children: [
                  TextFormField(
                    controller: _nomController,
                    decoration: InputDecoration(labelText: 'Nom'),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Veuillez entrer un nom';
                      }
                      return null;
                    },
                  ),
                  TextFormField(
                    controller: _phoneController,
                    keyboardType: TextInputType.phone,
                    decoration: InputDecoration(labelText: 'Phone'),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Veuillez entrer un Tel';
                      }
                      return null;
                    },
                  ),
                  TextFormField(
                    controller: _adresseController,
                    decoration: InputDecoration(labelText: 'Adresse'),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Veuillez entrer une adresse';
                      }
                      return null;
                    },
                  ),
                ],
              ),
            ),
            SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: Text('Annuler'),
                ),
                TextButton(
                  onPressed: () {
                    if (_formKey.currentState!.validate()) {
                      final fournisseur = Fournisseur(
                        qr: '',
                        nom: _nomController.text,
                        phone: _phoneController.text,
                        adresse: _adresseController.text,
                        dateCreation: DateTime.parse(_creationController.text),
                        derniereModification: DateTime.parse(
                            _derniereModificationController.text),
                      );
                      context
                          .read<CommerceProvider>()
                          .addFournisseur(fournisseur);
                      Navigator.of(context).pop();
                    }
                  },
                  child: Text('Ajouter'),
                ),
              ],
            ),
            SizedBox(height: 60),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _nomController.dispose();
    _phoneController.dispose();
    _adresseController.dispose();
    super.dispose();
  }
}

class FournisseurSelectionScreen extends StatefulWidget {
  final Produit? produit;
  final List<Fournisseur> selectedFournisseurs;
  final Function(List<Fournisseur>) onSelectedFournisseursChanged;

  const FournisseurSelectionScreen({
    Key? key,
    this.produit,
    required this.selectedFournisseurs,
    required this.onSelectedFournisseursChanged,
  }) : super(key: key);

  @override
  _FournisseurSelectionScreenState createState() =>
      _FournisseurSelectionScreenState();
}

class _FournisseurSelectionScreenState
    extends State<FournisseurSelectionScreen> {
  String _searchQuery = '';
  late List<Fournisseur> _selectedFournisseurs;

  @override
  void initState() {
    super.initState();
    _selectedFournisseurs = List.from(widget.selectedFournisseurs);
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
        title: Text('Sélectionner Fournisseurs'),
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
          ElevatedButton(
            onPressed: () {
              widget.onSelectedFournisseursChanged(_selectedFournisseurs);
              Navigator.of(context).pop();
            },
            child: Text('Sauvegarder Sélection'),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: filteredFournisseurs.length,
              itemBuilder: (context, index) {
                final fournisseur = filteredFournisseurs[index];
                final isSelected = _selectedFournisseurs.contains(fournisseur);
                return ListTile(
                  title: Text(fournisseur.nom),
                  trailing: Checkbox(
                    value: isSelected,
                    onChanged: (bool? selected) {
                      setState(() {
                        if (selected!) {
                          _selectedFournisseurs.add(fournisseur);
                        } else {
                          _selectedFournisseurs.remove(fournisseur);
                        }
                      });
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class FournisseurSearchDelegate extends SearchDelegate<Fournisseur> {
  final Produit produit;

  FournisseurSearchDelegate(this.produit);

  @override
  List<Widget> buildActions(BuildContext context) {
    return [
      IconButton(
        icon: Icon(Icons.clear),
        onPressed: () {
          query = '';
        },
      ),
    ];
  }

  @override
  Widget buildLeading(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.arrow_back),
      onPressed: () => Navigator.of(context).pop(),
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    return _buildSuggestions(context);
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    return _buildSuggestions(context);
  }

  Widget _buildSuggestions(BuildContext context) {
    final fournisseurProvider =
        Provider.of<CommerceProvider>(context, listen: false);
    final produitProvider =
        Provider.of<CommerceProvider>(context, listen: false);

    final fournisseurs = fournisseurProvider.fournisseurs.where((fournisseur) {
      return fournisseur.nom.toLowerCase().contains(query.toLowerCase());
    }).toList();

    return ListView.builder(
      itemCount: fournisseurs.length,
      itemBuilder: (context, index) {
        final fournisseur = fournisseurs[index];

        return ListTile(
          title: Text(fournisseur.nom),
          onTap: () {
            close(context, fournisseur);
          },
          trailing: IconButton(
            icon: Icon(Icons.add),
            onPressed: () {
              if (!produit.fournisseurs.contains(fournisseur)) {
                produit.fournisseurs.add(fournisseur);
                produitProvider.updateProduit(produit);
              }
              Navigator.of(context).pop();
            },
          ),
        );
      },
    );
  }
}
