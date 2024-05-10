// import 'package:flutter/material.dart';
// import 'package:provider/provider.dart';
// import 'providers.dart';
//
// class TransactionPage extends StatefulWidget {
//   final String scannedUserId;
//
//   TransactionPage({required this.scannedUserId});
//
//   @override
//   _TransactionPageState createState() => _TransactionPageState();
// }
//
// class _TransactionPageState extends State<TransactionPage> {
//   @override
//   void initState() {
//     super.initState();
//     //final userProvider = Provider.of<UserProviderFire>(context, listen: false);
//     //  userProvider.loadUser(); // Charger l'utilisateur au démarrage
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//         appBar: AppBar(
//           title: Text("Transaction Page"),
//         ),
//         body: Center(
//             child: Column(
//           children: [
//             Text(widget.scannedUserId),
//           ],
//         )));
//   }
// }
