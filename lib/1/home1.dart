import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'transfers_provider.dart';

class home1 extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => TransfersProvider()),
      ],
      child: MaterialApp(
        home: HomeScreen(),
      ),
    );
  }
}

class HomeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Selector<TransfersProvider, double>(
          selector: (context, provider) => provider.balance,
          builder: (context, balance, child) => Text('Solde: \$${balance}'),
        ),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisignment.start,
        children: [
          Selector<TransfersProvider, List<Transfer>>(
            selector: (context, provider) => provider.recentTransfers,
            builder: (context, recentTransfers, child) => SizedBox(
              height: 100,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: recentTransfers.length,
                itemBuilder: (context, index) {
                  final transfer = recentTransfers[index];
                  return Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Text(transfer.toUser),
                    ),
                  );
                },
              ),
            ),
          ),

          // Afficher tous les transferts
          Selector<TransfersProvider, List<Transfer>>(
            selector: (context, provider) => provider.allTransfers,
            builder: (context, allTransfers, child) => Expanded(
              child: ListView.builder(
                itemCount: allTransfers.length,
                itemBuilder: (context, index) {
                  final transfer = allTransfers[index];
                  return ListTile(
                    title: Text(
                      'Transfert de ${transfer.fromUser} à ${transfer.toUser} de \$${transfer.amount}',
                    ),
                    subtitle: Text('Date: ${transfer.date.toLocal()}'),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// // Widget affichant le solde et les utilisateurs récents
// class HomeScreen extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     final provider = Provider.of<TransfersProvider>(context);
//
//     return Scaffold(
//       appBar: AppBar(
//         title: Text('Home'),
//       ),
//       body: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           // Afficher le solde
//           Padding(
//             padding: const EdgeInsets.all(16.0),
//             child: Text(
//               'Solde: \$${provider.balance}',
//               style: TextStyle(fontSize: 24),
//             ),
//           ),
//
//           // Liste horizontale des utilisateurs récents
//           SizedBox(
//             height: 100,
//             child: ListView.builder(
//               scrollDirection: Axis.horizontal,
//               itemCount: provider.recentTransfers.length,
//               itemBuilder: (context, index) {
//                 final transfer = provider.recentTransfers[index];
//                 return Card(
//                   child: Padding(
//                     padding: const EdgeInsets.all(16.0),
//                     child: Text(transfer.toUser),
//                   ),
//                 );
//               },
//             ),
//           ),
//
//           // Historique des transferts
//           Expanded(
//             child: ListView.builder(
//               itemCount: provider.allTransfers.length,
//               itemBuilder: (context, index) {
//                 final transfer = provider.allTransfers[index];
//                 return ListTile(
//                   title: Text(
//                     'Transfert de ${transfer.fromUser} à ${transfer.toUser} de \$${transfer.amount}',
//                   ),
//                   subtitle: Text('Date: ${transfer.date.toLocal()}'),
//                 );
//               },
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }
