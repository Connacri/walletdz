import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:pretty_qr_code/pretty_qr_code.dart';
import 'package:provider/provider.dart';
import '../Entity.dart';
import '../MyProviders.dart';
import 'AddProduitScreen.dart';
import 'FournisseurListScreen.dart';
import 'dart:io' show Platform;
import 'package:flutter/foundation.dart' show kIsWeb;

class ProduitListScreen extends StatefulWidget {
  @override
  _ProduitListScreenState createState() => _ProduitListScreenState();
}

class _ProduitListScreenState extends State<ProduitListScreen> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels ==
        _scrollController.position.maxScrollExtent) {
      // Charger plus de produits lorsque l'utilisateur atteint la fin de la liste
      Provider.of<CommerceProvider>(context, listen: false).chargerProduits();
    }
  }

  @override
  Widget build(BuildContext context) {
    final double largeur;
    if (kIsWeb || Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
      // Pour le web
      largeur = 1 / 10;
    } else if (Platform.isAndroid || Platform.isIOS) {
      // Pour Android et iOS
      largeur = 0.5;
    } else {
      // Pour les autres plateformes (Desktop)
      largeur = 1 / 10;
    }
    return Scaffold(
      appBar: AppBar(
        title: Text('Produits'),
        actions: [
          IconButton(
            icon: Icon(Icons.search),
            onPressed: () async {
              final produitProvider =
                  Provider.of<CommerceProvider>(context, listen: false);
              showSearch(
                context: context,
                delegate: ProduitSearchDelegateMain(produitProvider),
              );
            },
          )
        ],
      ),
      body: Consumer<CommerceProvider>(
        builder: (context, produitProvider, child) {
          return ListView.builder(
            controller: _scrollController,
            itemCount: produitProvider.produitsP.length + 1,
            itemBuilder: (context, index) {
              if (index < produitProvider.produitsP.length) {
                final produit = produitProvider.produitsP[index];
                return Slidable(
                  key: ValueKey(produit.id),
                  startActionPane: ActionPane(
                    extentRatio: largeur,
                    motion: ScrollMotion(),
                    children: [
                      SlidableAction(
                        onPressed: (BuildContext context) {
                          Navigator.of(context).push(MaterialPageRoute(
                            builder: (ctx) =>
                                EditProduitScreen(produit: produit),
                          ));
                        },
                        backgroundColor: Colors.blue,
                        icon: Icons.edit,
                        label: 'Editer',
                      ),
                    ],
                  ),
                  child: Card(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        ListTile(
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
                                  child: Icon(Icons.image_not_supported),
                                )
                              : CircleAvatar(
                                  backgroundImage: CachedNetworkImageProvider(
                                    produit.image!,
                                    errorListener: (error) => Icon(Icons.error),
                                  ),
                                ),
                          title: Text(produit.nom),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'A: ${produit.prixAchat.toStringAsFixed(2)}\nB: ${(produit.prixVente - produit.prixAchat).toStringAsFixed(2)} ',
                              ),
                              _buildChipRow(context, produit)
                            ],
                          ),
                          trailing: Text(
                            '${produit.prixVente.toStringAsFixed(2)}',
                            style: TextStyle(fontSize: 20),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              } else if (produitProvider.hasMoreProduits) {
                return Center(child: CircularProgressIndicator());
              } else {
                return SizedBox.shrink();
              }
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.of(context)
              .push(MaterialPageRoute(builder: (_) => EditProduitScreen()));
        },
        child: Icon(Icons.add),
      ),
    );
  }
}

Widget _buildChipRow(
    BuildContext context, produit /*List<Fournisseur> fournisseurs*/) {
  final List<Fournisseur> fournisseurs = produit.fournisseurs;
  if (fournisseurs.length <= 2) {
    return Wrap(
      spacing: 4.0,
      runSpacing: 0.0,
      children: fournisseurs.map((fournisseur) {
        return InkWell(
          onTap: () {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (ctx) =>
                    ProduitsFournisseurPage(fournisseur: fournisseur),
              ),
            );
          },
          child: Chip(
            shadowColor: Colors.black,
            backgroundColor: Theme.of(context).chipTheme.backgroundColor,
            labelStyle: TextStyle(
              color: Theme.of(context).chipTheme.labelStyle?.color,
            ),
            side: BorderSide.none,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(10)),
            ),
            padding: EdgeInsets.zero,
            label: Text(
              fournisseur.nom,
              style: TextStyle(fontSize: 10),
            ),
          ),
        );
      }).toList(),
    );
  } else {
    return Wrap(
      spacing: 4.0,
      runSpacing: 0.0,
      children: [
        for (var i = 0; i < 2; i++)
          InkWell(
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (ctx) =>
                      ProduitsFournisseurPage(fournisseur: fournisseurs[i]),
                ),
              );
            },
            child: Chip(
              shadowColor: Colors.black,
              backgroundColor: Theme.of(context).chipTheme.backgroundColor,
              labelStyle: TextStyle(
                color: Theme.of(context).chipTheme.labelStyle?.color,
              ),
              side: BorderSide.none,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.all(Radius.circular(10)),
              ),
              padding: EdgeInsets.zero,
              label: Text(
                fournisseurs[i].nom,
                style: TextStyle(fontSize: 10),
              ),
            ),
          ),
        IconButton(
          onPressed: () {
            _showAllFournisseursDialog(
              context,
              produit, /*fournisseurs*/
            );
          },
          icon: Icon(Icons.add),
        ),
      ],
    );
  }
}

void _showAllFournisseursDialog(
  BuildContext context,
  produit,
  /* List<Fournisseur> fournisseurs*/
) {
  final List<Fournisseur> fournisseurs = produit.fournisseurs;
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: Text('Les Fournisseurs du ${produit.nom}'),
        content: SingleChildScrollView(
          child: Wrap(
            spacing: 4.0,
            runSpacing: 0.0,
            children: fournisseurs.map((fournisseur) {
              return InkWell(
                // onTap: () {
                //   Navigator.of(context).push(
                //     MaterialPageRoute(
                //       builder: (ctx) =>
                //           ProduitsFournisseurPage(fournisseur: fournisseur),
                //     ),
                //   );
                // },
                child: Chip(
                  shadowColor: Colors.black,
                  backgroundColor: Theme.of(context).chipTheme.backgroundColor,
                  labelStyle: TextStyle(
                    color: Theme.of(context).chipTheme.labelStyle?.color,
                  ),
                  side: BorderSide.none,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.all(Radius.circular(10)),
                  ),
                  padding: EdgeInsets.zero,
                  label: Text(
                    fournisseur.nom,
                    style: TextStyle(fontSize: 10),
                  ),
                ),
              );
            }).toList(),
          ),
        ),
        actions: <Widget>[
          TextButton(
            child: Text('Fermer'),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
        ],
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
                      context
                          .read<CommerceProvider>()
                          .supprimerProduit(produit);
                      // .removeProduit(produit.id, produit.image);
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

class ProduitDetailPage extends StatelessWidget {
  final Produit produit;

  ProduitDetailPage({required this.produit});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: CustomScrollView(
      slivers: [
        SliverAppBar(
          expandedHeight: 200.0,
          pinned: true,
          flexibleSpace: FlexibleSpaceBar(
            title: Text(produit.nom, style: TextStyle(color: Colors.white)),
            background: Stack(
              alignment: Alignment.bottomCenter,
              fit: StackFit.expand,
              children: [
                produit.image!.isEmpty
                    ? Center(child: Icon(Icons.image_not_supported, size: 50))
                    : CachedNetworkImage(
                        imageUrl: produit.image!,
                        fit: BoxFit.cover,
                        errorWidget: (context, url, error) =>
                            Center(child: Icon(Icons.error, size: 50)),
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
                      stops: [0.0, 1.0], // position du dégradé
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        SliverList(
          delegate: SliverChildListDelegate(
            [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Center(
                    //   child: Padding(
                    //       padding: EdgeInsets.symmetric(
                    //           horizontal: 50, vertical: 16),
                    //       child: ElevatedButton(
                    //         onPressed: () async {
                    //           final updatedProduit =
                    //               await Navigator.of(context).push(
                    //             MaterialPageRoute(
                    //               builder: (ctx) => EditProduitScreen(
                    //                 produit: produit,
                    //               ),
                    //             ),
                    //           );
                    //         },
                    //         child: Text('Modifier'),
                    //       )),
                    // ),
                    Center(
                      child: PrettyQr(
                        data: produit.qr.toString(),
                        elementColor: Theme.of(context).hintColor,
                      ),
                    ),
                    Center(child: Text('Id : ${produit.id}')),
                    Center(
                      child: Text(
                        produit.nom,
                        style: TextStyle(
                            fontSize: 24, fontWeight: FontWeight.bold),
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      'Prix d\'achat: ${produit.prixAchat.toStringAsFixed(2)}',
                      style: TextStyle(fontSize: 16),
                    ),
                    Text(
                      'Prix de vente: ${produit.prixVente.toStringAsFixed(2)}',
                      style: TextStyle(fontSize: 16),
                    ),
                    SizedBox(height: 16),
                    Text('Description : ${produit.description}'),
                    SizedBox(height: 16),
                    Text(
                        'Earn : ${(produit.prixVente - produit.prixAchat).toStringAsFixed(2)}'),
                    SizedBox(height: 16),
                    Text('Stock : ' + produit.stock.toString()),
                    SizedBox(
                      height: 16,
                    ),
                    Divider(),
                    Text(
                      'Fournisseurs',
                      style:
                          TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 8),
                    Consumer<CommerceProvider>(
                      builder: (context, produitProvider, child) {
                        return Wrap(
                          spacing: 6.0, // Espace horizontal entre les éléments
                          runSpacing: 4.0, // Espace vertical entre les lignes
                          children: produit.fournisseurs.map((fournisseur) {
                            return InkWell(
                              onTap: () {
                                Navigator.of(context).push(MaterialPageRoute(
                                    builder: (ctx) => ProduitsFournisseurPage(
                                          fournisseur: fournisseur,
                                        )));
                              },
                              child: Chip(
                                shadowColor: Colors.black,
                                backgroundColor:
                                    Theme.of(context).chipTheme.backgroundColor,
                                labelStyle: TextStyle(
                                  color: Theme.of(context)
                                      .chipTheme
                                      .labelStyle
                                      ?.color,
                                ),
                                side: BorderSide.none,
                                shape: RoundedRectangleBorder(
                                    borderRadius:
                                        BorderRadius.all(Radius.circular(10))),
                                padding: EdgeInsets.zero,
                                label: Text(
                                  fournisseur.nom,
                                  style: TextStyle(fontSize: 10),
                                ),
                              ),
                            );
                          }).toList(),
                        );
                      },
                    ),
                    SizedBox(
                      height: 50,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    ));
  }
}

// class ProduitSearchDelegateMain extends SearchDelegate {
//   final List<Produit> produits;
//
//   ProduitSearchDelegateMain(this.produits);
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
//     final results = produits
//         .where((f) => f.nom.toLowerCase().contains(query.toLowerCase()))
//         .toList();
//
//     return ListView.builder(
//       itemCount: results.length,
//       itemBuilder: (context, index) {
//         final produit = results[index];
//         return ListTile(
//           onTap: () {
//             Navigator.of(context).push(MaterialPageRoute(
//               builder: (ctx) => ProduitDetailPage(produit: produit),
//             ));
//           },
//           title: Text(produit.nom),
//         );
//       },
//     );
//   }
//
//   @override
//   Widget buildSuggestions(BuildContext context) {
//     final suggestions = produits
//         .where((f) => f.nom.toLowerCase().contains(query.toLowerCase()))
//         .toList();
//
//     return ListView.builder(
//       itemCount: suggestions.length,
//       itemBuilder: (context, index) {
//         final produit = suggestions[index];
//         return ListTile(
//           onTap: () {
//             query = produit.nom;
//             showResults(context);
//           },
//           title: Text(produit.nom),
//         );
//       },
//     );
//   }
// }

// class ProduitSearchDelegateMain extends SearchDelegate {
//   final List<Produit> produits;
//
//   ProduitSearchDelegateMain(this.produits);
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
//     // final results = produits
//     //     .where((f) => f.nom.toLowerCase().contains(query.toLowerCase()))
//     //     .toList();
//     final results = produits.where((produit) {
//       final queryLower = query.toLowerCase();
//       final nomLower = produit.nom.toLowerCase();
//       return nomLower.contains(queryLower) ||
//           produit.id.toString().contains(query);
//     }).toList();
//     return ListView.builder(
//       itemCount: results.length,
//       itemBuilder: (context, index) {
//         final produit = results[index];
//         return ListTile(
//           onTap: () {
//             Navigator.of(context).push(
//               MaterialPageRoute(
//                 builder: (context) => ProduitDetailPage(produit: produit),
//               ),
//             );
//           },
//           title: Text('${produit.id}' + ' ' '${produit.nom}'),
//         );
//       },
//     );
//   }
//
//   @override
//   Widget buildSuggestions(BuildContext context) {
//     // final suggestions = produits
//     //     .where((f) => f.nom.toLowerCase().contains(query.toLowerCase()))
//     //     .toList();
//     final suggestions = produits.where((produit) {
//       final queryLower = query.toLowerCase();
//       final nomLower = produit.nom.toLowerCase();
//       return nomLower.contains(queryLower) ||
//           produit.id.toString().contains(query);
//     }).toList();
//     return ListView.builder(
//       itemCount: suggestions.length,
//       itemBuilder: (context, index) {
//         final produit = suggestions[index];
//         return ListTile(
//           onTap: () {
//             Navigator.of(context).push(
//               MaterialPageRoute(
//                 builder: (context) => ProduitDetailPage(produit: produit),
//               ),
//             );
//           },
//           title: Text('${produit.id}' + ' ' '${produit.nom}'),
//         );
//       },
//     );
//   }
// }
// class ProduitSearchDelegateMain extends SearchDelegate {
//   final List<Produit> produits;
//
//   ProduitSearchDelegateMain(this.produits);
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
//     final results = produits.where((produit) {
//       final queryLower = query.toLowerCase();
//       final nomLower = produit.nom.toLowerCase();
//       return nomLower.contains(queryLower) ||
//           produit.id.toString().contains(query);
//     }).toList();
//
//     return ListView.builder(
//       itemCount: results.length,
//       itemBuilder: (context, index) {
//         final produit = results[index];
//         return ListTile(
//           onTap: () {
//             Navigator.of(context).push(
//               MaterialPageRoute(
//                 builder: (context) => ProduitDetailPage(produit: produit),
//               ),
//             );
//           },
//           title: Text('${produit.id} ${produit.nom}'),
//         );
//       },
//     );
//   }
//
//   @override
//   Widget buildSuggestions(BuildContext context) {
//     final suggestions = produits.where((produit) {
//       final queryLower = query.toLowerCase();
//       final nomLower = produit.nom.toLowerCase();
//       return nomLower.contains(queryLower) ||
//           produit.id.toString().contains(query);
//     }).toList();
//
//     return ListView.builder(
//       itemCount: suggestions.length,
//       itemBuilder: (context, index) {
//         final produit = suggestions[index];
//         return ListTile(
//           onTap: () {
//             Navigator.of(context).push(
//               MaterialPageRoute(
//                 builder: (context) => ProduitDetailPage(produit: produit),
//               ),
//             );
//           },
//           title: Text('${produit.id} ${produit.nom}'),
//         );
//       },
//     );
//   }
// }

class ProduitSearchDelegateMain extends SearchDelegate {
  final CommerceProvider commerceProvider;

  ProduitSearchDelegateMain(this.commerceProvider);

  @override
  List<Widget>? buildActions(BuildContext context) {
    return [
      IconButton(
        icon: Icon(Icons.clear),
        onPressed: () {
          query = '';
          showSuggestions(context);
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
    return _buildSearchResults(context);
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    return _buildSearchResults(context);
  }

  Widget _buildSearchResults(BuildContext context) {
    return FutureBuilder<List<Produit>>(
      future: commerceProvider.rechercherProduits(query),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(child: Text('Erreur: ${snapshot.error}'));
        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return Center(child: Text('Aucun résultat trouvé'));
        } else {
          final results = snapshot.data!;
          return ListView.builder(
            itemCount: results.length,
            itemBuilder: (context, index) {
              final produit = results[index];
              return ListTile(
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => ProduitDetailPage(produit: produit),
                    ),
                  );
                },
                title: Text('${produit.id} ${produit.nom}'),
                subtitle:
                    Text('Prix: ${produit.prixVente.toStringAsFixed(2)} DZD'),
              );
            },
          );
        }
      },
    );
  }
}
