import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class deleteCollection extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: Text('Suppression de Document'),
        ),
        body: Center(
          child: ElevatedButton(
            onPressed: () async {
              // Appel de la fonction pour supprimer le document
              await deleteDocument(
                  'votre_collection', 'document_id_a_supprimer');
            },
            child: Text('Supprimer Document'),
          ),
        ),
      ),
    );
  }
}

// Fonction pour supprimer un document par son ID
Future<void> deleteDocument(String collectionName, String documentId) async {
  try {
    // Référence au document spécifié
    DocumentReference documentReference =
        FirebaseFirestore.instance.collection(collectionName).doc(documentId);

    // Supprimer le document
    await documentReference.delete();
    print(
        'Document $documentId supprimé avec succès de la collection $collectionName');
  } catch (e) {
    print('Erreur lors de la suppression du document : $e');
  }
}
