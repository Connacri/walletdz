import 'dart:math';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../objectBox/pages/ClientListScreen.dart';
import '../objectBox/pages/FactureListScreen.dart';
import '../../MyListLotties.dart';
import 'Entity.dart';
import 'MyProviders.dart';
import 'classeObjectBox.dart';
import 'hash.dart';
import 'pages/FournisseurListScreen.dart';
import 'package:flutter/foundation.dart';
import 'dart:io' show Platform;
import 'dart:io';
import 'package:faker/faker.dart' as Faker;

import 'pages/ProduitListScreen.dart';
import 'pages/ProduitListSupabase.dart' as supa;
import 'pages/add_Produit.dart'; // Importez le package path_provider

class MyMain extends StatelessWidget {
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
          create: (_) => CartProvider(objectBox),
        ),
        ChangeNotifierProvider(
          create: (_) => ClientProvider(objectBox),
        ),
      ],
      child: MaterialApp(
        title: 'POS',
        theme: ThemeData(
          fontFamily: 'oswald',
          brightness: Brightness.light,
          primarySwatch: Colors.blue,
          chipTheme: ChipThemeData(
            backgroundColor: Colors.grey[300]!,
            labelStyle: TextStyle(color: Colors.black),
          ),
        ),
        darkTheme: ThemeData(
          fontFamily: 'oswald',
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
    } else if (Platform.isIOS || Platform.isAndroid) {
      return HomeScreen(objectBox: objectBox);
    } else {
      return HomeScreenWide(objectBox: objectBox);
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
  double prixMin = 0;
  double prixMax = 0;
  final TextEditingController _productController = TextEditingController();
  final TextEditingController _supplierController = TextEditingController();
  final TextEditingController _clientController = TextEditingController();
  int lengthPin = 10;

  @override
  void initState() {
    super.initState();
    _loadPrix();
  }

  Future<void> _savePrix() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble('prixMin', prixMin);
    await prefs.setDouble('prixMax', prixMax);
  }

  Future<void> _loadPrix() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      prixMin = prefs.getDouble('prixMin') ?? 0.0;
      prixMax = prefs.getDouble('prixMax') ?? 0.0;
    });
  }

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
                _savePrix(); // Sauvegarder les nouvelles valeurs
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  void _showDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Définir les données factices'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: _productController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(labelText: 'Nombre de produits'),
              ),
              TextField(
                controller: _supplierController,
                keyboardType: TextInputType.number,
                decoration:
                    InputDecoration(labelText: 'Nombre de fournisseurs'),
              ),
              TextField(
                controller: _clientController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(labelText: 'Nombre de clients'),
              ),
            ],
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
                final int products = int.tryParse(_productController.text) ?? 0;
                final int suppliers =
                    int.tryParse(_supplierController.text) ?? 0;
                final int clients = int.tryParse(_clientController.text) ?? 0;

                widget.objectBox
                    .fillWithFakeData(20, clients, suppliers, products);
                // ScaffoldMessenger.of(context).showSnackBar(
                //   SnackBar(content: Text('Données factices ajoutées !')),
                // );

                Navigator.of(context).pop();
              },
              child: Text('OK'),
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
        title: Text('POS'),
        actions: [
          Platform.isAndroid || Platform.isIOS
              ? IconButton(
                  onPressed: () {
                    Navigator.of(context).push(MaterialPageRoute(
                        builder: (ctx) => HashAdmin(
                              lengthPin: lengthPin,
                            )));
                  },
                  icon: Icon(Icons.add_chart_rounded),
                )
              : Container(),
          // IconButton(
          //         onPressed: () {
          //           Navigator.of(context)
          //               .push(MaterialPageRoute(builder: (ctx) => hashPage()));
          //         },
          //         icon: Icon(Icons.add_chart_rounded),
          //       ),
          IconButton(
            onPressed: () {
              Navigator.of(context)
                  .push(MaterialPageRoute(builder: (ctx) => LicensePage()));
            },
            icon: Icon(Icons.account_tree_rounded),
          ),
          // IconButton(
          //   onPressed: () {
          //     Navigator.of(context).push(
          //         MaterialPageRoute(builder: (ctx) => FacturesListPage()));
          //   },
          //   icon: Icon(Icons.hail_outlined),
          // ),
          // IconButton(
          //   onPressed: () {
          //     Navigator.of(context)
          //         .push(MaterialPageRoute(builder: (ctx) => FacturePage()));
          //   },
          //   icon: Icon(Icons.invert_colors_off),
          // ),
          // SizedBox(
          //   width: 50,
          // ),
          IconButton(
            onPressed: () {
              Navigator.of(context).push(MaterialPageRoute(
                  builder: (ctx) => supa.ProduitListPage(
                      supabase: Supabase.instance.client,
                      objectboxStore: widget.objectBox.store)));
            },
            icon: Icon(Icons.local_police),
          ),
          IconButton(
            onPressed: () {
              // widget.objectBox.fillWithFakeData(1000, 500);
              // ScaffoldMessenger.of(context).showSnackBar(
              //   SnackBar(content: Text('Données factices ajoutées !')),
              // );
              _showDialog();
            },
            icon: Icon(Icons.send),
          ),
          IconButton(
            onPressed: () {
              Navigator.of(context)
                  .push(MaterialPageRoute(builder: (ctx) => LottieListPage()));
            },
            icon: Icon(Icons.local_bar_outlined),
          ),
        ],
      ),
      body: Consumer<CommerceProvider>(
          builder: (context, produitProvider, child) {
        int totalProduits = produitProvider.getTotalProduits();
        List<Produit> produitsFiltres =
            produitProvider.getProduitsBetweenPrices(prixMin, prixMax);
        var produitsLowStock = produitProvider.getProduitsLowStock(5.0);
        var produitsLowStock0 = produitProvider.getProduitsLowStock(0.0);
        return Padding(
            padding: const EdgeInsets.all(5.0),
            child: ListView(
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
                    SmallBanner: true,
                  ),
                ),
                Container(
                  width: MediaQuery.of(context).size.width,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      ElevatedButton.icon(
                          onPressed: () {
                            Navigator.of(context).push(MaterialPageRoute(
                                builder: (_) => FacturePage()));
                          },
                          label: Text('Facture Page'),
                          icon: Icon(Icons.monetization_on_sharp)),
                      ElevatedButton.icon(
                          onPressed: () {
                            Navigator.of(context).push(MaterialPageRoute(
                                builder: (_) => FacturesListPage()));
                          },
                          label: Text('Facture List'),
                          icon: Icon(Icons.list_alt)),
                    ],
                  ),
                ),
                ElevatedButton.icon(
                    onPressed: () {
                      Navigator.of(context).push(MaterialPageRoute(
                          builder: (_) => ClientListScreen()));
                    },
                    label: Text('Client List'),
                    icon: Icon(Icons.account_circle)),
                GestureDetector(
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                          builder: (context) => ClientListScreen()),
                    );
                  },
                  child: CardTop(
                    image: 'https://picsum.photos/seed/${randomId + 2}/200/100',
                    text: '${produitProvider.getTotalClientsCount()} Clients',
                    provider: produitProvider,
                    // button: ElevatedButton(
                    //   onPressed: () {
                    //     Navigator.of(context).push(
                    //       MaterialPageRoute(
                    //           builder: (context) => ProduitListScreen()),
                    //     );
                    //   },
                    //   child: Text('Voir plus'),
                    // ),
                    SmallBanner: false,
                  ),
                ),
                GestureDetector(
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                          builder: (context) => ProduitListScreen()),
                    );
                  },
                  child: CardTop(
                    image: 'https://picsum.photos/seed/$randomId/200/100',
                    text: '${produitProvider.getTotalProduits()} Produits',
                    provider: produitProvider,
                    // button: ElevatedButton(
                    //   onPressed: () {
                    //     Navigator.of(context).push(
                    //       MaterialPageRoute(
                    //           builder: (context) => ProduitListScreen()),
                    //     );
                    //   },
                    //   child: Text('Voir plus'),
                    // ),
                    SmallBanner: false,
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
                            label: Text(('Voire La List'))),
                    SmallBanner: false,
                  ),
                ),
                CardAlert(
                  image: 'https://picsum.photos/seed/${randomId + 3}/200/100',
                  text:
                      'Alert stock < 5\n${produitsLowStock['count']} Produits\n\nRupture de stock\n${produitsLowStock0['count']} Produits',
                  provider: produitProvider,
                  button: produitsLowStock['count'] == 0 &&
                          produitsLowStock0['count'] == 0
                      ? null
                      : ElevatedButton(
                          onPressed: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (context) => LowStockList(
                                    produitsLowStock: produitsLowStock),
                                // ProduitListInterval(
                                //   produitsFiltres:
                                //       produitsFiltres,
                                // ),
                              ),
                            );
                          },
                          child: Text(('Voire La List'))),
                  Color1: Colors.red.shade100,
                  Color2: Colors.black,
                ),
                SizedBox(height: 18),
                ElevatedButton.icon(
                    onPressed: () {
                      Navigator.of(context).push(
                          MaterialPageRoute(builder: (_) => add_Produit()));
                    },
                    label: Text('Ajouter  Produit'),
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
                    label: Text('Ajouter Fournisseur'),
                    icon: Icon(Icons.send)),
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
                      SnackBar(
                          content: Text('Base de Données Vider avec succes!')),
                    );
                  },
                ),
              ],
            ));
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
  final TextEditingController _productController = TextEditingController();
  final TextEditingController _supplierController = TextEditingController();
  final TextEditingController _clientController = TextEditingController();

  List<Widget> _widgetOptions() {
    return [
      homeRail(),
      FacturesListPage(),
      FournisseurListScreen(),
    ];
  }

  double prixMin = 0;
  double prixMax = 0;

  @override
  void initState() {
    super.initState();
    _loadPrix();
  }

  Future<void> _savePrix() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble('prixMin', prixMin);
    await prefs.setDouble('prixMax', prixMax);
  }

  Future<void> _loadPrix() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      prixMin = prefs.getDouble('prixMin') ?? 0.0;
      prixMax = prefs.getDouble('prixMax') ?? 0.0;
    });
  }

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
                _savePrix(); // Sauvegarder les nouvelles valeurs
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  void _showDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Définir les données factices'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: _productController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(labelText: 'Nombre de produits'),
              ),
              TextField(
                controller: _supplierController,
                keyboardType: TextInputType.number,
                decoration:
                    InputDecoration(labelText: 'Nombre de fournisseurs'),
              ),
              TextField(
                controller: _clientController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(labelText: 'Nombre de clients'),
              ),
            ],
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
                final int products = int.tryParse(_productController.text) ?? 0;
                final int suppliers =
                    int.tryParse(_supplierController.text) ?? 0;
                final int clients = int.tryParse(_clientController.text) ?? 0;

                widget.objectBox
                    .fillWithFakeData(20, clients, suppliers, products);
                // ScaffoldMessenger.of(context).showSnackBar(
                //   SnackBar(content: Text('Données factices ajoutées !')),
                // );

                Navigator.of(context).pop();
              },
              child: Text('OK'),
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
          // ElevatedButton(
          //   onPressed: () {
          //     // Appelez la méthode ici sans essayer d'utiliser sa valeur de retour
          //     widget.objectBox.ajouterQuantitesAleatoires();
          //   },
          //   child: Text('Ajouter Quantités Aléatoires'),
          // ),
          // ElevatedButton(
          //   onPressed: () async {
          //     String filePath =
          //         "C:/Users/INDRA/Documents/Articles.xls"; // Assurez-vous de mettre le bon chemin ici.
          //     await widget.objectBox
          //         .importProduitsDepuisExcel(filePath, 20, 3000, 500);
          //
          //     print("Produits importés avec succès !");
          //   },
          //   child: Text("Importer Produits"),
          // ),
          IconButton(
            onPressed: () {
              Navigator.of(context)
                  .push(MaterialPageRoute(builder: (ctx) => hashPage()));
            },
            icon: Icon(Icons.add_chart_rounded),
          ),
          IconButton(
            onPressed: () {
              Navigator.of(context)
                  .push(MaterialPageRoute(builder: (ctx) => LicensePage()));
            },
            icon: Icon(Icons.account_tree_rounded),
          ),
          IconButton(
            onPressed: () {
              Navigator.of(context).push(
                  MaterialPageRoute(builder: (ctx) => FacturesListPage()));
            },
            icon: Icon(Icons.hail_outlined),
          ),
          IconButton(
            onPressed: () {
              Navigator.of(context)
                  .push(MaterialPageRoute(builder: (ctx) => FacturePage()));
            },
            icon: Icon(Icons.invert_colors_off),
          ),
          SizedBox(
            width: 50,
          ),
          IconButton(
            onPressed: () {
              Navigator.of(context).push(MaterialPageRoute(
                  builder: (ctx) => supa.ProduitListPage(
                      supabase: Supabase.instance.client,
                      objectboxStore: widget.objectBox.store)));
            },
            icon: Icon(Icons.local_police),
          ),
          IconButton(
            onPressed: () {
              // widget.objectBox.fillWithFakeData(1000, 500);
              // ScaffoldMessenger.of(context).showSnackBar(
              //   SnackBar(content: Text('Données factices ajoutées !')),
              // );
              _showDialog();
            },
            icon: Icon(Icons.send),
          ),
          IconButton(
            onPressed: () {
              Navigator.of(context)
                  .push(MaterialPageRoute(builder: (ctx) => LottieListPage()));
            },
            icon: Icon(Icons.local_bar_outlined),
          ),
          SizedBox(
            width: 50,
          )
        ],
      ),
      body: Consumer<CommerceProvider>(
        builder: (context, produitProvider, child) {
          int totalProduits = produitProvider.getTotalProduits();
          List<Produit> produitsFiltres =
              produitProvider.getProduitsBetweenPrices(prixMin, prixMax);
          var produitsLowStock = produitProvider.getProduitsLowStock(5.0);
          var produitsLowStock0 = produitProvider.getProduitsLowStock(0.0);

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
                    icon: Icon(Icons.shopping_basket),
                    selectedIcon: Icon(Icons.shopping_cart),
                    label: Text('Caisse'),
                  ),
                  NavigationRailDestination(
                    icon: Icon(Icons.account_box),
                    selectedIcon: Icon(Icons.account_circle_sharp),
                    label: Text('Clients'),
                  ),
                ],
              ),
              _selectedIndex == 0
                  ? buildExpanded(context, randomId, produitProvider,
                      produitsFiltres, produitsLowStock, produitsLowStock0)
                  : _selectedIndex == 1
                      ? Expanded(flex: 2, child: FacturePage())
                      : Expanded(flex: 1, child: ClientListScreen()),
              Expanded(
                flex: 1,
                child: _widgetOptions()[_selectedIndex],
              ),
            ],
          );
        },
      ),
    );
  }

  Expanded buildExpanded(
      BuildContext context,
      int randomId,
      CommerceProvider produitProvider,
      List<Produit> produitsFiltres,
      Map<String, dynamic> produitsLowStock,
      Map<String, dynamic> produitsLowStock0) {
    return Expanded(
      flex: 1,
      child: ListView(
        children: [
          Padding(
            padding: const EdgeInsets.all(18.0),
            child: Row(
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                            builder: (context) => FournisseurListScreen()),
                      );
                    },
                    child: CardTop(
                      image:
                          'https://picsum.photos/seed/${randomId + 8}/200/100',
                      text:
                          '${produitProvider.fournisseurs.length} Fournisseurs',
                      provider: produitProvider,
                      // button: ElevatedButton(
                      //   onPressed: () {
                      //     Navigator.of(context).push(
                      //       MaterialPageRoute(
                      //           builder: (context) =>
                      //               FournisseurListScreen()),
                      //     );
                      //   },
                      //   child: Text('Voir plus'),
                      // ),
                      SmallBanner: true,
                    ),
                  ),
                ),
                Expanded(
                  child: GestureDetector(
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                            builder: (context) => ProduitListScreen()),
                      );
                    },
                    child: CardTop(
                      image: 'https://picsum.photos/seed/$randomId/200/100',
                      text: '${produitProvider.getTotalProduits()} Produits',
                      provider: produitProvider,
                      // button: ElevatedButton(
                      //   onPressed: () {
                      //     Navigator.of(context).push(
                      //       MaterialPageRoute(
                      //           builder: (context) =>
                      //               ProduitListScreen()),
                      //     );
                      //   },
                      //   child: Text('Voir plus'),
                      // ),
                      SmallBanner: false,
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
                          '${produitsFiltres.length} Produits\n${prixMin.toStringAsFixed(2)}\n${prixMax.toStringAsFixed(2)}',
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
                              label: Text(('Voire La List'))),
                      SmallBanner: false,
                    ),
                  ),
                ),
                Expanded(
                  child: CardAlert(
                    image: 'https://picsum.photos/seed/${randomId + 2}/200/100',
                    text:
                        'Alert stock < 5\n${produitsLowStock['count']} Produits\n\nRupture de stock\n${produitsLowStock0['count']} Produits',
                    provider: produitProvider,
                    button: produitsLowStock['count'] == 0 &&
                            produitsLowStock0['count'] == 0
                        ? null
                        : ElevatedButton(
                            onPressed: () {
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (context) => LowStockList(
                                      produitsLowStock: produitsLowStock),
                                  // ProduitListInterval(
                                  //   produitsFiltres:
                                  //       produitsFiltres,
                                  // ),
                                ),
                              );
                            },
                            child: Text(('Voire La List'))),
                    Color1: Colors.red[500]!,
                    Color2: Colors.black,
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
                    showModalBottomSheet(
                      context: context,
                      isScrollControlled:
                          true, // Permet de redimensionner en fonction de la hauteur du contenu
                      builder: (context) => AddFournisseurForm(),
                    );
                  },
                  label: Text('Ajouter Un Fournisseur'),
                  icon: Icon(Icons.add)),
              SizedBox(width: 18),
              ElevatedButton.icon(
                onPressed: () {
                  Navigator.of(context)
                      .push(MaterialPageRoute(builder: (ctx) => add_Produit()));
                },
                label: Text('Ajouter Produit'),
                icon: Icon(Icons.safety_check_rounded),
              ),
            ],
          ),
          SizedBox(height: 18),
          Container(
            width: MediaQuery.of(context).size.width / 5,
            child: ElevatedButton(
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
          ),
          SizedBox(height: 18),
          ElevatedButton.icon(
              onPressed: () {
                Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => ClientListScreen()));
              },
              label: Text('Client List'),
              icon: Icon(Icons.account_circle)),
          SizedBox(height: 18),
          GestureDetector(
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (context) => ClientListScreen()),
              );
            },
            child: CardTop(
              image: 'https://picsum.photos/seed/${randomId + 2}/200/100',
              text: '${produitProvider.clients.length} Clients',
              provider: produitProvider,
              // button: ElevatedButton(
              //   onPressed: () {
              //     Navigator.of(context).push(
              //       MaterialPageRoute(
              //           builder: (context) => ProduitListScreen()),
              //     );
              //   },
              //   child: Text('Voir plus'),
              // ),
              SmallBanner: false,
            ),
          ),
          SizedBox(height: 18),
        ],
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
          return Card(
            child: ListTile(
              title: Text('${produit.nom}'),
              subtitle: Text('${produit.stockinit}'),
              trailing: Text('Stock : ${produit.stock}'),
            ),
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
    this.button,
    this.filtre,
    required this.image,
    required this.SmallBanner,
  }) : super(key: key);

  final String? text;
  final CommerceProvider provider;
  final ElevatedButton? button;
  final bool? filtre;
  final image;
  final bool SmallBanner;

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
            : SmallBanner
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
                placeholder: (context, url) => Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [Colors.blue, Colors.black],
                    ),
                  ),
                ),
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
                button != null
                    ? SizedBox(
                        height: 15,
                      )
                    : Container(),
                button != null ? FittedBox(child: button) : Container(),
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
      this.button,
      this.filtre,
      required this.image,
      required this.Color1,
      required this.Color2})
      : super(key: key);

  final String? text;
  final CommerceProvider provider;
  final ElevatedButton? button;
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
            : MediaQuery.of(context).size.height * 0.35,
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
                      padding: const EdgeInsets.all(18.0),
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
                button != null ? FittedBox(child: button) : Container(),
              ],
            )
          ],
        ),
      ),
    );
  }
}

class homeRail extends StatefulWidget {
  const homeRail({super.key});

  @override
  State<homeRail> createState() => _homeRailState();
}

class _homeRailState extends State<homeRail> {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          IconButton(
            onPressed: () {
              Navigator.of(context)
                  .push(MaterialPageRoute(builder: (ctx) => add_Produit()));
            },
            icon: Icon(Icons.add),
          ),
          // IconButton(
          //   onPressed: () {
          //     Navigator.of(context)
          //         .push(MaterialPageRoute(builder: (ctx) => edit_Product()));
          //   },
          //   icon: Icon(Icons.edit),
          // ),
        ],
      ),
    );
  }
}
