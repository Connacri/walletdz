import 'dart:math';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:lottie/lottie.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:walletdz/objectBox/pages/addProduct.dart';
import 'package:walletdz/objectBox/pages/addProduct.dart';
import 'package:window_manager/window_manager.dart';
import '../objectBox/pages/ClientListScreen.dart';
import '../objectBox/pages/FactureListScreen.dart';
import '../objectBox/tests/cruds.dart' as cruds;
import '../../MyListLotties.dart';
import 'Entity.dart';
import 'MyProviders.dart';
import 'Utils/ads/AnchoredAdaptiveExample.dart';
import 'Utils/ads/FluidExample.dart';
import 'Utils/ads/InlineAdaptiveExample.dart';
import 'Utils/ads/NativeTemplateExample.dart';
import 'Utils/ads/WebViewExample.dart';
import 'Utils/ads/homeExemple.dart';
import 'Utils/excel.dart';
import 'Utils/mobile_scanner/main.dart';
import 'Utils/supabase_sync.dart';
import 'Utils/winMobile.dart';
import 'classeObjectBox.dart';
import 'hash.dart';
import 'hash2.dart';
import 'pages/FournisseurListScreen.dart';
import 'package:flutter/foundation.dart';
import 'dart:io' show Platform;
import 'dart:io';
import 'package:faker/faker.dart' as Faker;

import 'pages/ProduitListScreen.dart';
import 'pages/ProduitListSupabase.dart' as supa;

class MyMain extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return FutureProvider<ObjectBox?>(
      create: (_) async {
        final objectBox = ObjectBox();
        try {
          await objectBox.init();
          if (objectBox.isAdminAvailable()) {
            print('isAdminAvailable');
          }
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

const int maxFailedLoadAttempts = 3;

class MyApp9 extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final objectBox = Provider.of<ObjectBox?>(context);
    if (objectBox == null) {
      return Center(child: CircularProgressIndicator());
    }
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => CrudProvider(objectBox)),
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
        ChangeNotifierProvider(create: (_) => AdProvider()),
        ChangeNotifierProvider(
          create: (_) => ThemeProvider(),
        ),
      ],
      child: Consumer<ThemeProvider>(builder: (context, themeProvider, child) {
        return MaterialApp(
          title: 'POS',
          theme: ThemeData(
            fontFamily: 'OSWALD',
            brightness: Brightness.light,
            primarySwatch: Colors.blue,
            chipTheme: ChipThemeData(
              backgroundColor: Colors.grey[300]!,
              labelStyle: TextStyle(fontFamily: 'oswald'),
            ),
          ),
          darkTheme: ThemeData(
            fontFamily: 'oswald',
            brightness: Brightness.dark,
            primaryColor: Colors.blueGrey,
            chipTheme: ChipThemeData(
              backgroundColor: Colors.grey[800]!,
              labelStyle: TextStyle(fontFamily: 'oswald'),
            ),
          ),
          themeMode:
              themeProvider.isDarkTheme ? ThemeMode.dark : ThemeMode.light,

          //darkTheme: ThemeData.dark(),

          home: /*showPlatform*/ adaptiveHome(
            objectBox: objectBox,
          ),
        );
      }),
    );
  }
}

class adaptiveHome extends StatefulWidget {
  final ObjectBox objectBox;

  adaptiveHome({required this.objectBox});

  @override
  State<adaptiveHome> createState() => _adaptiveHomeState();
}

class _adaptiveHomeState extends State<adaptiveHome> {
  double prixMin = 0;
  double prixMax = 0;
  final TextEditingController _userController =
      TextEditingController(text: '20');
  final TextEditingController _clientController =
      TextEditingController(text: '20');
  final TextEditingController _supplierController =
      TextEditingController(text: '20');
  final TextEditingController _productController =
      TextEditingController(text: '20');
  final TextEditingController _approviController =
      TextEditingController(text: '20');

  int lengthPin = 10;

  @override
  void initState() {
    super.initState();
    _loadPrix();
    // _showInterstitialAd();
  }

  //////////////////////////////////////ads////////////////////////////////////////
  void _showInterstitialAd() {
    final adProvider = Provider.of<AdProvider>(context, listen: false);
    if (adProvider.isInterstitialAdReady) {
      adProvider.showInterstitialAd();
    }
  }
  //////////////////////////////////////ads////////////////////////////////////////

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

  void _showDialogFake(ObjectBox objectBox) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Générer des données factices'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                    controller: _userController,
                    decoration:
                        InputDecoration(labelText: 'Nombre d\'utilisateurs')),
                TextField(
                    controller: _clientController,
                    decoration:
                        InputDecoration(labelText: 'Nombre de clients')),
                TextField(
                    controller: _supplierController,
                    decoration:
                        InputDecoration(labelText: 'Nombre de fournisseurs')),
                TextField(
                    controller: _productController,
                    decoration:
                        InputDecoration(labelText: 'Nombre de produits')),
                TextField(
                    controller: _approviController,
                    decoration: InputDecoration(
                        labelText: 'Nombre d\'approvisionnements')),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('Annuler'),
            ),
            ElevatedButton(
              onPressed: () async {
                final int users = int.tryParse(_userController.text) ?? 20;
                final int clients = int.tryParse(_clientController.text) ?? 10;
                final int suppliers =
                    int.tryParse(_supplierController.text) ?? 10;
                final int products =
                    int.tryParse(_productController.text) ?? 10;
                final int approvi = int.tryParse(_approviController.text) ?? 10;
                objectBox.fillWithFakeData(
                    users, clients, suppliers, products, approvi);
                // await fakeDataGenerator.generateFakeData(
                //     objectBox, users, clients, suppliers, products, approvi);
                Navigator.of(context).pop();
              },
              child: Text('Générer'),
            ),
          ],
        );
      },
    );
  }

  int _selectedIndex = 0;

  List<Widget> _widgetOptions() {
    return [
      Container(), //homeRail(),
      FacturesListPage(),
      Container(),
      //FournisseurListScreen(),
    ];
  }

  void cleanQrCodes() {
    // Récupération de tous les produits de la base de données ObjectBox
    List<Produit> produits = widget.objectBox.produitBox.getAll();

    for (var produit in produits) {
      // Vérifier si le produit a un QR code
      if (produit.qr != null && produit.qr!.isNotEmpty) {
        // Supprimer les espaces du QR code
        produit.qr = produit.qr!.replaceAll(' ', '');
        produit.qr = produit.qr!.trim();

        // Mettre à jour le produit dans la base de données
        widget.objectBox.produitBox.put(produit);
        print('Produit id : ${produit.id} ===> QR: ${produit.qr} ');
      }
    }

    print("Tous les QR codes ont été nettoyés.");
  }

// Variable pour suivre le mode (desktop ou mobile)
  bool isSwitchOn = false; // État du switch
  @override
  Widget build(BuildContext context) {
    final objectBoxi = Provider.of<ObjectBox>(context, listen: false);

    final randomId = Random().nextInt(100);
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        if (constraints.maxWidth < 700) {
          // Mobile layout
          return SafeArea(
            child: DefaultTabController(
              length: 2,
              child: Scaffold(
                appBar: AppBar(
                  title: Text('POS'),
                  actions: [
                    WinMobile(),
                    // Switch(
                    //   value: isSwitchOn,
                    //   onChanged: _toggleWindowSize, // Bascule entre les modes
                    // ),
                    // IconButton(
                    //   onPressed: () async {
                    //     if (Platform.isAndroid) {
                    //       String filePath =
                    //           "/storage/emulated/0/Download/Articles.xls";
                    //       await widget.objectBox
                    //           .importProduitsRestantsDepuisExcel(filePath);
                    //       //.importProduitsDepuisExcel(filePath, 20, 3000, 500);
                    //     } else {
                    //       String filePath =
                    //           "C:/Users/INDRA/Documents/Articles.xls"; // Assurez-vous de mettre le bon chemin ici.
                    //       await widget.objectBox
                    //           .importProduitsRestantsDepuisExcel(filePath);
                    //       //.importProduitsDepuisExcel(filePath, 20, 3000, 500);
                    //     }
                    //
                    //     print("Produits importés avec succès !");
                    //   },
                    //   icon: Icon(FontAwesomeIcons.fileExcel),
                    // ),
                    // buildIconButtonClearQrCodes(),
                    // IconButton(
                    //   // onPressed: () {
                    //   //   Navigator.of(context).push(
                    //   //       MaterialPageRoute(builder: (ctx) => MyHomePageAds()));
                    //   // },
                    //   icon: Icon(Icons.ads_click, color: Colors.deepPurple),
                    // ),
                    // PopupMenuButton<String>(
                    //   onSelected: (String result) {
                    //     switch (result) {
                    //       case interstitialButtonText:
                    //         _showInterstitialAd();
                    //         break;
                    //       case rewardedButtonText:
                    //         _showRewardedAd();
                    //         break;
                    //       case rewardedInterstitialButtonText:
                    //         _showRewardedInterstitialAd();
                    //         break;
                    //       case fluidButtonText:
                    //         Navigator.push(
                    //           context,
                    //           MaterialPageRoute(
                    //               builder: (context) => FluidExample()),
                    //         );
                    //         break;
                    //       case inlineAdaptiveButtonText:
                    //         Navigator.push(
                    //           context,
                    //           MaterialPageRoute(
                    //               builder: (context) => InlineAdaptiveExample()),
                    //         );
                    //         break;
                    //       case anchoredAdaptiveButtonText:
                    //         Navigator.push(
                    //           context,
                    //           MaterialPageRoute(
                    //               builder: (context) => AnchoredAdaptiveExample()),
                    //         );
                    //         break;
                    //       case nativeTemplateButtonText:
                    //         Navigator.push(
                    //           context,
                    //           MaterialPageRoute(
                    //               builder: (context) => NativeTemplateExample()),
                    //         );
                    //         break;
                    //       case webviewExampleButtonText:
                    //         Navigator.push(
                    //           context,
                    //           MaterialPageRoute(
                    //               builder: (context) => WebViewExample()),
                    //         );
                    //         break;
                    //       case adInspectorButtonText:
                    //         MobileAds.instance.openAdInspector((error) => log(
                    //             ('Ad Inspector ' +
                    //                     (error == null
                    //                         ? 'opened.'
                    //                         : 'error: ' + (error.message ?? '')))
                    //                 as num)); /////////////////*********************hna pas sure
                    //         break;
                    //       default:
                    //         throw AssertionError('unexpected button: $result');
                    //     }
                    //   },
                    //   itemBuilder: (BuildContext context) =>
                    //       <PopupMenuEntry<String>>[
                    //     PopupMenuItem<String>(
                    //       value: interstitialButtonText,
                    //       child: Text(interstitialButtonText),
                    //     ),
                    //     PopupMenuItem<String>(
                    //       value: rewardedButtonText,
                    //       child: Text(rewardedButtonText),
                    //     ),
                    //     PopupMenuItem<String>(
                    //       value: rewardedInterstitialButtonText,
                    //       child: Text(rewardedInterstitialButtonText),
                    //     ),
                    //     PopupMenuItem<String>(
                    //       value: fluidButtonText,
                    //       child: Text(fluidButtonText),
                    //     ),
                    //     PopupMenuItem<String>(
                    //       value: inlineAdaptiveButtonText,
                    //       child: Text(inlineAdaptiveButtonText),
                    //     ),
                    //     PopupMenuItem<String>(
                    //       value: anchoredAdaptiveButtonText,
                    //       child: Text(anchoredAdaptiveButtonText),
                    //     ),
                    //     PopupMenuItem<String>(
                    //       value: nativeTemplateButtonText,
                    //       child: Text(nativeTemplateButtonText),
                    //     ),
                    //     PopupMenuItem<String>(
                    //       value: webviewExampleButtonText,
                    //       child: Text(webviewExampleButtonText),
                    //     ),
                    //     PopupMenuItem<String>(
                    //       value: adInspectorButtonText,
                    //       child: Text(adInspectorButtonText),
                    //     ),
                    //   ],
                    // ),

                    // IconButton(
                    //   onPressed: () {
                    //     Navigator.of(context).push(MaterialPageRoute(
                    //         builder: (ctx) => mobile_scanner_example()));
                    //   },
                    //   icon: Icon(Icons.home, color: Colors.black),
                    // ),
                    // IconButton(
                    //   onPressed: () {
                    //     Navigator.of(context).push(MaterialPageRoute(
                    //         builder: (ctx) => QRScannerPage(
                    //               lengthPin: 8,
                    //               p4ssw0rd: 'Oran2024',
                    //             )));
                    //   },
                    //   icon: Icon(Icons.qr_code_scanner, color: Colors.blue),
                    // ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Switch(
                        value: Provider.of<ThemeProvider>(context).isDarkTheme,
                        onChanged: (value) {
                          Provider.of<ThemeProvider>(context, listen: false)
                              .toggleTheme();
                        },
                        inactiveThumbImage: CachedNetworkImageProvider(
                            'https://img.freepik.com/free-vector/natural-landscape-background-video-conferencing_23-2148653740.jpg?semt=ais_hybrid'),
                        activeThumbImage: CachedNetworkImageProvider(
                            'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcSdyzjpBSojo_zxZ535JaX7d9dVC-aF-fPr3A&s'),
                      ),
                    ),
                    Platform.isAndroid || Platform.isIOS
                        ? Container()
                        : IconButton(
                            onPressed: () =>
                                showForcedRewardedAd(context, hashPage()),

                            // onPressed: () {
                            //   Navigator.of(context)
                            //       .push(MaterialPageRoute(builder: (ctx) => hashPage()));
                            // },
                            icon: Icon(Icons.add_chart_rounded,
                                color: Colors.green),
                          ),
                    Platform.isAndroid || Platform.isIOS
                        ? IconButton(
                            onPressed: () {
                              Navigator.of(context).push(MaterialPageRoute(
                                  builder: (ctx) => HashAdmin(
                                        lengthPin: lengthPin,
                                      )));
                            },
                            icon: Icon(Icons.qr_code_scanner),
                          )
                        : Container(),
                    // IconButton(
                    //         onPressed: () {
                    //           Navigator.of(context)
                    //               .push(MaterialPageRoute(builder: (ctx) => hashPage()));
                    //         },
                    //         icon: Icon(Icons.add_chart_rounded),
                    //       ),
                    // IconButton(
                    //   onPressed: () {
                    //     Navigator.of(context).push(
                    //         MaterialPageRoute(builder: (ctx) => LicensePage()));
                    //   },
                    //   icon: Icon(Icons.account_tree_rounded),
                    // ),
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
                            builder: (ctx) => ProduitListPage(
                                supabase: Supabase.instance.client,
                                objectboxStore: widget.objectBox.store)));
                      },
                      icon: Icon(Icons.local_police),
                    ),
                    IconButton(
                      onPressed: () => _showDialogFake(objectBoxi),
                      icon: Icon(Icons.send),
                    ),
                    // IconButton(
                    //   onPressed: () {
                    //     Navigator.of(context).push(MaterialPageRoute(
                    //         builder: (ctx) => LottieListPage()));
                    //   },
                    //   icon: Icon(Icons.local_bar_outlined),
                    // ),
                    SizedBox(
                      width: 60,
                    )
                  ],
                  bottom: TabBar(
                    tabs: [
                      Tab(text: 'Liste'), // Onglet pour la liste
                      Tab(text: 'Carrousel'), // Onglet pour le carrousel
                    ],
                  ),
                ),
                body: Consumer<CommerceProvider>(
                    builder: (context, produitProvider, child) {
                  int totalProduits = produitProvider.getTotalProduits();
                  List<Produit> produitsFiltres = produitProvider
                      .getProduitsBetweenPrices(prixMin, prixMax);
                  // var produitsLowStock = produitProvider.getProduitsLowStock(5.0);
                  // var produitsLowStock0 = produitProvider.getProduitsLowStock(0.0);
                  return Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: TabBarView(children: [
                      ListView(
                        children: [
                          // Padding(
                          //   padding: const EdgeInsets.all(18.0),
                          //   child: Center(
                          //     child: Text(
                          //       'Mode ${Provider.of<ThemeProvider>(context).isDarkTheme ? "Sombre" : "Clair"}',
                          //       style: Theme.of(context).textTheme.bodyLarge,
                          //     ),
                          //   ),
                          // ),
                          GestureDetector(
                            onTap: () => showForcedRewardedAd(
                                context, ProduitListScreen()),
                            // onTap: () {
                            //   Navigator.of(context).push(
                            //     MaterialPageRoute(
                            //         builder: (context) => ProduitListScreen()),
                            //   );
                            // },
                            child: CardTop(
                              image:
                                  'https://picsum.photos/seed/$randomId/200/100',
                              text:
                                  '${produitProvider.getTotalProduits()} Produits',
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
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Expanded(
                                child: Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: ElevatedButton.icon(
                                      style: ElevatedButton.styleFrom(
                                        foregroundColor: Theme.of(context)
                                            .colorScheme
                                            .onPrimary,
                                        backgroundColor: Theme.of(context)
                                            .colorScheme
                                            .primary,
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(15.0),
                                        ),
                                      ),
                                      onPressed: () {
                                        Navigator.of(context).push(
                                            MaterialPageRoute(
                                                builder: (_) => addProduct()));
                                      },
                                      label: Text(
                                        'Produit',
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      icon: Padding(
                                        padding: const EdgeInsets.symmetric(
                                            vertical: 50),
                                        child: Icon(Icons.add),
                                      )),
                                ),
                              ),
                              Expanded(
                                child: Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: ElevatedButton.icon(
                                      style: ElevatedButton.styleFrom(
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(15.0),
                                        ),
                                      ),
                                      onPressed: () {
                                        showModalBottomSheet(
                                          context: context,
                                          isScrollControlled:
                                              true, // Permet de redimensionner en fonction de la hauteur du contenu
                                          builder: (context) =>
                                              AddFournisseurForm(),
                                        );
                                      },
                                      label: Text(
                                        'Fournisseur',
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      icon: Padding(
                                        padding: const EdgeInsets.symmetric(
                                            vertical: 50),
                                        child: Icon(Icons.add),
                                      )),
                                ),
                              ),
                            ],
                          ),
                          ElevatedButton(
                              onPressed: () {
                                Navigator.of(context).push(MaterialPageRoute(
                                    builder: (_) => addProduct()));
                              },
                              child: Text('Add Product 2')),
                          // Padding(
                          //   padding: const EdgeInsets.symmetric(
                          //       horizontal: 8, vertical: 15),
                          //   child: ElevatedButton(
                          //     onPressed: () async {
                          //       await replaceObjectBoxDatabase(context);
                          //       // Rafraîchir l'interface utilisateur ou redémarrer l'application si nécessaire
                          //     },
                          //     child: Text('Remplacer la base de données'),
                          //   ),
                          // ),
                          // Padding(
                          //   padding: const EdgeInsets.symmetric(
                          //       horizontal: 18, vertical: 20),
                          //   child: ElevatedButton.icon(
                          //       style: ElevatedButton.styleFrom(
                          //         foregroundColor:
                          //             Theme.of(context).colorScheme.onPrimary,
                          //         backgroundColor:
                          //             Theme.of(context).colorScheme.primary,
                          //         shape: RoundedRectangleBorder(
                          //           borderRadius: BorderRadius.circular(15.0),
                          //         ),
                          //       ),
                          //       onPressed: () {
                          //         Navigator.of(context).push(MaterialPageRoute(
                          //             builder: (ctx) => add_Produit()));
                          //       },
                          //       label: Text('Add Product'),
                          //       icon: Icon(Icons.add)),
                          // ),
                          Padding(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 50, vertical: 15),
                            child: ElevatedButton.icon(
                                onPressed: () =>
                                    DatabaseUpdater.pickAndReplaceDatabase(
                                        context),
                                label: Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 8, vertical: 8),
                                  child: Text(
                                    'Upload DB',
                                    overflow: TextOverflow.ellipsis,
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                                icon: Icon(
                                  Icons.download,
                                  color: Colors.blue,
                                )),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Container(
                              width: MediaQuery.of(context).size.width,
                              padding: EdgeInsets.all(
                                  15.0), // Espacement à l'intérieur du cadre
                              decoration: BoxDecoration(
                                //      color: Colors.grey, // Couleur de fond
                                borderRadius: BorderRadius.circular(
                                    8.0), // Bords arrondis
                                border: Border.all(
                                  color: Colors.grey, // Couleur de la bordure
                                  width: 1.0, // Épaisseur de la bordure
                                ),
                              ),
                              child: Column(
                                children: [
                                  Text('Factures'),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Expanded(
                                        child: Padding(
                                          padding: const EdgeInsets.all(8.0),
                                          child: ElevatedButton.icon(
                                              onPressed: () =>
                                                  showForcedRewardedAd(
                                                      context, FacturePage()),
                                              // onPressed: () {
                                              //   Navigator.of(context).push(MaterialPageRoute(
                                              //       builder: (_) => FacturePage()));
                                              // },
                                              label: Text(
                                                'Ajouter',
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                              icon: Icon(Icons.add)),
                                        ),
                                      ),
                                      Expanded(
                                        child: Padding(
                                          padding: const EdgeInsets.all(8.0),
                                          child: ElevatedButton.icon(
                                              onPressed: () =>
                                                  showForcedRewardedAd(context,
                                                      FacturesListPage()),
                                              // onPressed: () {
                                              //   Navigator.of(context).push(MaterialPageRoute(
                                              //       builder: (_) => FacturesListPage()));
                                              // },
                                              label: Text(
                                                'List',
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                              icon: Icon(Icons.list_alt)),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                          GestureDetector(
                            onTap: () {
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                    builder: (context) =>
                                        cruds.UserListScreen()),
                              );
                            },
                            child: CardTop(
                              image:
                                  'https://picsum.photos/seed/${randomId + 4}/200/100',
                              text: '${produitProvider.users.length} Users',
                              provider: produitProvider,
                              SmallBanner: true,
                            ),
                          ),
                          // Padding(
                          //   padding: const EdgeInsets.all(8.0),
                          //   child: ElevatedButton.icon(
                          //       onPressed: () => showForcedRewardedAd(
                          //           context, ClientListScreen()),
                          //       // onPressed: () {
                          //       //   Navigator.of(context).push(MaterialPageRoute(
                          //       //       builder: (_) => ClientListScreen()));
                          //       // },
                          //       label: Text('Client List'),
                          //       icon: Icon(Icons.account_circle)),
                          // ),
                          GestureDetector(
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
                              SmallBanner: true,
                            ),
                          ),
                          GestureDetector(
                            onTap: () => showForcedRewardedAd(
                                context, ClientListScreen()),
                            // onTap: () {
                            //   Navigator.of(context).push(
                            //     MaterialPageRoute(
                            //         builder: (context) => ClientListScreen()),
                            //   );
                            // },
                            child: CardTop(
                              image:
                                  'https://picsum.photos/seed/${randomId + 2}/200/100',
                              text:
                                  '${produitProvider.getTotalClientsCount()} Clients',
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
                            child: CardTop2(
                              image:
                                  'https://picsum.photos/seed/${randomId + 1}/200/100',
                              text:
                                  '${produitsFiltres.length} Produits\nentre ${prixMin.toStringAsFixed(2)} DZD et ${prixMax.toStringAsFixed(2)} DZD',
                              provider: produitProvider,
                              button: produitsFiltres.length == 0
                                  ? ElevatedButton(
                                      onPressed: null,
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors
                                            .grey[300], // Couleur de fond grise
                                        foregroundColor: Colors.grey[
                                            600], // Couleur du texte grise
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
                                              builder: (context) =>
                                                  ProduitListInterval(
                                                    produitsFiltres:
                                                        produitsFiltres,
                                                  )),
                                        );
                                      },
                                      label: Text(('Voire La List'))),
                              SmallBanner: false,
                            ),
                          ),
                          // CardAlert(
                          //   image:
                          //       'https://picsum.photos/seed/${randomId + 3}/200/100',
                          //   text:
                          //       'Alert stock < 5\n${produitsLowStock['count']} Produits\n\nRupture de stock\n${produitsLowStock0['count']} Produits',
                          //   provider: produitProvider,
                          //   button: produitsLowStock['count'] == 0 &&
                          //           produitsLowStock0['count'] == 0
                          //       ? null
                          //       : ElevatedButton(
                          //           onPressed: () {
                          //             Navigator.of(context).push(
                          //               MaterialPageRoute(
                          //                 builder: (context) => LowStockList(
                          //                     produitsLowStock: produitsLowStock),
                          //                 // ProduitListInterval(
                          //                 //   produitsFiltres:
                          //                 //       produitsFiltres,
                          //                 // ),
                          //               ),
                          //             );
                          //           },
                          //           child: Text(('Voire La List'))),
                          //   Color1: Colors.red,
                          //   Color2: Colors.black,
                          // ),
                          Padding(
                            padding: const EdgeInsets.all(15.0),
                            child: TextButton.icon(
                              onPressed: () {
                                widget.objectBox.deleteDatabase();

                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                      content: Text(
                                          'Base de Données Vider avec succes!')),
                                );
                              },
                              style: ElevatedButton.styleFrom(
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(15.0),
                                ),
                                // Couleur de fond grise

                                backgroundColor:
                                    Colors.red, // Couleur de fond grise
                                foregroundColor:
                                    Colors.grey[300], // Couleur du texte grise
                                disabledBackgroundColor: Colors.grey[
                                    300], // Assure que la couleur reste grise même désactivé
                                disabledForegroundColor: Colors.grey[
                                    600], // Assure que la couleur du texte reste grise même désactivé
                              ),
                              icon: Icon(Icons.delete_outline_sharp),
                              label: Text('DB Erase'),
                            ),
                          ),
                        ],
                      ),
                      // Vue pour le CarouselExample
                      CarouselExample(
                        provider: produitProvider,
                      ),
                    ]),
                  );
                }),
              ),
            ),
          );
        } else if (constraints.maxWidth < 1200) {
          // Tablet layout
          return SafeArea(
            child: Scaffold(
              appBar: AppBar(
                title: Text('POS'),
                actions: [
                  WinMobile(),

                  // Switch(
                  //   value: isSwitchOn,
                  //   onChanged: _toggleWindowSize, // Bascule entre les modes
                  // ),
                  // buildIconButtonClearQrCodes(),

                  // Switch pour basculer entre les thèmes
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Switch(
                      value: Provider.of<ThemeProvider>(context).isDarkTheme,
                      onChanged: (value) {
                        Provider.of<ThemeProvider>(context, listen: false)
                            .toggleTheme();
                      },
                      inactiveThumbImage: CachedNetworkImageProvider(
                          'https://img.freepik.com/free-vector/natural-landscape-background-video-conferencing_23-2148653740.jpg?semt=ais_hybrid'),
                      activeThumbImage: CachedNetworkImageProvider(
                          'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcSdyzjpBSojo_zxZ535JaX7d9dVC-aF-fPr3A&s'),
                    ),
                  ),
                  // IconButton(
                  //   onPressed: () {
                  //     Navigator.of(context).push(
                  //         MaterialPageRoute(builder: (ctx) => MyHomePageAds()));
                  //   },
                  //   icon: Icon(Icons.ads_click, color: Colors.deepPurple),
                  // ),
                  // IconButton(
                  //   onPressed: () {
                  //     // Appelez la méthode ici sans essayer d'utiliser sa valeur de retour
                  //     widget.objectBox..ajouterQuantitesAleatoires();
                  //   },
                  //  icon: Icon(Icons.qr_code_scanner, color: Colors.blue),
                  // ),
                  IconButton(
                    onPressed: () async {
                      if (Platform.isAndroid) {
                        String filePath =
                            "/storage/emulated/0/Download/Articles.xls";
                        await widget.objectBox
                            //   .importProduitsRestantsDepuisExcel(filePath);
                            .importProduitsDepuisExcel(filePath, 20, 3000, 500);
                      } else {
                        String filePath =
                            "C:/Users/INDRA/Documents/Articles.xls"; // Assurez-vous de mettre le bon chemin ici.
                        await widget.objectBox
                            //  .importProduitsRestantsDepuisExcel(filePath);
                            .importProduitsDepuisExcel(filePath, 20, 3000, 500);
                      }

                      print("Produits importés avec succès !");
                    },
                    icon: Icon(FontAwesomeIcons.fileExcel),
                  ),
                  // IconButton(
                  //   onPressed: () {
                  //     Navigator.of(context).push(MaterialPageRoute(
                  //         builder: (ctx) => mobile_scanner_example()));
                  //   },
                  //   icon: Icon(Icons.home, color: Colors.black),
                  // ),
                  // IconButton(
                  //   onPressed: () {
                  //     Navigator.of(context).push(MaterialPageRoute(
                  //         builder: (ctx) => QRScannerPage(
                  //               lengthPin: 8,
                  //               p4ssw0rd: 'Oran2024',
                  //             )));
                  //   },
                  //   icon: Icon(Icons.qr_code_scanner, color: Colors.blue),
                  // ),
                  IconButton(
                    onPressed: () {
                      Navigator.of(context).push(
                          MaterialPageRoute(builder: (ctx) => hashPage()));
                    },
                    icon: Icon(Icons.qr_code_scanner, color: Colors.green),
                  ),
                  IconButton(
                    onPressed: () {
                      Navigator.of(context).push(
                          MaterialPageRoute(builder: (ctx) => LicensePage()));
                    },
                    icon: Icon(Icons.account_tree_rounded),
                  ),
                  IconButton(
                    onPressed: () {
                      Navigator.of(context).push(MaterialPageRoute(
                          builder: (ctx) => FacturesListPage()));
                    },
                    icon: Icon(Icons.hail_outlined),
                  ),
                  IconButton(
                    onPressed: () {
                      Navigator.of(context).push(
                          MaterialPageRoute(builder: (ctx) => FacturePage()));
                    },
                    icon: Icon(Icons.invert_colors_off),
                  ),
                  SizedBox(
                    width: 50,
                  ),
                  IconButton(
                    onPressed: () {
                      Navigator.of(context).push(MaterialPageRoute(
                          builder: (ctx) => ProduitListPage(
                              supabase: Supabase.instance.client,
                              objectboxStore: widget.objectBox.store)));
                    },
                    icon: Icon(Icons.local_police),
                  ),
                  IconButton(
                    onPressed: () =>
                        //objectBox.fillWithFakeData(20, 20, 10, 20, 20),

                        _showDialogFake(objectBoxi),
                    icon: Icon(Icons.send),
                  ),
                  IconButton(
                    onPressed: () {
                      Navigator.of(context).push(MaterialPageRoute(
                          builder: (ctx) => LottieListPage()));
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
                  List<Produit> produitsFiltres = produitProvider
                      .getProduitsBetweenPrices(prixMin, prixMax);
                  // var produitsLowStock = produitProvider.getProduitsLowStock(5.0);
                  // var produitsLowStock0 =
                  //     produitProvider.getProduitsLowStock(0.0);

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
                          ? buildExpanded(
                              context,
                              randomId,
                              produitProvider,
                              produitsFiltres,
                              // produitsLowStock,
                              // produitsLowStock0,
                            )
                          : _selectedIndex == 1
                              ? Expanded(flex: 2, child: FacturePage())
                              : Expanded(
                                  flex: 1,
                                  child: CarouselExample(
                                    provider: produitProvider,
                                  ),
                                ),
                      _selectedIndex == 1
                          ? Expanded(
                              flex: 1,
                              child: _widgetOptions()[_selectedIndex],
                            )
                          : Container(),
                    ],
                  );
                },
              ),
            ),
          );
        } else {
          // Desktop layout
          return SafeArea(
            child: Scaffold(
              appBar: AppBar(
                title: Text('POS Desktop'),
                actions: [
                  WinMobile(),

                  // Switch(
                  //   value: isSwitchOn,
                  //   onChanged: _toggleWindowSize, // Bascule entre les modes
                  // ),
                  // buildIconButtonClearQrCodes(),

                  // Switch pour basculer entre les thèmes
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Switch(
                      value: Provider.of<ThemeProvider>(context).isDarkTheme,
                      onChanged: (value) {
                        Provider.of<ThemeProvider>(context, listen: false)
                            .toggleTheme();
                      },
                      inactiveThumbImage: CachedNetworkImageProvider(
                          'https://img.freepik.com/free-vector/natural-landscape-background-video-conferencing_23-2148653740.jpg?semt=ais_hybrid'),
                      activeThumbImage: CachedNetworkImageProvider(
                          'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcSdyzjpBSojo_zxZ535JaX7d9dVC-aF-fPr3A&s'),
                    ),
                  ),
                  // IconButton(
                  //   onPressed: () {
                  //     Navigator.of(context).push(
                  //         MaterialPageRoute(builder: (ctx) => MyHomePageAds()));
                  //   },
                  //   icon: Icon(Icons.ads_click, color: Colors.deepPurple),
                  // ),
                  // IconButton(
                  //   onPressed: () {
                  //     // Appelez la méthode ici sans essayer d'utiliser sa valeur de retour
                  //     widget.objectBox..ajouterQuantitesAleatoires();
                  //   },
                  //  icon: Icon(Icons.qr_code_scanner, color: Colors.blue),
                  // ),
                  IconButton(
                    onPressed: () async {
                      if (Platform.isAndroid) {
                        String filePath =
                            "/storage/emulated/0/Download/Articles.xls";
                        await widget.objectBox
                            //   .importProduitsRestantsDepuisExcel(filePath);
                            .importProduitsDepuisExcel(filePath, 20, 3000, 500);
                      } else {
                        String filePath =
                            "C:/Users/INDRA/Documents/Articles.xls"; // Assurez-vous de mettre le bon chemin ici.
                        await widget.objectBox
                            //  .importProduitsRestantsDepuisExcel(filePath);
                            .importProduitsDepuisExcel(filePath, 20, 3000, 500);
                      }

                      print("Produits importés avec succès !");
                    },
                    icon: Icon(FontAwesomeIcons.fileExcel),
                  ),
                  // IconButton(
                  //   onPressed: () {
                  //     Navigator.of(context).push(MaterialPageRoute(
                  //         builder: (ctx) => mobile_scanner_example()));
                  //   },
                  //   icon: Icon(Icons.home, color: Colors.black),
                  // ),
                  // IconButton(
                  //   onPressed: () {
                  //     Navigator.of(context).push(MaterialPageRoute(
                  //         builder: (ctx) => QRScannerPage(
                  //               lengthPin: 8,
                  //               p4ssw0rd: 'Oran2024',
                  //             )));
                  //   },
                  //   icon: Icon(Icons.qr_code_scanner, color: Colors.blue),
                  // ),
                  IconButton(
                    onPressed: () {
                      Navigator.of(context).push(
                          MaterialPageRoute(builder: (ctx) => hashPage()));
                    },
                    icon: Icon(Icons.qr_code_scanner, color: Colors.green),
                  ),
                  IconButton(
                    onPressed: () {
                      Navigator.of(context).push(
                          MaterialPageRoute(builder: (ctx) => LicensePage()));
                    },
                    icon: Icon(Icons.account_tree_rounded),
                  ),
                  IconButton(
                    onPressed: () {
                      Navigator.of(context).push(MaterialPageRoute(
                          builder: (ctx) => FacturesListPage()));
                    },
                    icon: Icon(Icons.hail_outlined),
                  ),
                  IconButton(
                    onPressed: () {
                      Navigator.of(context).push(
                          MaterialPageRoute(builder: (ctx) => FacturePage()));
                    },
                    icon: Icon(Icons.invert_colors_off),
                  ),
                  SizedBox(
                    width: 50,
                  ),
                  IconButton(
                    onPressed: () {
                      Navigator.of(context).push(MaterialPageRoute(
                          builder: (ctx) => ProduitListPage(
                              supabase: Supabase.instance.client,
                              objectboxStore: widget.objectBox.store)));
                    },
                    icon: Icon(Icons.local_police),
                  ),
                  IconButton(
                    onPressed: () =>
                        //objectBox.fillWithFakeData(20, 20, 10, 20, 20),

                        _showDialogFake(objectBoxi),
                    icon: Icon(Icons.send),
                  ),
                  IconButton(
                    onPressed: () {
                      Navigator.of(context).push(MaterialPageRoute(
                          builder: (ctx) => LottieListPage()));
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
                  List<Produit> produitsFiltres = produitProvider
                      .getProduitsBetweenPrices(prixMin, prixMax);
                  // var produitsLowStock = produitProvider.getProduitsLowStock(5.0);
                  // var produitsLowStock0 =
                  //     produitProvider.getProduitsLowStock(0.0);

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
                          ? buildExpanded(
                              context,
                              randomId,
                              produitProvider,
                              produitsFiltres,
                              // produitsLowStock,
                              // produitsLowStock0,
                            )
                          : _selectedIndex == 1
                              ? Expanded(flex: 2, child: FacturePage())
                              : Expanded(
                                  flex: 1,
                                  child: CarouselExample(
                                    provider: produitProvider,
                                  ),
                                ),
                      _selectedIndex == 1
                          ? Expanded(
                              flex: 1,
                              child: _widgetOptions()[_selectedIndex],
                            )
                          : Container(),
                    ],
                  );
                },
              ),
            ),
          );
        }
      },
    );
  }

  IconButton buildIconButtonClearQrCodes() {
    return IconButton(
      onPressed: () {
        cleanQrCodes();
      },
      icon: Icon(FontAwesomeIcons.radiation),
    );
  }

  Expanded buildExpanded(
    BuildContext context,
    int randomId,
    CommerceProvider produitProvider,
    List<Produit> produitsFiltres,
    // Map<String, dynamic> produitsLowStock,
    // Map<String, dynamic> produitsLowStock0
  ) {
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
                            builder: (context) => cruds.UserListScreen()),
                      );
                    },
                    child: CardTop(
                      image:
                          'https://picsum.photos/seed/${randomId + 4}/200/100',
                      text: '${produitProvider.users.length} Users',
                      provider: produitProvider,
                      SmallBanner: true,
                    ),
                  ),
                ),
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
                // Expanded(
                //   child: CardAlert(
                //     image: 'https://picsum.photos/seed/${randomId + 2}/200/100',
                //     text:
                //         'Alert stock < 5\n${produitsLowStock['count']} Produits\n\nRupture de stock\n${produitsLowStock0['count']} Produits',
                //     provider: produitProvider,
                //     button: produitsLowStock['count'] == 0 &&
                //             produitsLowStock0['count'] == 0
                //         ? null
                //         : ElevatedButton(
                //             onPressed: () {
                //               Navigator.of(context).push(
                //                 MaterialPageRoute(
                //                   builder: (context) => LowStockList(
                //                       produitsLowStock: produitsLowStock),
                //                   // ProduitListInterval(
                //                   //   produitsFiltres:
                //                   //       produitsFiltres,
                //                   // ),
                //                 ),
                //               );
                //             },
                //             child: Text(('Voire La List'))),
                //     Color1: Colors.red[900]!,
                //     Color2: Colors.black,
                //   ),
                // ),
                // Expanded(
                //     child: _buildPriceRangeProductsCard(
                //         context, produitProvider)),
              ],
            ),
          ),

          // Padding(
          //   padding: const EdgeInsets.all(28.0),
          //   child: ElevatedButton.icon(
          //     onPressed: () {
          //       Navigator.of(context).push(
          //           MaterialPageRoute(builder: (ctx) => SyncProductsPage()));
          //     },
          //     label: Text('Open Food Facts Correction'),
          //     icon: Icon(Icons.event_seat),
          //   ),
          // ),
          Padding(
            padding: const EdgeInsets.all(18.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          foregroundColor:
                              Theme.of(context).colorScheme.onPrimary,
                          backgroundColor:
                              Theme.of(context).colorScheme.primary,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15.0),
                          ),
                        ),
                        onPressed: () {
                          Navigator.of(context).push(
                              MaterialPageRoute(builder: (_) => addProduct()));
                        },
                        label: Text(
                          'Produit',
                          overflow: TextOverflow.ellipsis,
                        ),
                        icon: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 50),
                          child: Icon(Icons.add),
                        )),
                  ),
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15.0),
                          ),
                        ),
                        onPressed: () {
                          showModalBottomSheet(
                            context: context,
                            isScrollControlled:
                                true, // Permet de redimensionner en fonction de la hauteur du contenu
                            builder: (context) => AddFournisseurForm(),
                          );
                        },
                        label: Text(
                          'Fournisseur',
                          overflow: TextOverflow.ellipsis,
                        ),
                        icon: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 50),
                          child: Icon(Icons.add),
                        )),
                  ),
                ),
              ],
            ),
          ),
          // Padding(
          //   padding: const EdgeInsets.symmetric(horizontal: 8.0),
          //   child: Row(
          //     mainAxisAlignment: MainAxisAlignment.spaceAround,
          //     children: [
          //       Padding(
          //         padding: const EdgeInsets.all(8.0),
          //         child: ElevatedButton.icon(
          //           style: ElevatedButton.styleFrom(
          //             foregroundColor: Theme.of(context).colorScheme.onPrimary,
          //             backgroundColor: Theme.of(context).colorScheme.primary,
          //             shape: RoundedRectangleBorder(
          //               borderRadius: BorderRadius.circular(15.0),
          //             ),
          //           ),
          //           onPressed: () {
          //             Navigator.of(context).push(
          //                 MaterialPageRoute(builder: (ctx) => addProduct()));
          //           },
          //           label: Text('Ajouter Produit'),
          //           icon: Icon(Icons.safety_check_rounded),
          //         ),
          //       ),
          //       ElevatedButton.icon(
          //           onPressed: () {
          //             showModalBottomSheet(
          //               context: context,
          //               isScrollControlled:
          //                   true, // Permet de redimensionner en fonction de la hauteur du contenu
          //               builder: (context) => AddFournisseurForm(),
          //             );
          //           },
          //           label: Text('Ajouter Un Fournisseur'),
          //           icon: Icon(Icons.add)),
          //     ],
          //   ),
          // ),
          // SizedBox(height: 18),
          // ElevatedButton.icon(
          //     onPressed: () {
          //       Navigator.of(context).push(
          //           MaterialPageRoute(builder: (_) => ClientListScreen()));
          //     },
          //     label: Text('Client List'),
          //     icon: Icon(Icons.account_circle)),
          // SizedBox(height: 18),
          Padding(
            padding: const EdgeInsets.all(18.0),
            child: GestureDetector(
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
          ),
          Container(
            width: 150,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.grey[300], // Couleur de fond grise
                foregroundColor: Colors.red, // Couleur du texte grise
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
          SizedBox(
            height: 28,
          ),
        ],
      ),
    );
  }

  // Future<void> _toggleWindowSize(bool value) async {
  //   // Ne pas exécuter ce code sur Android/iOS
  //   if (Platform.isAndroid || Platform.isIOS) return;
  //
  //   setState(() {
  //     isSwitchOn = value; // Mettre à jour l'état du switch
  //   });
  //
  //   if (isPhoneSize) {
  //     // Passer en mode Desktop
  //     await windowManager.setSize(const Size(1920, 1080)); // Taille Desktop
  //     setState(() {
  //       isPhoneSize = false; // Met à jour l'état pour refléter le mode Desktop
  //     });
  //   } else {
  //     // Passer en mode Mobile
  //     await windowManager.setSize(const Size(380, 812)); // Taille Mobile
  //     setState(() {
  //       isPhoneSize = true; // Met à jour l'état pour refléter le mode Mobile
  //     });
  //   }
  // }
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
            ? MediaQuery.of(context).size.height * 0.25
            : SmallBanner
                ? MediaQuery.of(context).size.height * 0.15
                : MediaQuery.of(context).size.height * 0.35,
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

class CardTop2 extends StatelessWidget {
  const CardTop2({
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
            ? MediaQuery.of(context).size.height * 0.25
            : SmallBanner
                ? MediaQuery.of(context).size.height * 0.15
                : MediaQuery.of(context).size.height * 0.55,
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
                  .push(MaterialPageRoute(builder: (ctx) => addProduct()));
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
/////////////////////////////////////////////////////////////////////////////

/////////////////////////////////////////////////////////////////////////////
void showForcedRewardedAd(BuildContext context, Widget destinationPage) async {
  final adProvider = Provider.of<AdProvider>(context, listen: false);
  if (adProvider.isRewardedAdReady) {
    bool rewardEarned = await adProvider.showRewardedAd();
    if (rewardEarned) {
      // L'utilisateur a regardé la vidéo jusqu'à la fin
      _navigateToNextScreen(context, destinationPage);
    } else {
      // L'utilisateur n'a pas terminé la vidéo
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text(
                'Veuillez regarder la publicité en entier pour continuer')),
      );
    }
  } else {
    // ScaffoldMessenger.of(context).showSnackBar(
    // SnackBar(
    //     content: Text('Publicité non prête. Veuillez réessayer plus tard.')),
    //);
    _navigateToNextScreen(context, destinationPage);
  }
}

void _navigateToNextScreen(BuildContext context, Widget destinationPage) {
  Navigator.of(context).push(MaterialPageRoute(
    builder: (context) => destinationPage,
  ));
}

//////////////////////////////////////////////////test//////////////////////////////
class CarouselExample extends StatefulWidget {
  const CarouselExample({
    super.key,
    required this.provider,
  });

  final CommerceProvider provider;

  @override
  State<CarouselExample> createState() => _CarouselExampleState();
}

class _CarouselExampleState extends State<CarouselExample> {
  final CarouselController controller = CarouselController(initialItem: 1);

  double prixMin = 0;
  double prixMax = 0;

  @override
  void initState() {
    super.initState();
    _loadPrix();
    // _showInterstitialAd();
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

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final double height = MediaQuery.sizeOf(context).height;
    int totalProduits = widget.provider.getTotalProduits();
    List<Produit> produitsFiltres =
        widget.provider.getProduitsBetweenPrices(prixMin, prixMax);
    // var produitsLowStock = produitProvider.getProduitsLowStock(5.0);
    // var produitsLowStock0 = produitProvider.getProduitsLowStock(0.0);
    return Center(
      child: ListView(
        children: <Widget>[
          ConstrainedBox(
            constraints: BoxConstraints(maxHeight: height / 2),
            child: CarouselView(
                controller: controller,
                itemExtent: 330, // Largeur de chaque item
                shrinkExtent: 100, // Largeur réduite lors du défilement
                children: [
                  HeroLayoutCard(
                      title: totalProduits.toString(),
                      subTitle: 'Total Des Produits',
                      image: 'https://random.imagecdn.app/700/150'),
                  HeroLayoutCard(
                      title: widget.provider.produits.length.toString(),
                      subTitle: 'Total Des Produits',
                      image: 'https://picsum.photos/700?random=3'),
                  HeroLayoutCard(
                      title: widget.provider.clients.length.toString(),
                      subTitle: 'Total Des Clients',
                      image: 'https://picsum.photos/700?random=4'),
                  HeroLayoutCard(
                      title: widget.provider.fournisseurs.length.toString(),
                      subTitle: 'Total Des Fournisseurs',
                      image: 'https://picsum.photos/700?random=5'),
                  HeroLayoutCard(
                      title: widget.provider.users.length.toString(),
                      subTitle: 'Total Des Users',
                      image: 'https://picsum.photos/700?random=6'),
                ]
                // ImageInfo.values.map((ImageInfo image) {
                //   return HeroLayoutCard(imageInfo: image);
                // }).toList(),
                ),
          ),
          const SizedBox(height: 20),
          const Padding(
            padding: EdgeInsetsDirectional.only(top: 8.0, start: 8.0),
            child: Text('Multi-browse layout'),
          ),
          ConstrainedBox(
            constraints: const BoxConstraints(maxHeight: 50),
            child: CarouselView(
              itemExtent: 100, // Largeur de base pour chaque item
              shrinkExtent: 80, // Largeur réduite
              children: List<Widget>.generate(20, (int index) {
                return ColoredBox(
                  color: Colors.primaries[index % Colors.primaries.length]
                      .withOpacity(0.8),
                  child: const SizedBox.expand(),
                );
              }),
            ),
          ),
          const SizedBox(height: 20),
          ConstrainedBox(
            constraints: const BoxConstraints(maxHeight: 200),
            child: CarouselView(
                itemExtent: 150, // Largeur de base pour chaque item
                shrinkExtent: 120, // Largeur réduite
                children: CardInfo.values.map((CardInfo info) {
                  return ColoredBox(
                    color: info.backgroundColor,
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          Icon(info.icon, color: info.color, size: 32.0),
                          Text(info.label,
                              style:
                                  const TextStyle(fontWeight: FontWeight.bold),
                              overflow: TextOverflow.clip,
                              softWrap: false),
                        ],
                      ),
                    ),
                  );
                }).toList()),
          ),
          const SizedBox(height: 20),
          const Padding(
            padding: EdgeInsetsDirectional.only(top: 8.0, start: 8.0),
            child: Text('Uncontained layout'),
          ),
          ConstrainedBox(
            constraints: const BoxConstraints(maxHeight: 200),
            child: CarouselView(
              itemExtent: 330,
              shrinkExtent: 200,
              children: List<Widget>.generate(20, (int index) {
                return UncontainedLayoutCard(
                    index: index, label: 'Show $index');
              }),
            ),
          )
        ],
      ),
    );
  }
}

class HeroLayoutCard extends StatelessWidget {
  const HeroLayoutCard({
    super.key,
    required this.title,
    required this.subTitle,
    required this.image,
  });

  final String title;
  final String subTitle;
  final String image;
  @override
  Widget build(BuildContext context) {
    final double width = MediaQuery.sizeOf(context).width;
    return Stack(
        alignment: AlignmentDirectional.bottomStart,
        children: <Widget>[
          ClipRect(
            child: OverflowBox(
              alignment:
                  Alignment.center, // centre l'image dans la zone de recadrage
              maxWidth:
                  width, // double.infinity, // autorise l'image à couvrir toute la largeur
              minWidth: 0.0, // autorise une largeur minimale flexible
              child: ShaderMask(
                shaderCallback: (rect) {
                  return LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.transparent,
                      Colors.black87,
                    ],
                  ).createShader(Rect.fromLTRB(0, 0, rect.width, rect.height));
                },
                blendMode: BlendMode.srcATop,
                child: CachedNetworkImage(
                  imageUrl: image,
                  fit: BoxFit.cover, // remplit toute la zone de recadrage
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(18.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Text(
                  title,
                  overflow: TextOverflow.clip,
                  softWrap: false,
                  style: Theme.of(context)
                      .textTheme
                      .headlineLarge
                      ?.copyWith(color: Colors.white),
                ),
                const SizedBox(height: 10),
                Text(
                  subTitle,
                  overflow: TextOverflow.clip,
                  softWrap: false,
                  style: Theme.of(context)
                      .textTheme
                      .bodyLarge
                      ?.copyWith(color: Colors.white),
                )
              ],
            ),
          ),
        ]);
  }
}

class UncontainedLayoutCard extends StatelessWidget {
  const UncontainedLayoutCard({
    super.key,
    required this.index,
    required this.label,
  });

  final int index;
  final String label;

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: Colors.primaries[index % Colors.primaries.length].withOpacity(0.5),
      child: Center(
        child: Text(
          label,
          style: const TextStyle(color: Colors.white, fontSize: 20),
          overflow: TextOverflow.clip,
          softWrap: false,
        ),
      ),
    );
  }
}

enum CardInfo {
  camera('Cameras', Icons.video_call, Color(0xff2354C7), Color(0xffECEFFD)),
  lighting('Lighting', Icons.lightbulb, Color(0xff806C2A), Color(0xffFAEEDF)),
  climate('Climate', Icons.thermostat, Color(0xffA44D2A), Color(0xffFAEDE7)),
  wifi('Wifi', Icons.wifi, Color(0xff417345), Color(0xffE5F4E0)),
  media('Media', Icons.library_music, Color(0xff2556C8), Color(0xffECEFFD)),
  security(
      'Security', Icons.crisis_alert, Color(0xff794C01), Color(0xffFAEEDF)),
  safety(
      'Safety', Icons.medical_services, Color(0xff2251C5), Color(0xffECEFFD)),
  more('', Icons.add, Color(0xff201D1C), Color(0xffE3DFD8));

  const CardInfo(this.label, this.icon, this.color, this.backgroundColor);
  final String label;
  final IconData icon;
  final Color color;
  final Color backgroundColor;
}

enum ImageInfo {
  image0('The Flow', 'Sponsored | Season 1 Now Streaming',
      'content_based_color_scheme_1.png'),
  image1('Through the Pane', 'Sponsored | Season 1 Now Streaming',
      'content_based_color_scheme_2.png'),
  image2('Iridescence', 'Sponsored | Season 1 Now Streaming',
      'content_based_color_scheme_3.png'),
  image3('Sea Change', 'Sponsored | Season 1 Now Streaming',
      'content_based_color_scheme_4.png'),
  image4('Blue Symphony', 'Sponsored | Season 1 Now Streaming',
      'content_based_color_scheme_5.png'),
  image5('When It Rains', 'Sponsored | Season 1 Now Streaming',
      'content_based_color_scheme_6.png');

  const ImageInfo(this.title, this.subtitle, this.url);
  final String title;
  final String subtitle;
  final String url;
}
