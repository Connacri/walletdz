import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';
import '../Entity.dart';
import '../MyProviders.dart';
import 'AddProduitScreen.dart';
import 'ProduitListScreen.dart';

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
            onPressed: () async {},
          )
        ],
      ),
      body: Consumer<FournisseurProvider>(
        builder: (context, fournisseurProvider, child) {
          final fournisseurs = fournisseurProvider.fournisseurs;

          return ListView.builder(
            itemCount: fournisseurs.length,
            itemBuilder: (context, index) {
              // final fournisseur = fournisseurs[index];
              //  final produitCount = fournisseurProvider
              //     .countProduitsForFournisseur(fournisseur.id);
              // Utiliser l'index inverse
              final reversedIndex = fournisseurs.length - 1 - index;
              final fournisseur = fournisseurs[reversedIndex];
              // final produitCount = fournisseurProvider
              //     .countProduitsForFournisseur(fournisseur.id);
              final produits =
                  fournisseurProvider.getProduitsByFournisseur(fournisseur);
              return ListTile(
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) =>
                          ProduitsFournisseurPage(fournisseur: fournisseur),
                    ),
                  );
                },
                title: Text('${fournisseur.nom}'),
                subtitle: Text('${produits.length} produits'),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: Icon(
                        Icons.edit,
                      ),
                      onPressed: () {
                        _editFournisseur(context, fournisseur);
                      },
                    ),
                    IconButton(
                      icon: Icon(Icons.delete, color: Colors.red),
                      onPressed: () {
                        _deleteFournisseur(context, fournisseur);
                      },
                    ),
                  ],
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

        //     () {
        //   Navigator.of(context).push(
        //       MaterialPageRoute(builder: (ctx) => AddFournisseurWidget()));
        // },
        child: Icon(Icons.add),
      ),
    );
  }
}

// class ProduitsFournisseurPage extends StatelessWidget {
//   final Fournisseur fournisseur;
//
//   ProduitsFournisseurPage({required this.fournisseur});
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: CustomScrollView(
//         slivers: <Widget>[
//           SliverAppBar(
//             expandedHeight: 200.0,
//             pinned: true,
//             flexibleSpace: FlexibleSpaceBar(
//               collapseMode: CollapseMode.parallax,
//               background: Stack(
//                 alignment: Alignment.bottomCenter,
//                 fit: StackFit.expand,
//                 children: [
//                   Container(
//                     decoration: BoxDecoration(
//                       image: DecorationImage(
//                         image: fournisseur.produits.isNotEmpty &&
//                                 fournisseur.produits.first.image != null
//                             ? CachedNetworkImageProvider(
//                                 fournisseur.produits.first.image!)
//                             : CachedNetworkImageProvider(
//                                 'https://picsum.photos/200/300?random=${(fournisseur.id) + 5}',
//                               ),
//                         fit: BoxFit.cover,
//                         filterQuality: FilterQuality.low,
//                       ),
//                     ),
//                   ),
//                   Container(
//                     decoration: BoxDecoration(
//                       gradient: LinearGradient(
//                         begin: Alignment.topCenter,
//                         end: Alignment.bottomCenter,
//                         colors: [
//                           Colors.transparent,
//                           Colors.black.withOpacity(0.7),
//                         ],
//                         stops: [0.0, 1.0],
//                       ),
//                     ),
//                   ),
//                   Positioned(
//                     bottom: 10,
//                     left: 16,
//                     right: 16,
//                     child: Text(
//                       fournisseur.nom,
//                       overflow: TextOverflow.ellipsis,
//                       style: TextStyle(
//                         color: Colors.white,
//                         fontSize: 24, // Taille du texte ajustée
//                         fontWeight: FontWeight.bold,
//                       ),
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//           ),
//           SliverToBoxAdapter(
//             child: Padding(
//               padding: const EdgeInsets.all(18.0),
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 mainAxisAlignment: MainAxisAlignment.end,
//                 children: [
//                   SizedBox(height: 8),
//                   Text(fournisseur.phone == null && fournisseur.phone == 0
//                       ? ''
//                       : 'Téléphone: ${fournisseur.phone ?? "N/A"}'),
//                   Text(fournisseur.adresse == null && fournisseur.adresse == ''
//                       ? ''
//                       : 'Adresse: ${fournisseur.adresse ?? "N/A"}'),
//                   SizedBox(
//                     height: 10,
//                   ),
//                   Divider(),
//                   SizedBox(
//                     height: 20,
//                   ),
//                   Text(
//                     'Liste Des Produits:',
//                     style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
//                   ),
//                 ],
//               ),
//             ),
//           ),
//           SliverList(
//             delegate: SliverChildBuilderDelegate(
//               (BuildContext context, int index) {
//                 return Consumer<FournisseurProvider>(
//                   builder: (context, fournisseurProvider, child) {
//                     final produits = fournisseurProvider
//                         .getProduitsByFournisseur(fournisseur);
//
//                     if (index >= produits.length) {
//                       return Container();
//                     }
//
//                     final produit = produits[index];
//                     return ListTile(
//                       onTap: () {
//                         Navigator.of(context).push(MaterialPageRoute(
//                             builder: (ctx) => ProduitDetailPage(
//                                   produit: produit,
//                                 )));
//                       },
//                       leading: ClipRRect(
//                         borderRadius: const BorderRadius.only(
//                           topRight: Radius.circular(5),
//                           topLeft: Radius.circular(5),
//                           bottomLeft: Radius.circular(5),
//                           bottomRight: Radius.circular(5),
//                         ),
//                         child: produit.image != null
//                             ? CachedNetworkImage(
//                                 imageUrl: produit.image!,
//                                 height: 50,
//                                 width: 50,
//                                 fit: BoxFit.cover,
//                                 // width: double.infinity,
//                               )
//                             : null,
//                       ),
//                       title: Text(produit.nom),
//                       subtitle: Row(children: [
//                         Icon(
//                           Icons.factory,
//                           size: 15,
//                         ),
//                         Text(
//                           ' ${produit.prixAchat.toStringAsFixed(2)}',
//                         ),
//                         Spacer(),
//                         Icon(
//                           Icons.add_business,
//                           size: 15,
//                         ),
//                         Text(
//                           ' ${produit.prixVente.toStringAsFixed(2)}',
//                         ),
//                         Spacer(),
//                         Icon(
//                           Icons.egg_alt_rounded,
//                           size: 15,
//                         ),
//                         Text(
//                           ' ${(produit.prixVente - produit.prixAchat).toStringAsFixed(2)}',
//                         ),
//                       ]),
//                     );
//                   },
//                 );
//               },
//               childCount: fournisseur.produits.length,
//             ),
//           ),
//           SliverToBoxAdapter(
//             child: SizedBox(
//               height: 50,
//             ),
//           ),
//         ],
//       ),
//       floatingActionButton: FloatingActionButton(
//         onPressed: () {
//           Navigator.of(context).push(MaterialPageRoute(
//               builder: (_) =>
//                   EditProduitScreen(specifiquefournisseur: fournisseur)));
//         },
//         child: Icon(Icons.add),
//       ),
//     );
//   }
// }

class ProduitsFournisseurPage extends StatelessWidget {
  final Fournisseur fournisseur;

  ProduitsFournisseurPage({required this.fournisseur});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: <Widget>[
          SliverAppBar(
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
                  Positioned(
                    bottom: 10,
                    left: 16,
                    right: 16,
                    child: Text(
                      fournisseur.nom,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          SliverToBoxAdapter(
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
                ],
              ),
            ),
          ),
          SliverList(
            delegate: SliverChildBuilderDelegate(
              (BuildContext context, int index) {
                return Consumer<FournisseurProvider>(
                  builder: (context, fournisseurProvider, child) {
                    final produits = fournisseurProvider
                        .getProduitsByFournisseur(fournisseur);

                    if (index >= produits.length) {
                      return Container();
                    }

                    final produit = produits[index];
                    return ListTile(
                      onTap: () {
                        Navigator.of(context).push(MaterialPageRoute(
                            builder: (ctx) => ProduitDetailPage(
                                  produit: produit,
                                )));
                      },
                      leading: ClipRRect(
                        borderRadius: const BorderRadius.only(
                          topRight: Radius.circular(5),
                          topLeft: Radius.circular(5),
                          bottomLeft: Radius.circular(5),
                          bottomRight: Radius.circular(5),
                        ),
                        child: produit.image != null
                            ? CachedNetworkImage(
                                imageUrl: produit.image!,
                                height: 50,
                                width: 50,
                                fit: BoxFit.cover,
                              )
                            : null,
                      ),
                      title: Text(produit.nom),
                      subtitle: Row(
                        children: [
                          Icon(
                            Icons.factory,
                            size: 15,
                          ),
                          Text(' ${produit.prixAchat.toStringAsFixed(2)}'),
                          Spacer(),
                          Icon(
                            Icons.add_business,
                            size: 15,
                          ),
                          Text(' ${produit.prixVente.toStringAsFixed(2)}'),
                          Spacer(),
                          Icon(
                            Icons.egg_alt_rounded,
                            size: 15,
                          ),
                          Text(
                              ' ${(produit.prixVente - produit.prixAchat).toStringAsFixed(2)}'),
                        ],
                      ),
                    );
                  },
                );
              },
              childCount: fournisseur.produits.length,
            ),
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

class AddFournisseurWidget extends StatefulWidget {
  @override
  _AddFournisseurWidgetState createState() => _AddFournisseurWidgetState();
}

class _AddFournisseurWidgetState extends State<AddFournisseurWidget> {
  final _formKey = GlobalKey<FormState>();
  final _nomController = TextEditingController();
  final _phoneController = TextEditingController();
  final _adresseController = TextEditingController();

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
                  qr: '');
              context.read<FournisseurProvider>().addFournisseur(fournisseur);
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
                    );
                    context
                        .read<FournisseurProvider>()
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
    super.dispose();
  }
}

void _editFournisseur(BuildContext context, Fournisseur fournisseur) {
  final _nomController = TextEditingController(text: fournisseur.nom);
  final _phoneController = TextEditingController(text: fournisseur.phone);
  final _adresseController = TextEditingController(text: fournisseur.adresse);

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
                    );
                    context
                        .read<FournisseurProvider>()
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
        color: Colors.white,
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
                          .read<FournisseurProvider>()
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
