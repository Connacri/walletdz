import 'package:flutter/material.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:faker/faker.dart';
import 'DatabaseHelper.dart';
import 'models.dart';

class MySqfliteApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Gestion de Stock et Facturation',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: HomeScreen(),
    );
  }
}

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final DatabaseHelper databaseHelper = DatabaseHelper();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Gestion de Stock et Facturation'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            ElevatedButton(
              onPressed: () {
                databaseHelper.fillWithFakeData();
              },
              child: Text('Remplir la base de données'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => ProductsScreen()),
                );
              },
              child: Text('Gestion des Produits'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => ClientsScreen()),
                );
              },
              child: Text('Gestion des Clients'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => FacturesScreen()),
                );
              },
              child: Text('Gestion des Factures'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => FournisseurListScreen()),
                );
              },
              child: Text('Gestion des Fournisseurs'),
            ),
            ElevatedButton(
              onPressed: () async {
                await databaseHelper.clearDatabase();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Database cleared successfully')),
                );
              },
              child: Text('Clear Database'),
            ),
          ],
        ),
      ),
    );
  }
}

class ProductsScreen extends StatelessWidget {
  final DatabaseHelper dbHelper = DatabaseHelper();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Gestion des Produits'),
      ),
      body: FutureBuilder<List<Produit>>(
        future: dbHelper.getProduits(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
              child: CircularProgressIndicator(),
            );
          } else if (snapshot.hasError) {
            return Center(
              child: Text('Erreur: ${snapshot.error}'),
            );
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(
              child: Text('Aucun produit trouvé'),
            );
          } else {
            final produits = snapshot.data!;
            return ListView.builder(
              itemCount: produits.length,
              itemBuilder: (context, index) {
                final produit = produits[index];
                return ListTile(
                  title: Text(produit.name!),
                  subtitle: Text('Prix Vente: ${produit.prixVente}'),
                  trailing: IconButton(
                    icon: Icon(Icons.delete),
                    onPressed: () {
                      dbHelper.deleteProduit(produit.idProduit!);
                    },
                  ),
                );
              },
            );
          }
        },
      ),
    );
  }
}

class ClientsScreen extends StatelessWidget {
  final DatabaseHelper dbHelper = DatabaseHelper();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Gestion des Clients'),
      ),
      body: FutureBuilder<List<Client>>(
        future: dbHelper.getClients(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
              child: CircularProgressIndicator(),
            );
          } else if (snapshot.hasError) {
            return Center(
              child: Text('Erreur: ${snapshot.error}'),
            );
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(
              child: Text('Aucun client trouvé'),
            );
          } else {
            final clients = snapshot.data!;
            return ListView.builder(
              itemCount: clients.length,
              itemBuilder: (context, index) {
                final client = clients[index];
                return ListTile(
                  title: Text(client.nom),
                  subtitle: Text('Téléphone: ${client.telephone}'),
                  trailing: IconButton(
                    icon: Icon(Icons.delete),
                    onPressed: () {
                      dbHelper.deleteClient(client.idClient!);
                    },
                  ),
                );
              },
            );
          }
        },
      ),
    );
  }
}

class FacturesScreen extends StatelessWidget {
  final DatabaseHelper dbHelper = DatabaseHelper();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Gestion des Factures'),
      ),
      body: FutureBuilder<List<Facture>>(
        future: dbHelper.getFactures(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
              child: CircularProgressIndicator(),
            );
          } else if (snapshot.hasError) {
            return Center(
              child: Text('Erreur: ${snapshot.error}'),
            );
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(
              child: Text('Aucune facture trouvée'),
            );
          } else {
            final factures = snapshot.data!;
            return ListView.builder(
              itemCount: factures.length,
              itemBuilder: (context, index) {
                final facture = factures[index];
                return GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            DetailFacturePage(idFacture: facture.idFacture!),
                      ),
                    );
                  },
                  child: ListTile(
                    title: Text('Facture #${facture.idFacture}'),
                    subtitle: Text(
                        'Prix Vente: ${facture.idClient} - Date: ${facture.date}'),
                    trailing: IconButton(
                      icon: Icon(Icons.delete),
                      onPressed: () {
                        dbHelper.deleteFacture(facture.idFacture!);
                      },
                    ),
                  ),
                );
              },
            );
          }
        },
      ),
    );
  }
}

class FournisseurListScreen extends StatefulWidget {
  @override
  _FournisseurListScreenState createState() => _FournisseurListScreenState();
}

class _FournisseurListScreenState extends State<FournisseurListScreen> {
  late Future<List<Fournisseur>> _fournisseursFuture;
  final dbHelper = DatabaseHelper();

  @override
  void initState() {
    super.initState();
    _fournisseursFuture = dbHelper.getAllFournisseurs();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Liste des fournisseurs'),
      ),
      body: FutureBuilder<List<Fournisseur>>(
        future: _fournisseursFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Erreur : ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text('Aucun fournisseur trouvé.'));
          } else {
            List<Fournisseur> fournisseurs = snapshot.data!;
            return ListView.builder(
              itemCount: fournisseurs.length,
              itemBuilder: (context, index) {
                Fournisseur fournisseur = fournisseurs[index];
                return ListTile(
                  title: Text(fournisseur.nom),
                  subtitle: Text(fournisseur.contact),
                  // Vous pouvez ajouter d'autres informations du fournisseur ici
                );
              },
            );
          }
        },
      ),
    );
  }
}

class DetailFacturePage extends StatelessWidget {
  final int idFacture;

  const DetailFacturePage({Key? key, required this.idFacture})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Détails de la facture'),
      ),
      body: FutureBuilder<Map<Facture, List<Produit>>>(
        future: DatabaseHelper().getDetailsFacture(idFacture),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            print(snapshot.error);
            return Center(
                child: Text('Une erreur s\'est produite : ${snapshot.error}'));
          } else {
            Facture facture = snapshot.data!.keys.first;
            List<Produit> produits = snapshot.data!.values.first;

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ListTile(
                  title: Text('Numéro de facture: ${facture.numero}'),
                  subtitle: Text('Date: ${facture.date}'),
                ),
                Divider(),
                ListTile(
                  title: Text('Produits associés à cette facture:'),
                ),
                Expanded(
                  child: ListView.builder(
                    itemCount: produits.length,
                    itemBuilder: (context, index) {
                      Produit produit = produits[index];
                      return ListTile(
                        title: Text(produit.name),
                        subtitle: Text('Prix de vente: ${produit.prixVente}'),
                        // Ajoutez d'autres détails du produit selon vos besoins
                      );
                    },
                  ),
                ),
              ],
            );
          }
        },
      ),
    );
  }
}
