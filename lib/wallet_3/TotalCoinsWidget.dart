// import 'package:animated_flip_counter/animated_flip_counter.dart';
// import 'package:flutter/material.dart';
// import 'package:lottie/lottie.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'functions.dart';
//
// class TotalCoinsWidget extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     return StreamBuilder<QuerySnapshot>(
//       stream: FirebaseFirestore.instance.collection('gaines').snapshots(),
//       builder: (context, snapshot) {
//         if (!snapshot.hasData) {
//           // Afficher un indicateur de chargement si les données ne sont pas encore disponibles.
//           return Center(
//             child: Padding(
//               padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 10),
//               child: Lottie.asset('assets/lotties/1 (65).json'),
//             ),
//           );
//         }
//
//         final documents = snapshot.data!.docs;
//
//         if (documents.isEmpty) {
//           // Si la liste des documents est vide, affichez un message approprié.
//           return Center(
//             //child: FittedBox(
//             child: Lottie.asset('assets/lotties/1 (14).json', height: 80),
//             // ),
//           );
//         }
//
//         // Calculez le total des "gaines"
//         double totalGaines = 0;
//         for (var document in documents) {
//           totalGaines += document['coins'];
//         }
//         final myUtils = utilsFunctions();
//         return Center(
//             child: InkWell(
//           onTap: () async {
//             try {
//               await myUtils.deleteAllDocumentsInCollection('gaines');
//             } catch (e) {
//               print('Erreur lors de la mise à jour des coins : $e');
//               // Gestion de l'erreur ici
//             }
//           },
//           child: Stack(
//             alignment: Alignment.center,
//             children: [
//               AnimatedFlipCounter(
//                 value: totalGaines,
//                 prefix: "Gaines : ",
//                 suffix: ' DZD',
//                 fractionDigits: 2,
//                 mainAxisAlignment: MainAxisAlignment.start,
//                 duration: const Duration(milliseconds: 800),
//                 textStyle: TextStyle(
//                   fontFamily: 'OSWALD',
//                   color: Colors.teal,
//                   fontSize: 18,
//                   fontWeight: FontWeight.w500,
//                 ),
//               ),
//             ],
//           ),
//         ));
//       },
//     );
//   }
// }
