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
                    // Card(
                    //   child: ListTile(
                    //     title:
                    //         Text('${produitProvider.produits.length} Produits'),
                    //     onTap: () {
                    //       Navigator.of(context).push(
                    //         MaterialPageRoute(
                    //             builder: (context) => ProduitListScreen()),
                    //       );
                    //     },
                    //   ),
                    // ),
                    // Card(
                    //   child: ListTile(
                    //     title: Text(
                    //         '${produitProvider.fournisseurs.length}  Fournisseurs'),
                    //     onTap: () {
                    //       Navigator.of(context).push(
                    //         MaterialPageRoute(
                    //             builder: (context) => FournisseurListScreen()),
                    //       );
                    //     },
                    //   ),
                    // ),
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
