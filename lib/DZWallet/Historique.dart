import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:lottie/lottie.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:shimmer/shimmer.dart';
import 'package:intl/intl.dart' as intl;
import 'payment.dart';
import 'providers.dart';

class Historique extends StatelessWidget {
  const Historique({Key? key}) : super(key: key);

  get _color => Colors.white;

  @override
  Widget build(BuildContext context) {
    final dataProvider = Provider.of<UserProvider>(context, listen: false);
    final dataCurrentUserProvider =
        Provider.of<UserProvider>(context, listen: false);

    final User? user = FirebaseAuth.instance.currentUser;
    Provider.of<UserProvider>(context, listen: false).fetchCurrentUserData();
    Provider.of<UserProvider>(context, listen: false)
        .fetchScannedUserData(user!.uid);
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
                child: Text('Une erreur s\'est produite : ${snapshot.error}'));
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(child: Lottie.asset('assets/lotties/1 (8).json'));
          }

          final transactions = snapshot.data!.docs;

          return CustomScrollView(
            slivers: <Widget>[
              SliverAppBar(
                actions: [],
                expandedHeight: 220.0,
                floating: true,
                pinned: true,
                snap: true,
                elevation: 50,
                backgroundColor: Colors.black38,
                flexibleSpace: FlexibleSpaceBar(
                  titlePadding: EdgeInsets.symmetric(vertical: 0),
                  centerTitle: true,
                  title: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Row(
                      //crossAxisAlignment: CrossAxisAlignment.end,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Mon Solde',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                        Consumer<UserProvider>(
                          builder: (context, dataProvider, child) {
                            final userData = dataProvider.currentUserData;

                            if (userData.isEmpty) {
                              return Center();
                            } else {
                              return Text(
                                intl.NumberFormat.currency(
                                  symbol: 'DZD ',
                                  locale: 'fr_FR',
                                  decimalDigits: 2,
                                ).format(userData['coins']),
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
                  ),
                  background: ShaderMask(
                    shaderCallback: (rect) {
                      return const LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomLeft,
                        colors: [Colors.transparent, Colors.black],
                      ).createShader(
                          Rect.fromLTRB(0, 0, rect.width, rect.height));
                    },
                    blendMode: BlendMode.darken,
                    child: Consumer<UserProvider>(
                      builder: (context, dataProvider, child) {
                        final userData = dataProvider.currentUserData;

                        if (userData.isEmpty) {
                          return Center();
                        } else {
                          return CachedNetworkImage(
                            fit: BoxFit.cover,
                            imageUrl: userData['timeline'] ??
                                'https://source.unsplash.com/random?sig=20*3+1',
                            errorWidget: (context, url, error) => const Icon(
                              Icons.error,
                              color: Colors.red,
                            ),
                          );
                        }
                      },
                    ),
                  ),
                ),
              ),
              SliverToBoxAdapter(
                child: Center(
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
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
                                'Current Account',
                                style: TextStyle(
                                  color: _color,
                                ),
                              ),
                              Consumer<UserProvider>(
                                builder: (context, dataProvider, child) {
                                  final userData = dataProvider.currentUserData;

                                  if (userData.isEmpty) {
                                    return Center();
                                  } else {
                                    return Text(
                                      NumberFormat.currency(
                                        symbol: 'DZD',
                                        decimalDigits: 2,
                                        locale:
                                            'fr_FR', // Utilisez la locale appropriée pour votre format
                                      ).format(userData['coins']),
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(
                                        color: _color,
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
                ),
              ),
              SliverToBoxAdapter(
                child:
                    Lottie.asset('assets/lotties/1 (15).json', fit: BoxFit.cover
                        // repeat: false,
                        ),
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 10, 0, 0),
                  child: Text('Mes Transactions',
                      style: TextStyle(
                        fontStyle: FontStyle.italic,
                        fontSize: 15,
                      )),
                ),
              ),
              SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    final transactionData =
                        transactions[index].data() as Map<String, dynamic>;
                    final receiverUserId = transactionData['receiverUserId'];
                    final senderUserId = transactionData['senderUserId'];

                    final isCurrentUserTransaction =
                        senderUserId == user.uid || receiverUserId == user.uid;

                    if (!isCurrentUserTransaction) {
                      return SizedBox.shrink();
                    }

                    return FutureBuilder(
                      future: dataCurrentUserProvider.fetchScannedUserData(
                          receiverUserId == user.uid
                              ? senderUserId
                              : receiverUserId),
                      builder: (context, userDataSnapshot) {
                        if (userDataSnapshot.connectionState ==
                            ConnectionState.waiting) {
                          return Shimmer.fromColors(
                            child: ListTile(
                              title: Text(
                                  'Transaction #${transactions[index].id}'),
                              subtitle: Text('Transaction #$receiverUserId'),
                              trailing: PriceWidget(
                                price: transactionData['amount'],
                              ),
                            ),
                            baseColor: Colors.grey[300]!,
                            highlightColor: Colors.grey[100]!,
                          );
                        }

                        if (userDataSnapshot.hasError) {
                          return ListTile(
                            title:
                                Text('Transaction #${transactions[index].id}'),
                            subtitle: Text('Transaction #$receiverUserId'),
                            trailing: PriceWidget(
                              price: transactionData['amount'],
                            ),
                          );
                        }

                        final userData =
                            userDataSnapshot.data as Map<String, dynamic>;
                        final displayName = userData['displayName'];
                        final email = userData['email'];
                        final coins = userData['coins'];

                        return ListTile(
                          dense: true,
                          leading: Container(
                            width: 70,
                            child: Row(
                              children: [
                                CircleAvatar(
                                  backgroundImage:
                                      NetworkImage(userData['avatar']),
                                ),
                                receiverUserId == user.uid
                                    ? Icon(Icons.arrow_upward,
                                        color: Colors.green)
                                    : senderUserId == user.uid
                                        ? Icon(Icons.arrow_downward,
                                            color: Colors.red)
                                        : Icon(Icons.arrow_circle_left,
                                            color: Colors.grey),
                              ],
                            ),
                          ),
                          subtitle: Text(
                            dateText(transactionData['timestamp']),
                            style: TextStyle(
                              color: Colors.black45,
                              fontSize: 13,
                            ),
                          ),
                          title: Text(
                            userData['displayName'].toString().toUpperCase(),
                            overflow: TextOverflow.ellipsis,
                          ),
                          trailing: Text(
                            intl.NumberFormat.currency(
                              locale: 'fr_FR',
                              symbol: 'DZD ',
                              decimalDigits: 2,
                            ).format(transactionData['amount']),
                            overflow: TextOverflow.ellipsis,
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
                    );
                  },
                  childCount: transactions.length,
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  String dateText(Timestamp? timestamp) {
    if (timestamp != null) {
      final dateTime = timestamp.toDate();
      final dateFormatter = DateFormat('dd MMM yyyy HH:mm');
      return dateFormatter.format(dateTime);
    } else {
      return '';
    }
  }
}
