import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:provider/provider.dart';
import '../../../objectbox.g.dart';
import '../Entity.dart';
import '../classeObjectBox.dart';
import 'AddProduitScreen.dart';
import 'ProduitListScreen.dart';
import 'package:objectbox/objectbox.dart';

import 'package:flutter/foundation.dart';

class CommerceProviderTest extends ChangeNotifier {
  final ObjectBox objectBox;
  List<Produit> _produits = [];
  int _currentPage = 0;
  final int _pageSize = 20;
  bool _hasMoreProduits = true;
  bool _isLoading = false;

  CommerceProviderTest(this.objectBox);

  List<Produit> get produits => _produits;
  bool get hasMoreProduits => _hasMoreProduits;
  bool get isLoading => _isLoading;

  Future<void> loadInitialProducts() async {
    if (_produits.isEmpty) {
      await loadMoreProduits();
    }
  }

  Future<void> loadMoreProduits() async {
    if (_isLoading || !_hasMoreProduits) return;
    _isLoading = true;
    notifyListeners();

    try {
      final query = objectBox.produitBox
          .query()
          .order(Produit_.id, flags: Order.descending)
          .build();

      final newProduits = query
        ..offset = _currentPage * _pageSize
        ..limit = _pageSize;

      final results = newProduits.find();
      query.close();

      if (results.isEmpty) {
        _hasMoreProduits = false;
      } else {
        _produits.addAll(results);
        _currentPage++;
      }
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void resetProduits() {
    _produits.clear();
    _currentPage = 0;
    _hasMoreProduits = true;
    loadMoreProduits();
  }

  Future<List<Produit>> searchProduits(String query) async {
    if (query.isEmpty) {
      return [];
    }
    final searchQuery = objectBox.produitBox
        .query(Produit_.nom.contains(query, caseSensitive: false))
        .order(Produit_.nom)
        .build();
    searchQuery.limit = _pageSize;
    final searchResults = searchQuery.find();
    searchQuery.close();
    return searchResults;
  }
}

class ProduitListScreenTest extends StatefulWidget {
  @override
  _ProduitListScreenTestState createState() => _ProduitListScreenTestState();
}

class _ProduitListScreenTestState extends State<ProduitListScreenTest> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<CommerceProviderTest>(context, listen: false)
          .loadInitialProducts();
    });
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels ==
        _scrollController.position.maxScrollExtent) {
      Provider.of<CommerceProviderTest>(context, listen: false)
          .loadMoreProduits();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Produits'), actions: [
        IconButton(
          icon: Icon(Icons.search),
          onPressed: () async {
            final produitProvider =
                Provider.of<CommerceProviderTest>(context, listen: false);
            final selectedProduit = await showSearch(
              context: context,
              delegate: PaginatedProduitSearchDelegate(produitProvider),
            );
            if (selectedProduit != null) {
              Navigator.of(context).push(MaterialPageRoute(
                builder: (ctx) => ProduitDetailPage(produit: selectedProduit),
              ));
            }
          },
        ),
      ]),
      body: Consumer<CommerceProviderTest>(
        builder: (context, produitProvider, child) {
          if (produitProvider.produits.isEmpty && produitProvider.isLoading) {
            return Center(child: CircularProgressIndicator());
          }
          return ListView.builder(
            shrinkWrap: true,
            controller: _scrollController,
            itemCount: produitProvider.produits.length +
                (produitProvider.hasMoreProduits ? 1 : 0),
            itemBuilder: (context, index) {
              if (index < produitProvider.produits.length) {
                final produit = produitProvider.produits[index];
                return ProduitListItem(produit: produit);
              } else if (produitProvider.hasMoreProduits) {
                return Center(child: CircularProgressIndicator());
              } else {
                return SizedBox.shrink();
              }
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.of(context)
              .push(MaterialPageRoute(builder: (_) => EditProduitScreen()));
        },
        child: Icon(Icons.add),
      ),
    );
  }
}

class ProduitListItem extends StatelessWidget {
  final Produit produit;

  const ProduitListItem({Key? key, required this.produit}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Slidable(
        key: ValueKey(produit.id),
        startActionPane: ActionPane(
          motion: ScrollMotion(),
          children: [
            SlidableAction(
              onPressed: (BuildContext context) {
                Navigator.of(context).push(MaterialPageRoute(
                  builder: (ctx) => EditProduitScreen(produit: produit),
                ));
              },
              backgroundColor: Colors.blue,
              icon: Icons.edit,
              label: 'Editer',
            ),
          ],
        ),
        child: Card(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ListTile(
                  onTap: () {
                    Navigator.of(context).push(MaterialPageRoute(
                      builder: (ctx) => ProduitDetailPage(produit: produit),
                    ));
                  },
                  leading: produit.image == null || produit.image!.isEmpty
                      ? CircleAvatar(
                          child: Icon(
                          Icons.image_not_supported,
                        ))
                      : CircleAvatar(
                          backgroundImage: CachedNetworkImageProvider(
                            produit.image!,
                            errorListener: (error) => Icon(Icons.error),
                          ),
                        ),
                  title: Text(produit.nom),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'A: ${produit.prixAchat.toStringAsFixed(2)}\nB: ${(produit.prixVente - produit.prixAchat).toStringAsFixed(2)} ',
                      ),
                    ],
                  ),
                  trailing: Text(
                    '${produit.prixVente.toStringAsFixed(2)}',
                    style: TextStyle(fontSize: 20),
                  )),
            ],
          ),
        ));
  }
}

class PaginatedProduitSearchDelegate extends SearchDelegate<Produit?> {
  final CommerceProviderTest provider;

  PaginatedProduitSearchDelegate(this.provider);

  @override
  List<Widget> buildActions(BuildContext context) {
    return [
      IconButton(
        icon: Icon(Icons.clear),
        onPressed: () {
          query = '';
        },
      ),
    ];
  }

  @override
  Widget buildLeading(BuildContext context) {
    return IconButton(
      icon: Icon(Icons.arrow_back),
      onPressed: () {
        close(context, null);
      },
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    return _buildSearchResults();
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    return _buildSearchResults();
  }

  Widget _buildSearchResults() {
    return FutureBuilder<List<Produit>>(
      future: provider.searchProduits(query),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(child: Text('Une erreur est survenue'));
        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return Center(child: Text('Aucun résultat trouvé'));
        } else {
          return ListView.builder(
            itemCount: snapshot.data!.length,
            itemBuilder: (context, index) {
              final produit = snapshot.data![index];
              return ListTile(
                title: Text(produit.nom),
                subtitle: Text('Prix: ${produit.prixVente.toStringAsFixed(2)}'),
                onTap: () {
                  close(context, produit);
                },
              );
            },
          );
        }
      },
    );
  }
}
