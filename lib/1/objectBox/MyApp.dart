import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'Entity.dart';
import 'MyProviders.dart';
import 'classeObjectBox.dart';
import 'pages/ClientListScreen.dart';
import 'pages/FactureListScreen.dart';
import 'pages/FournisseurListScreen.dart';
import 'pages/ProduitListScreen.dart';

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
  // final ObjectBox objectBox;
  //
  // MyApp99({required this.objectBox});

  @override
  Widget build(BuildContext context) {
    final objectBox = Provider.of<ObjectBox?>(context);
    if (objectBox == null) {
      return Center(child: CircularProgressIndicator());
    }

    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => ProduitProvider(
            objectBox,
          ),
        ),
        ChangeNotifierProvider(
          create: (_) => FournisseurProvider(objectBox),
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

        home: HomeScreen(
          objectBox: objectBox,
        ),
      ),
    );
  }
}

class HomeScreen extends StatelessWidget {
  final ObjectBox objectBox;

  HomeScreen({required this.objectBox});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Facturation'),
        actions: [
          IconButton(
            onPressed: () {
              objectBox.fillWithFakeData(1000);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Données factices ajoutées !')),
              );
            },
            icon: Icon(Icons.send),
          ),
        ],
      ),
      body: ListView(
        children: [
          Card(
            child: ListTile(
              title: Text('Produits'),
              onTap: () {
                Navigator.of(context).push(MaterialPageRoute(
                    builder: (context) => ProduitListScreen()));
              },
            ),
          ),
          Card(
            child: ListTile(
              title: Text('Fournisseurs'),
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
                  SnackBar(content: Text('Base de Données Vider avec succes!')),
                );
              },
              style: ButtonStyle(
                backgroundColor: WidgetStateProperty.all<Color>(Colors.red),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// class Reset extends StatelessWidget {
//   final ObjectBox objectBox;
//
//   Reset({required this.objectBox});
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text('Facturation'),
//         actions: [
//           IconButton(
//             onPressed: () {
//               objectBox.fillWithFakeData(
//                   100); // Remplir avec 100 enregistrements factices
//               ScaffoldMessenger.of(context).showSnackBar(
//                 SnackBar(content: Text('Données factices ajoutées !')),
//               );
//             },
//             icon: Icon(Icons.send),
//           ),
//         ],
//       ),
//       body: ListView(
//         children: [
//           Card(
//             child: ListTile(
//               title: Text('Produits'),
//               onTap: () {
//                 Navigator.of(context).push(MaterialPageRoute(
//                     builder: (context) => ProduitListScreen()));
//               },
//             ),
//           ),
//           Card(
//             child: ListTile(
//               title: Text('Fournisseurs'),
//               onTap: () {
//                 Navigator.of(context).push(MaterialPageRoute(
//                     builder: (context) => FournisseurListScreen()));
//               },
//             ),
//           ),
//           SizedBox(height: 30),
//           Padding(
//             padding: const EdgeInsets.symmetric(horizontal: 30),
//             child: ElevatedButton(
//               child: Text('Delete all'),
//               onPressed: () {
//                 objectBox.clearDatabase();
//                 ScaffoldMessenger.of(context).showSnackBar(
//                   SnackBar(content: Text('Base de Données Vidée avec succès!')),
//                 );
//               },
//               style: ButtonStyle(
//                 backgroundColor: MaterialStateProperty.all<Color>(Colors.red),
//               ),
//             ),
//           ),
//           SizedBox(height: 10),
//           Padding(
//             padding: const EdgeInsets.symmetric(horizontal: 30),
//             child: ElevatedButton(
//               child: Text('Reset Database'),
//               onPressed: () async {
//                 await objectBox.resetDatabase();
//                 ScaffoldMessenger.of(context).showSnackBar(
//                   SnackBar(
//                       content:
//                           Text('Base de Données Réinitialisée avec succès!')),
//                 );
//               },
//               style: ButtonStyle(
//                 backgroundColor:
//                     MaterialStateProperty.all<Color>(Colors.orange),
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }
