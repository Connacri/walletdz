import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:walletdz/wallet_3/payment.dart';

import 'UserListPageCoins.dart';
import 'mainLocal.dart';

class Transaction extends StatelessWidget {
  const Transaction({Key? key, required this.userId}) : super(key: key);
  final String userId;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('User Profile'),
      ),
      body: Column(
        children: [
          Consumer<UserProvider>(builder: (context, dataProvider, child) {
            dataProvider.fetchUserAndWatchCoins(
                userId); // Appel de la méthode pour récupérer les données

            return Center(
              child: Column(
                children: [
                  // Afficher les "coins" de l'utilisateur actuel
                  Text('Coins: ${dataProvider.coins.toString()}'),
                  SizedBox(
                    height: 30,
                  ),
                  TotalCoinsWidget(),
                  // Ajout du bouton ici
                  Padding(
                    padding: const EdgeInsets.fromLTRB(0, 50, 0, 20),
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                              builder: (context) => UserListPageCoins(
                                    userId: userId,
                                  )),
                        );
                      },
                      child: Text('Users'),
                    ),
                  ),
                ],
              ),
            );
          }),
          TotalCoinsWidget(),
        ],
      ),
    );
  }
}
