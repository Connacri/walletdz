import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../Entity.dart';
import '../MyProviders.dart';

class ClientListScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Clients')),
      body: Consumer<ClientProvider>(
        builder: (context, clientProvider, child) {
          final clients = clientProvider.clients;

          return ListView.builder(
            itemCount: clients.length,
            itemBuilder: (context, index) {
              final client = clients[index];
              return Card(
                child: ListTile(
                  onTap: () {
                    Navigator.of(context).push(MaterialPageRoute(
                        builder: (ctx) => ClientDetailScreen(
                              client: client,
                            )));
                  },
                  title: Text(client.nom),
                  subtitle: Text(client.phone.toString()),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: Icon(Icons.edit),
                        onPressed: () =>
                            _showEditDialog(context, client, clientProvider),
                      ),
                      IconButton(
                        icon: Icon(Icons.delete),
                        onPressed: () => clientProvider.deleteClient(client),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  Future<void> _showEditDialog(BuildContext context, Client client,
      ClientProvider clientProvider) async {
    final TextEditingController nameController =
        TextEditingController(text: client.nom);
    final TextEditingController phoneController =
        TextEditingController(text: client.phone);
    final TextEditingController addressController =
        TextEditingController(text: client.adresse);
    final TextEditingController descriptionController =
        TextEditingController(text: client.description);

    return showDialog<void>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Modifier le client'),
          content: SingleChildScrollView(
            child: Column(
              children: [
                TextField(
                  controller: nameController,
                  decoration: InputDecoration(labelText: 'Nom'),
                ),
                TextField(
                  controller: phoneController,
                  decoration: InputDecoration(labelText: 'Téléphone'),
                ),
                TextField(
                  controller: addressController,
                  decoration: InputDecoration(labelText: 'Adresse'),
                ),
                TextField(
                  controller: descriptionController,
                  decoration: InputDecoration(labelText: 'Description'),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('Annuler'),
            ),
            TextButton(
              onPressed: () async {
                client.nom = nameController.text;
                client.phone = phoneController.text;
                client.adresse = addressController.text;
                client.description = descriptionController.text;

                await clientProvider.updateClient(client);
                Navigator.of(context).pop();
              },
              child: Text('Sauvegarder'),
            ),
          ],
        );
      },
    );
  }
}

class ClientDetailScreen extends StatelessWidget {
  final Client client;

  ClientDetailScreen({required this.client});

  @override
  Widget build(BuildContext context) {
    final clientProvider = Provider.of<ClientProvider>(context, listen: false);
    final TextEditingController nameController =
        TextEditingController(text: client.nom);
    final TextEditingController phoneController =
        TextEditingController(text: client.phone);
    final TextEditingController addressController =
        TextEditingController(text: client.adresse);
    final TextEditingController descriptionController =
        TextEditingController(text: client.description);

    return Scaffold(
      appBar: AppBar(
        title: Text('Détails du Client'),
        actions: [
          IconButton(
            icon: Icon(Icons.delete),
            onPressed: () async {
              await clientProvider.deleteClient(client);
              Navigator.of(context).pop();
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: nameController,
              decoration: InputDecoration(labelText: 'Nom'),
            ),
            TextField(
              controller: phoneController,
              decoration: InputDecoration(labelText: 'Téléphone'),
            ),
            TextField(
              controller: addressController,
              decoration: InputDecoration(labelText: 'Adresse'),
            ),
            TextField(
              controller: descriptionController,
              decoration: InputDecoration(labelText: 'Description'),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () async {
                client.nom = nameController.text;
                client.phone = phoneController.text;
                client.adresse = addressController.text;
                client.description = descriptionController.text;

                await clientProvider.updateClient(client);
                Navigator.of(context).pop();
              },
              child: Text('Sauvegarder'),
            ),
          ],
        ),
      ),
    );
  }
}
