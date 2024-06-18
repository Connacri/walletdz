// import 'package:flutter/material.dart';
// import 'package:provider/provider.dart';
//
//
// class ClientListScreen extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     final clientBox = Provider.of<Box<Client>>(context);
//     final clients = clientBox.getAll();
//
//     return Scaffold(
//       appBar: AppBar(title: Text('Clients')),
//       body: ListView.builder(
//         itemCount: clients.length,
//         itemBuilder: (context, index) {
//           final client = clients[index];
//           return ListTile(
//             title: Text(client.nom),
//           );
//         },
//       ),
//     );
//   }
// }
