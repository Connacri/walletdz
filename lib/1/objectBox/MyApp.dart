import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:percent_indicator/linear_percent_indicator.dart';
import 'package:provider/provider.dart';
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

class HomeScreen extends StatelessWidget {
  final ObjectBox objectBox;

  HomeScreen({required this.objectBox});

  // void checkDiskSpace() {
  //   var directory = Directory.current;
  //   var stat = directory.statSync();
  //   var availableSpace = stat..freeSpace;
  //   print('Available space: $availableSpace bytes');
  // }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Facturation'),
        actions: [
          // IconButton(
          //     onPressed: () async {
          //   checkDiskSpace;
          //
          // },
          // icon : Icon(Icons.dis),
          // ),
          IconButton(
            onPressed: () async {
              objectBox.fillWithFakeData();
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
        print('Nombre total de produits : $totalProduits');
        return ListView(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Card(
                  child: InkWell(
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                            builder: (context) => ProduitListScreenTest()),
                      );
                    },
                    child: Container(
                        height: 100,
                        width: MediaQuery.of(context).size.width / 2.5,
                        child: Center(
                          child: Text(
                              '${produitProvider.produitsP.length} Produits'),
                        )),
                  ),
                ),
                Card(
                  child: InkWell(
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                            builder: (context) => FournisseurListScreen()),
                      );
                    },
                    child: Container(
                        height: 100,
                        width: MediaQuery.of(context).size.width / 2.5,
                        child: Center(
                          child: Text(
                              '${produitProvider.fournisseurs.length}\nFournisseurs'),
                        )),
                  ),
                ),
              ],
            ),
            Card(
              child: ListTile(
                title: Text('${totalProduits}\nProduits'),
                //Text('${produitProvider.produitsP.length}\nProduits'),
                onTap: () {
                  Navigator.of(context).push(MaterialPageRoute(
                      builder: (context) => ProduitListScreen()));
                },
              ),
            ),
            Card(
              child: ListTile(
                title:
                    Text('${produitProvider.fournisseurs.length} Fournisseurs'),
                onTap: () {
                  Navigator.of(context).push(MaterialPageRoute(
                      builder: (context) => FournisseurListScreen()));
                },
              ),
            ),
            Card(
                // child: ListTile(
                //   title: Text('Clients'),
                //   onTap: () {
                //     Navigator.push(
                //         context,
                //         MaterialPageRoute(
                //             builder: (context) => ClientListScreen()));
                //   },
                // ),
                ),
            Card(
                // child: ListTile(
                //   title: Text('Factures'),
                //   onTap: () {
                //     Navigator.push(
                //         context,
                //         MaterialPageRoute(
                //             builder: (context) => FactureListScreen()));
                //   },
                // ),
                ),
            SizedBox(
              height: 30,
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 30),
              child: ElevatedButton(
                child: Text('Delete all'),
                onPressed: () {
                  objectBox.deleteDatabase();

                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                        content: Text('Base de Données Vider avec succes!')),
                  );
                },
                style: ButtonStyle(
                  backgroundColor: WidgetStateProperty.all<Color>(Colors.red),
                ),
              ),
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

  @override
  Widget build(BuildContext context) {
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
          print('Nombre total de produits : $totalProduits');
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
                    label: Text('Business'),
                  ),
                  NavigationRailDestination(
                    icon: Icon(Icons.school),
                    selectedIcon: Icon(Icons.school),
                    label: Text('School'),
                  ),
                ],
              ),
              VerticalDivider(thickness: 1, width: 1),
              Expanded(
                child: ListView(
                  children: [
                    Row(
                      children: [
                        // Expanded(
                        //     child: _buildTotalProductsCard(
                        //         context, produitProvider)),
                        CardTop(
                          provider: produitProvider,
                        ),
                        Expanded(
                            child: _buildPriceRangeProductsCard(
                                context, produitProvider)),
                      ],
                    ),
                    SizedBox(height: 16),
                    _buildLowStockProductsCard(produitProvider),
                    Center(
                      child: Text(_selectedIndex.toString()),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Card(
                          child: InkWell(
                            onTap: () {
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                    builder: (context) => ProduitListScreen()),
                              );
                            },
                            child: Container(
                                height: 100,
                                width: 200,
                                child: Center(
                                  child: Text('${totalProduits}\nProduits'
                                      //'${produitProvider.produitsP.length}\nProduits'
                                      ),
                                )),
                          ),
                        ),
                        Card(
                          child: InkWell(
                            onTap: () {
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                    builder: (context) =>
                                        FournisseurListScreen()),
                              );
                            },
                            child: Container(
                                height: 100,
                                width: 200,
                                child: Center(
                                  child: Text(
                                      '${produitProvider.fournisseurs.length}\nFournisseurs'),
                                )),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 30),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 30),
                      child: ElevatedButton(
                        child: Text('Delete all'),
                        onPressed: () {
                          widget.objectBox.deleteDatabase();

                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                                content:
                                    Text('Base de Données Vider avec succes!')),
                          );
                        },
                        style: ElevatedButton.styleFrom(),
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

Widget _buildTotalProductsCard(context, CommerceProvider provider) {
  return GestureDetector(
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(builder: (context) => ProduitListScreen()),
        );
      },
      child:
          // Card(
          //   child: Padding(
          //     padding: EdgeInsets.all(16.0),
          //     // child: Column(
          //     //   crossAxisAlignment: CrossAxisAlignment.start,
          //     //   children: [
          //     //     Text('Total des produits ${provider.getTotalProduits()}',
          //     //         style: TextStyle(
          //     //           fontSize: 18,
          //     //         )),
          //     //     SizedBox(height: 8),
          //     //     Text('${provider.getTotalProduits()}',
          //     //         style: TextStyle(fontSize: 24)),
          //     //     ElevatedButton(
          //     //       onPressed: () {
          //     //         Navigator.of(context).push(
          //     //           MaterialPageRoute(builder: (context) => ProduitListScreen()),
          //     //         );
          //     //       },
          //     //       child: Text('Voire La List'),
          //     //     )
          //     //   ],
          //     // ),
          //     child: Text('Total des produits ${provider.getTotalProduits()}',
          //         style: TextStyle(
          //           fontSize: 18,
          //         )),
          //   ),
          // ),
          GestureDetector(
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (context) => ProduitListScreen()),
                );
              },
              child: Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16.0),
                ),
                elevation: 4.0,
                shadowColor: Colors.grey.withOpacity(0.5),
                clipBehavior: Clip.antiAlias,
                child: Container(
                  width: 300,
                  height: 200,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      // Image de fond
                      Image.network(
                        'https://picsum.photos/300/200',
                        width: 300,
                        height: 200,
                        fit: BoxFit.cover,
                      ),
                      // Dégradé
                      Positioned.fill(
                        child: Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [
                                Colors.transparent,
                                Colors.black.withOpacity(0.7),
                              ],
                            ),
                          ),
                        ),
                      ),
                      // Texte avec padding
                      Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Align(
                          alignment: Alignment.bottomCenter,
                          child: Text(
                            'Total des produits ${provider.getTotalProduits()}',
                            style: TextStyle(
                              color: Colors.cyanAccent,
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
                    ],
                  ),
                ),
              )));
}

Widget _buildPriceRangeProductsCard(context, CommerceProvider provider) {
  List<Produit> produitsFiltres =
      provider.getProduitsBetweenPrices(50.0, 50.15);
  return Card(
    child: Padding(
      padding: EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Produits entre 50€ et 50.15€',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          SizedBox(height: 8),
          Text('${produitsFiltres.length}', style: TextStyle(fontSize: 24)),
          //SizedBox(height: 8),
          // Text('Liste des produits :',
          //     style: TextStyle(fontWeight: FontWeight.bold)),
          // SizedBox(height: 8),
          // ProduitListInterval(produitsFiltres: produitsFiltres),
          ElevatedButton(
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                      builder: (context) => ProduitListInterval(
                            produitsFiltres: produitsFiltres,
                          )),
                );
              },
              child: Text(('Voire La List')))
        ],
      ),
    ),
  );
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

Widget _buildLowStockProductsCard(CommerceProvider provider) {
  var produitsLowStock = provider.getProduitsLowStock();
  return Card(
    child: Padding(
      padding: EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Produits avec stock faible (< 5)',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          SizedBox(height: 8),
          Text('${produitsLowStock['count']}', style: TextStyle(fontSize: 24)),
          SizedBox(height: 8),
          Text('Liste des produits :',
              style: TextStyle(fontWeight: FontWeight.bold)),
          Container(
            height: 150,
            child: ListView.builder(
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
          ),
          // if ((produitsLowStock['produits'] as List<Produit>).length > 5)
          //   Text(
          //       '... et ${(produitsLowStock['produits'] as List<Produit>).length - 5} de plus'),
        ],
      ),
    ),
  );
}

class CardTop extends StatelessWidget {
  const CardTop({Key? key, required this.provider}) : super(key: key);
  final CommerceProvider provider;

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(6),
      ),
      clipBehavior: Clip.antiAliasWithSaveLayer,
      elevation: 2,
      semanticContainer: true,
      color: Colors.white70,
      child: GestureDetector(
        onTap: () {
          Navigator.of(context).push(
            MaterialPageRoute(builder: (context) => ProduitListScreen()),
          );
        },
        child: SizedBox(
          height: MediaQuery.of(context).size.width * 0.15,
          width: MediaQuery.of(context).size.width * 0.30,
          child: Stack(
            fit: StackFit.expand,
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
                  width: 300,
                  height: 200,
                  fit: BoxFit.cover,
                  imageUrl: 'https://picsum.photos/300/200',
                  placeholder: (context, url) => Center(
                    child: CircularProgressIndicator(),
                  ),
                  errorWidget: (context, url, error) => const Icon(Icons.error),
                ),
              ),
              Text(
                'Total des produits ${provider.getTotalProduits()}',
                style: TextStyle(
                  color: Colors.cyanAccent,
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
              ), // image
            ],
          ),
        ),
      ),
    );
  }
}
