import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:intl/intl.dart';
import 'package:lottie/lottie.dart';
import 'package:shimmer/shimmer.dart';

import 'providers.dart';

class Historique extends StatelessWidget {
  const Historique({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final User? user = FirebaseAuth.instance.currentUser;
    final userProvider = Provider.of<UserProviderFire>(context, listen: false);

    // Appeler une seule fois pour charger les données
    userProvider.currentUser;
    userProvider.fetchScannedUserData(user!.uid);

    return Scaffold(
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('transactions')
            .orderBy('timestamp', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(
              child: Text("Une erreur s'est produite : ${snapshot.error}"),
            );
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(
              child: Lottie.asset(
                'assets/lotties/1 (8).json',
                fit: BoxFit.cover,
              ),
            );
          }

          final transactions = snapshot.data!.docs;

          return CustomScrollView(
            slivers: <Widget>[
              _buildAppBar(context, userProvider), // Construisez l'appbar
              _buildAccountCard(context, userProvider), // Card avec le solde
              _buildTransactionList(context, userProvider, transactions,
                  user), // Liste des transactions
            ],
          );
        },
      ),
    );
  }

  SliverAppBar _buildAppBar(
      BuildContext context, UserProviderFire userProvider) {
    return SliverAppBar(
      expandedHeight: 220.0,
      floating: true,
      pinned: true,
      snap: true,
      flexibleSpace: FlexibleSpaceBar(
        titlePadding: const EdgeInsets.symmetric(vertical: 0),
        centerTitle: true,
        title: _buildAppBarTitle(context, userProvider),
        background: _buildAppBarBackground(context, userProvider),
      ),
    );
  }

  Widget _buildAppBarTitle(
      BuildContext context, UserProviderFire userProvider) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            "Mon Solde",
            style: TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.w400,
            ),
          ),
          Consumer<UserProviderFire>(
            builder: (context, userProvider, _) {
              final currentUserData = userProvider.currentUser;
              if (currentUserData!.uid.isEmpty) {
                return Container(); // Retourner un conteneur vide si pas de données
              } else {
                final coins = currentUserData.coins ?? 0.0;
                final formattedCoins = NumberFormat.currency(
                  symbol: 'DZD',
                  locale: 'fr_FR',
                  decimalDigits: 2,
                ).format(coins);

                return Text(
                  formattedCoins,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.w400,
                  ),
                );
              }
            },
          ),
        ],
      ),
    );
  }

  Widget _buildAppBarBackground(
      BuildContext context, UserProviderFire userProvider) {
    return ShaderMask(
      shaderCallback: (rect) {
        return const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomLeft,
          colors: [Colors.transparent, Colors.black],
        ).createShader(
          Rect.fromLTRB(0, 0, rect.width, rect.height),
        );
      },
      blendMode: BlendMode.darken,
      child: Consumer<UserProviderFire>(
        builder: (context, userProvider, _) {
          final currentUserData = userProvider.currentUser;

          if (currentUserData!.uid.isEmpty) {
            return Container(); // Retourner un conteneur vide si pas de données
          } else {
            return CachedNetworkImage(
              fit: BoxFit.cover,
              imageUrl: currentUserData.timeline ?? '',
              errorWidget: (context, url, error) => const Icon(
                Icons.error,
                color: Colors.red,
              ),
            );
          }
        },
      ),
    );
  }

  SliverToBoxAdapter _buildAccountCard(
      BuildContext context, UserProviderFire userProvider) {
    return SliverToBoxAdapter(
      child: Center(
        child: Card(
          color: Colors.black45,
          child: Container(
            width: MediaQuery.of(context).size.width * 0.8,
            height: MediaQuery.of(context).size.height / 9,
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    "Compte Courant",
                    style: TextStyle(
                      color: Colors.white,
                    ),
                  ),
                  Consumer<UserProviderFire>(
                    builder: (context, userProvider, _) {
                      final currentUserData = userProvider.currentUser;
                      if (currentUserData!.uid.isEmpty) {
                        return Container(); // Retourner un conteneur vide
                      } else {
                        final coins = currentUserData.coins ?? 0.0;
                        final formattedCoins = NumberFormat.currency(
                          symbol: 'DZD',
                          locale: 'fr_FR',
                          decimalDigits: 2,
                        ).format(coins);

                        return Text(
                          formattedCoins,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 30,
                            fontWeight: FontWeight.w400,
                          ),
                        );
                      }
                    },
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  SliverList _buildTransactionList(BuildContext context, userProvider,
      List<DocumentSnapshot> transactions, User? user) {
    return SliverList(
      delegate: SliverChildBuilderDelegate(
        (context, index) {
          final transaction = transactions[index];
          final transactionData = transaction.data() as Map<String, dynamic>;
          final receiverUserId = transactionData['receiverUserId'];
          final senderUserId = transactionData['senderUserId'];

          final isCurrentUserTransaction =
              senderUserId == user!.uid || receiverUserId == user.uid;

          if (!isCurrentUserTransaction) {
            return SizedBox.shrink(); // Ignore transactions non liées
          }

          return ListTile(
            dense: true,
            leading: _buildTransactionLeading(
                context, userProvider, transactionData),
            title: Text(
              transactionData['description'] ?? 'Aucune description',
              overflow: TextOverflow.ellipsis,
            ),
            subtitle: Text(
              _formatTimestamp(transactionData['timestamp']),
            ),
            trailing: Text(
              NumberFormat.currency(
                locale: 'fr_FR',
                symbol: 'DZD ',
                decimalDigits: 2,
              ).format(transactionData['amount']),
              style: TextStyle(
                color: receiverUserId == user.uid
                    ? Colors.green
                    : senderUserId == user.uid
                        ? Colors.red
                        : Colors.grey,
                fontSize: 18,
                fontWeight: FontWeight.w400,
              ),
            ),
          );
        },
        childCount: transactions.length,
      ),
    );
  }

  Widget _buildTransactionLeading(BuildContext context,
      UserProviderFire userProvider, Map<String, dynamic> transactionData) {
    final receiverUserId = transactionData['receiverUserId'];
    final senderUserId = transactionData['senderUserId'];

    return Consumer<UserProviderFire>(
      builder: (context, dataProvider, _) {
        final userData = userProvider.scannedUserData;

        if (userData!.uid.isEmpty) {
          return Shimmer.fromColors(
            child: CircleAvatar(
              radius: 30,
              backgroundColor: Colors.grey,
            ),
            baseColor: Colors.grey[300]!,
            highlightColor: Colors.grey[100]!,
          );
        }

        return CircleAvatar(
          backgroundImage: CachedNetworkImageProvider(userData.avatar ??
              "https://source.unsplash.com/featured/300x202"),
        );
      },
    );
  }

  String _formatTimestamp(Timestamp? timestamp) {
    if (timestamp != null) {
      final dateTime = timestamp.toDate();
      final dateFormatter = DateFormat('dd MMM yyyy HH:mm');
      return dateFormatter.format(dateTime);
    } else {
      return '';
    }
  }
}
