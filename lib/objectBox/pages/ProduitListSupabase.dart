import 'dart:io';
import 'dart:isolate';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:objectbox/objectbox.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:percent_indicator/linear_percent_indicator.dart';
import '../../objectbox.g.dart';
import '../Entity.dart';
import '../classeObjectBox.dart';
import 'FournisseurListScreen.dart';
import 'ProduitListScreen.dart';
import 'dart:io' show Platform;
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:timeago/timeago.dart' as timeago;

class SyncException implements Exception {
  final String message;
  SyncException(this.message);
  @override
  String toString() => 'SyncException: $message';
}

class SupabaseSync {
  final SupabaseClient supabase;
  final Store objectboxStore;

  SupabaseSync(this.supabase, this.objectboxStore);

  Future<void> syncToSupabase() async {
    final fournisseurBox = objectboxStore.box<Fournisseur>();
    final produitBox = objectboxStore.box<Produit>();

    // Collecte des données à synchroniser
    List<Map<String, dynamic>> fournisseursData = [];
    List<Map<String, dynamic>> produitsData = [];
    List<Map<String, dynamic>> relationsData = [];

    try {
      // Effectuer les opérations synchrones dans la transaction
      objectboxStore.runInTransaction(TxMode.read, () {
        // Collecte des données fournisseurs
        for (var fournisseur in fournisseurBox.getAll()) {
          fournisseursData.add({
            'id': fournisseur.id,
            'qr': fournisseur.qr,
            'nom': fournisseur.nom,
            'phone': fournisseur.phone,
            'adresse': fournisseur.adresse,
            'datecreation': fournisseur.dateCreation.toIso8601String(),
            'dernieremodification':
                fournisseur.derniereModification?.toIso8601String(),
          });
        }

        // Collecte des données produits
        for (var produit in produitBox.getAll()) {
          produitsData.add({
            'id': produit.id,
            'qr': produit.qr,
            'image': produit.image,
            'nom': produit.nom,
            'description': produit.description,
            'prixachat': produit.prixAchat,
            'prixvente': produit.prixVente,
            'stock': produit.stock,
            'minimstock': produit.minimStock,
            'stockinit': produit.stockinit,
            'datecreation': produit.dateCreation?.toIso8601String(),
            'dateperemption': produit.datePeremption?.toIso8601String(),
            'stockupdate': produit.stockUpdate?.toIso8601String(),
            'dernieremodification':
                produit.derniereModification.toIso8601String(),
          });
        }

        // Collecte des relations
        for (var fournisseur in fournisseurBox.getAll()) {
          for (var produit in fournisseur.produits) {
            relationsData.add({
              'fournisseurid': fournisseur.id,
              'produitid': produit.id,
            });
          }
        }
      });

      // Effectuer les opérations asynchrones après la fin de la transaction
      // Synchronisation des fournisseurs
      await supabase
          .from('fournisseur')
          .upsert(fournisseursData, onConflict: 'id');

      // Synchronisation des produits
      await supabase.from('produit').upsert(produitsData, onConflict: 'id');

      // Synchronisation des relations
      await supabase
          .from('produitfournisseur')
          .delete()
          .neq('fournisseurid', 0)
          .neq('produitid', 0);
      await supabase.from('produitfournisseur').insert(relationsData);
    } catch (e) {
      throw SyncException(
          'Erreur lors de la synchronisation vers Supabase: $e');
    }
  }

  Future<void> syncFromSupabase() async {
    final fournisseurBox = objectboxStore.box<Fournisseur>();
    final produitBox = objectboxStore.box<Produit>();

    try {
      // Préparer les données à synchroniser
      final fournisseursResponse = await supabase.from('fournisseur').select();
      final fournisseursData = fournisseursResponse as List<dynamic>;

      final produitsResponse = await supabase.from('produit').select();
      final produitsData = produitsResponse as List<dynamic>;

      final relationsResponse =
          await supabase.from('produitfournisseur').select();
      final relationsData = relationsResponse as List<dynamic>;

      // Effectuer les opérations dans une transaction ObjectBox
      objectboxStore.runInTransaction(TxMode.write, () {
        // Synchroniser les fournisseurs
        for (var data in fournisseursData) {
          final fournisseur = Fournisseur.fromJson(data);
          fournisseurBox.put(fournisseur);
        }

        // Synchroniser les produits
        for (var data in produitsData) {
          final produit = Produit.fromJson(data);
          produitBox.put(produit);
        }

        // Synchroniser les relations plusieurs-à-plusieurs
        for (var data in relationsData) {
          final fournisseur = fournisseurBox.get(data['fournisseurid']);
          final produit = produitBox.get(data['produitid']);
          if (fournisseur != null && produit != null) {
            fournisseur.produits.add(produit);
            produit.fournisseurs.add(fournisseur);
          }
        }

        // Sauvegarder les modifications des relations
        fournisseurBox.putMany(fournisseurBox.getAll());
        produitBox.putMany(produitBox.getAll());
      });
    } catch (e) {
      print(e);
      throw SyncException(
          'Erreur lors de la synchronisation depuis Supabase: $e');
    }
  }
}

class ProduitListPage extends StatefulWidget {
  final SupabaseClient supabase;
  final Store objectboxStore;

  ProduitListPage({required this.supabase, required this.objectboxStore});

  @override
  _ProduitListPageState createState() => _ProduitListPageState();
}

class _ProduitListPageState extends State<ProduitListPage>
    with TickerProviderStateMixin {
  // late Future<List<Produit>> _produitsFuture;
  List<Produit> _produits = [];
  List<Fournisseur> _fournisseurs = [];
  bool _isLoading = false;
  bool _hasMore = true;
  final int _pageSize = 20;
  int _currentPage = 0;
  bool _isLoadingf = false;
  bool _hasMoref = true;
  final int _pageSizef = 20;
  int _currentPagef = 0;

  final ScrollController _scrollController = ScrollController();
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _loadMoreProduits();
    _loadMoreFournisseurs();
    _scrollController.addListener(_onScroll);
    _scrollController.addListener(_onScrollf);
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    _tabController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels ==
        _scrollController.position.maxScrollExtent) {
      _loadMoreProduits();
    }
  }

  void _onScrollf() {
    if (_scrollController.position.pixels ==
        _scrollController.position.maxScrollExtent) {
      _loadMoreFournisseurs();
    }
  }

  Future<void> _loadMoreProduits() async {
    if (_isLoading || !_hasMore) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final supabase = Supabase.instance.client;
      final List<Map<String, dynamic>> data = await supabase
          .from('produit')
          .select()
          .order('id', ascending: false)
          .range(_currentPage * _pageSize, (_currentPage + 1) * _pageSize - 1);

      if (data.isEmpty) {
        setState(() {
          _hasMore = false;
        });
      } else {
        setState(() {
          _produits.addAll(data.map((item) => Produit.fromJson(item)).toList());
          _currentPage++;
        });
      }
    } catch (e) {
      print('Erreur lors de la récupération des produits: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _loadMoreFournisseurs() async {
    if (_isLoadingf || !_hasMoref) return;

    setState(() {
      _isLoadingf = true;
    });

    try {
      final supabase = Supabase.instance.client;
      final List<Map<String, dynamic>> data = await supabase
          .from('fournisseur')
          .select()
          .order('id', ascending: false)
          .range(
              _currentPagef * _pageSizef, (_currentPagef + 1) * _pageSizef - 1);

      if (data.isEmpty) {
        setState(() {
          _hasMoref = false;
        });
      } else {
        setState(() {
          _fournisseurs
              .addAll(data.map((item) => Fournisseur.fromJson(item)).toList());
          _currentPagef++;
        });
      }
    } catch (e) {
      print('Erreur lors de la récupération des Fournisseurs: $e');
    } finally {
      setState(() {
        _isLoadingf = false;
      });
    }
  }

  bool _isSyncing = false;
  String? _errorMessage;
  String? _successMessage;

  Future<void> _syncData() async {
    setState(() {
      _isSyncing = true;
      _errorMessage = null;
      _successMessage = null;
    });

    final sync = SupabaseSync(widget.supabase, widget.objectboxStore);

    try {
      await sync.syncToSupabase();
      // await sync.syncFromSupabase();
      setState(() {
        _successMessage = 'Synchronisation réussie';
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              _successMessage!,
              style: TextStyle(color: Colors.white),
            ),
            backgroundColor: Colors.green,
          ),
        );
      });
    } on SyncException catch (e) {
      setState(() {
        _errorMessage = e.message;
      });
    } finally {
      setState(() {
        _isSyncing = false;
      });
    }
  }

  Future<List<Produit>> fetchProduitsFromSupabase() async {
    final supabase = Supabase.instance.client;
    try {
      final List<Map<String, dynamic>> data =
          await supabase.from('produit').select().order('id', ascending: true);

      List<Produit> produits =
          data.map((item) => Produit.fromJson(item)).toList();
      return produits;
    } catch (e) {
      print('Erreur lors de la récupération des produits: $e');
      return [];
    }
  }

  Future<List<Object>> fetchFournisseursFromSupabase() async {
    final supabase = Supabase.instance.client;
    try {
      final List<Map<String, dynamic>> data = await supabase
          .from('fournisseur')
          .select()
          .order('id', ascending: true);

      List<Fournisseur> fournisseurs =
          data.map((item) => Fournisseur.fromJson(item)).toList();
      return fournisseurs;
    } catch (e) {
      print('Erreur lors de la récupération des fournisseurs: $e');
      return [];
    }
  }

  Future<void> clearAllTables() async {
    final supabase = Supabase.instance.client;

    try {
      // Supprimer les lignes de la table de relation en premier
      print('Suppression des lignes de la table produitfournisseur...');
      await supabase
          .from('produitfournisseur')
          .delete()
          .neq('produitid', 0)
          .neq('fournisseurid', 0);
      setState(() {
        _produits.clear();
        _successMessage = "Toutes les tables ont été vidées";
      });
      print('Lignes de la table produitfournisseur supprimées avec succès.');

      // Supprimer les lignes de la table produits
      print('Suppression des lignes de la table produits...');
      await supabase.from('produit').delete().neq('id', 0);
      print('Lignes de la table produits supprimées avec succès.');

      // Supprimer les lignes de la table fournisseurs
      print('Suppression des lignes de la table fournisseurs...');
      await supabase.from('fournisseur').delete().neq('id', 0);
      print('Lignes de la table fournisseurs supprimées avec succès.');

      print('Toutes les tables ont été vidées avec succès.');

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Toutes les tables ont été vidées avec succès.',
            style: TextStyle(color: Colors.white),
          ),
          backgroundColor: Colors.blue,
        ),
      );
    } catch (e) {
      print('Erreur lors de la suppression des tables: $e');
    }
  }

  Color getColorBasedOnPeremption(int peremption, double alert) {
    if (peremption <= 0) {
      return Colors.red;
    } else if (peremption > 0 && peremption <= alert) {
      return Colors.orange;
    } else {
      return Colors.green;
    }
  }

  Color getColorBasedOnStock(double stock, double stockInit, double alert) {
    if (stock <= 0) {
      return Colors.grey;
    } else if (stock > 0 && stock <= alert) {
      return Colors.red;
    } else if (stock <= alert && stock > stockInit * 0.30) {
      return Colors.orange;
    } else {
      return Colors.green;
    }
  }

  @override
  Widget build(BuildContext context) {
    final double largeur;
    if (kIsWeb || Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
      // Pour le web
      largeur = 1 / 10;
    } else if (Platform.isAndroid || Platform.isIOS) {
      // Pour Android et iOS
      largeur = 0.5;
    } else {
      // Pour les autres plateformes (Desktop)
      largeur = 1 / 10;
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('Liste des Produits'),
        actions: [
          Center(
            child: Padding(
              padding: const EdgeInsets.all(2.0),
              child: Row(
                children: [
                  if (_errorMessage != null)
                    Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Center(
                          child: Text(
                            'Erreur', // : $_errorMessage',
                            style: TextStyle(color: Colors.red),
                          ),
                        )),
                  if (_successMessage != null)
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Center(
                        child: Text(
                          '$_successMessage',
                          style: TextStyle(color: Colors.green),
                        ),
                      ),
                    ),
                  if (_isSyncing)
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: CircularProgressIndicator(
                        strokeWidth: 3.0,
                      ),
                    )
                  else
                    IconButton(
                      icon: Icon(Icons.sync),
                      onPressed: _syncData,
                    ),
                ],
              ),
            ),
          ),
          IconButton(
            icon: Icon(Icons.delete_forever, color: Colors.red),
            onPressed: clearAllTables,
          ),
          kIsWeb ||
                  Platform.isWindows ||
                  Platform.isLinux ||
                  Platform.isMacOS //|| Platform.isFushia
              ? SizedBox(
                  width: 50,
                )
              : Container()
        ],
        bottom: TabBar(
          controller: _tabController,
          tabs: [
            Tab(text: 'Produits'),
            Tab(text: 'Fournisseurs'),
            Tab(text: 'Factures'),
            Tab(text: 'Clients'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          ListView.builder(
            controller: _scrollController,
            itemCount: _produits.length + 1,
            itemBuilder: (context, index) {
              if (index < _produits.length) {
                final produit = _produits[index];

                final peremption =
                    produit.datePeremption!.difference(DateTime.now()).inDays;
                Color colorPeremption =
                    getColorBasedOnPeremption(peremption, 5.0);
                final double percentProgress = produit.stock != 0 &&
                        produit.stockinit != 0 &&
                        produit.stockinit >= produit.stock
                    ? produit.stock / produit.stockinit
                    : 0;
                Color colorStock = getColorBasedOnStock(
                    produit.stock, produit.stockinit, produit.minimStock);
                return Card(
                  child: Platform.isIOS || Platform.isAndroid
                      ? Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                              ListTile(
                                leading: Tooltip(
                                  message: 'ID : ${produit.id}',
                                  child: GestureDetector(
                                    child: produit.image == null ||
                                            produit.image!.isEmpty
                                        ? CircleAvatar(
                                            child:
                                                Icon(Icons.image_not_supported),
                                          )
                                        : Column(
                                            children: [
                                              Expanded(
                                                child: CircleAvatar(
                                                  backgroundImage:
                                                      CachedNetworkImageProvider(
                                                    produit.image!,
                                                    errorListener: (error) =>
                                                        Icon(Icons.error),
                                                  ),
                                                ),
                                              ),
                                              Text('Id:' +
                                                  produit.id.toString()),
                                            ],
                                          ),
                                  ),
                                ),
                                title: Padding(
                                  padding:
                                      const EdgeInsets.symmetric(horizontal: 8),
                                  child: Text(produit.nom),
                                ),
                                subtitle: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Column(
                                      children: [
                                        Row(
                                          children: [
                                            Center(
                                              child: Text(
                                                'A : ${produit.prixAchat.toStringAsFixed(2)} ',
                                              ),
                                            ),
                                            SizedBox(
                                              width: 10,
                                            ),
                                            Container(
                                              padding: EdgeInsets.symmetric(
                                                  horizontal: 5, vertical: 2),
                                              decoration: BoxDecoration(
                                                gradient: LinearGradient(
                                                  colors: [
                                                    Colors.lightGreen,
                                                    Colors.black45
                                                  ], // Couleurs du dégradé
                                                  begin: Alignment
                                                      .topLeft, // Début du dégradé
                                                  end: Alignment
                                                      .bottomRight, // Fin du dégradé
                                                ), // Couleur de fond
                                                borderRadius:
                                                    BorderRadius.circular(
                                                        10), // Coins arrondis
                                              ),
                                              child: Center(
                                                child: Text(
                                                  '${(produit.prixVente - produit.prixAchat).toStringAsFixed(2)}',
                                                  style: TextStyle(
                                                      color: Colors.white),
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                        SizedBox(height: 5),
                                        Container(
                                          padding: EdgeInsets.symmetric(
                                              horizontal: 5, vertical: 2),
                                          decoration: BoxDecoration(
                                            gradient: LinearGradient(
                                              colors: [
                                                Colors.red,
                                                Colors.black45
                                              ], // Couleurs du dégradé
                                              begin: Alignment
                                                  .topLeft, // Début du dégradé
                                              end: Alignment
                                                  .bottomRight, // Fin du dégradé
                                            ), // Couleur de fond
                                            borderRadius: BorderRadius.circular(
                                                10), // Coins arrondis
                                          ),
                                          child: Center(
                                            child: Text(
                                              'Reste : ${produit.datePeremption!.difference(DateTime.now()).inDays} Jours ',
                                              style: TextStyle(
                                                  color: Colors.white),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    SizedBox(
                                      height: 5,
                                    ),
                                  ],
                                ),
                                trailing: Padding(
                                  padding: const EdgeInsets.only(left: 15),
                                  child: Text(
                                    '${produit.prixVente.toStringAsFixed(2)}',
                                    style: TextStyle(fontSize: 20),
                                  ),
                                ),
                              ),
                              Row(
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 8),
                                    child:
                                        Text('QR : ' + produit.qr.toString()),
                                  ),
                                  SizedBox(width: 2),
                                  Container(
                                    padding: EdgeInsets.symmetric(
                                        horizontal: 5, vertical: 2),
                                    decoration: BoxDecoration(
                                      gradient: LinearGradient(
                                        colors: [
                                          Colors.blue,
                                          Colors.black45
                                        ], // Couleurs du dégradé
                                        begin: Alignment
                                            .topLeft, // Début du dégradé
                                        end: Alignment
                                            .bottomRight, // Fin du dégradé
                                      ), // Couleur de fond
                                      borderRadius: BorderRadius.circular(
                                          10), // Coins arrondis
                                    ),
                                    child: Center(
                                      child: Text(
                                        '${produit.minimStock.toStringAsFixed(produit.minimStock.truncateToDouble() == produit.minimStock ? 0 : 2)}',
                                        // '${(produit.minimStock).toStringAsFixed(2)}',
                                        style: TextStyle(color: Colors.white),
                                      ),
                                    ),
                                  ),
                                  SizedBox(width: 2),
                                  Expanded(
                                    child: Padding(
                                      padding:
                                          EdgeInsets.symmetric(horizontal: 15),
                                      child: new LinearPercentIndicator(
                                        animation: true,
                                        animationDuration: 1000,
                                        lineHeight: 20.0,
                                        leading: new Text(produit.stockinit
                                            .toStringAsFixed(1)),
                                        trailing: new Text(
                                            produit.stock.toStringAsFixed(1)),
                                        percent: percentProgress,
                                        center: new Text(
                                            '${(percentProgress * 100).toStringAsFixed(1)}%'),
                                        linearStrokeCap:
                                            LinearStrokeCap.roundAll,
                                        backgroundColor: Colors.grey.shade300,
                                        progressColor: colorStock,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(height: 15),
                            ])
                      : GestureDetector(
                          onTap: () {
                            Navigator.of(context).push(MaterialPageRoute(
                              builder: (ctx) =>
                                  ProduitDetailPage(produit: produit),
                            ));
                          },
                          child: Container(
                            width: MediaQuery.of(context).size.width,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 15, vertical: 8),
                                  child: Tooltip(
                                    message: 'ID : ${produit.id}',
                                    child: produit.image == null ||
                                            produit.image!.isEmpty
                                        ? CircleAvatar(
                                            child:
                                                Icon(Icons.image_not_supported),
                                          )
                                        : Column(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            crossAxisAlignment:
                                                CrossAxisAlignment.center,
                                            children: [
                                              CircleAvatar(
                                                backgroundImage:
                                                    CachedNetworkImageProvider(
                                                  produit.image!,
                                                  errorListener: (error) =>
                                                      Icon(Icons.error),
                                                ),
                                              ),
                                              Padding(
                                                padding: const EdgeInsets.only(
                                                    top: 8),
                                                child: Text('Id:' +
                                                    produit.id.toString()),
                                              ),
                                            ],
                                          ),
                                  ),
                                ),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(produit.nom),
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Row(
                                            children: [
                                              Center(
                                                child: Text(
                                                  'A: ${produit.prixAchat.toStringAsFixed(2)} ',
                                                ),
                                              ),
                                              SizedBox(
                                                width: 10,
                                              ),
                                              Container(
                                                padding: EdgeInsets.symmetric(
                                                    horizontal: 5, vertical: 2),
                                                decoration: BoxDecoration(
                                                  gradient: LinearGradient(
                                                    colors: [
                                                      Colors.lightGreen,
                                                      Colors.black45
                                                    ], // Couleurs du dégradé
                                                    begin: Alignment
                                                        .topLeft, // Début du dégradé
                                                    end: Alignment
                                                        .bottomRight, // Fin du dégradé
                                                  ), // Couleur de fond
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          10), // Coins arrondis
                                                ),
                                                child: Center(
                                                  child: Text(
                                                    '${(produit.prixVente - produit.prixAchat).toStringAsFixed(2)}',
                                                    style: TextStyle(
                                                        color: Colors.white),
                                                  ),
                                                ),
                                              ),
                                              SizedBox(
                                                width: 10,
                                              ),
                                              Container(
                                                padding: EdgeInsets.symmetric(
                                                    horizontal: 5, vertical: 2),
                                                decoration: BoxDecoration(
                                                  gradient: LinearGradient(
                                                    colors: [
                                                      Colors.black45,
                                                      colorPeremption,
                                                    ], // Couleurs du dégradé
                                                    begin: Alignment
                                                        .topLeft, // Début du dégradé
                                                    end: Alignment
                                                        .bottomRight, // Fin du dégradé
                                                  ), // Couleur de fond
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          10), // Coins arrondis
                                                ),
                                                child: Center(
                                                  child: Text(
                                                    'Péremption : ${produit.datePeremption!.day}/${produit.datePeremption!.month}/${produit.datePeremption!.year}  Reste : ${peremption} Jours ',
                                                    style: TextStyle(
                                                        color: Colors.white),
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                          SizedBox(height: 5),
                                          Center(
                                            child: Padding(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                      horizontal: 15),
                                              child: Text('QR : ' +
                                                  produit.qr.toString()),
                                            ),
                                          )
                                        ],
                                      ),
                                      SizedBox(height: 5),
                                      Row(
                                        children: [
                                          Container(
                                            padding: EdgeInsets.symmetric(
                                                horizontal: 5, vertical: 2),
                                            decoration: BoxDecoration(
                                              gradient: LinearGradient(
                                                colors: [
                                                  Colors.blue,
                                                  Colors.black45
                                                ], // Couleurs du dégradé
                                                begin: Alignment
                                                    .topLeft, // Début du dégradé
                                                end: Alignment
                                                    .bottomRight, // Fin du dégradé
                                              ), // Couleur de fond
                                              borderRadius:
                                                  BorderRadius.circular(
                                                      10), // Coins arrondis
                                            ),
                                            child: Center(
                                              child: Text(
                                                '${produit.minimStock.toStringAsFixed(produit.minimStock.truncateToDouble() == produit.minimStock ? 0 : 2)}',
                                                style: TextStyle(
                                                    color: Colors.white),
                                              ),
                                            ),
                                          ),
                                          SizedBox(width: 5),
                                          Expanded(
                                            child: new LinearPercentIndicator(
                                              animation: true,
                                              animationDuration: 1000,
                                              lineHeight: 20.0,
                                              leading: new Text(produit
                                                  .stockinit
                                                  .toStringAsFixed(2)),
                                              trailing: new Text(produit.stock
                                                  .toStringAsFixed(2)),
                                              percent: percentProgress,
                                              center: new Text(
                                                  '${(percentProgress * 100).toStringAsFixed(1)}%'),
                                              linearStrokeCap:
                                                  LinearStrokeCap.roundAll,
                                              backgroundColor:
                                                  Colors.grey.shade300,
                                              progressColor: colorStock,
                                            ),
                                          ),
                                        ],
                                      ),
                                      SizedBox(height: 5),
                                    ],
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                      vertical: 8, horizontal: 25),
                                  child: Text(
                                    '${produit.prixVente.toStringAsFixed(2)}',
                                    style: TextStyle(fontSize: 20),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                );
              } else if (_hasMore) {
                return Center(
                  child: LinearProgressIndicator(),
                );
              } else {
                return Container(
                  padding: EdgeInsets.all(16),
                  alignment: Alignment.center,
                  child: Text('Fin de la liste'),
                );
              }
            },
          ),
          ListView.builder(
            controller: _scrollController,
            itemCount: _fournisseurs.length + 1,
            itemBuilder: (context, index) {
              if (index < _fournisseurs.length) {
                final fournisseur = _fournisseurs[index];
                return Card(
                  child: ListTile(
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => ProduitsFournisseurPage(
                            fournisseur: fournisseur,
                          ),
                        ),
                      );
                    },
                    leading: CircleAvatar(
                      child: FittedBox(
                          child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(fournisseur.id.toString()),
                      )),
                    ),
                    title: Text(fournisseur.nom),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Phone : ${fournisseur.phone}'),
                        Text(
                          'Créer le ${fournisseur.dateCreation.day}-${fournisseur.dateCreation.month}-${fournisseur.dateCreation.year}  Modifié ${timeago.format(fournisseur.derniereModification!, locale: 'fr')}',
                          style: TextStyle(
                              fontSize: 13, fontWeight: FontWeight.w300),
                        ),
                      ],
                    ),
                    trailing: Container(
                      width: 50,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Text(
                              fournisseur.produits.length.toString(),
                              style: TextStyle(fontSize: 20),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              } else if (_hasMore) {
                return Center(
                  child: LinearProgressIndicator(),
                );
              } else {
                return Container(
                  padding: EdgeInsets.all(16),
                  alignment: Alignment.center,
                  child: Text('Fin de la liste'),
                );
              }
            },
          ),
          Center(
            child: Text('Factures'),
          ),
          Center(
            child: Text('Clients'),
          ),
        ],
      ),
    );
  }
}
