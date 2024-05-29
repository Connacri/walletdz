import 'package:flutter/material.dart';
import 'DatabaseHelper.dart';
import 'models.dart';

class ClientProvider with ChangeNotifier {
  List<Client> _clients = [];

  List<Client> get clients => _clients;

  Future<void> fetchClients() async {
    final db = await DatabaseHelper().database;
    final List<Map<String, dynamic>> maps = await db.query('clients');

    _clients = List.generate(maps.length, (i) {
      return Client.fromMap(maps[i]);
    });

    notifyListeners();
  }

  Future<void> addClient(Client client) async {
    final db = await DatabaseHelper().database;
    await db.insert('clients', client.toMap());
    fetchClients();
  }

  Future<void> updateClient(Client client) async {
    final db = await DatabaseHelper().database;
    await db.update(
      'clients',
      client.toMap(),
      where: 'id = ?',
      whereArgs: [client.id],
    );
    fetchClients();
  }

  Future<void> deleteClient(int id) async {
    final db = await DatabaseHelper().database;
    await db.delete(
      'clients',
      where: 'id = ?',
      whereArgs: [id],
    );
    fetchClients();
  }
}
