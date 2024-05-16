import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class gpt extends StatefulWidget {
  @override
  _gptState createState() => _gptState();
}

class _gptState extends State<gpt> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  int? _selectedUserId;
  final supabase = Supabase.instance.client;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Supabase CRUD Example'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildForm(),
            SizedBox(height: 16.0),
            Expanded(
              child: _buildUserList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildForm() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        TextField(
          controller: _nameController,
          decoration: InputDecoration(labelText: 'Name'),
        ),
        TextField(
          controller: _emailController,
          decoration: InputDecoration(labelText: 'Email'),
        ),
        SizedBox(height: 16.0),
        Row(
          children: [
            ElevatedButton(
              onPressed: _selectedUserId == null ? _createUser : _updateUser,
              child: Text(_selectedUserId == null ? 'Add User' : 'Update User'),
            ),
            SizedBox(width: 16.0),
            ElevatedButton(
              onPressed: _clearFields,
              child: Text('Clear'),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildUserList() {
    return StreamBuilder<List<dynamic>>(
      stream: supabase.from('users').stream(primaryKey: ['id']).execute(),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          final List<dynamic> users = snapshot.data!;
          return ListView.builder(
            itemCount: users.length,
            itemBuilder: (context, index) {
              final user = users[index];
              return ListTile(
                title: Text(user['name']),
                subtitle: Text(user['email']),
                selected: _selectedUserId == user['id'],
                onTap: () => _selectUser(user['id']),
                trailing: IconButton(
                  icon: Icon(Icons.delete),
                  onPressed: () => _deleteUser(user['id']),
                ),
              );
            },
          );
        } else if (snapshot.hasError) {
          print(snapshot.error);
          return Text('Error: ${snapshot.error}');
        }
        return Center(child: CircularProgressIndicator());
      },
    );
  }

  void _selectUser(int userId) {
    setState(() {
      _selectedUserId = userId;
      _nameController.text = '';
      _emailController.text = '';
    });
    _getUserDetails(userId);
  }

  Future<void> _getUserDetails(int userId) async {
    try {
      final user =
          await supabase.from('users').select().eq('id', userId).single();
      _nameController.text = user['name'];
      _emailController.text = user['email'];
    } catch (error) {
      // Handle any errors that occur during the database query
      print('Error fetching user details: $error');
    }
  }

  Future<void> _createUser() async {
    final name = _nameController.text;
    final email = _emailController.text;
    await supabase.from('users').insert({'name': name, 'email': email});
    _clearFields();
  }

  Future<void> _updateUser() async {
    final name = _nameController.text;
    final email = _emailController.text;
    await supabase
        .from('users')
        .update({'name': name, 'email': email}).eq('id', _selectedUserId!);
    _clearFields();
  }

  Future<void> _deleteUser(int userId) async {
    await supabase.from('users').delete().eq('id', userId);
    _clearFields();
  }

  void _clearFields() {
    setState(() {
      _selectedUserId = null;
      _nameController.clear();
      _emailController.clear();
    });
  }
}
