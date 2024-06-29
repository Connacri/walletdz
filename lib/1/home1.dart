import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:lottie/lottie.dart';
import 'package:provider/provider.dart';
import 'package:walletdz/1/objectBox/MyApp.dart';
import '../1/providers.dart';
import '../iptv/main.dart';
import '../MyListLotties.dart';
import 'NetworkingPageHeader.dart';
import 'QrScanner.dart';
import 'models1.dart';

class home1 extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return //MyHomePage();

        MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => UserProviderFire()),
        ChangeNotifierProvider(create: (context) => TransfersProvider()),
        // ProduitModel ajouté ici
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
          _buildTransactionOptions(context),
          UniqueUsersHorizontalList(),
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

  // Construire les options de transaction (QR Scanner, etc.)
  SliverToBoxAdapter _buildTransactionOptions(BuildContext context) {
    return SliverToBoxAdapter(
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 5),
        height: 120,
        child: ListView(
          shrinkWrap: true, scrollDirection: Axis.horizontal,
          //mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildCard(
              context,
              'assets/lotties/1 (117).json',
              () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => MyMainO(),
                  ),
                );
              },
            ),
            // _buildCard(
            //   context,
            //   'assets/lotties/1 (99).json',
            //   () {
            //     Navigator.of(context).push(
            //       MaterialPageRoute(
            //         builder: (context) => homeFact(),
            //       ),
            //     );
            //   },
            // ),
            // _buildCard(
            //   context,
            //   'assets/lotties/1 (49).json',
            //   () {
            //     Navigator.of(context).push(
            //       MaterialPageRoute(
            //         builder: (context) => MySqfliteApp(),
            //       ),
            //     );
            //   },
            // ),
            // _buildCard(
            //   context,
            //   'assets/lotties/1 (45).json',
            //   () {
            //     Navigator.of(context).push(
            //       MaterialPageRoute(
            //         builder: (context) => MysembastApp(),
            //       ),
            //     );
            //   },
            // ),
            // _buildCard(
            //   context,
            //   'assets/lotties/1 (106).json',
            //   () {
            //     Navigator.of(context).push(
            //       MaterialPageRoute(
            //         builder: (context) => gpt(),
            //       ),
            //     );
            //   },
            // ),
            // _buildCard(
            //   context,
            //   'assets/lotties/1 (20).json',
            //   () {
            //     Navigator.of(context).push(
            //       MaterialPageRoute(
            //         builder: (context) => Supabase(),
            //       ),
            //     );
            //   },
            // ),
            // _buildCard(
            //   context,
            //   'assets/lotties/1 (26).json',
            //   () {
            //     Navigator.of(context).push(
            //       MaterialPageRoute(
            //         builder: (context) => countries(),
            //       ),
            //     );
            //   },
            // ),
            _buildCard(
              context,
              'assets/lotties/1 (85).json',
              () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => QrScanner(),
                  ),
                );
              },
            ),
            _buildCard(
              context,
              'assets/lotties/1 (32).json',
              () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => MyAppIptv(),
                  ),
                );
              },
            ),
            _buildCard(
              context,
              'assets/lotties/1 (12).json',
              () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => LottieListPage(),
                  ),
                );
              },
            ),
          ],
        ),
      ),
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
                subtitle: Text(
                  formattedDate,
                  style: TextStyle(fontSize: 10),
                ),
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
            visible: !isEndReached,
            // Afficher le bouton si on peut encore charger plus de données
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

  Widget _buildCard(BuildContext context, String asset, VoidCallback onTap) {
    return Padding(
      padding: const EdgeInsets.all(5.0),
      child: Card(
        child: Container(
          height: 100,
          width: 100,
          child: GestureDetector(
            onTap: onTap,
            child: Lottie.asset(
              asset,
              // fit: BoxFit.cover,
            ),
          ),
        ),
      ),
    );
  }
}

class UniqueUsersHorizontalList extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Consumer<TransfersProvider>(
      builder: (context, transfersProvider, child) {
        // Extraire les utilisateurs uniques avec détails des transactions
        final uniqueUsers = {
          for (var transaction in transfersProvider.allTransfers)
            {
              'userId': transaction.id,
              'avatar': transaction.avatar, // Image associée à l'utilisateur
              'displayName': transaction.displayName, // Nom d'affichage
            }
        }.toList(); // Convertir le set en liste

        return SliverToBoxAdapter(
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 15, vertical: 15),
            height: 150.0, // Hauteur pour la liste horizontale
            child: ListView.builder(
              shrinkWrap: true,
              scrollDirection: Axis.horizontal, // Liste horizontale
              itemCount: uniqueUsers.length, // Nombre d'utilisateurs uniques
              itemBuilder: (context, index) {
                final user = uniqueUsers[index];
                final avatar = user['avatar'] as String?; // URL de l'avatar
                final displayName =
                    user['displayName'] as String?; // Nom d'affichage

                return Padding(
                  padding: EdgeInsets.symmetric(horizontal: 8.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CircleAvatar(
                        radius: 30.0,
                        backgroundColor: Colors.blue, // Couleur par défaut
                        backgroundImage: avatar != null && avatar.isNotEmpty
                            ? NetworkImage(
                                avatar) // Charger l'image si elle existe
                            : null, // Aucun avatar si vide ou nul
                        child: (avatar == null ||
                                avatar
                                    .isEmpty) // Afficher texte si pas d'avatar
                            ? displayName != null && displayName.isNotEmpty
                                ? Text(
                                    displayName[0].toUpperCase(),
                                    style: TextStyle(
                                        fontSize: 24, color: Colors.white),
                                  )
                                : Center(
                                    child: Icon(
                                      Icons.account_circle_sharp,
                                      size: 40,
                                      color: Colors.white,
                                    ),
                                  )
                            : null,
                      ),
                      SizedBox(height: 8.0),
                      Text(
                        displayName != null && displayName.isNotEmpty
                            ? displayName
                            : 'Inconnu', // Afficher le nom d'affichage
                        style: TextStyle(fontSize: 16),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        );
      },
    );
  }
}
