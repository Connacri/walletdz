import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:provider/provider.dart';
import 'models.dart';
import 'providers.dart';
import 'NetworkingPageHeader.dart';
import 'QrScanner.dart';
import 'lastUsersList.dart';

class mainDz extends StatelessWidget {
  const mainDz({
    super.key,
    required this.currentUser,
  });

  final String currentUser;

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<WalletProvider>(
          create: (context) => WalletProvider(currentUser: currentUser),
        ),
        ChangeNotifierProvider<UserProvider>(
          create: (context) => UserProvider(),
        ),
      ],
      child: MaterialApp(
        locale: const Locale('fr', 'FR'),
        debugShowCheckedModeBanner: false,
        themeMode: ThemeMode.dark,
        theme: ThemeData(
          fontFamily: 'oswald',
          useMaterial3: true,
          colorScheme: ColorScheme.fromSwatch(
              primarySwatch: Colors.lightBlue, backgroundColor: Colors.white),
        ),
        home: HomeWalletPage(
          currentUser: currentUser,
        ),
      ),
    );
  }
}

class HomeWalletPage extends StatelessWidget {
  final String currentUser;

  const HomeWalletPage({
    super.key,
    required this.currentUser,
  });

  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context, listen: false);

    // Assurez-vous de n'appeler fetchUserAndWatchCoins qu'une seule fois
    if (userProvider.user == null) {
      userProvider.fetchUserAndWatchCoins(currentUser);
    }

    return Scaffold(
      body: Consumer<WalletProvider>(
        builder: (context, walletProvider, _) {
          return CustomScrollView(
            slivers: [
              // Définition des éléments de votre Sliver
              _buildHeader(),
              _buildTransactionOptions(context, currentUser),
              _buildUserSection(currentUser),
              _buildTransactionList(walletProvider),
            ],
          );
        },
      ),
    );
  }

  // Construire le SliverPersistentHeader
  SliverPersistentHeader _buildHeader() {
    return SliverPersistentHeader(
      pinned: true,
      delegate: NetworkingPageHeader(), // Utilisez votre délégate ici
    );
  }

  // Construire les options de transaction (QR Scanner, etc.)
  SliverToBoxAdapter _buildTransactionOptions(
      BuildContext context, String currentUser) {
    return SliverToBoxAdapter(
      child: Container(
        height: 150,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildCard(
              context,
              'assets/lotties/1 (85).json',
              () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => QrScanner(currentUser: currentUser),
                  ),
                );
              },
            ),
            _buildCard(
              context,
              'assets/lotties/1 (17).json',
              () {
                // Ajoutez votre logique ici
              },
            ),
          ],
        ),
      ),
    );
  }

  // Méthode pour construire les cartes d'option de transaction
  Widget _buildCard(BuildContext context, String asset, VoidCallback onTap) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Card(
        child: GestureDetector(
          onTap: onTap,
          child: Lottie.asset(
            asset,
            fit: BoxFit.cover,
          ),
        ),
      ),
    );
  }

  // Construire la section des utilisateurs
  SliverToBoxAdapter _buildUserSection(String currentUser) {
    return SliverToBoxAdapter(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Text(
              'Derniers utilisateurs',
              style: TextStyle(
                fontStyle: FontStyle.italic,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: SizedBox(
              height: 80,
              child: LastUsersList(userId: currentUser), // Votre composant ici
            ),
          ),
        ],
      ),
    );
  }

  // Construire la liste des transactions
  SliverList _buildTransactionList(WalletProvider walletProvider) {
    return SliverList(
      delegate: SliverChildBuilderDelegate(
        (context, index) {
          final transaction = walletProvider.transactions[index];
          return _buildTransactionTile(transaction, index);
        },
        childCount: walletProvider.transactions.length,
      ),
    );
  }

  // Construire un élément de la liste des transactions
  Widget _buildTransactionTile(Transactions transaction, int index) {
    return ListTile(
      leading: CircleAvatar(
        backgroundImage: transaction.avatar != null
            ? (transaction.avatar!.isNotEmpty
                ? CachedNetworkImageProvider(transaction.avatar!)
                : CachedNetworkImageProvider(
                    'https://picsum.photos/200/300?random=$index'))
            : null,
      ),
      title: Text(transaction.description),
      subtitle: Text(transaction.timestamp.toString()),
      trailing: Text(
        "${transaction.amount.toStringAsFixed(2)} DZD",
        style: TextStyle(
          fontSize: 20,
          color: transaction.direction ? Colors.red : Colors.green,
        ),
      ),
    );
  }
}
// Composant qui affiche la liste des derniers utilisateurs
// class HomeWalletPage extends StatelessWidget {
//   const HomeWalletPage({
//     super.key,
//     required this.currentUser,
//   });
//
//   final String currentUser;
//   @override
//   Widget build(BuildContext context) {
//     final userModel = Provider.of<UserProvider>(context);
//     userModel.fetchUserAndWatchCoins(currentUser);
//     return Scaffold(
//       body: Consumer<WalletProvider>(
//         builder: (context, walletProvider, _) {
//           return CustomScrollView(
//             shrinkWrap: true,
//             slivers: [
//               SliverPersistentHeader(
//                 pinned: true,
//                 delegate: NetworkingPageHeader(),
//               ),
//               SliverToBoxAdapter(
//                 child: Container(
//                   height: 150,
//                   child: Row(
//                     mainAxisAlignment: MainAxisAlignment.center,
//                     children: [
//                       Padding(
//                         padding: const EdgeInsets.all(8.0),
//                         child: Card(
//                           child: GestureDetector(
//                               onTap: () {
//                                 Navigator.of(context).push(MaterialPageRoute(
//                                     builder: (context) => QrScanner(
//                                           currentUser: currentUser,
//                                         )));
//                               },
//                               child: Lottie.asset('assets/lotties/1 (85).json',
//                                   fit: BoxFit.cover)),
//                         ),
//                       ),
//                       Padding(
//                         padding: const EdgeInsets.all(8.0),
//                         child: Card(
//                           child: GestureDetector(
//                               onTap: () {
//                                 // Navigator.of(context).push(MaterialPageRoute(
//                                 //     builder: (context) => UserListPageCoins(
//                                 //       userId: userId,
//                                 //     )));
//                               },
//                               child: Lottie.asset('assets/lotties/1 (17).json',
//                                   fit: BoxFit.cover)),
//                         ),
//                       ),
//                     ],
//                   ),
//                 ),
//               ),
//               SliverToBoxAdapter(
//                 child: Padding(
//                   padding: const EdgeInsets.symmetric(horizontal: 20),
//                   child: Text(
//                     'Last Users',
//                     style: TextStyle(
//                         fontStyle: FontStyle.italic,
//                         fontWeight: FontWeight.w500),
//                   ),
//                 ),
//               ),
//               SliverToBoxAdapter(
//                 child: Container(
//                   padding: EdgeInsets.symmetric(horizontal: 10),
//                   height: 80,
//                   child: lastUsersList(
//                     userId: currentUser,
//                   ),
//                   width: MediaQuery.of(context).size.width,
//                 ),
//               ),
//               SliverToBoxAdapter(
//                 child: Padding(
//                   padding: const EdgeInsets.symmetric(horizontal: 20),
//                   child: Text(
//                     'Last Transactions',
//                     style: TextStyle(
//                         fontStyle: FontStyle.italic,
//                         fontWeight: FontWeight.w500),
//                   ),
//                 ),
//               ),
//               SliverList(
//                 delegate: SliverChildBuilderDelegate(
//                   (context, index) {
//                     final transaction = walletProvider.transactions[index];
//                     return ListTile(
//                       leading: CircleAvatar(
//                         backgroundImage: transaction.avatar != null
//                             ? transaction.avatar != ''
//                                 ? CachedNetworkImageProvider(
//                                     transaction.avatar!)
//                                 : CachedNetworkImageProvider(
//                                     'https://picsum.photos/200/300?random=$index')
//                             : null,
//                       ),
//                       title: Text(transaction.description),
//                       subtitle: Text(
//                         transaction.timestamp.toString(),
//                       ),
//                       trailing: Text(
//                         "${transaction.amount.toStringAsFixed(2)} DZD",
//                         style: TextStyle(
//                           fontSize: 20,
//                           color:
//                               transaction.direction ? Colors.red : Colors.green,
//                         ),
//                       ),
//                     );
//                   },
//                   childCount: walletProvider.transactions.length,
//                 ),
//               ),
//               SliverList(
//                 delegate: SliverChildBuilderDelegate(
//                   (context, index) {
//                     final transaction = walletProvider.transactions[index];
//                     return ListTile(
//                       leading: CircleAvatar(
//                         backgroundImage: transaction.avatar != null
//                             ? transaction.avatar != ''
//                                 ? CachedNetworkImageProvider(
//                                     transaction.avatar!)
//                                 : CachedNetworkImageProvider(
//                                     'https://picsum.photos/200/300?random=$index')
//                             : null,
//                       ),
//                       title: Text(transaction.description),
//                       subtitle: Text(
//                         transaction.timestamp.toString(),
//                       ),
//                       trailing: Text(
//                         "${transaction.amount.toStringAsFixed(2)} DZD",
//                         style: TextStyle(
//                           fontSize: 20,
//                           color:
//                               transaction.direction ? Colors.red : Colors.green,
//                         ),
//                       ),
//                     );
//                   },
//                   childCount: walletProvider.transactions.length,
//                 ),
//               ),
//               SliverList(
//                 delegate: SliverChildBuilderDelegate(
//                   (context, index) {
//                     final transaction = walletProvider.transactions[index];
//                     return ListTile(
//                       leading: CircleAvatar(
//                         backgroundImage: transaction.avatar != null
//                             ? transaction.avatar != ''
//                                 ? CachedNetworkImageProvider(
//                                     transaction.avatar!)
//                                 : CachedNetworkImageProvider(
//                                     'https://picsum.photos/200/300?random=$index')
//                             : null,
//                       ),
//                       title: Text(transaction.description),
//                       subtitle: Text(
//                         transaction.timestamp.toString(),
//                       ),
//                       trailing: Text(
//                         "${transaction.amount.toStringAsFixed(2)} DZD",
//                         style: TextStyle(
//                           fontSize: 20,
//                           color:
//                               transaction.direction ? Colors.red : Colors.green,
//                         ),
//                       ),
//                     );
//                   },
//                   childCount: walletProvider.transactions.length,
//                 ),
//               ),
//               SliverList(
//                 delegate: SliverChildBuilderDelegate(
//                   (context, index) {
//                     final transaction = walletProvider.transactions[index];
//                     return ListTile(
//                       leading: CircleAvatar(
//                         backgroundImage: transaction.avatar != null
//                             ? transaction.avatar != ''
//                                 ? CachedNetworkImageProvider(
//                                     transaction.avatar!)
//                                 : CachedNetworkImageProvider(
//                                     'https://picsum.photos/200/300?random=$index')
//                             : null,
//                       ),
//                       title: Text(transaction.description),
//                       subtitle: Text(
//                         transaction.timestamp.toString(),
//                       ),
//                       trailing: Text(
//                         "${transaction.amount.toStringAsFixed(2)} DZD",
//                         style: TextStyle(
//                           fontSize: 20,
//                           color:
//                               transaction.direction ? Colors.red : Colors.green,
//                         ),
//                       ),
//                     );
//                   },
//                   childCount: walletProvider.transactions.length,
//                 ),
//               ),
//               SliverList(
//                 delegate: SliverChildBuilderDelegate(
//                   (context, index) {
//                     final transaction = walletProvider.transactions[index];
//                     return ListTile(
//                       leading: CircleAvatar(
//                         backgroundImage: transaction.avatar != null
//                             ? transaction.avatar != ''
//                                 ? CachedNetworkImageProvider(
//                                     transaction.avatar!)
//                                 : CachedNetworkImageProvider(
//                                     'https://picsum.photos/200/300?random=$index')
//                             : null,
//                       ),
//                       title: Text(transaction.description),
//                       subtitle: Text(
//                         transaction.timestamp.toString(),
//                       ),
//                       trailing: Text(
//                         "${transaction.amount.toStringAsFixed(2)} DZD",
//                         style: TextStyle(
//                           fontSize: 20,
//                           color:
//                               transaction.direction ? Colors.red : Colors.green,
//                         ),
//                       ),
//                     );
//                   },
//                   childCount: walletProvider.transactions.length,
//                 ),
//               ),
//               SliverList(
//                 delegate: SliverChildBuilderDelegate(
//                   (context, index) {
//                     final transaction = walletProvider.transactions[index];
//                     return ListTile(
//                       leading: CircleAvatar(
//                         backgroundImage: transaction.avatar != null
//                             ? transaction.avatar != ''
//                                 ? CachedNetworkImageProvider(
//                                     transaction.avatar!)
//                                 : CachedNetworkImageProvider(
//                                     'https://picsum.photos/200/300?random=$index')
//                             : null,
//                       ),
//                       title: Text(transaction.description),
//                       subtitle: Text(
//                         transaction.timestamp.toString(),
//                       ),
//                       trailing: Text(
//                         "${transaction.amount.toStringAsFixed(2)} DZD",
//                         style: TextStyle(
//                           fontSize: 20,
//                           color:
//                               transaction.direction ? Colors.red : Colors.green,
//                         ),
//                       ),
//                     );
//                   },
//                   childCount: walletProvider.transactions.length,
//                 ),
//               ),
//               SliverToBoxAdapter(
//                 child: SizedBox(
//                   height: 40,
//                 ),
//               )
//             ],
//           );
//         },
//       ),
//     );
//   }
// }
