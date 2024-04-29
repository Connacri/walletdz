import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class deleteCollection extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: Text('Suppression de Documents'),
        ),
        body: Center(
          child: ElevatedButton(
            onPressed: () async {
              // Appel de la fonction pour supprimer tous les documents
              await deleteAllDocuments('FoodPods');
              await deleteAllDocuments('requeteError');
            },
            child: Text('Supprimer Tous les Documents'),
          ),
        ),
      ),
    );
  }
}

// Fonction pour supprimer tous les documents d'une collection
Future<void> deleteAllDocuments(String collectionName) async {
  try {
    // Récupérer tous les documents de la collection
    QuerySnapshot querySnapshot =
        await FirebaseFirestore.instance.collection(collectionName).get();

    // Supprimer chaque document de la collection
    for (QueryDocumentSnapshot document in querySnapshot.docs) {
      await document.reference.delete();
    }

    print(
        'Tous les documents de la collection $collectionName ont été supprimés avec succès');
  } catch (e) {
    print('Erreur lors de la suppression des documents de la collection : $e');
  }
}
