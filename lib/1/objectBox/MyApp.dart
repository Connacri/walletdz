import 'dart:math';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:percent_indicator/linear_percent_indicator.dart';
import 'package:provider/provider.dart';
import 'package:walletdz/1/objectBox/pages/Add_Edit_ProduitScreen.dart';
import 'package:walletdz/1/objectBox/pages/ProduitListScreen.dart';
import 'package:walletdz/1/objectBox/pages/test.dart';
import 'Entity.dart';
import 'MyProviders.dart';
import 'classeObjectBox.dart';
import 'pages/FournisseurListScreen.dart';
import 'package:flutter/foundation.dart';
import 'dart:io' show Platform;
import 'dart:io';
import 'dart:isolate';
import 'package:percent_indicator/percent_indicator.dart';
import 'package:faker/faker.dart';
import 'package:path_provider/path_provider.dart'; // Importez le package path_provider

class MyMainO extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return FutureProvider<ObjectBox?>(
      create: (_) async {
        final objectBox = ObjectBox();
        try {
          await objectBox.init();
        } catch (e) {
          print('Error initializing ObjectBox: $e');
          return null;
        }
        return objectBox;
      },
      initialData: null,
      catchError: (context, error) {
        print('Error in FutureProvider: $error');
        return null;
      },
      child: MyApp9(),
    );
  }
}

class MyApp9 extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final objectBox = Provider.of<ObjectBox?>(context);
    if (objectBox == null) {
      return Center(child: CircularProgressIndicator());
    }

    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => CommerceProvider(
            objectBox,
          ),
        ),
        ChangeNotifierProvider(
          create: (_) => CommerceProviderTest(
            objectBox,
          ),
        ),
        // Ajoutez les autres providers ici de la même manière
      ],
      child: MaterialApp(
        title: 'POS',
        theme: ThemeData(
          fontFamily: 'OSWALD',
          brightness: Brightness.light,
          primarySwatch: Colors.blue,
          chipTheme: ChipThemeData(
            backgroundColor: Colors.grey[300]!,
            labelStyle: TextStyle(color: Colors.black),
          ),
        ),
        darkTheme: ThemeData(
          brightness: Brightness.dark,
          chipTheme: ChipThemeData(
            backgroundColor: Colors.grey[800]!,
            labelStyle: TextStyle(color: Colors.white),
          ),
        ),
        themeMode: ThemeMode.system,

        //darkTheme: ThemeData.dark(),

        home: showPlatform(
          objectBox: objectBox,
        ),
      ),
    );
  }
}

class showPlatform extends StatelessWidget {
  const showPlatform({super.key, required this.objectBox});

  final ObjectBox objectBox;

  @override
  Widget build(BuildContext context) {
    if (kIsWeb) {
      return HomeScreenWide(objectBox: objectBox);
    } else if (Platform.isIOS) {
      return HomeScreen(objectBox: objectBox);
    } else if (Platform.isAndroid) {
      return HomeScreen(objectBox: objectBox);
    } else if (Platform.isWindows) {
      return HomeScreenWide(objectBox: objectBox);
    } else if (Platform.isLinux) {
      return HomeScreenWide(objectBox: objectBox);
    } else {
      return HomeScreen(objectBox: objectBox);
    }
  }
}

class HomeScreen extends StatefulWidget {
  final ObjectBox objectBox;

  HomeScreen({required this.objectBox});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  double prixMin = 50.0;
  double prixMax = 50.15;

  void _ouvrirDialogAjustementPrix(BuildContext context) {
    double nouveauPrixMin = prixMin;
    double nouveauPrixMax = prixMax;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Ajuster les prix'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                decoration: InputDecoration(labelText: 'Prix minimum'),
                keyboardType: TextInputType.number,
                onChanged: (value) =>
                    nouveauPrixMin = double.tryParse(value) ?? nouveauPrixMin,
              ),
              TextField(
                decoration: InputDecoration(labelText: 'Prix maximum'),
                keyboardType: TextInputType.number,
                onChanged: (value) =>
                    nouveauPrixMax = double.tryParse(value) ?? nouveauPrixMax,
              ),
            ],
          ),
          actions: [
            TextButton(
              child: Text('Annuler'),
              onPressed: () => Navigator.of(context).pop(),
            ),
            TextButton(
              child: Text('Valider'),
              onPressed: () {
                setState(() {
                  prixMin = nouveauPrixMin;
                  prixMax = nouveauPrixMax;
                });
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
    final randomId = Random().nextInt(100);
    return Scaffold(
      appBar: AppBar(
        title: Text('Facturation'),
        actions: [
          IconButton(
            onPressed: () {
              widget.objectBox.fillWithFakeData();
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Données factices ajoutées !')),
              );
            },
            icon: Icon(Icons.send),
          ),
        ],
      ),
      body: Consumer<CommerceProvider>(
          builder: (context, produitProvider, child) {
        int totalProduits = produitProvider.getTotalProduits();
        List<Produit> produitsFiltres =
            produitProvider.getProduitsBetweenPrices(prixMin, prixMax);
        var produitsLowStock = produitProvider.getProduitsLowStock(5);
        print(produitsLowStock.length);
        return ListView(
          children: [
            GestureDetector(
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                      builder: (context) => FournisseurListScreen()),
                );
              },
              child: CardTop(
                image: 'https://picsum.photos/seed/${randomId + 8}/200/100',
                text: '${produitProvider.fournisseurs.length} Fournisseurs',
                provider: produitProvider,
                button: ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                          builder: (context) => FournisseurListScreen()),
                    );
                  },
                  child: Text('Voir plus'),
                ),
              ),
            ),
            GestureDetector(
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (context) => ProduitListScreen()),
                );
              },
              child: CardTop(
                image: 'https://picsum.photos/seed/$randomId/200/100',
                text: '${produitProvider.getTotalProduits()} Produits',
                provider: produitProvider,
                button: ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                          builder: (context) => ProduitListScreen()),
                    );
                  },
                  child: Text('Voir plus'),
                ),
              ),
            ),
            GestureDetector(
              onTap: () => _ouvrirDialogAjustementPrix(context),
              child: CardTop(
                  image: 'https://picsum.photos/seed/${randomId + 1}/200/100',
                  text:
                      '${produitsFiltres.length} Produits\nentre ${prixMin.toStringAsFixed(2)} DZD et ${prixMax.toStringAsFixed(2)} DZD',
                  provider: produitProvider,
                  button: produitsFiltres.length == 0
                      ? ElevatedButton(
                          onPressed: null,
                          style: ElevatedButton.styleFrom(
                            backgroundColor:
                                Colors.grey[300], // Couleur de fond grise
                            foregroundColor:
                                Colors.grey[600], // Couleur du texte grise
                            disabledBackgroundColor: Colors.grey[
                                300], // Assure que la couleur reste grise même désactivé
                            disabledForegroundColor: Colors.grey[
                                600], // Assure que la couleur du texte reste grise même désactivé
                          ),
                          child: Text(('Liste Vide')))
                      : ElevatedButton.icon(
                          onPressed: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                  builder: (context) => ProduitListInterval(
                                        produitsFiltres: produitsFiltres,
                                      )),
                            );
                          },
                          label: Text(('Voire La List')))),
            ),
            GestureDetector(
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) =>
                        LowStockList(produitsLowStock: produitsLowStock),
                  ),
                );
              },
              child: CardAlert(
                image: 'https://picsum.photos/seed/${randomId + 2}/200/100',
                text: //'${produitsLowStock.length} Low Stock',
                    'Alert stock < 5\n${produitsLowStock['count']}',
                provider: produitProvider,
                button: ElevatedButton(
                    onPressed: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) =>
                              LowStockList(produitsLowStock: produitsLowStock),
                          // ProduitListInterval(
                          //   produitsFiltres:
                          //       produitsFiltres,
                          // ),
                        ),
                      );
                    },
                    child: Text(('Voire La List'))),
                Color1: Colors.red,
                Color2: Colors.black,
              ),
            ),
            SizedBox(height: 18),
            ElevatedButton.icon(
                onPressed: () {
                  Navigator.of(context).push(MaterialPageRoute(
                      builder: (_) => Add_Edit_ProduitScreen()));
                },
                label: Text('Ajouter Un Nouveau Produit'),
                icon: Icon(Icons.add)),
            ElevatedButton.icon(
                onPressed: () {
                  showModalBottomSheet(
                    context: context,
                    isScrollControlled:
                        true, // Permet de redimensionner en fonction de la hauteur du contenu
                    builder: (context) => AddFournisseurForm(),
                  );
                },
                label: Text('Ajouter Un Nouveau Fournisseur'),
                icon: Icon(Icons.add)),
            SizedBox(height: 18),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red, // Couleur de fond grise
                foregroundColor: Colors.grey[300], // Couleur du texte grise
                disabledBackgroundColor: Colors.grey[
                    300], // Assure que la couleur reste grise même désactivé
                disabledForegroundColor: Colors.grey[
                    600], // Assure que la couleur du texte reste grise même désactivé
              ),
              child: Text('Delete all'),
              onPressed: () {
                widget.objectBox.deleteDatabase();

                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Base de Données Vider avec succes!')),
                );
              },
            ),
          ],
        );
      }),
    );
  }
}

class HomeScreenWide extends StatefulWidget {
  final ObjectBox objectBox;

  HomeScreenWide({required this.objectBox});

  @override
  State<HomeScreenWide> createState() => _HomeScreenWideState();
}

class _HomeScreenWideState extends State<HomeScreenWide> {
  int _selectedIndex = 0;
  List<Widget> _widgetOptions() {
    return [
      Center(child: Text('Home Screen')),
      ProduitListScreen(),
      FournisseurListScreen(),
    ];
  }

  double prixMin = 50.0;
  double prixMax = 50.15;

  void _ouvrirDialogAjustementPrix(BuildContext context) {
    double nouveauPrixMin = prixMin;
    double nouveauPrixMax = prixMax;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Ajuster les prix'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                decoration: InputDecoration(labelText: 'Prix minimum'),
                keyboardType: TextInputType.number,
                onChanged: (value) =>
                    nouveauPrixMin = double.tryParse(value) ?? nouveauPrixMin,
              ),
              TextField(
                decoration: InputDecoration(labelText: 'Prix maximum'),
                keyboardType: TextInputType.number,
                onChanged: (value) =>
                    nouveauPrixMax = double.tryParse(value) ?? nouveauPrixMax,
              ),
            ],
          ),
          actions: [
            TextButton(
              child: Text('Annuler'),
              onPressed: () => Navigator.of(context).pop(),
            ),
            TextButton(
              child: Text('Valider'),
              onPressed: () {
                setState(() {
                  prixMin = nouveauPrixMin;
                  prixMax = nouveauPrixMax;
                });
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
    final randomId = Random().nextInt(100);
    return Scaffold(
      appBar: AppBar(
        title: Text('Facturation'),
        actions: [
          IconButton(
            onPressed: () {
              widget.objectBox.fillWithFakeData();
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Données factices ajoutées !')),
              );
            },
            icon: Icon(Icons.send),
          ),
        ],
      ),
      body: Consumer<CommerceProvider>(
        builder: (context, produitProvider, child) {
          int totalProduits = produitProvider.getTotalProduits();
          List<Produit> produitsFiltres =
              produitProvider.getProduitsBetweenPrices(prixMin, prixMax);
          var produitsLowStock = produitProvider.getProduitsLowStock(5);
          print(produitsLowStock.length);
          return Row(
            children: [
              NavigationRail(
                selectedIndex: _selectedIndex,
                onDestinationSelected: (int index) {
                  setState(() {
                    _selectedIndex = index;
                  });
                },
                labelType: NavigationRailLabelType.selected,
                destinations: [
                  NavigationRailDestination(
                    icon: Icon(Icons.home),
                    selectedIcon: Icon(Icons.home_filled),
                    label: Text('Home'),
                  ),
                  NavigationRailDestination(
                    icon: Icon(Icons.business),
                    selectedIcon: Icon(Icons.business_center),
                    label: Text('Produits'),
                  ),
                  NavigationRailDestination(
                    icon: Icon(Icons.factory),
                    selectedIcon: Icon(Icons.factory),
                    label: Text('Fournisseurs'),
                  ),
                ],
              ),
              Expanded(
                child: ListView(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(18.0),
                      child: Row(
                        children: [
                          // Expanded(
                          //     child: _buildTotalProductsCard(
                          //         context, produitProvider)),
                          Expanded(
                            child: GestureDetector(
                              onTap: () {
                                Navigator.of(context).push(
                                  MaterialPageRoute(
                                      builder: (context) =>
                                          FournisseurListScreen()),
                                );
                              },
                              child: CardTop(
                                image:
                                    'https://picsum.photos/seed/${randomId + 8}/200/100',
                                text:
                                    '${produitProvider.fournisseurs.length} Fournisseurs',
                                provider: produitProvider,
                                button: ElevatedButton(
                                  onPressed: () {
                                    Navigator.of(context).push(
                                      MaterialPageRoute(
                                          builder: (context) =>
                                              FournisseurListScreen()),
                                    );
                                  },
                                  child: Text('Voir plus'),
                                ),
                              ),
                            ),
                          ),
                          Expanded(
                            child: GestureDetector(
                              onTap: () {
                                Navigator.of(context).push(
                                  MaterialPageRoute(
                                      builder: (context) =>
                                          ProduitListScreen()),
                                );
                              },
                              child: CardTop(
                                image:
                                    'https://picsum.photos/seed/$randomId/200/100',
                                text:
                                    '${produitProvider.getTotalProduits()} Produits',
                                provider: produitProvider,
                                button: ElevatedButton(
                                  onPressed: () {
                                    Navigator.of(context).push(
                                      MaterialPageRoute(
                                          builder: (context) =>
                                              ProduitListScreen()),
                                    );
                                  },
                                  child: Text('Voir plus'),
                                ),
                              ),
                            ),
                          ),
                          Expanded(
                            child: GestureDetector(
                              onTap: () => _ouvrirDialogAjustementPrix(context),
                              child: CardTop(
                                  image:
                                      'https://picsum.photos/seed/${randomId + 1}/200/100',
                                  text:
                                      '${produitsFiltres.length} Produits\nentre ${prixMin.toStringAsFixed(2)} DZD et ${prixMax.toStringAsFixed(2)} DZD',
                                  provider: produitProvider,
                                  button: produitsFiltres.length == 0
                                      ? ElevatedButton(
                                          onPressed: null,
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: Colors.grey[
                                                300], // Couleur de fond grise
                                            foregroundColor: Colors.grey[
                                                600], // Couleur du texte grise
                                            disabledBackgroundColor: Colors
                                                    .grey[
                                                300], // Assure que la couleur reste grise même désactivé
                                            disabledForegroundColor: Colors
                                                    .grey[
                                                600], // Assure que la couleur du texte reste grise même désactivé
                                          ),
                                          child: Text(('Liste Vide')))
                                      : ElevatedButton.icon(
                                          onPressed: () {
                                            Navigator.of(context).push(
                                              MaterialPageRoute(
                                                  builder: (context) =>
                                                      ProduitListInterval(
                                                        produitsFiltres:
                                                            produitsFiltres,
                                                      )),
                                            );
                                          },
                                          label: Text(('Voire La List')))),
                            ),
                          ),
                          Expanded(
                            child: GestureDetector(
                              onTap: () {
                                Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (context) => LowStockList(
                                        produitsLowStock: produitsLowStock),
                                  ),
                                );
                              },
                              child: CardAlert(
                                image:
                                    'https://picsum.photos/seed/${randomId + 2}/200/100',
                                text: //'${produitsLowStock.length} Low Stock',
                                    'Alert stock < 5\n${produitsLowStock['count']}',
                                provider: produitProvider,
                                button: ElevatedButton(
                                    onPressed: () {
                                      Navigator.of(context).push(
                                        MaterialPageRoute(
                                          builder: (context) => LowStockList(
                                              produitsLowStock:
                                                  produitsLowStock),
                                          // ProduitListInterval(
                                          //   produitsFiltres:
                                          //       produitsFiltres,
                                          // ),
                                        ),
                                      );
                                    },
                                    child: Text(('Voire La List'))),
                                Color1: Colors.red,
                                Color2: Colors.black,
                              ),
                            ),
                          ),
                          // Expanded(
                          //     child: _buildPriceRangeProductsCard(
                          //         context, produitProvider)),
                        ],
                      ),
                    ),
                    SizedBox(height: 18),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        ElevatedButton.icon(
                            onPressed: () {
                              Navigator.of(context).push(MaterialPageRoute(
                                  builder: (_) => Add_Edit_ProduitScreen()));
                            },
                            label: Text('Ajouter Un Nouveau Produit'),
                            icon: Icon(Icons.add)),
                        ElevatedButton.icon(
                            onPressed: () {
                              showModalBottomSheet(
                                context: context,
                                isScrollControlled:
                                    true, // Permet de redimensionner en fonction de la hauteur du contenu
                                builder: (context) => AddFournisseurForm(),
                              );
                            },
                            label: Text('Ajouter Un Nouveau Fournisseur'),
                            icon: Icon(Icons.add)),
                      ],
                    ),
                    SizedBox(height: 18),
                    Container(
                      width: MediaQuery.of(context).size.width / 5,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red, // Couleur de fond grise
                          foregroundColor:
                              Colors.grey[300], // Couleur du texte grise
                          disabledBackgroundColor: Colors.grey[
                              300], // Assure que la couleur reste grise même désactivé
                          disabledForegroundColor: Colors.grey[
                              600], // Assure que la couleur du texte reste grise même désactivé
                        ),
                        child: Text('Delete all'),
                        onPressed: () {
                          widget.objectBox.deleteDatabase();

                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                                content:
                                    Text('Base de Données Vider avec succes!')),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: _widgetOptions()[_selectedIndex],
              ),
            ],
          );
        },
      ),
    );
  }
}

class ProduitListInterval extends StatelessWidget {
  const ProduitListInterval({
    super.key,
    required this.produitsFiltres,
  });

  final List<Produit> produitsFiltres;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: ListView.builder(
        itemCount: produitsFiltres.length,
        itemBuilder: (context, index) {
          final produit = produitsFiltres[index];
          return Padding(
            padding: const EdgeInsets.all(8.0),
            child: Card(
                child: ListTile(
              title: Text(
                produit.nom,
                style: TextStyle(fontWeight: FontWeight.bold),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              trailing: Text(
                'DZD ${produit.prixVente.toStringAsFixed(2)}',
                style: TextStyle(color: Colors.green, fontSize: 20),
              ),
              subtitle: Text('Stock: ${produit.stock}'),
            )),
          );
        },
      ),
    );
  }
}

class LowStockList extends StatelessWidget {
  const LowStockList({
    super.key,
    required this.produitsLowStock,
  });

  final Map<String, dynamic> produitsLowStock;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: ListView.builder(
        itemCount: (produitsLowStock['produits'] as List<Produit>)
            //.take(5)
            .length,
        itemBuilder: (context, index) {
          final produit = (produitsLowStock['produits'] as List<Produit>)
              //.take(5)
              .toList()[index];
          return ListTile(
            title: Text('${produit.nom}'),
            subtitle: Text('Stock : ${produit.stock}'),
          );
        },
      ),
    );
  }
}

class CardTop extends StatelessWidget {
  const CardTop({
    Key? key,
    this.text,
    required this.provider,
    required this.button,
    this.filtre,
    required this.image,
  }) : super(key: key);

  final String? text;
  final CommerceProvider provider;
  final ElevatedButton button;
  final bool? filtre;
  final image;

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      clipBehavior: Clip.antiAliasWithSaveLayer,
      elevation: 2,
      semanticContainer: true,
      color: Colors.white70,
      child: SizedBox(
        height: Platform.isWindows || Platform.isMacOS || Platform.isLinux
            ? MediaQuery.of(context).size.width * 0.15
            : MediaQuery.of(context).size.width * 0.55,
        width: MediaQuery.of(context).size.width * 0.30,
        child: Stack(
          fit: StackFit.passthrough,
          children: [
            ShaderMask(
              shaderCallback: (rect) {
                return const LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Colors.transparent, Colors.black],
                ).createShader(Rect.fromLTRB(0, 0, rect.width, rect.height));
              },
              blendMode: BlendMode.darken,
              child: CachedNetworkImage(
                width: 250,
                height: 150,
                fit: BoxFit.cover,
                imageUrl: image,
                // placeholder: (context, url) => Center(
                //   child: CircularProgressIndicator(),
                // ),
                errorWidget: (context, url, error) => const Icon(Icons.error),
              ),
            ),
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Center(
                  child: FittedBox(
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(
                        text!,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          shadows: [
                            Shadow(
                              blurRadius: 2.0,
                              color: Colors.black,
                              offset: Offset(0.5, 0.5),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                SizedBox(
                  height: 15,
                ),
                FittedBox(child: button),
              ],
            )
          ],
        ),
      ),
    );
  }
}

class CardAlert extends StatelessWidget {
  const CardAlert(
      {Key? key,
      this.text,
      required this.provider,
      required this.button,
      this.filtre,
      required this.image,
      required this.Color1,
      required this.Color2})
      : super(key: key);

  final String? text;
  final CommerceProvider provider;
  final ElevatedButton button;
  final bool? filtre;
  final image;
  final Color Color1;
  final Color Color2;

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      clipBehavior: Clip.antiAliasWithSaveLayer,
      elevation: 2,
      semanticContainer: true,
      color: Colors.white70,
      child: SizedBox(
        height: Platform.isWindows || Platform.isMacOS || Platform.isLinux
            ? MediaQuery.of(context).size.width * 0.15
            : MediaQuery.of(context).size.width * 0.55,
        width: MediaQuery.of(context).size.width * 0.30,
        child: Stack(
          fit: StackFit.passthrough,
          children: [
            Container(
              width: 300,
              height: 200,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(15.0),
              ),
              child: ShaderMask(
                shaderCallback: (rect) {
                  return LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [Color1, Color2],
                  ).createShader(Rect.fromLTRB(0, 0, rect.width, rect.height));
                },
                blendMode: BlendMode.srcATop,
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(15.0),
                  ),
                ),
              ),
            ),
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Center(
                  child: FittedBox(
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(
                        text!,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          shadows: [
                            Shadow(
                              blurRadius: 2.0,
                              color: Colors.black,
                              offset: Offset(0.5, 0.5),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                SizedBox(
                  height: 15,
                ),
                FittedBox(child: button),
              ],
            )
          ],
        ),
      ),
    );
  }
}

// Widget _buildTotalProductsCard(context, CommerceProvider provider) {
//   return GestureDetector(
//       onTap: () {
//         Navigator.of(context).push(
//           MaterialPageRoute(builder: (context) => ProduitListScreen()),
//         );
//       },
//       child:
//       // Card(
//       //   child: Padding(
//       //     padding: EdgeInsets.all(16.0),
//       //     // child: Column(
//       //     //   crossAxisAlignment: CrossAxisAlignment.start,
//       //     //   children: [
//       //     //     Text('Total des produits ${provider.getTotalProduits()}',
//       //     //         style: TextStyle(
//       //     //           fontSize: 18,
//       //     //         )),
//       //     //     SizedBox(height: 8),
//       //     //     Text('${provider.getTotalProduits()}',
//       //     //         style: TextStyle(fontSize: 24)),
//       //     //     ElevatedButton(
//       //     //       onPressed: () {
//       //     //         Navigator.of(context).push(
//       //     //           MaterialPageRoute(builder: (context) => ProduitListScreen()),
//       //     //         );
//       //     //       },
//       //     //       child: Text('Voire La List'),
//       //     //     )
//       //     //   ],
//       //     // ),
//       //     child: Text('Total des produits ${provider.getTotalProduits()}',
//       //         style: TextStyle(
//       //           fontSize: 18,
//       //         )),
//       //   ),
//       // ),
//       GestureDetector(
//           onTap: () {
//             Navigator.of(context).push(
//               MaterialPageRoute(builder: (context) => ProduitListScreen()),
//             );
//           },
//           child: Card(
//             shape: RoundedRectangleBorder(
//               borderRadius: BorderRadius.circular(16.0),
//             ),
//             elevation: 4.0,
//             shadowColor: Colors.grey.withOpacity(0.5),
//             clipBehavior: Clip.antiAlias,
//             child: Container(
//               width: 300,
//               height: 200,
//               child: Stack(
//                 alignment: Alignment.center,
//                 children: [
//                   // Image de fond
//                   Image.network(
//                     'https://picsum.photos/300/200',
//                     width: 300,
//                     height: 200,
//                     fit: BoxFit.cover,
//                   ),
//                   // Dégradé
//                   Positioned.fill(
//                     child: Container(
//                       decoration: BoxDecoration(
//                         gradient: LinearGradient(
//                           begin: Alignment.topCenter,
//                           end: Alignment.bottomCenter,
//                           colors: [
//                             Colors.transparent,
//                             Colors.black.withOpacity(0.7),
//                           ],
//                         ),
//                       ),
//                     ),
//                   ),
//                   // Texte avec padding
//                   Padding(
//                     padding: const EdgeInsets.all(16.0),
//                     child: Align(
//                       alignment: Alignment.bottomCenter,
//                       child: Text(
//                         'Total des produits ${provider.getTotalProduits()}',
//                         style: TextStyle(
//                           color: Colors.cyanAccent,
//                           fontSize: 18,
//                           fontWeight: FontWeight.bold,
//                           shadows: [
//                             Shadow(
//                               blurRadius: 2.0,
//                               color: Colors.black,
//                               offset: Offset(0.5, 0.5),
//                             ),
//                           ],
//                         ),
//                       ),
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//           )));
// }
//
// Widget _buildPriceRangeProductsCard(context, CommerceProvider provider) {
//   List<Produit> produitsFiltres =
//   provider.getProduitsBetweenPrices(50.0, 50.15);
//   return Card(
//     child: Padding(
//       padding: EdgeInsets.all(16.0),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Text('Produits entre 50€ et 50.15€',
//               style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
//           SizedBox(height: 8),
//           Text('${produitsFiltres.length}', style: TextStyle(fontSize: 24)),
//           //SizedBox(height: 8),
//           // Text('Liste des produits :',
//           //     style: TextStyle(fontWeight: FontWeight.bold)),
//           // SizedBox(height: 8),
//           // ProduitListInterval(produitsFiltres: produitsFiltres),
//           ElevatedButton(
//               onPressed: () {
//                 Navigator.of(context).push(
//                   MaterialPageRoute(
//                       builder: (context) => ProduitListInterval(
//                         produitsFiltres: produitsFiltres,
//                       )),
//                 );
//               },
//               child: Text(('Voire La List')))
//         ],
//       ),
//     ),
//   );
// }
// Widget _buildLowStockProductsCard(CommerceProvider provider) {
//   var produitsLowStock = provider.getProduitsLowStock(5);
//   return Card(
//     child: Padding(
//       padding: EdgeInsets.all(16.0),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Text('Produits avec stock faible (< 5)',
//               style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
//           SizedBox(height: 8),
//           Text('${produitsLowStock['count']}', style: TextStyle(fontSize: 24)),
//           SizedBox(height: 8),
//           Text('Liste des produits :',
//               style: TextStyle(fontWeight: FontWeight.bold)),
//           // LowStockList(produitsLowStock: produitsLowStock),
//           // if ((produitsLowStock['produits'] as List<Produit>).length > 5)
//           //   Text(
//           //       '... et ${(produitsLowStock['produits'] as List<Produit>).length - 5} de plus'),
//         ],
//       ),
//     ),
//   );
// }
