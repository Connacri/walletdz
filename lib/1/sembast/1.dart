import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sembast/sembast.dart';
import 'package:sembast/sembast_io.dart';

class MysembastApp extends StatefulWidget {
  @override
  State<MysembastApp> createState() => _MysembastAppState();
}

class _MysembastAppState extends State<MysembastApp> {
  Database? _db;

  @override
  void initState() {
    super.initState();
    _initializeDatabase();
  }

  Future<void> _initializeDatabase() async {
    _db = await databaseFactoryIo.openDatabase('example.db');
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    if (_db == null) {
      return MaterialApp(
        home: Scaffold(
          appBar: AppBar(title: Text('Sembast Example')),
          body: Center(child: CircularProgressIndicator()),
        ),
      );
    }

    return ChangeNotifierProvider(
      create: (context) => DatabaseModel(_db!),
      child: MaterialApp(
        home: Scaffold(
          appBar: AppBar(title: Text('Sembast Example')),
          body: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton(
                  onPressed: () async {
                    Provider.of<DatabaseModel>(context, listen: false)
                        .insertRecord({'name': 'Alice', 'age': 30});
                  },
                  child: Text('Insert Record'),
                ),
                ElevatedButton(
                  onPressed: () async {
                    Provider.of<DatabaseModel>(context, listen: false)
                        .loadRecords();
                  },
                  child: Text('Read Records'),
                ),
                ElevatedButton(
                  onPressed: () async {
                    Provider.of<DatabaseModel>(context, listen: false)
                        .updateRecord(1, {'name': 'Bob', 'age': 32});
                  },
                  child: Text('Update Record'),
                ),
                ElevatedButton(
                  onPressed: () async {
                    Provider.of<DatabaseModel>(context, listen: false)
                        .deleteRecord(1);
                  },
                  child: Text('Delete Record'),
                ),
                Expanded(
                  child: Consumer<DatabaseModel>(
                    builder: (context, model, child) {
                      return ListView.builder(
                        itemCount: model.records.length,
                        itemBuilder: (context, index) {
                          final record = model.records[index];
                          return ListTile(
                            title: Text('Name: ${record['name']}'),
                            subtitle: Text('Age: ${record['age']}'),
                          );
                        },
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class DatabaseModel with ChangeNotifier {
  final Database db;
  final StoreRef<int, Map<String, dynamic>> store =
      intMapStoreFactory.store('my_store');

  List<Map<String, dynamic>> _records = [];

  DatabaseModel(this.db) {
    loadRecords();
  }

  List<Map<String, dynamic>> get records => _records;

  Future<void> loadRecords() async {
    final snapshots = await store.find(db);
    _records = snapshots.map((snapshot) => snapshot.value).toList();
    notifyListeners();
  }

  Future<void> insertRecord(Map<String, dynamic> value) async {
    await store.add(db, value);
    await loadRecords();
  }

  Future<void> updateRecord(int key, Map<String, dynamic> value) async {
    final finder = Finder(filter: Filter.byKey(key));
    await store.update(db, value, finder: finder);
    await loadRecords();
  }

  Future<void> deleteRecord(int key) async {
    final finder = Finder(filter: Filter.byKey(key));
    await store.delete(db, finder: finder);
    await loadRecords();
  }
}
