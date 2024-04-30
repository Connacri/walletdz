import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

class lastUsersList extends StatelessWidget {
  const lastUsersList({
    super.key,
    required this.userId,
  });

  final String userId;
  @override
  Widget build(BuildContext context) {
    Map<String, dynamic> lastElements = {};
    return StreamBuilder(
      stream: FirebaseFirestore.instance
          .collection('Users')
          .doc(userId)
          .collection('transactions')
          .limit(5)
          .snapshots(),
      builder: (BuildContext ctx,
          AsyncSnapshot<QuerySnapshot<Map<String, dynamic>>> snap) {
        if (snap.hasError) {
          return Center(
            child: Text("Erreur : ${snap.error}"),
          );
        } else if (!snap.hasData ||
            snap.data == null ||
            snap.data!.docs.isEmpty) {
          return Center(
            child: Lottie.asset('assets/lotties/1 (8).json', fit: BoxFit.cover),
            //Text("Aucune transaction disponible."),
          );
        } else {
          // Parcourir chaque document
          snap.data!.docs.forEach((doc) {
            // Récupérer l'ID du document
            String id = doc['id'];

            // Mettre à jour le Map avec le dernier élément de chaque ID
            lastElements[id] = doc.data();
          });

          return ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: lastElements.length,
            shrinkWrap: true,
            itemBuilder: (BuildContext context, int index) {
              // Récupérer la clé (ID) et la valeur (dernier élément) du Map
              String id = lastElements.keys.elementAt(index);
              //dynamic user = lastElements[id];

              //Afficher les données dans votre élément de liste
              return FutureBuilder(
                future: FirebaseFirestore.instance
                    .collection('Users')
                    .doc(id)
                    .get(),
                builder: (BuildContext ctx,
                    AsyncSnapshot<DocumentSnapshot<Map<String, dynamic>>>
                        userSnapshot) {
                  if (userSnapshot.hasError) {
                    return Text("Erreur : ${userSnapshot.error}");
                  }

                  if (!userSnapshot.hasData || userSnapshot.data == null) {
                    return Container(); // Return an empty container if no data
                  }

                  final user =
                      userSnapshot.data!.data() as Map<String, dynamic>;
                  double avatarSize = 40.0;
                  return Padding(
                      padding: const EdgeInsets.all(5.0),
                      child: Container(
                        width: avatarSize + 20,
                        height: avatarSize + 20,
                        child: CircleAvatar(
                          backgroundColor: Colors
                              .transparent, // Permet à l'image de couvrir complètement le cercle
                          child: CachedNetworkImage(
                            imageUrl: user['avatar'],
                            imageBuilder: (context, imageProvider) =>
                                CircleAvatar(
                              backgroundImage: imageProvider,
                              radius: avatarSize,
                            ),
                            placeholder: (context, url) =>
                                CircularProgressIndicator(
                              strokeWidth: 2,
                            ), // Placeholder pendant le chargement de l'image
                            errorWidget: (context, url, error) => Icon(Icons
                                .error), // Widget à afficher en cas d'erreur de chargement de l'image
                            fit: BoxFit.cover,
                          ),
                        ),
                      )

                      // CircleAvatar(
                      //   radius: 20,
                      //   backgroundColor: Colors.grey, // Add a background color
                      //   backgroundImage: CachedNetworkImageProvider(
                      //       user['avatar']), // Provide a default avatar
                      // ),
                      );
                },
              );
            },
          );
        }
      },
    );
  }
}