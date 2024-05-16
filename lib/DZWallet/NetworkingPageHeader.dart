// import 'package:intl/intl.dart' as intl;
// import 'package:cached_network_image/cached_network_image.dart';
// import 'package:flutter/material.dart';
// import 'package:lottie/lottie.dart';
// import 'package:provider/provider.dart';
// import '../classes.dart';
// import 'providers.dart';
//
// class NetworkingPageHeader extends SliverPersistentHeaderDelegate {
//   @override
//   Widget build(
//     BuildContext context,
//     double shrinkOffset,
//     bool overlapsContent,
//   ) {
//     final opacity = (shrinkOffset < 1) ? 1.0 : 0.0;
//     final opacity2 = (shrinkOffset > 1) ? 1.0 : 0.0;
//
//     return Stack(
//       alignment: Alignment.bottomCenter,
//       fit: StackFit.expand,
//       children: [
//         Lottie.asset(
//           'assets/lotties/1 (5).json',
//           fit: BoxFit.fill,
//         ),
//         AnimatedOpacity(
//           opacity: opacity,
//           duration: Duration(milliseconds: 300), // Durée de l'animation
//           child: Center(
//             child: Consumer<WalletProvider>(
//               builder: (context, walletProvider, _) {
//                 final currentUserData = walletProvider.balance;
//                 final coins = currentUserData;
//                 final formattedCoins = intl.NumberFormat.currency(
//                   locale: 'fr_FR',
//                   symbol: 'DZD',
//                   decimalDigits: 2,
//                 ).format(coins);
//
//                 return Padding(
//                   padding: const EdgeInsets.all(12.0),
//                   child: FittedBox(
//                     child: Text(
//                       formattedCoins,
//                       style: TextStyle(
//                         color: Colors.white,
//                         fontSize: 50,
//                         fontWeight: FontWeight.w600,
//                       ),
//                     ),
//                   ),
//                 );
//               },
//             ),
//           ),
//         ),
//         Align(
//           alignment: Alignment.bottomCenter,
//           child: Padding(
//             padding: const EdgeInsets.all(8.0),
//             child: Consumer<UserProvider>(
//               builder: (context, userCoinsModel, child) {
//                 final coins = userCoinsModel.coins;
//                 final formattedCoins = intl.NumberFormat.currency(
//                   locale: 'fr_FR',
//                   symbol: 'DZD',
//                   decimalDigits: 2,
//                 ).format(coins);
//                 return ListTile(
//                   leading: InkWell(
//                     onTap: () => Navigator.of(context).push(
//                       MaterialPageRoute(builder: (context) => Profile()),
//                     ),
//                     child: CircleAvatar(
//                       // Vérifiez si userCoinsModel.avatar est non nul et non vide
//                       backgroundImage: userCoinsModel.avatar.isNotEmpty
//                           ? CachedNetworkImageProvider(userCoinsModel.avatar)
//                           : null, // Utilisez une image de remplacement en cas d'URL vide
//                     ),
//                   ),
//                   title: Text(
//                     userCoinsModel.displayName.toString().toUpperCase(),
//                     overflow: TextOverflow.ellipsis,
//                     style: TextStyle(
//                       color: Colors.lightBlue,
//                       fontWeight: FontWeight.w600,
//                     ),
//                   ),
//                   subtitle: Text(
//                     userCoinsModel.email,
//                     overflow: TextOverflow.ellipsis,
//                     style: TextStyle(
//                       color: Colors.white,
//                       fontWeight: FontWeight.w600,
//                     ),
//                   ),
//                   trailing: AnimatedOpacity(
//                       opacity: opacity2,
//                       duration: Duration(milliseconds: 300),
//                       child: Padding(
//                         padding: const EdgeInsets.all(12.0),
//                         child: FittedBox(
//                           child: Text(
//                             formattedCoins,
//                             style: TextStyle(
//                               color: Colors.white,
//                               fontSize: 18,
//                               fontWeight: FontWeight.w600,
//                             ),
//                           ),
//                         ),
//                       )),
//                 );
//               },
//             ),
//           ),
//         ),
//       ],
//     );
//   }
//
//   @override
//   double maxExtent = 300.0;
//
//   @override
//   double minExtent = 100.0;
//
//   @override
//   bool shouldRebuild(covariant SliverPersistentHeaderDelegate oldDelegate) =>
//       false;
// }

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; // Importation pour le formatage
import 'package:lottie/lottie.dart';
import 'package:provider/provider.dart';

import '../Profile.dart';
import 'providers.dart';

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
            child: Consumer<WalletProvider>(
              builder: (context, walletProvider, _) {
                final coins = walletProvider.balance;
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
            child: Consumer<UserProvider>(
              builder: (context, userProvider, _) {
                final coins =
                    userProvider.coins; // Assurez-vous que 'coins' existe
                final formattedCoins = NumberFormat.currency(
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
                      backgroundImage: userProvider.avatar.isNotEmpty
                          ? CachedNetworkImageProvider(userProvider.avatar)
                          : null, // Assurez-vous que 'avatar' existe
                    ),
                  ),
                  title: Text(
                    userProvider.displayName
                        .toUpperCase(), // Assurez-vous que 'displayName' existe
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Colors.lightBlue,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  subtitle: Text(
                    userProvider.email, // Assurez-vous que 'email' existe
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  trailing: AnimatedOpacity(
                    opacity: opacity2,
                    duration: const Duration(milliseconds: 300),
                    child: Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: FittedBox(
                        child: Text(
                          formattedCoins,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              },
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
