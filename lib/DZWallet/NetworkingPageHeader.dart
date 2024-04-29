import 'package:intl/intl.dart' as intl;
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:provider/provider.dart';
import 'package:walletdz/DZWallet/providers.dart';

import '../Profile.dart';

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
            child: Consumer<WalletProvider>(
              builder: (context, walletProvider, _) {
                final currentUserData = walletProvider.balance;
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
