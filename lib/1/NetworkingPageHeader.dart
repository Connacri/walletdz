import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:intl/intl.dart'; // Importation pour le formatage
import 'package:lottie/lottie.dart';
import 'providers.dart';

import '../Profile.dart';

class NetworkingPageHeader extends SliverPersistentHeaderDelegate {
  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    final opacity = shrinkOffset < 1 ? 1.0 : 0.0;
    final opacity2 = shrinkOffset > 1 ? 1.0 : 0.0;

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
          duration: const Duration(milliseconds: 300),
          child: Center(
            child: Selector<UserProviderFire, double>(
              selector: (context, provider) =>
                  provider.currentUser?.coins ?? 0.0,
              builder: (context, balance, child) {
                final coins = balance;
                final formattedCoins = NumberFormat.currency(
                  locale: 'fr_FR',
                  symbol: 'DZD',
                  decimalDigits: 2,
                ).format(coins);
                return Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: FittedBox(
                    child: Text(
                      formattedCoins,
                      style: const TextStyle(
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
            child: ListTile(
              leading: InkWell(
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute(builder: (context) => Profile()),
                ),
                child: Selector<UserProviderFire, String?>(
                  selector: (context, provider) => provider.currentUser?.avatar,
                  builder: (context, avatarUrl, child) {
                    return CircleAvatar(
                      backgroundImage: avatarUrl != null && avatarUrl.isNotEmpty
                          ? NetworkImage(avatarUrl)
                          : null,
                      child: avatarUrl == null || avatarUrl.isEmpty
                          ? Icon(Icons.person)
                          : null,
                    );
                  },
                ),
              ),
              title: Selector<UserProviderFire, String?>(
                selector: (context, provider) => provider.currentUser?.name,
                builder: (context, name, child) {
                  return Text(
                    name ?? 'Email inconnu',
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Colors.lightBlue,
                      fontWeight: FontWeight.w600,
                    ),
                  );
                },
              ),
              subtitle: Selector<UserProviderFire, String?>(
                selector: (context, provider) => provider.currentUser?.email,
                builder: (context, email, child) {
                  return Text(
                    email ?? 'inconnu', // Assurez-vous que 'email' existe
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w400,
                    ),
                  );
                },
              ),
              trailing: AnimatedOpacity(
                opacity: opacity2,
                duration: const Duration(milliseconds: 300),
                child: Selector<UserProviderFire, double>(
                  selector: (context, provider) =>
                      provider.currentUser?.coins ?? 0.0,
                  builder: (context, balance, child) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 5.0),
                      child: FittedBox(
                        child: Text(
                          'DZD ${balance.toStringAsFixed(2)}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  @override
  double get maxExtent => 300.0;

  @override
  double get minExtent => 100.0;

  @override
  bool shouldRebuild(covariant SliverPersistentHeaderDelegate oldDelegate) {
    return false; // Évitez le rebuild inutile
  }
}
