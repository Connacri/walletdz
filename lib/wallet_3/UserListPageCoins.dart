import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutterflow_paginate_firestore/bloc/pagination_listeners.dart';
import 'package:flutterflow_paginate_firestore/paginate_firestore.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:lottie/lottie.dart';

import '../f_wallet/usersList.dart';

class UserListPageCoins extends StatelessWidget {
  const UserListPageCoins({
    super.key,
    required this.userId,
  });

  final String userId;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: StreamBuilder<QuerySnapshot>(
          stream: getUsersListStream(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(
                  child: Container(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator()));
            }

            if (snapshot.hasError) {
              return Center(child: Text('Erreur : ${snapshot.error}'));
            }

            // Affichez la liste des utilisateurs en temps réel dans une ListView.builder
            List<DocumentSnapshot> users = snapshot.data!.docs;
            int nombre = snapshot.data!.size;
            return FittedBox(child: Text('${nombre} users'));
          },
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.fromLTRB(0, 0, 20, 0),
            child: StreamBuilder<double>(
              stream: getTotalCoinsStream(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Container(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator());
                }

                if (snapshot.hasError) {
                  return Text('Erreur : ${snapshot.error}');
                }

                // Affichez le total des coins en temps réel dans la barre de navigation
                return Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                      'Total des Coins : ${snapshot.data!.toStringAsFixed(2)}'),
                );
              },
            ),
          ),
          IconButton.filledTonal(
              onPressed: () {
                Navigator.of(context).push(
                    MaterialPageRoute(builder: (context) => Historique()));
              },
              icon: Icon(FontAwesomeIcons.moneyBillTrendUp))
        ],
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: getUsersListStream(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
                child: Container(
                    height: 30, width: 30, child: CircularProgressIndicator()));
          }

          if (snapshot.hasError) {
            return Center(child: Text('Erreur : ${snapshot.error}'));
          }

          // Affichez la liste des utilisateurs en temps réel dans une ListView.builder
          List<DocumentSnapshot> users = snapshot.data!.docs;
          int nombre = snapshot.data!.size;
          return ListView.builder(
            itemCount: users.length,
            itemBuilder: (context, index) {
              var user = users[index];
              String displayName = user['displayName'] ?? 'Utilisateur';
              String email = user['email'] ?? 'N/A';
              double coins = user['coins'] ?? 0.0;
              // users.sort((a, b) {
              //   double coinsA = a['coins'] ?? 0.0;
              //   double coinsB = b['coins'] ?? 0.0;
              //   return coinsB.compareTo(coinsA); // Trie en ordre décroissant
              // });
              return ListTile(
                leading: InkWell(
                    onTap: () {
                      //   Navigator.of(context).push(MaterialPageRoute(
                      //    builder: (context) =>
                      //    TransactionPage(scannedUserId: users[index].id)));
                    },
                    child: FutureBuilder<DocumentSnapshot>(
                      future: FirebaseFirestore.instance
                          .collection('Users')
                          .doc(user.id)
                          .get(),
                      builder: (BuildContext context,
                          AsyncSnapshot<DocumentSnapshot> snapshot) {
                        if (snapshot.hasError) {
                          return Text("Something went wrong");
                        }

                        if (snapshot.hasData && !snapshot.data!.exists) {
                          return Text("Document does not exist");
                        }

                        if (snapshot.connectionState == ConnectionState.done) {
                          Map<String, dynamic> data =
                              snapshot.data!.data() as Map<String, dynamic>;
                          return CircleAvatar(
                            backgroundImage: NetworkImage(user['avatar'] ?? ''),
                          );
                        }

                        return Text("loading");
                      },
                    )),
                title: Text(displayName),
                subtitle: Text(email),
                trailing: InkWell(
                    onTap: () async {
                      try {
                        await FirebaseFirestore.instance
                            .collection('Users')
                            .doc(user.id)
                            .update({'coins': 0.0});
                      } catch (e) {
                        print('Erreur lors de la mise à jour des coins : $e');
                        // Gestion de l'erreur ici
                      }
                    },
                    child: Text(coins.toStringAsFixed(2))),
              );
            },
          );
        },
      ),
    );
  }

  Stream<QuerySnapshot> getUsersListStream() {
    return FirebaseFirestore.instance
        .collection('Users')
        // .doc(userId)
        // .collection('transactions')
        .snapshots();
  }

  Stream<double> getTotalCoinsStream() {
    return getUsersListStream().map((querySnapshot) {
      double totalCoins = 0.0;
      for (QueryDocumentSnapshot doc in querySnapshot.docs) {
        double coins = doc['coins'] ?? 0.0;
        totalCoins += coins;
      }
      return totalCoins;
    });
  }
}

class MyWidgetPaginateFirestore extends StatefulWidget {
  const MyWidgetPaginateFirestore({
    super.key,
    required this.userId,
  });

  final String userId;

  @override
  State<MyWidgetPaginateFirestore> createState() =>
      _MyWidgetPaginateFirestoreState();
}

class _MyWidgetPaginateFirestoreState extends State<MyWidgetPaginateFirestore> {
  PaginateRefreshedChangeListener refreshChangeListener =
      PaginateRefreshedChangeListener();

  @override
  Widget build(BuildContext context) {
    return
        //RefreshIndicator(
        //  child:
        PaginateFirestore(
      //onEmpty: const EmptyDisplay(),
      //separator: const EmptySeparator(),
      //initialLoader: const InitialLoader(),
      //bottomLoader: const BottomLoader(),

      //physics: ScrollPhysics(parent: BouncingScrollPhysics()),
      scrollDirection: Axis.horizontal,
      // isLive: true,
      itemBuilderType: PaginateBuilderType.listView,
      itemBuilder: (context, documentSnapshots, index) => Center(
        child: FutureBuilder<DocumentSnapshot<Map<String, dynamic>>>(
          future: FirebaseFirestore.instance
              .collection('Users')
              .doc(documentSnapshots[index]['id'])
              .get(),
          builder: (BuildContext context,
              AsyncSnapshot<DocumentSnapshot<Map<String, dynamic>>> snapshot) {
            if (snapshot.hasData) {
              return Container(
                padding: EdgeInsets.all(5),
                height: 60,
                width: 60,
                child: CircleAvatar(
                  radius: 100,
                  backgroundImage:
                      CachedNetworkImageProvider(snapshot.data!['avatar']),
                ),
              );
            } else {
              return Center(
                  child: Container(
                      height: 2,
                      width: MediaQuery.of(context).size.width,
                      child: CircularProgressIndicator()));
            }
            //{
            //  return CircleAvatar(child: Icon(Icons.person));
            // }
          },
        ),
      ),
      // orderBy is compulsary to enable pagination
      query: FirebaseFirestore.instance
          .collection('Users')
          .doc(widget.userId)
          .collection('transactions'),
      // listeners: [
      //  refreshChangeListener,
      //  ],
    ) //,
        //onRefresh: () async {
        // refreshChangeListener.refreshed = true;
        // },
        // )
        ;
  }
}

class listhorizontal5 extends StatefulWidget {
  const listhorizontal5({
    super.key,
    required this.userId,
  });

  final String userId;

  @override
  State<listhorizontal5> createState() => _listhorizontal5State();
}

class _listhorizontal5State extends State<listhorizontal5> {
  @override
  Widget build(BuildContext context) {
    Map<String, dynamic> lastElements = {};
    return Expanded(
      child: StreamBuilder(
        stream: FirebaseFirestore.instance
            .collection('Users')
            .doc(widget.userId)
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
              child:
                  Lottie.asset('assets/lotties/1 (8).json', fit: BoxFit.cover),
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
                        padding: const EdgeInsets.all(10.0),
                        child: Container(
                          width: avatarSize + 20,
                          height: avatarSize + 20,
                          child: CircleAvatar(
                            backgroundColor: Colors.transparent,
                            // Permet à l'image de couvrir complètement le cercle
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
                              ),
                              // Placeholder pendant le chargement de l'image
                              errorWidget: (context, url, error) =>
                                  Icon(Icons.error),
                              // Widget à afficher en cas d'erreur de chargement de l'image
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
      ),
    );
  }
}
