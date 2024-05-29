import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'DetailFactureProvider.dart';

class DetailFactureScreen extends StatefulWidget {
  final int factureId;
  final int idClient;
  final String nomClient;
  DetailFactureScreen(
      {required this.factureId,
      required this.idClient,
      required this.nomClient});

  @override
  _DetailFactureScreenState createState() => _DetailFactureScreenState();
}

class _DetailFactureScreenState extends State<DetailFactureScreen> {
  double totalFacture = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('${widget.nomClient} '),
        actions: [
          Consumer<DetailFactureProvider>(
            builder: (context, detailFactureProvider, _) {
              final calcul = detailFactureProvider.totalFacture;
              final tva = calcul * 19 / 100;
              final ttc = calcul + tva;
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      'Total : ${calcul.toStringAsFixed(2)} DZD',
                      style:
                          TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                    ),
                    Text(
                      'TVA 19% : ${tva.toStringAsFixed(2)} DZD',
                      style:
                          TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                    ),
                    Text(
                      'TTC : ${ttc.toStringAsFixed(2)} DZD',
                      style:
                          TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
      body: Consumer<DetailFactureProvider>(
        builder: (context, detailFactureProvider, child) {
          detailFactureProvider.fetchDetailsFacture(widget.factureId);
          // Calculer le total de la facture à partir des détails de la facture
          totalFacture = detailFactureProvider.detailsFacture.fold(
            0,
            (previousValue, detailFacture) =>
                previousValue +
                (detailFacture['prix_unitaire'] * detailFacture['quantite']),
          );
          return ListView.builder(
            itemCount: detailFactureProvider.detailsFacture.length,
            itemBuilder: (context, index) {
              final detailFacture = detailFactureProvider.detailsFacture[index];
              return Card(
                child: ListTile(
                  dense: true,
                  leading: CircleAvatar(
                    child: Text(detailFacture['quantite'].toString()),
                  ),
                  title: Text(
                    'Produit: ${detailFacture['produit_nom'] ?? 'Nom du produit non disponible'}',
                    overflow: TextOverflow.ellipsis,
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Description: ${detailFacture['produit_description'] ?? 'Description non disponible'}',
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        'PU : ${detailFacture['prix_unitaire'].toStringAsFixed(2)} DZD',
                      ),
                    ],
                  ),
                  trailing: Text(
                    '${(detailFacture['prix_unitaire'] * detailFacture['quantite']).toStringAsFixed(2)} DZD',
                    style: TextStyle(fontSize: 20),
                  ),
                  onTap: () {
                    print(detailFactureProvider.detailsFacture.toList());
                  },
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Ajouter un nouveau détail de facture
        },
        child: Icon(Icons.add),
      ),
    );
  }
}
