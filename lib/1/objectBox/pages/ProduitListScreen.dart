import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:pretty_qr_code/pretty_qr_code.dart';
import 'package:provider/provider.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';
import '../Entity.dart';
import '../MyProviders.dart';
import 'AddProduitScreen.dart';
import 'FournisseurListScreen.dart';

class ProduitListScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Produits'),
      ),
      body: Consumer<ProduitProvider>(
        builder: (context, produitProvider, child) {
          final produits = produitProvider.produits.reversed.toList();
          print(produits.length);
          return ListView.builder(
            itemCount: produits.length,
            itemBuilder: (context, index) {
              final produit = produits[index];
              final fournisseurs = [];
              // Provider.of<ProduitProvider>(context)
              //     .getFournisseursForProduit(produit.id);

              return Slidable(
                  key: ValueKey(produit.id),
                  startActionPane: ActionPane(
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
                        leading: produit.image == null || produit.image!.isEmpty
                            ? CircleAvatar(
                                child: Icon(
                                Icons.image_not_supported,
                              ))
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
                            produit.fournisseurs.isEmpty
                                ? Container()
                                : Wrap(
                                    spacing:
                                        6.0, // Espace horizontal entre les éléments
                                    runSpacing:
                                        4.0, // Espace vertical entre les lignes
                                    children:
                                        produit.fournisseurs.map((fournisseur) {
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
                                        child: Chip(
                                          shadowColor: Colors.black,
                                          backgroundColor: Theme.of(context)
                                              .chipTheme
                                              .backgroundColor,
                                          labelStyle: TextStyle(
                                            color: Theme.of(context)
                                                .chipTheme
                                                .labelStyle
                                                ?.color,
                                          ),
                                          side: BorderSide.none,
                                          shape: RoundedRectangleBorder(
                                              borderRadius: BorderRadius.all(
                                                  Radius.circular(10))),
                                          padding: EdgeInsets.zero,
                                          label: Text(
                                            fournisseur.nom,
                                            style: TextStyle(fontSize: 10),
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
                  ));
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
                      context.read<ProduitProvider>().supprimerProduit(produit);
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
                    Consumer<ProduitProvider>(
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