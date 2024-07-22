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
import 'AddFournisseurFormFromProduit.dart';
import 'FournisseurListScreen.dart';
import 'dart:io' show Platform;
import 'package:flutter/foundation.dart' show kIsWeb;

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

  List<Fournisseur> _selectedFournisseurs = [];

  File? _image;
  String? _existingImageUrl;
  String _tempProduitId = '';
  bool _isFirstFieldFilled = false;
  bool _editQr = true;
  DateTime selectedDate = DateTime.now();
  String _lastScannedCode = '';
  bool _isFinded = false;

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
          _existingImageUrl = '';
          _isFirstFieldFilled = false;
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
      _existingImageUrl = '';
      _isFirstFieldFilled = false;
      _image = null;
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
          child: _editQr == true
              ? _tempProduitId.isNotEmpty
                  ? Text('ID : ${_tempProduitId}',
                      style: TextStyle(
                        fontSize: 20,
                      ))
                  : Text(
                      'L\'ID du Produit n\'a pas encore été créer',
                      style: TextStyle(fontSize: 15),
                    )
              : Text(
                  'Nouveau ID du produit sera créer',
                  style: TextStyle(fontSize: 15),
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
