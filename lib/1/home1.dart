import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:walletdz/1/providers.dart';

import 'NetworkingPageHeader.dart';
import 'models1.dart';

class home1 extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => UserProviderPref()),
        ChangeNotifierProvider(create: (context) => UserProviderFire()),
        ChangeNotifierProvider(create: (context) => TransfersProvider()),
      ],
      child: MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  @override
  void initState() {
    super.initState();
    final userProvider = Provider.of<UserProviderFire>(context, listen: false);
    userProvider.loadUser(); // Charger l'utilisateur au démarrage
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          _buildHeader(),
          buildAllTrans(),
          buildPagination(),
          SliverToBoxAdapter(
            child: SizedBox(
              height: 50,
            ),
          )
        ],
      ),
    );
  }

  SliverPersistentHeader _buildHeader() {
    return SliverPersistentHeader(
      pinned: true,
      delegate: NetworkingPageHeader(), // Utilisez votre délégate ici
    );
  }

  Selector<TransfersProvider, List<Transactionss>> buildAllTrans() {
    return Selector<TransfersProvider, List<Transactionss>>(
      selector: (_, provider) => provider.paginatedTransfers, // Paginated list
      builder: (context, transactions, child) {
        return SliverList(
          delegate: SliverChildBuilderDelegate(
            (context, index) {
              final transfer = transactions[index];
              final formattedDate = DateFormat('yyyy-MM-dd HH:mm:ss')
                  .format(transfer.timestamp.toDate());
              // Vérifier si l'URL de l'image est valide
              final isValidUrl =
                  Uri.tryParse(transfer.avatar)?.hasAbsolutePath == true;
              return ListTile(
                leading: transfer.avatar.isEmpty || transfer.avatar == ''
                    ? CircleAvatar(
                        backgroundImage: CachedNetworkImageProvider(
                            'https://picsum.photos/200/300?random=$index'))
                    : isValidUrl
                        ? CircleAvatar(
                            backgroundImage: CachedNetworkImageProvider(
                            transfer.avatar,
                          ))
                        : CircleAvatar(
                            child: Text(
                            transfer.displayName.substring(0, 1).toUpperCase(),
                            textAlign: TextAlign.center,
                            style: TextStyle(
                                fontSize: 24, fontWeight: FontWeight.bold),
                          )),
                title: transfer.displayName.isNotEmpty
                    ? Text(transfer.displayName)
                    : Text('Utilisateur Inconnu'),
                trailing: Text(transfer.amount.toStringAsFixed(2)),
                subtitle: Text(formattedDate),
              );
            },
            childCount: transactions.length,
          ),
        );
      },
    );
  }

  SliverToBoxAdapter buildPagination() {
    return SliverToBoxAdapter(
      child: Selector<TransfersProvider, bool>(
        selector: (_, provider) =>
            provider.currentPage * provider.itemsPerPage >=
            provider.allTransfers.length,
        builder: (context, isEndReached, child) {
          return Visibility(
            visible:
                !isEndReached, // Afficher le bouton si on peut encore charger plus de données
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: ElevatedButton(
                onPressed: () {
                  // Chargez la page suivante lorsqu'on clique sur le bouton
                  context.read<TransfersProvider>().loadNextPage();
                },
                child: Text("Charger Plus"),
              ),
            ),
          );
        },
      ),
    );
  }
}
