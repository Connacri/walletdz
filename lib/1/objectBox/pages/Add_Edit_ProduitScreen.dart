import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
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

class Add_Edit_ProduitScreen extends StatefulWidget {
  final Produit? produit;
  final Fournisseur? specifiquefournisseur;

  Add_Edit_ProduitScreen(
      {Key? key, this.produit, this.qrCode, this.specifiquefournisseur})
      : super(key: key);
  final String? qrCode;

  @override
  _Add_Edit_ProduitScreenState createState() => _Add_Edit_ProduitScreenState();
}

class _Add_Edit_ProduitScreenState extends State<Add_Edit_ProduitScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nomController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _prixAchatController = TextEditingController();
  final _prixVenteController = TextEditingController();
  final _stockController = TextEditingController();
  final _serialController = TextEditingController();
  final _peremptionController = TextEditingController();
  final _creationController = TextEditingController();
  final _modificationController = TextEditingController();
  List<Fournisseur> _selectedFournisseurs = [];

  File? _image;
  String? _existingImageUrl;
  bool _isFinded = false;
  String _tempProduitId = '';
  bool _editQr = true;

  @override
  void initState() {
    super.initState();

    _serialController.addListener(_onSerialChanged);

    if (widget.produit != null) {
      _serialController.text = widget.produit!.qr ?? '';
      _nomController.text = widget.produit!.nom ?? '';
      _descriptionController.text = widget.produit!.description ?? '';
      _prixAchatController.text = widget.produit!.prixAchat.toString();
      _prixVenteController.text = widget.produit!.prixVente.toString();
      _stockController.text = widget.produit!.stock.toString();
      _existingImageUrl = widget.produit!.image;
      // _peremptionController.text = widget.produit!.datePeremption.toString();
      // _creationController.text = widget.produit!.dateCreation.toString();
      // _modificationController.text =
      //     widget.produit!.derniereModification.toString();
      _selectedFournisseurs = List.from(widget.produit!.fournisseurs);
    } else {
      _serialController.text = '';
      _nomController.text = '';
      _descriptionController.text = '';
      _prixAchatController.text = '';
      _prixVenteController.text = '';
      _stockController.text = '';
      // _peremptionController.text = '';
      // _creationController.text = '';
      // _modificationController.text = '';
    }
    // Initialize with specific supplier if provided
    if (widget.specifiquefournisseur != null) {
      _selectedFournisseurs = [widget.specifiquefournisseur!];
    }
  }

  @override
  void dispose() {
    _serialController.removeListener(_onSerialChanged);
    _serialController.dispose();
    _nomController.dispose();
    _descriptionController.dispose();
    _prixAchatController.dispose();
    _prixVenteController.dispose();
    _stockController.dispose();
    _peremptionController.dispose();
    _creationController.dispose();
    _modificationController.dispose();
    super.dispose();
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

  // Future<void> _scanQRCode() async {
  //   final code = await Navigator.of(context).push<String>(
  //     MaterialPageRoute(
  //       builder: (context) => QRViewExample(),
  //     ),
  //   );
  //   if (code != null) {
  //     setState(() {
  //       _serialController.text = code;
  //     });
  //   }
  // }
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
          _descriptionController.text = produit.description ?? '';
          _prixAchatController.text = produit.prixAchat.toString();
          _prixVenteController.text = produit.prixVente.toString();
          _stockController.text = produit.stock.toString();
          _isFinded = true;
        });
      } else {
        setState(() {
          _nomController.clear();
          _descriptionController.clear();
          _prixAchatController.clear();
          _prixVenteController.clear();
          _stockController.clear();
          _isFinded = false;
        });
      }
      print(_isFinded);
    }
  }

  void _onSerialChanged() {
    final code = _serialController.text;
    if (code.isNotEmpty) {
      if (_editQr) {
        _updateProductInfo(code);
      }
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
        _prixAchatController.text = produit.prixAchat.toString();
        _prixVenteController.text = produit.prixVente.toString();
        _stockController.text = produit.stock.toString();
        _selectedFournisseurs = List.from(produit.fournisseurs);
        _existingImageUrl = produit.image;
        _isFinded = true;
      });
    } else {
      setState(() {
        _tempProduitId = '';
        _nomController.clear();
        _descriptionController.clear();
        _prixAchatController.clear();
        _prixVenteController.clear();
        _stockController.clear();
        _selectedFournisseurs.clear();
        _existingImageUrl = '';
        _isFinded = false;
      });
    }
    print(_isFinded);
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
      appBar: AppBar(
        title: Text(widget.produit != null
            ? 'Modifier ${widget.produit!.nom}'
            : widget.specifiquefournisseur == null
                ? (_isFinded ? 'Modifier' : 'Ajouter')
                : 'Ajouter Produit ${' à \n' + widget.specifiquefournisseur!.nom}'),
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: EdgeInsets.all(16.0),
          child: Column(
            children: [
              Container(
                height: 30,
                child: widget.produit != null
                    ? Text(
                        'ID : ${widget.produit!.id}',
                        style: TextStyle(
                          fontSize: 20,
                        ),
                      )
                    : _tempProduitId.isNotEmpty
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
                        'Creation d\'un Nouveau Produit',
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
                    hintText: 'Code Barre',

                    suffixIcon: Platform.isWindows ||
                            Platform.isLinux ||
                            Platform.isMacOS
                        ? null
                        : IconButton(
                            icon: Icon(Icons.qr_code_scanner),
                            onPressed: _scanQRCode,
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
                ),
              ),
              SizedBox(height: 10),
              Container(
                width: largeur,
                child: TextFormField(
                  controller: _nomController,
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 18, color: Colors.black),
                  keyboardType: TextInputType.text,
                  decoration: InputDecoration(
                    hintStyle: TextStyle(color: Colors.black38),
                    fillColor: Colors.blue.shade50,
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
                  controller: _descriptionController,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 18,
                  ),
                  keyboardType: TextInputType.text,
                  decoration: InputDecoration(
                    hintStyle: TextStyle(color: Colors.black38),
                    //fillColor: Colors.blue.shade50,
                    hintText: 'Description',
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
              Container(
                width: largeur,
                child: TextFormField(
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
                    FilteringTextInputFormatter.allow(
                        RegExp(r'^\d+\.?\d{0,2}')),
                  ],
                  onChanged: (value) {
                    if (value.isNotEmpty) {
                      double? parsed = double.tryParse(value);
                      if (parsed != null) {
                        _prixAchatController.text = parsed.toStringAsFixed(2);
                        _prixAchatController.selection =
                            TextSelection.fromPosition(
                          TextPosition(
                              offset: _prixAchatController.text.length),
                        );
                      }
                    }
                  },
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Veuillez entrer le prix d\'achat';
                    }
                    if (double.tryParse(value) == null) {
                      return 'Veuillez entrer un prix valide';
                    }
                    return null;
                  },
                ),
              ),
              SizedBox(height: 10),
              Container(
                width: largeur,
                child: TextFormField(
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
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(
                        RegExp(r'^\d+\.?\d{0,2}')),
                  ],
                  onChanged: (value) {
                    if (value.isNotEmpty) {
                      double? parsed = double.tryParse(value);
                      if (parsed != null) {
                        _prixAchatController.text = parsed.toStringAsFixed(2);
                        _prixAchatController.selection =
                            TextSelection.fromPosition(
                          TextPosition(
                              offset: _prixAchatController.text.length),
                        );
                      }
                    }
                  },
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Veuillez entrer le prix d\'achat';
                    }
                    if (double.tryParse(value) == null) {
                      return 'Veuillez entrer un prix valide';
                    }
                    return null;
                  },
                ),
              ),
              SizedBox(height: 10),
              Container(
                width: largeur,
                child: TextFormField(
                  controller: _stockController,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 18,
                  ),
                  decoration: InputDecoration(
                    hintStyle: TextStyle(color: Colors.black38),
                    //fillColor: Colors.blue.shade50,
                    hintText: 'Stock',
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
              SizedBox(height: 20),
              Center(
                child: Container(
                  width: largeur,
                  height: 150,
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
              ),
              SizedBox(height: 20),
              Row(
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
                                  produit: widget.produit,
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
              SizedBox(height: 20),
              buildButton_Edit_Add(context, produitProvider, _isFinded),
              SizedBox(
                height: 50,
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _onSelectedFournisseursChanged(List<Fournisseur> fournisseurs) {
    setState(() {
      _selectedFournisseurs = fournisseurs;
    });
  }

  ElevatedButton buildButton_Edit_Add(
      BuildContext context, CommerceProvider produitProvider, _isFinded) {
    return ElevatedButton(
      onPressed: () async {
        if (_formKey.currentState!.validate()) {
          String imageUrl = '';
          final produitDejaExist =
              await produitProvider.getProduitByQr(_serialController.text);
          if (_image != null) {
            imageUrl = await uploadImageToSupabase(_image!, _existingImageUrl);
          } else if (_existingImageUrl != null &&
              _existingImageUrl!.isNotEmpty) {
            imageUrl = _existingImageUrl!;
          }

          if (mounted) {
            final produit = Produit(
              qr: _serialController.text,
              image: imageUrl,
              nom: _nomController.text,
              description: _descriptionController.text,
              prixAchat: double.parse(_prixAchatController.text),
              prixVente: double.parse(_prixVenteController.text),
              stock: int.parse(_stockController.text),
              // datePeremption: DateTime.parse(_peremptionController.text),
              // dateCreation: DateTime.parse(_creationController.text),
              // derniereModification:
              //     DateTime.parse(_modificationController.text),
            );

            if (produitDejaExist == null) {
              if (widget.produit != null) {
                // Mise à jour d'un produit existant
                produitProvider.updateProduitById(widget.produit!.id, produit,
                    fournisseurs: widget.specifiquefournisseur != null
                        ? null
                        : _selectedFournisseurs);

                print('Produit existant mis à jour');
              } else if (_isFinded) {
                produitProvider.updateProduitById(
                    int.parse(_tempProduitId), produit,
                    fournisseurs: widget.specifiquefournisseur != null
                        ? null
                        : _selectedFournisseurs);

                print('Produit trouvé mis à jour');
              } else {
                // Ajout d'un nouveau produit
                //produitProvider.ajouterProduit(produit, _selectedFournisseurs);
                context
                    .read<CommerceProvider>()
                    .ajouterProduit(produit, _selectedFournisseurs);
                print('Nouveau produit ajouté');
              }
            } else {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    'QR / Code Barre Produit existe déja !',
                    style: TextStyle(color: Colors.white),
                  ),
                  backgroundColor: Colors.red,
                ),
              );
            }
            _formKey.currentState!.save();
            produitDejaExist != null ? null : Navigator.of(context).pop();
          }
        }
      },
      child: Text(widget.produit != null
          ? 'Modifier'
          : (_isFinded ? 'Modifier' : 'Ajouter')),
    );
  }
}

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
  final _modificationController = TextEditingController();

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
                        // dateCreation: DateTime.parse(_creationController.text),
                        // derniereModification:
                        //     DateTime.parse(_modificationController.text),
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
