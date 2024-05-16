import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart' as intl;
import 'package:lottie/lottie.dart';
import 'package:provider/provider.dart';
import 'package:walletdz/wallet_3/payment.dart';

import '../MyListLotties.dart';
import '../Profile.dart';
import '../wallet_3/QrScanner.dart';
import '../wallet_3/UserListPageCoins.dart';
import 'mainLocal.dart';

class h0me extends StatelessWidget {
  const h0me({
    super.key,
    required this.userId,
  });

  final String userId;

  @override
  Widget build(BuildContext context) {
    // Récupérez le modèle UserProvider à partir du provider.
    final userModel = Provider.of<UserProvider>(context);
    userModel.fetchUserAndWatchCoins(userId);

    return Scaffold(
      body: CustomScrollView(
        shrinkWrap: true,
        clipBehavior: Clip.hardEdge,
        slivers: [
          SliverPersistentHeader(
            pinned: true,
            delegate: NetworkingPageHeader(),
          ),
          SliverToBoxAdapter(
            child: Center(
              child: ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => LottieListPage(),
                    ),
                  );
                },
                child: Text('Open Lottie Files List'),
              ),
            ),

            // SizedBox(
            //   height: 20,
            //   width: MediaQuery.of(context).size.width,
            // ),
          ),
          // SliverToBoxAdapter(
          //   child: Center(
          //     child: Padding(
          //       padding: const EdgeInsets.all(18.0),
          //       child: Wrap(
          //         children: [
          //           ElevatedButton(
          //             onPressed: () => Navigator.of(context).push(
          //                 MaterialPageRoute(
          //                     builder: (context) => MyAppTwoDimentional())),
          //             child: Text('2 Dimentional'),
          //           ),
          //           ElevatedButton(
          //             onPressed: () => Navigator.of(context).push(
          //                 MaterialPageRoute(builder: (context) => JsonTest())),
          //             child: Text('JsonTest'),
          //           ),
          //           ElevatedButton(
          //             onPressed: () => Navigator.of(context).push(
          //                 MaterialPageRoute(
          //                     builder: (context) => TotalCoinsWidget())),
          //             child: Text('TotalCoinsWidget'),
          //           ),
          //         ],
          //       ),
          //     ),
          //   ),
          // ),

          SliverToBoxAdapter(
              child: Container(
            height: 80,
            child: listhorizontal5(
              userId: userId,
            ),
            width: MediaQuery.of(context).size.width,
          )),
          // SliverToBoxAdapter(
          //   child: Center(
          //     child: TotalCoinsWidget(),
          //   ),
          // ),
          SliverToBoxAdapter(
            child: Container(
              height: 150,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Card(
                      child: GestureDetector(
                          onTap: () {
                            Navigator.of(context).push(MaterialPageRoute(
                                builder: (context) => QrScanner()));
                          },
                          child: Lottie.asset('assets/lotties/1 (85).json',
                              fit: BoxFit.cover)),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Card(
                      child: GestureDetector(
                          onTap: () {
                            Navigator.of(context).push(MaterialPageRoute(
                                builder: (context) => UserListPageCoins(
                                      userId: userId,
                                    )));
                          },
                          child: Lottie.asset('assets/lotties/1 (17).json',
                              fit: BoxFit.cover)),
                    ),
                  ),
                ],
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Container(
              height: 150,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Card(
                      child: GestureDetector(
                          onTap: () {
                            // Navigator.of(context).push(MaterialPageRoute(
                            //   builder: (context) =>     Transaction(
                            //     userId: userId,
                            //   ),
                            // ));
                          },
                          child: Lottie.asset('assets/lotties/1 (31).json',
                              fit: BoxFit.cover)),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Card(
                      child: GestureDetector(
                          onTap: () {
                            // Navigator.of(context).push(MaterialPageRoute(
                            //     builder: (context) => UserListPageCoins(userId: '',)));
                          },
                          child: Lottie.asset('assets/lotties/1 (13).json',
                              fit: BoxFit.cover)),
                    ),
                  ),
                ],
              ),
            ),
          ),
          // SliverToBoxAdapter(
          //   child: Container(
          //     height: 150,
          //     child: Row(
          //       mainAxisAlignment: MainAxisAlignment.center,
          //       children: [
          //         Padding(
          //           padding: const EdgeInsets.all(8.0),
          //           child: Card(
          //             child: GestureDetector(
          //                 onTap: () {
          //                   Navigator.of(context).push(MaterialPageRoute(
          //                       builder: (context) => QRCodePage(
          //                             currentUserData: {},
          //                           )));
          //                 },
          //                 child: Lottie.asset('assets/lotties/1 (9).json',
          //                     fit: BoxFit.cover)),
          //           ),
          //         ),
          //         Padding(
          //           padding: const EdgeInsets.all(8.0),
          //           child: Card(
          //             child: GestureDetector(
          //                 // onTap: () {
          //                 //   Navigator.of(context).push(MaterialPageRoute(
          //                 //       builder: (context) => UserListPageCoins()));
          //                 // },
          //                 child: Lottie.asset('assets/lotties/1 (64).json',
          //                     fit: BoxFit.cover)),
          //           ),
          //         ),
          //       ],
          //     ),
          //   ),
          // ),
          // SliverToBoxAdapter(
          //   child: Container(
          //     height: 150,
          //     child: Row(
          //       mainAxisAlignment: MainAxisAlignment.center,
          //       children: [
          //         Padding(
          //           padding: const EdgeInsets.all(8.0),
          //           child: Card(
          //             child: GestureDetector(
          //                 // onTap: () {
          //                 //   Navigator.of(context).push(MaterialPageRoute(
          //                 //       builder: (context) => QrScanner()));
          //                 // },
          //                 child: Lottie.asset('assets/lotties/1 (40).json',
          //                     fit: BoxFit.cover)),
          //           ),
          //         ),
          //         Padding(
          //           padding: const EdgeInsets.all(8.0),
          //           child: Card(
          //             child: GestureDetector(
          //                 // onTap: () {
          //                 //   Navigator.of(context).push(MaterialPageRoute(
          //                 //       builder: (context) => UserListPageCoins()));
          //                 // },
          //                 child: Lottie.asset('assets/lotties/1 (54).json',
          //                     fit: BoxFit.cover)),
          //           ),
          //         ),
          //       ],
          //     ),
          //   ),
          // ),
          // SliverToBoxAdapter(
          //   child: Container(
          //     height: 150,
          //     child: Row(
          //       mainAxisAlignment: MainAxisAlignment.center,
          //       children: [
          //         Padding(
          //           padding: const EdgeInsets.all(8.0),
          //           child: Card(
          //             child: GestureDetector(
          //                 // onTap: () {
          //                 //   Navigator.of(context).push(MaterialPageRoute(
          //                 //       builder: (context) => QrScanner()));
          //                 // },
          //                 child: Lottie.asset('assets/lotties/1 (42).json',
          //                     fit: BoxFit.cover)),
          //           ),
          //         ),
          //         Padding(
          //           padding: const EdgeInsets.all(8.0),
          //           child: Card(
          //             child: GestureDetector(
          //                 // onTap: () {
          //                 //   Navigator.of(context).push(MaterialPageRoute(
          //                 //       builder: (context) => UserListPageCoins()));
          //                 // },
          //                 child: Lottie.asset('assets/lotties/1 (35).json',
          //                     fit: BoxFit.cover)),
          //           ),
          //         ),
          //       ],
          //     ),
          //   ),
          // ),
          // SliverToBoxAdapter(
          //   child: SizedBox(
          //     height: 50,
          //   ),
          // )
        ],
      ),
    );
  }
}

class TransactionList extends StatelessWidget {
  final String userId;

  TransactionList({required this.userId});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('Users')
          .doc(userId)
          .collection('transactions')
          .snapshots(),
      builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
        if (snapshot.hasError) {
          return Text('Quelque chose s\'est mal passé');
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          return CircularProgressIndicator();
        }

        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return Text('Aucune transaction');
        }

        List<DocumentSnapshot> documents = snapshot.data!.docs;

        return Container(
          height: 100, // Ajustez la hauteur en fonction de vos besoins
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: documents.length,
            itemBuilder: (context, index) {
              DocumentSnapshot document = documents[index];
              Map<String, dynamic> data =
                  document.data() as Map<String, dynamic>;

              // Créez un widget pour représenter chaque transaction (vous pouvez personnaliser cela)
              return Card(
                child: Column(
                  children: <Widget>[
                    Text('ID: ${data['id']}'),
                    Text('State: ${data['state']}'),
                    // Ajoutez d'autres éléments si nécessaire
                  ],
                ),
              );
            },
          ),
        );
      },
    );
  }
}

class history extends StatelessWidget {
  const history({
    super.key,
    required this.userId,
  });

  final String userId;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: FirebaseFirestore.instance
          .collection('Users')
          .doc(userId)
          .collection('transactions')
          .snapshots(),
      builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
        if (snapshot.hasError) {
          return Text('Quelque chose s\'est mal passé');
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        }

        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return Text('Aucune transaction');
        }

        return ListView(
          scrollDirection: Axis.horizontal,
          physics: NeverScrollableScrollPhysics(),
          shrinkWrap: true,
          children: snapshot.data!.docs.map((DocumentSnapshot document) {
            Map<String, dynamic> data = document.data() as Map<String, dynamic>;

            return ListTile(
              /*leading: FutureBuilder<DocumentSnapshot>(
                future: FirebaseFirestore.instance
                    .collection('Users')
                    .doc(userId)
                    .get(),
                builder: (BuildContext context,
                    AsyncSnapshot<DocumentSnapshot> userSnapshot) {
                  if (userSnapshot.connectionState == ConnectionState.waiting) {
                    print('not yet 000000000000000000000000000000000000');
                    return Center(child: CircularProgressIndicator());
                  }

                  if (userSnapshot.hasError) {
                    print('error 000000000000000000000000000000000000');

                    return Text(
                        'Quelque chose s\'est mal passé : ${userSnapshot.error}');
                  }

                  if (!userSnapshot.hasData) {
                    print('not has data 000000000000000000000000000000000000');

                    return Text(
                        'Aucune donnée d\'utilisateur trouvée pour l\'ID $userId');
                  }

                  Map<String, dynamic> userData =
                      userSnapshot.data!.data() as Map<String, dynamic>;

                  // Obtenez l'URL de l'avatar à partir des données de l'utilisateur (remplacez 'avatar_url' par le nom du champ approprié).
                  String avatarUrl = userData['avatar'];
                  print(userData);

                  return CircleAvatar(
                    backgroundImage: NetworkImage(
                        avatarUrl), // Chargez l'avatar depuis l'URL.
                  );
                },
              ),
              */
              title: Text(data['id']), // Remplacez 'id' par le champ souhaité.
              subtitle: Text(
                  data['state']), // Remplacez 'state' par le champ souhaité.
            );
          }).toList(),
        );
      },
    );
  }
}

class NetworkingPageHeader extends SliverPersistentHeaderDelegate {
  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    final opacity = (shrinkOffset < 1) ? 1.0 : 0.0;
    final opacity2 = (shrinkOffset > 1) ? 1.0 : 0.0;
    return Stack(
      alignment: Alignment.bottomCenter,
      fit: StackFit.expand,
      children: [
        Lottie.asset(
          'assets/lotties/1 (5).json',
          fit: BoxFit.fill,
        ),
        AnimatedOpacity(
          opacity: opacity,
          duration: Duration(milliseconds: 300), // Durée de l'animation
          child: Center(
            child: Consumer<UserProvider>(
              builder: (context, userDataProvider, _) {
                final currentUserData = userDataProvider.coins;
                final coins = currentUserData;
                final formattedCoins = intl.NumberFormat.currency(
                  locale: 'fr_FR',
                  symbol: 'DZD',
                  decimalDigits: 2,
                ).format(coins);

                return Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: FittedBox(
                    child: Text(
                      formattedCoins,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 50,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ),
        Align(
          alignment: Alignment.bottomCenter,
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Consumer<UserProvider>(
              builder: (context, userCoinsModel, child) {
                final coins = userCoinsModel.coins;
                final formattedCoins = intl.NumberFormat.currency(
                  locale: 'fr_FR',
                  symbol: 'DZD',
                  decimalDigits: 2,
                ).format(coins);
                return ListTile(
                  leading: InkWell(
                    onTap: () => Navigator.of(context).push(
                      MaterialPageRoute(builder: (context) => Profile()),
                    ),
                    child: CircleAvatar(
                      // Vérifiez si userCoinsModel.avatar est non nul et non vide
                      backgroundImage: userCoinsModel.avatar.isNotEmpty
                          ? CachedNetworkImageProvider(userCoinsModel.avatar)
                          : null, // Utilisez une image de remplacement en cas d'URL vide
                    ),
                  ),
                  title: Text(
                    userCoinsModel.displayName.toString().toUpperCase(),
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: Colors.lightBlue,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  subtitle: Text(
                    userCoinsModel.email,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  trailing: AnimatedOpacity(
                      opacity: opacity2,
                      duration: Duration(milliseconds: 300),
                      child: Padding(
                        padding: const EdgeInsets.all(12.0),
                        child: FittedBox(
                          child: Text(
                            formattedCoins,
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      )),
                );
              },
            ),
          ),
        ),
      ],
    );
  }

  @override
  double maxExtent = 300.0;

  @override
  double minExtent = 100.0;

  @override
  bool shouldRebuild(covariant SliverPersistentHeaderDelegate oldDelegate) =>
      false;
}

class MyGaines extends StatelessWidget {
  const MyGaines({
    super.key,
    required this.currentUserDatas,
  });

  final Map<String, dynamic> currentUserDatas;

  @override
  Widget build(BuildContext context) {
    return Container(
      // height: 200,
      // width: 150,
      child: Consumer<UserProvider>(
        builder: (context, userDataProvider, _) {
          final String role = currentUserDatas['role'] ?? '';
          if (role == 'owner') {
            return TotalCoinsWidget();
          } else {
            return SizedBox();
          }
        },
      ),
    );
  }
}
