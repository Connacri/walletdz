import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class jsoncodescan extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  String scannedCode = 'Aucun code scanné';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Scanner de codes-barres'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(
              'Code scanné:',
              style: TextStyle(fontSize: 20),
            ),
            SizedBox(height: 20),
            Text(
              scannedCode,
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () async {
                try {
                  // Commencez à partir d'un numéro de départ
                  int startNumber = 7622210449283;

                  // Incrémente le dernier chiffre du code-barres
                  for (int i = 0; i < 10; i++) {
                    var currentCode = startNumber + i;
                    await fetchProductInfo(currentCode.toString());
                  }
                } catch (e) {
                  print('Erreur lors du scan du code-barres: $e');
                }
              },
              child: Text('Scanner des codes-barres'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> fetchProductInfo(String barcode) async {
    final apiUrl = 'https://world.openfoodfacts.net/api/v2/product/$barcode';

    try {
      final response = await http.get(Uri.parse(apiUrl));
      if (response.statusCode == 200) {
        // Analysez ici la réponse JSON pour obtenir des informations sur le produit
        print('Informations sur le produit: ${response.body}');

        // Ajoutez ici la logique pour vérifier si le produit est lié à l'Algérie
        // Par exemple, vous pourriez vérifier la présence du mot "Algeria" dans la réponse JSON
        if (response.body.toLowerCase().contains('algeria')) {
          setState(() {
            scannedCode = barcode;
          });
        }
      } else {
        print(
            'Erreur lors de la récupération des informations sur le produit: ${response.statusCode}');
      }
    } catch (e) {
      print(
          'Erreur réseau lors de la récupération des informations sur le produit: $e');
    }
  }
}
