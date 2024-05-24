import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;
import 'package:sembast/sembast.dart';
import 'package:sembast/sembast_io.dart';
import 'package:faker/faker.dart';

class MysembastApp extends StatefulWidget {
  @override
  State<MysembastApp> createState() => _MysembastAppState();
}

class _MysembastAppState extends State<MysembastApp> {
  Database? _db;
  List<Map<String, dynamic>> _records = [];
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();
  final TextEditingController _codeController = TextEditingController();
  int? _selectedRecordKey;

  @override
  void initState() {
    super.initState();
    _initializeDatabase();
  }

  Future<void> _initializeDatabase() async {
    final dir = await getApplicationDocumentsDirectory();
    final dbPath = path.join(dir.path, 'example.db');
    _db = await databaseFactoryIo.openDatabase(dbPath);
    _loadRecords();
  }

  Future<void> _loadRecords() async {
    if (_db != null) {
      final store = intMapStoreFactory.store('my_store');
      final snapshots = await store.find(_db!);
      setState(() {
        _records = snapshots
            .map((snapshot) => {
                  ...snapshot.value,
                  'key': snapshot.key,
                })
            .toList();
      });
    }
  }

  Future<void> _saveRecord() async {
    if (_formKey.currentState!.validate()) {
      final name = _nameController.text;
      final price = double.parse(_priceController.text);
      final code = _codeController.text;
      final lastModified = DateTime.now().toIso8601String();

      if (_selectedRecordKey == null) {
        await _insertRecord({
          'name': name,
          'price': price,
          'code': code,
          'lastModified': lastModified
        });
      } else {
        await _updateRecord(_selectedRecordKey!, {
          'name': name,
          'price': price,
          'code': code,
          'lastModified': lastModified
        });
      }

      _clearForm();
    }
  }

  Future<void> _insertRecord(Map<String, dynamic> value) async {
    if (_db != null) {
      final store = intMapStoreFactory.store('my_store');
      await store.add(_db!, value);
      _loadRecords();
    }
  }

  Future<void> _updateRecord(int key, Map<String, dynamic> value) async {
    if (_db != null) {
      final store = intMapStoreFactory.store('my_store');
      final finder = Finder(filter: Filter.byKey(key));
      await store.update(_db!, value, finder: finder);
      _loadRecords();
    }
  }

  Future<void> _deleteRecord(int key) async {
    if (_db != null) {
      final store = intMapStoreFactory.store('my_store');
      final finder = Finder(filter: Filter.byKey(key));
      await store.delete(_db!, finder: finder);
      _loadRecords();
    }
  }

  Future<void> _populateWithRandomRecords() async {
    if (_db != null) {
      final store = intMapStoreFactory.store('my_store');
      var faker = Faker();
      for (int i = 0; i < 100000; i++) {
        final name = faker.person.name();
        final price = faker.randomGenerator.decimal(min: 1, scale: 2);
        final code = faker.lorem.word();
        final lastModified = DateTime.now().toIso8601String();

        await store.add(_db!, {
          'name': name,
          'price': price,
          'code': code,
          'lastModified': lastModified
        });
      }
      _loadRecords();
    }
  }

  Future<void> _deleteAllRecords() async {
    if (_db != null) {
      final store = intMapStoreFactory.store('my_store');
      await store.delete(_db!, finder: Finder());
      _loadRecords();
    }
  }

  void _clearForm() {
    _nameController.clear();
    _priceController.clear();
    _codeController.clear();
    setState(() {
      _selectedRecordKey = null;
    });
  }

  void _populateForm(Map<String, dynamic> record) {
    _nameController.text = record['name'];
    _priceController.text = record['price'].toString();
    _codeController.text = record['code'];
    setState(() {
      _selectedRecordKey = record['key'];
    });
  }

  // bool _formIsValid() {
  //   return _nameController.text.isNotEmpty &&
  //       _priceController.text.isNotEmpty &&
  //       _codeController.text.isNotEmpty &&
  //       _formKey.currentState!.validate();
  // }
  bool _formIsValid() {
    return _formKey.currentState?.validate() ?? false;
  }

  String _searchText = '';

  void _updateSearch(String text) {
    setState(() {
      _searchText = text;
    });
  }

  List<Map<String, dynamic>> _filteredRecords() {
    return _records.where((record) {
      final name = record['name'].toString().toLowerCase();
      final code = record['code'].toString().toLowerCase();
      final price = record['price'].toString();

      return name.contains(_searchText.toLowerCase()) ||
          code.contains(_searchText.toLowerCase()) ||
          price.contains(_searchText);
    }).toList();
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

    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(title: Text('Sembast Example')),
        body: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: Expanded(
                child: Padding(
                  padding: EdgeInsets.symmetric(vertical: 10, horizontal: 20),
                  child: Form(
                    key: _formKey,
                    onChanged: () {
                      // Appelé à chaque fois que le contenu du formulaire change
                      setState(() {});
                    },
                    child: Column(
                      children: [
                        TextFormField(
                          controller: _nameController,
                          decoration: InputDecoration(labelText: 'Name'),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter a name';
                            }
                            return null;
                          },
                        ),
                        TextFormField(
                          controller: _priceController,
                          decoration: InputDecoration(labelText: 'Price'),
                          keyboardType: TextInputType.number,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter a price';
                            }
                            if (double.tryParse(value) == null) {
                              return 'Please enter a valid number';
                            }
                            return null;
                          },
                        ),
                        TextFormField(
                          controller: _codeController,
                          decoration: InputDecoration(labelText: 'Code'),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter a code';
                            }
                            return null;
                          },
                        ),
                        SizedBox(height: 10),
                        ElevatedButton(
                          onPressed: _formIsValid() ? _saveRecord : null,
                          child: Text(_selectedRecordKey == null
                              ? 'Insert Record'
                              : 'Update Record'),
                        ),
                        SizedBox(height: 10),
                        ElevatedButton(
                          onPressed: _populateWithRandomRecords,
                          child: Text('Generate 1000 Random Records'),
                        ),
                        SizedBox(height: 10),
                        Center(
                            child: Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(_records.length.toString(),
                                style: TextStyle(
                                  fontSize: 30,
                                  fontWeight: FontWeight.bold,
                                )),
                            IconButton(
                              onPressed: _deleteAllRecords,
                              icon: Icon(Icons.delete),
                            ),
                          ],
                        )),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            SliverPadding(
              padding: EdgeInsets.all(10),
              sliver: SliverAppBar(
                //title: Text('Sembast Example'),
                floating: true,
                pinned: true,
                flexibleSpace: TextField(
                  decoration: InputDecoration(
                    labelText: 'Search (Name, Code, or Price)',
                    prefixIcon: Icon(Icons.search),
                  ),
                  onChanged: _updateSearch,
                ),
              ),
            ),
            SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  final reversedIndex = _filteredRecords().length - index - 1;
                  final record = _filteredRecords()[reversedIndex];
                  return ListTile(
                    title: Text('Name: ${record['name']}'),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Price: \$${record['price']}'),
                        Text('Code: ${record['code']}'),
                        Text('Last Modified: ${record['lastModified']}'),
                      ],
                    ),
                    onTap: () {
                      _populateForm(record);
                    },
                    trailing: IconButton(
                      icon: Icon(Icons.delete),
                      onPressed: () {
                        _deleteRecord(record['key']);
                      },
                    ),
                  );
                },
                childCount: _filteredRecords().length,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
