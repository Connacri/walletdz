import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:provider/provider.dart';
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
  const HomeWalletPage({
    super.key,
    required this.currentUser,
  });

  final String currentUser;
  @override
  Widget build(BuildContext context) {
    final userModel = Provider.of<UserProvider>(context);
    userModel.fetchUserAndWatchCoins(currentUser);
    return Scaffold(
      body: Consumer<WalletProvider>(
        builder: (context, walletProvider, _) {
          return CustomScrollView(
            shrinkWrap: true,
            slivers: [
              SliverPersistentHeader(
                pinned: true,
                delegate: NetworkingPageHeader(),
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
                                Navigator.of(context).push(MaterialPageRoute(
                                    builder: (context) => QrScanner(
                                          currentUser: currentUser,
                                        )));
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
                                // Navigator.of(context).push(MaterialPageRoute(
                                //     builder: (context) => UserListPageCoins(
                                //       userId: userId,
                                //     )));
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
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Text(
                    'Last Users',
                    style: TextStyle(
                        fontStyle: FontStyle.italic,
                        fontWeight: FontWeight.w500),
                  ),
                ),
              ),
              SliverToBoxAdapter(
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 10),
                  height: 80,
                  child: lastUsersList(
                    userId: currentUser,
                  ),
                  width: MediaQuery.of(context).size.width,
                ),
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Text(
                    'Last Transactions',
                    style: TextStyle(
                        fontStyle: FontStyle.italic,
                        fontWeight: FontWeight.w500),
                  ),
                ),
              ),
              SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    final transaction = walletProvider.transactions[index];
                    return ListTile(
                      leading: CircleAvatar(
                        backgroundImage: transaction.avatar != null
                            ? transaction.avatar != ''
                                ? CachedNetworkImageProvider(
                                    transaction.avatar!)
                                : CachedNetworkImageProvider(
                                    'https://picsum.photos/200/300?random=$index')
                            : null,
                      ),
                      title: Text(transaction.description),
                      subtitle: Text(
                        transaction.timestamp.toLocal().toString(),
                      ),
                      trailing: Text(
                        "${transaction.amount.toStringAsFixed(2)} DZD",
                        style: TextStyle(
                          fontSize: 20,
                          color:
                              transaction.direction ? Colors.red : Colors.green,
                        ),
                      ),
                    );
                  },
                  childCount: walletProvider.transactions.length,
                ),
              ),
              SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    final transaction = walletProvider.transactions[index];
                    return ListTile(
                      leading: CircleAvatar(
                        backgroundImage: transaction.avatar != null
                            ? transaction.avatar != ''
                                ? CachedNetworkImageProvider(
                                    transaction.avatar!)
                                : CachedNetworkImageProvider(
                                    'https://picsum.photos/200/300?random=$index')
                            : null,
                      ),
                      title: Text(transaction.description),
                      subtitle: Text(
                        transaction.timestamp.toLocal().toString(),
                      ),
                      trailing: Text(
                        "${transaction.amount.toStringAsFixed(2)} DZD",
                        style: TextStyle(
                          fontSize: 20,
                          color:
                              transaction.direction ? Colors.red : Colors.green,
                        ),
                      ),
                    );
                  },
                  childCount: walletProvider.transactions.length,
                ),
              ),
              SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    final transaction = walletProvider.transactions[index];
                    return ListTile(
                      leading: CircleAvatar(
                        backgroundImage: transaction.avatar != null
                            ? transaction.avatar != ''
                                ? CachedNetworkImageProvider(
                                    transaction.avatar!)
                                : CachedNetworkImageProvider(
                                    'https://picsum.photos/200/300?random=$index')
                            : null,
                      ),
                      title: Text(transaction.description),
                      subtitle: Text(
                        transaction.timestamp.toLocal().toString(),
                      ),
                      trailing: Text(
                        "${transaction.amount.toStringAsFixed(2)} DZD",
                        style: TextStyle(
                          fontSize: 20,
                          color:
                              transaction.direction ? Colors.red : Colors.green,
                        ),
                      ),
                    );
                  },
                  childCount: walletProvider.transactions.length,
                ),
              ),
              SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    final transaction = walletProvider.transactions[index];
                    return ListTile(
                      leading: CircleAvatar(
                        backgroundImage: transaction.avatar != null
                            ? transaction.avatar != ''
                                ? CachedNetworkImageProvider(
                                    transaction.avatar!)
                                : CachedNetworkImageProvider(
                                    'https://picsum.photos/200/300?random=$index')
                            : null,
                      ),
                      title: Text(transaction.description),
                      subtitle: Text(
                        transaction.timestamp.toLocal().toString(),
                      ),
                      trailing: Text(
                        "${transaction.amount.toStringAsFixed(2)} DZD",
                        style: TextStyle(
                          fontSize: 20,
                          color:
                              transaction.direction ? Colors.red : Colors.green,
                        ),
                      ),
                    );
                  },
                  childCount: walletProvider.transactions.length,
                ),
              ),
              SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    final transaction = walletProvider.transactions[index];
                    return ListTile(
                      leading: CircleAvatar(
                        backgroundImage: transaction.avatar != null
                            ? transaction.avatar != ''
                                ? CachedNetworkImageProvider(
                                    transaction.avatar!)
                                : CachedNetworkImageProvider(
                                    'https://picsum.photos/200/300?random=$index')
                            : null,
                      ),
                      title: Text(transaction.description),
                      subtitle: Text(
                        transaction.timestamp.toLocal().toString(),
                      ),
                      trailing: Text(
                        "${transaction.amount.toStringAsFixed(2)} DZD",
                        style: TextStyle(
                          fontSize: 20,
                          color:
                              transaction.direction ? Colors.red : Colors.green,
                        ),
                      ),
                    );
                  },
                  childCount: walletProvider.transactions.length,
                ),
              ),
              SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    final transaction = walletProvider.transactions[index];
                    return ListTile(
                      leading: CircleAvatar(
                        backgroundImage: transaction.avatar != null
                            ? transaction.avatar != ''
                                ? CachedNetworkImageProvider(
                                    transaction.avatar!)
                                : CachedNetworkImageProvider(
                                    'https://picsum.photos/200/300?random=$index')
                            : null,
                      ),
                      title: Text(transaction.description),
                      subtitle: Text(
                        transaction.timestamp.toLocal().toString(),
                      ),
                      trailing: Text(
                        "${transaction.amount.toStringAsFixed(2)} DZD",
                        style: TextStyle(
                          fontSize: 20,
                          color:
                              transaction.direction ? Colors.red : Colors.green,
                        ),
                      ),
                    );
                  },
                  childCount: walletProvider.transactions.length,
                ),
              ),
              SliverToBoxAdapter(
                child: SizedBox(
                  height: 40,
                ),
              )
            ],
          );
        },
      ),
    );
  }
}
