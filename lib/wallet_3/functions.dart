import 'package:avatar_glow/avatar_glow.dart';
import 'package:calendar_timeline/calendar_timeline.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:intl/intl.dart' as intl;
import 'package:lottie/lottie.dart';

import 'Models.dart';

class utilsFunctions {
  Future<void> deleteAllDocumentsInCollection(String collectionName) async {
    try {
      final CollectionReference collectionReference =
          FirebaseFirestore.instance.collection(collectionName);

      final QuerySnapshot querySnapshot = await collectionReference.get();

      for (QueryDocumentSnapshot document in querySnapshot.docs) {
        await collectionReference.doc(document.id).delete();
      }

      print(
          'Tous les documents de la collection $collectionName ont été supprimés.');
      Fluttertoast();
    } catch (e) {
      print('Erreur lors de la suppression des documents : $e');
    }
  }

  void showCongratulationsDialog(
      BuildContext context, double Coins, double total) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Félicitations !"),
          content: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              AvatarGlow(
                glowColor: Colors.blue,
                endRadius: 90.0,
                duration: Duration(milliseconds: 2000),
                repeat: true,
                showTwoGlows: true,
                repeatPauseDuration: Duration(milliseconds: 100),
                child: Material(
                  // Replace this child with your own
                  elevation: 8.0,
                  shape: CircleBorder(),
                  child: CircleAvatar(
                    backgroundColor: Colors.grey[100],
                    child: Lottie.asset(
                      'assets/lotties/animation_lmqwfkzg.json',
                      height: 60,
                      width: 60,
                      repeat: true,
                    ),
                    radius: 40.0,
                  ),
                ),
              ),
              FittedBox(
                child: Text(
                  'Envoyer : ' +
                      intl.NumberFormat.currency(
                        locale: 'fr_FR',
                        symbol: 'DZD',
                        decimalDigits: 2,
                      ).format(Coins),
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: Colors.green,
                    fontSize: 30,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ),
              Lottie.asset(
                'assets/lotties/animation_lmqwf1by.json',
                // Chemin vers votre animation Lottie
                width: 150,
                height: 150,
                repeat: true,
                animate: true,
              ),
              SizedBox(height: 20),
              Text(
                'Beneficier Solde : '.toString().capitalize(),
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: Colors.blue,
                  fontSize: 20,
                  fontWeight: FontWeight.w400,
                ),
              ),
              Text(
                intl.NumberFormat.currency(
                  locale: 'fr_FR',
                  symbol: 'DZD',
                  decimalDigits: 2,
                ).format(total),
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: Colors.blue,
                  fontSize: 20,
                  fontWeight: FontWeight.w400,
                ),
              ),
              Text("La transaction a réussi !".toString().capitalize()),
            ],
          ),
          actions: [
            Center(
              child: TextButton(
                onPressed: () {
                  Navigator.of(context).pop(); // Fermez la boîte de dialogue
                },
                child: Text("Fermer"),
              ),
            ),
          ],
        );
      },
    );
  }

  void showTransactionErrorDialog(BuildContext context, String errorMessage) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Erreur de transaction"),
          content: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(
                height: 100,
              ),
              AvatarGlow(
                glowColor: Colors.blue,
                endRadius: 90.0,
                duration: Duration(milliseconds: 2000),
                repeat: true,
                showTwoGlows: true,
                repeatPauseDuration: Duration(milliseconds: 100),
                child: Material(
                  // Replace this child with your own
                  elevation: 8.0,
                  shape: CircleBorder(),
                  child: CircleAvatar(
                    backgroundColor: Colors.grey[100],
                    child: Lottie.asset(
                      'assets/lotties/animation_lmqwfkzg.json',
                      height: 60,
                      width: 60,
                    ),
                    radius: 40.0,
                  ),
                ),
              ),
              Lottie.asset(
                'assets/lotties/animation_lmqwf1by.json',
                // Chemin vers votre animation Lottie
                width: 150,
                height: 150,
                repeat: false,
                animate: true,
              ),
              SizedBox(height: 20),
              Text("Erreur de la transaction!".toString().capitalize()),
            ],
          ),
          actions: [
            Center(
              child: TextButton(
                onPressed: () {
                  Navigator.of(context).pop(); // Fermez la boîte de dialogue
                },
                child: Text("Fermer"),
              ),
            ),
          ],
        );
      },
    );
  }

  void addTransactionToFirestore(
      String senderUserId, String receiverUserId, double amount) async {
    try {
      final Timestamp timestamp = Timestamp.now();
      final TransactionModel transaction = TransactionModel(
        senderUserId: senderUserId,
        receiverUserId: receiverUserId,
        amount: amount,
        timestamp: timestamp,
      );

      final DocumentReference transactionRef =
          FirebaseFirestore.instance.collection('transactions').doc();

      await transactionRef.set(transaction.toMap());
      print('Transaction réussie et ajoutée à la collection Firestore.');
    } catch (e) {
      print('Erreur lors de l\'ajout de la transaction à Firestore : $e');
    }
  }
}
