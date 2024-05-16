import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

// Initialisation de Supabase
final supabase = Supabase.instance.client;

class AddCountryPage extends StatefulWidget {
  @override
  _AddCountryPageState createState() => _AddCountryPageState();
}

class _AddCountryPageState extends State<AddCountryPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _iso2Controller = TextEditingController();
  final _iso3Controller = TextEditingController();
  final _localNameController = TextEditingController();
  String _continent = 'Africa';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Ajouter un pays'),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _nameController,
                decoration: InputDecoration(labelText: 'Nom complet'),
                validator: (value) {
                  if (value!.isEmpty) {
                    return 'Veuillez entrer le nom complet du pays';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _iso2Controller,
                decoration: InputDecoration(labelText: 'Code ISO alpha-2'),
                validator: (value) {
                  if (value!.isEmpty) {
                    return 'Veuillez entrer le code ISO alpha-2';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _iso3Controller,
                decoration: InputDecoration(labelText: 'Code ISO alpha-3'),
                validator: (value) {
                  if (value!.isEmpty) {
                    return 'Veuillez entrer le code ISO alpha-3';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _localNameController,
                decoration: InputDecoration(labelText: 'Nom local'),
              ),
              DropdownButtonFormField<String>(
                value: _continent,
                onChanged: (String? newValue) {
                  setState(() {
                    _continent = newValue!;
                  });
                },
                items: <String>[
                  'Africa',
                  'Antarctica',
                  'Asia',
                  'Europe',
                  'North America',
                  'Oceania',
                  'South America'
                ].map<DropdownMenuItem<String>>((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
                decoration: InputDecoration(labelText: 'Continent'),
              ),
              ElevatedButton(
                onPressed: () async {
                  if (_formKey.currentState!.validate()) {
                    final data = {
                      'name': _nameController.text,
                      'iso2': _iso2Controller.text,
                      'iso3': _iso3Controller.text,
                      'local_name': _localNameController.text,
                      'continent': _continent,
                    };

                    await supabase.from('countries').insert(data).select();
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Pays ajouté avec succès'),
                      ),
                    );

                    _nameController.clear();
                    _iso2Controller.clear();
                    _iso3Controller.clear();
                    _localNameController.clear();
                  }
                },
                child: Text('Ajouter'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
