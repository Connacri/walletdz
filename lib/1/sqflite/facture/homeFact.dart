import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'ClientProvider.dart';
import 'ClientScreen.dart';
import 'DataGenerator.dart';
import 'DatabaseHelper.dart';
import 'DetailFactureProvider.dart';
import 'FactureProvider.dart';
import 'FactureScreen.dart';
import 'FournisseurProvider.dart';
import 'FournisseurScreen.dart';
import 'ProduitProvider.dart';
import 'ProduitScreen.dart';

class homeFact extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => FournisseurProvider()),
        ChangeNotifierProvider(create: (_) => ClientProvider()),
        ChangeNotifierProvider(create: (_) => ProduitProvider()),
        ChangeNotifierProvider(create: (_) => FactureProvider()),
        ChangeNotifierProvider(create: (_) => DetailFactureProvider()),
      ],
      child: MaterialApp(
        title: 'Gestion de Stock et Facturation',
        theme: ThemeData(
          primarySwatch: Colors.blue,
        ),
        initialRoute: '/',
        routes: {
          '/': (context) => HomeScreen(),
          '/fournisseurs': (context) => FournisseurScreen(),
          '/clients': (context) => ClientScreen(),
          '/produits': (context) => ProduitScreen(),
          '/factures': (context) => FactureScreen(),
        },
      ),
    );
  }
}

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool _isGenerating = false;

  void _generateData() async {
    setState(() {
      _isGenerating = true;
    });

    await DataGenerator.generateData();

    setState(() {
      _isGenerating = false;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Les données ont été générées avec succès')),
    );
  }

  void _resetDatabase() async {
    setState(() {
      _isGenerating = true;
    });

    await DatabaseHelper().deleteDatabaseFile();

    setState(() {
      _isGenerating = false;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Base de données Supprimer avec succès')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Gestion de Stock et Facturation'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: _isGenerating ? null : _generateData,
              child: _isGenerating
                  ? CircularProgressIndicator(
                      color: Colors.white,
                    )
                  : Text('Générer des données'),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _resetDatabase,
              child: Text('Supprimer la base de données'),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                Navigator.pushNamed(context, '/fournisseurs');
              },
              child: Text('Gérer les fournisseurs'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pushNamed(context, '/clients');
              },
              child: Text('Gérer les clients'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pushNamed(context, '/produits');
              },
              child: Text('Gérer les produits'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pushNamed(context, '/factures');
              },
              child: Text('Gérer les factures'),
            ),
          ],
        ),
      ),
    );
  }
}
