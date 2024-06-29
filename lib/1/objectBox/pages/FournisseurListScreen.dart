import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';
import '../Entity.dart';
import '../MyProviders.dart';
import 'AddProduitScreen.dart';
import 'ProduitListScreen.dart';
import 'package:intl/intl.dart';
import 'package:capitalize/capitalize.dart';

class FournisseurListScreen extends StatelessWidget {
  final Produit? produit;

  FournisseurListScreen({Key? key, this.produit}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Fournisseurs'),
        actions: [
          IconButton(
            icon: Icon(Icons.search),
            onPressed: () async {
              final fournisseurProvider =
                  Provider.of<CommerceProvider>(context, listen: false);
              showSearch(
                context: context,
                delegate: FournisseurSearchDelegateMain(
                    fournisseurProvider.fournisseurs),
              );
            },
          )
        ],
      ),
      body: Consumer<CommerceProvider>(
        builder: (context, fournisseurProvider, child) {
          return ListView.builder(
            itemCount: fournisseurProvider.fournisseurs.length,
            itemBuilder: (context, index) {
              final fournisseur = fournisseurProvider.fournisseurs[index];
              return Card(
                child: ListTile(
                  onLongPress: () {
                    _deleteFournisseur(context, fournisseur);
                  },
                  onTap: () {
                    print(fournisseur.produits);
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => ProduitsFournisseurPage(
                          fournisseur: fournisseur,
                          //   produits: fournisseur.produits,
                        ),
                      ),
                    );
                  },
                  leading: CircleAvatar(
                    child: FittedBox(child: Text(fournisseur.id.toString())),
                  ),
                  title: Text(fournisseur.nom),
                  subtitle: Text('Phone : ${fournisseur.phone}'),
                  trailing: Container(
                    width: 50,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Text(
                            fournisseur.produits.length.toString(),
                            style: TextStyle(fontSize: 20),
                          ),
                        ),
                        Expanded(
                          child: IconButton(
                            icon: Icon(
                              Icons.edit,
                            ),
                            onPressed: () {
                              _editFournisseur(context, fournisseur);
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          showModalBottomSheet(
            context: context,
            isScrollControlled:
                true, // Permet de redimensionner en fonction de la hauteur du contenu
            builder: (context) => _AddFournisseurForm(),
          );
        },
        child: Icon(Icons.add),
      ),
    );
  }
}

class ProduitsFournisseurPage extends StatelessWidget {
  final Fournisseur fournisseur;
  //final List<Produit>? produits;

  ProduitsFournisseurPage({
    required this.fournisseur, //this.produits
  });

  @override
  Widget build(BuildContext context) {
    // final produits = Provider.of<CommerceProvider>(context)
    //     .getProduitsForFournisseur(fournisseur);
    //.getFournisseurById(fournisseur.id);
    // final produitProvider = Provider.of<CommerceProvider>(context);
    final commerceProvider =
        Provider.of<CommerceProvider>(context, listen: false);
    return Scaffold(
      body: CustomScrollView(
        slivers: <Widget>[
          MySliverAppBar(fournisseur: fournisseur),
          MySliverToBoxAdapter(fournisseur: fournisseur),
          Consumer<CommerceProvider>(
            builder: (context, commerceProvider, child) {
              final produits =
                  commerceProvider.getProduitsForFournisseur(fournisseur);
              print(produits
                  .length); // Vérifiez ce qui est retourné ici pour déboguer

              return SliverList(
                delegate: SliverChildBuilderDelegate(
                  (BuildContext context, int index) {
                    final produit = produits[index];
                    return Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Slidable(
                          key: ValueKey(produit.id),
                          startActionPane: ActionPane(
                            motion: ScrollMotion(),
                            children: [
                              SlidableAction(
                                onPressed: (BuildContext context) {
                                  Navigator.of(context).push(MaterialPageRoute(
                                    builder: (ctx) => EditProduitScreen(
                                      produit: produit,
                                      specifiquefournisseur: fournisseur,
                                    ),
                                  ));
                                },
                                backgroundColor: Colors.blue,
                                icon: Icons.edit,
                                label: 'Editer',
                              ),
                            ],
                          ),
                          child: Card(
                            child: ListTile(
                                onTap: () {
                                  Navigator.of(context).push(MaterialPageRoute(
                                    builder: (ctx) =>
                                        ProduitDetailPage(produit: produit),
                                  ));
                                },
                                onLongPress: () {
                                  _deleteProduit(context, produit);
                                },
                                leading: produit.image == null ||
                                        produit.image!.isEmpty
                                    ? CircleAvatar(
                                        child: Icon(
                                        Icons.image_not_supported,
                                      ))
                                    : CircleAvatar(
                                        backgroundImage:
                                            CachedNetworkImageProvider(
                                          produit.image!,
                                          errorListener: (error) =>
                                              Icon(Icons.error),
                                        ),
                                      ),
                                title: Text(produit.nom),
                                subtitle: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'A: ${produit.prixAchat.toStringAsFixed(2)}\nB: ${(produit.prixVente - produit.prixAchat).toStringAsFixed(2)} ',
                                    ),
                                    produit.fournisseurs.isEmpty
                                        ? Container()
                                        : Wrap(
                                            spacing:
                                                6.0, // Espace horizontal entre les éléments
                                            runSpacing:
                                                4.0, // Espace vertical entre les lignes
                                            children: produit.fournisseurs
                                                .map((fournisseurL) {
                                              // print(fournisseurL.id);
                                              // print(fournisseur.id);

                                              return InkWell(
                                                onTap: () {
                                                  Navigator.of(context).push(
                                                      MaterialPageRoute(
                                                          builder: (ctx) =>
                                                              ProduitsFournisseurPage(
                                                                fournisseur:
                                                                    fournisseur,
                                                              )));
                                                },
                                                child: fournisseur.id ==
                                                        fournisseurL.id
                                                    ? Container()
                                                    : Chip(
                                                        shadowColor:
                                                            Colors.black,
                                                        backgroundColor: Theme
                                                                .of(context)
                                                            .chipTheme
                                                            .backgroundColor,
                                                        labelStyle: TextStyle(
                                                          color:
                                                              Theme.of(context)
                                                                  .chipTheme
                                                                  .labelStyle
                                                                  ?.color,
                                                        ),
                                                        side: BorderSide.none,
                                                        shape: RoundedRectangleBorder(
                                                            borderRadius:
                                                                BorderRadius
                                                                    .all(Radius
                                                                        .circular(
                                                                            10))),
                                                        padding:
                                                            EdgeInsets.zero,
                                                        label: Text(
                                                          fournisseurL.nom,
                                                          style: TextStyle(
                                                              fontSize: 10),
                                                        ),
                                                      ),
                                              );
                                            }).toList(),
                                          ),
                                  ],
                                ),
                                trailing: Text(
                                  '${produit.prixVente.toStringAsFixed(2)}',
                                  style: TextStyle(fontSize: 20),
                                )),
                          )),
                    );

                    //   ListTile(
                    //   onLongPress: () {
                    //     _deleteProduit(context, produit);
                    //   },
                    //   onTap: () {
                    //     Navigator.of(context).push(
                    //       MaterialPageRoute(
                    //         builder: (context) => ProduitsFournisseurPage(
                    //           fournisseur: fournisseur,
                    //         ),
                    //       ),
                    //     );
                    //   },
                    //   title: Text(produit.nom),
                    //   subtitle: Text(
                    //     'Prix: ${produit.prixVente.toStringAsFixed(2)} €',
                    //   ),
                    // );
                  },
                  childCount: produits.length,
                ),
              );
            },
          ),
          SliverToBoxAdapter(
            child: SizedBox(
              height: 50,
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.of(context).push(MaterialPageRoute(
              builder: (_) =>
                  EditProduitScreen(specifiquefournisseur: fournisseur)));
        },
        child: Icon(Icons.add),
      ),
    );
  }
}

class MySliverToBoxAdapter extends StatelessWidget {
  const MySliverToBoxAdapter({
    super.key,
    required this.fournisseur,
  });

  final Fournisseur fournisseur;

  @override
  Widget build(BuildContext context) {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.all(18.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            SizedBox(height: 8),
            Text(fournisseur.phone == null && fournisseur.phone == 0
                ? ''
                : 'Téléphone: ${fournisseur.phone ?? "N/A"}'),
            Text(fournisseur.adresse == null && fournisseur.adresse == ''
                ? ''
                : 'Adresse: ${fournisseur.adresse ?? "N/A"}'),
            SizedBox(
              height: 10,
            ),
            Divider(),
            SizedBox(
              height: 20,
            ),
            Text(
              'Liste Des Produits:',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            ElevatedButton(
              onPressed: () {
                final fournisseurProvider =
                    Provider.of<CommerceProvider>(context, listen: false);
                fournisseurProvider.ajouterProduitsAleatoiresPourFournisseur(
                    fournisseur, 5); // Ajouter 5 produits aléatoires
              },
              child: Icon(Icons.add),
            )
          ],
        ),
      ),
    );
  }
}

class MySliverAppBar extends StatelessWidget {
  const MySliverAppBar({
    super.key,
    required this.fournisseur,
  });

  final Fournisseur fournisseur;

  @override
  Widget build(BuildContext context) {
    return SliverAppBar(
      expandedHeight: 200.0,
      pinned: true,
      flexibleSpace: FlexibleSpaceBar(
        collapseMode: CollapseMode.parallax,
        background: Stack(
          alignment: Alignment.bottomCenter,
          fit: StackFit.expand,
          children: [
            Container(
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: fournisseur.produits.isNotEmpty &&
                          fournisseur.produits.first.image != null
                      ? CachedNetworkImageProvider(
                          fournisseur.produits.first.image!)
                      : CachedNetworkImageProvider(
                          'https://picsum.photos/200/300?random=${(fournisseur.id) + 5}',
                        ),
                  fit: BoxFit.cover,
                  filterQuality: FilterQuality.low,
                ),
              ),
            ),
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.transparent,
                    Colors.black.withOpacity(0.7),
                  ],
                  stops: [0.0, 1.0],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Container(),
                  ),
                  Chip(
                    label: Text('Fournisseur'),
                  ),
                  Text(
                    //  'Produits du Fournisseur '
                    'ID : ${fournisseur.id}\n' + fournisseur.nom,
                    //overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 24, // Taille du texte ajustée
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            // Positioned(
            //     top: 20,
            //     left: 10,
            //     child: Chip(
            //       label: Text('Fournisseur'),
            //     )),
            // Positioned(
            //   bottom: 10,
            //   left: 16,
            //   right: 16,
            //   child: Text(
            //     //  'Produits du Fournisseur '
            //     'ID : ${fournisseur.id}\n' + fournisseur.nom,
            //     //overflow: TextOverflow.ellipsis,
            //     style: TextStyle(
            //       color: Colors.white,
            //       fontSize: 24, // Taille du texte ajustée
            //       fontWeight: FontWeight.bold,
            //     ),
            //   ),
            // ),
          ],
        ),
      ),
    );
  }
}

class AddFournisseurWidget extends StatefulWidget {
  @override
  _AddFournisseurWidgetState createState() => _AddFournisseurWidgetState();
}

class _AddFournisseurWidgetState extends State<AddFournisseurWidget> {
  final _formKey = GlobalKey<FormState>();
  final _nomController = TextEditingController();
  final _phoneController = TextEditingController();
  final _adresseController = TextEditingController();
  final _creationController = TextEditingController();
  final _modificationController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Ajouter un Fournisseur'),
      content: Form(
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
              decoration: InputDecoration(labelText: 'Nom'),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Veuillez entrer un nom';
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
        TextButton(
          onPressed: () {
            if (_formKey.currentState!.validate()) {
              final fournisseur = Fournisseur(
                nom: _nomController.text,
                phone: _phoneController.text,
                adresse: _adresseController.text,
                qr: '',
                // dateCreation: DateTime.parse(_creationController.text),
                // derniereModification:
                //     DateTime.parse(_modificationController.text)
              );
              context.read<CommerceProvider>().addFournisseur(fournisseur);
              Navigator.of(context).pop();
            }
          },
          child: Text('Ajouter'),
        ),
      ],
    );
  }

  @override
  void dispose() {
    _nomController.dispose();
    _phoneController.dispose();
    _adresseController.dispose();
    _creationController.dispose();
    _modificationController.dispose();
    super.dispose();
  }
}

class _AddFournisseurForm extends StatefulWidget {
  @override
  __AddFournisseurFormState createState() => __AddFournisseurFormState();
}

class __AddFournisseurFormState extends State<_AddFournisseurForm> {
  final _formKey = GlobalKey<FormState>();
  final _nomController = TextEditingController();
  final _phoneController = TextEditingController();
  final _adresseController = TextEditingController();
  final _creationController = TextEditingController();
  final _modificationController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Padding(
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
                      //     DateTime.parse(_modificationController.text)
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
    );
  }

  @override
  void dispose() {
    _nomController.dispose();
    _phoneController.dispose();
    _adresseController.dispose();
    _creationController.dispose();
    _modificationController.dispose();
    super.dispose();
  }
}

void _editFournisseur(BuildContext context, Fournisseur fournisseur) {
  final _nomController = TextEditingController(text: fournisseur.nom);
  final _phoneController = TextEditingController(text: fournisseur.phone);
  final _adresseController = TextEditingController(text: fournisseur.adresse);
  // final _creationController =
  //     TextEditingController(text: fournisseur.dateCreation.toString());
  // final _modificationController =
  //     TextEditingController(text: fournisseur.derniereModification.toString());
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    builder: (context) => Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
        left: 16,
        right: 16,
        top: 16,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'Modifier un Fournisseur',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          Form(
            child: Column(
              children: [
                TextFormField(
                  controller: _nomController,
                  decoration: InputDecoration(labelText: 'Nom'),
                ),
                TextFormField(
                  controller: _phoneController,
                  keyboardType: TextInputType.phone,
                  decoration: InputDecoration(labelText: 'Phone'),
                ),
                TextFormField(
                  controller: _adresseController,
                  decoration: InputDecoration(labelText: 'Adresse'),
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
                  if (_nomController.text.isNotEmpty &&
                      _phoneController.text.isNotEmpty &&
                      _adresseController.text.isNotEmpty) {
                    final updatedFournisseur = Fournisseur(
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
                        .updateFournisseur(fournisseur.id, updatedFournisseur);
                    Navigator.of(context).pop();
                  }
                },
                child: Text('Modifier'),
              ),
            ],
          ),
          SizedBox(height: 50),
        ],
      ),
    ),
  );
}

void _deleteFournisseur(BuildContext context, Fournisseur fournisseur) {
  showModalBottomSheet(
    context: context,
    builder: (BuildContext context) {
      return Container(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.all(15.0),
              child: Text(
                'Confirmer la suppression',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
            FittedBox(
                child: Text(
                    'Êtes-vous sûr de vouloir supprimer ce fournisseur ?')),
            SizedBox(
              height: 15,
            ),
            Divider(),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                ElevatedButton.icon(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  label: Text('Annuler'),
                  icon: Icon(Icons.cancel),
                ),
                ElevatedButton.icon(
                    onPressed: () {
                      context
                          .read<CommerceProvider>()
                          .supprimerFournisseur(fournisseur);
                      Navigator.of(context).pop();
                    },
                    label: Text(
                      'Supprimer',
                      style: TextStyle(color: Colors.white),
                    ),
                    icon: Icon(Icons.delete),
                    style: ButtonStyle(
                      iconColor: WidgetStateProperty.all<Color>(Colors.white),
                      backgroundColor:
                          WidgetStateProperty.all<Color>(Colors.red),
                    ))
              ],
            ),
            SizedBox(
              height: 60,
            )
          ],
        ),
      );
    },
  );
}

void _deleteProduit(BuildContext context, Produit produit) {
  showModalBottomSheet(
    context: context,
    builder: (BuildContext context) {
      return Container(
        padding: EdgeInsets.all(16.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text('Confirmer la suppression', style: TextStyle(fontSize: 20.0)),
            SizedBox(height: 20.0),
            Text('Êtes-vous sûr de vouloir supprimer ce produit ?'),
            SizedBox(height: 20.0),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                ElevatedButton.icon(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  label: Text('Annuler'),
                  icon: Icon(Icons.cancel),
                ),
                ElevatedButton.icon(
                    onPressed: () {
                      // context
                      //     .read<CommerceProvider>()
                      //     .supprimerProduit(produit);
                      print('deleted');
                      final produitProvider =
                          Provider.of<CommerceProvider>(context, listen: false);
                      produitProvider.supprimerProduit(produit);
                      Navigator.of(context).pop();
                    },
                    label: Text(
                      'Supprimer',
                      style: TextStyle(color: Colors.white),
                    ),
                    icon: Icon(Icons.delete),
                    style: ButtonStyle(
                      iconColor: WidgetStateProperty.all<Color>(Colors.white),
                      backgroundColor:
                          WidgetStateProperty.all<Color>(Colors.red),
                    ))
              ],
            ),
            SizedBox(
              height: 60,
            )
          ],
        ),
      );
    },
  );
}

// class FournisseurSearchDelegateMain extends SearchDelegate {
//   final List<Fournisseur> fournisseurs;
//
//   FournisseurSearchDelegateMain(this.fournisseurs);
//
//   @override
//   List<Widget>? buildActions(BuildContext context) {
//     return [
//       IconButton(
//         icon: Icon(Icons.clear),
//         onPressed: () {
//           query = '';
//         },
//       ),
//     ];
//   }
//
//   @override
//   Widget? buildLeading(BuildContext context) {
//     return IconButton(
//       icon: Icon(Icons.arrow_back),
//       onPressed: () {
//         close(context, null);
//       },
//     );
//   }
//
//   @override
//   Widget buildResults(BuildContext context) {
//     final results = fournisseurs
//         .where((f) => f.nom.toLowerCase().contains(query.toLowerCase()))
//         .toList();
//
//     return ListView.builder(
//       itemCount: results.length,
//       itemBuilder: (context, index) {
//         final fournisseur = results[index];
//         return ListTile(
//           onTap: () {
//             Navigator.of(context).push(
//               MaterialPageRoute(
//                 builder: (context) =>
//                     ProduitsFournisseurPage(fournisseur: fournisseur),
//               ),
//             );
//           },
//           title: Text(fournisseur.nom),
//           subtitle: Text('${fournisseur.produits.length} produits'),
//         );
//       },
//     );
//   }
//
//   @override
//   Widget buildSuggestions(BuildContext context) {
//     final suggestions = fournisseurs
//         .where((f) => f.nom.toLowerCase().contains(query.toLowerCase()))
//         .toList();
//
//     return ListView.builder(
//       itemCount: suggestions.length,
//       itemBuilder: (context, index) {
//         final fournisseur = suggestions[index];
//         return ListTile(
//           onTap: () {
//             query = fournisseur.nom;
//             showResults(context);
//           },
//           title: Text(fournisseur.nom),
//         );
//       },
//     );
//   }
// }
class FournisseurSearchDelegateMain extends SearchDelegate {
  final List<Fournisseur> fournisseurs;

  FournisseurSearchDelegateMain(this.fournisseurs);

  @override
  List<Widget>? buildActions(BuildContext context) {
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
  Widget? buildLeading(BuildContext context) {
    return IconButton(
      icon: Icon(Icons.arrow_back),
      onPressed: () {
        close(context, null);
      },
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    final results = fournisseurs
        .where((f) => f.nom.toLowerCase().contains(query.toLowerCase()))
        .toList();

    return ListView.builder(
      itemCount: results.length,
      itemBuilder: (context, index) {
        final fournisseur = results[index];
        return ListTile(
          onTap: () {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) =>
                    ProduitsFournisseurPage(fournisseur: fournisseur),
              ),
            );
          },
          title: Text(fournisseur.nom),
          subtitle: Text('${fournisseur.produits.length} produits'),
        );
      },
    );
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    final suggestions = fournisseurs
        .where((f) => f.nom.toLowerCase().contains(query.toLowerCase()))
        .toList();

    return ListView.builder(
      itemCount: suggestions.length,
      itemBuilder: (context, index) {
        final fournisseur = suggestions[index];
        return ListTile(
          onTap: () {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) =>
                    ProduitsFournisseurPage(fournisseur: fournisseur),
              ),
            );
          },
          title: Text(fournisseur.nom),
          trailing: Text('${fournisseur.produits.length}'),
        );
      },
    );
  }
}
