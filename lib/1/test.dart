import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:walletdz/1/test2add.dart';

class countries extends StatelessWidget {
  const countries({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      title: 'Countries',
      home: HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final _future = Supabase.instance.client.from('countries').select();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        actions: [
          IconButton(
              onPressed: () => Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => AddCountryPage(),
                    ),
                  ),
              icon: Icon(Icons.send))
        ],
      ),
      body: FutureBuilder(
        future: _future,
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          final countries = snapshot.data!;
          return ListView.builder(
            itemCount: countries.length,
            itemBuilder: ((context, index) {
              final country = countries[index];
              return ListTile(
                leading: CircleAvatar(
                  child: Text(country['iso2']),
                ),
                title: Row(
                  // mainAxisAlignment: MainAxisAlignment.start,
                  // crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Text(
                        country['name'],
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    Text(
                      country['iso3'],
                    ),
                    SizedBox(
                      width: 10,
                    ),
                    Text(index.toString()),
                  ],
                ),
                trailing: IconButton(
                  icon: Icon(Icons.delete),
                  onPressed: () {
                    deleteCountry(country['id'].toString());
                  },
                ),
              );
            }),
          );
        },
      ),
    );
  }

  void deleteCountry(String countryId) async {
    await supabase.from('countries').delete().eq('id', countryId);
    print('${countryId} deleting process..');
    setState(() {
      // Rafraîchir la liste des pays après la suppression
    });
  }
}
