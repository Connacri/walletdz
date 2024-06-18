// import 'package:flutter/material.dart';
// import 'package:provider/provider.dart';
// import '../../../objectbox.g.dart';
// import '../Entity.dart';
// import '../classeObjectBox.dart';
//
// class FactureListScreen extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     final factureBox = Provider.of<Box<Facture>>(context);
//     final factures = factureBox.getAll();
//
//     return Scaffold(
//       appBar: AppBar(title: Text('Factures')),
//       body: ListView.builder(
//         itemCount: factures.length,
//         itemBuilder: (context, index) {
//           final facture = factures[index];
//           return ListTile(
//             title: Text('Facture ${facture.id}'),
//             subtitle: Text(
//                 'Date: ${facture.date}, Client ID: ${facture.client.targetId}'),
//           );
//         },
//       ),
//     );
//   }
// }
