import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'ClientProvider.dart';

class ClientScreen extends StatefulWidget {
  @override
  State<ClientScreen> createState() => _ClientScreenState();
}

class _ClientScreenState extends State<ClientScreen> {
  @override
  void initState() {
    super.initState();
    // Appel de fetchFournisseurs lors de la création de l'écran
    Provider.of<ClientProvider>(context, listen: false).fetchClients();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Clients'),
      ),
      body: Consumer<ClientProvider>(
        builder: (context, clientProvider, child) {
          return ListView.builder(
            itemCount: clientProvider.clients.length,
            itemBuilder: (context, index) {
              final client = clientProvider.clients[index];
              return ListTile(
                title: Text(client.nom),
                subtitle: Text(client.adresse),
                onTap: () {
                  // Afficher les détails du client
                },
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Ajouter un nouveau client
        },
        child: Icon(Icons.add),
      ),
    );
  }
}
