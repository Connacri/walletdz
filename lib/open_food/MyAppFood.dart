import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:html/parser.dart' as htmlParser;
import 'package:html/dom.dart' as dom;
import 'package:openfoodfacts/openfoodfacts.dart';

import 'openfoodfacts .dart';
import 'jsoncodescan.dart';

class MyAppFood extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: Text('Open Food Facts 8'),
        ),
        body: ProductList(),
      ),
    );
  }
}

class ProductList extends StatefulWidget {
  @override
  _ProductListState createState() => _ProductListState();
}

class _ProductListState extends State<ProductList> {
  String resultText = 'Initial Text';
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getWebsiteData();
    print('intialised*************');
  }

  Future<void> getWebsiteData() async {
    final url = Uri.parse('https://www.ouedkniss.com/informatique/1');
    final response = await http.get(url);
    dom.Document html = dom.Document.html(response.body);
    final titles = html
        .querySelectorAll(
            'div > div.d-flex.flex-column.o-announ-card-column > a > div.mx-2 > h2')
        .map((e) => e.innerHtml.trim())
        .toList();
    print('Count: ${titles.length}');
    for (final title in titles) {
      debugPrint(title);
    }

    // Mettez à jour le texte avec les résultats
    setState(() {
      resultText =
          titles.join('\n'); // Concaténez les titres avec un saut de ligne
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Affichagedes Résultats'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: () => Navigator.of(context).push(
                  MaterialPageRoute(builder: (context) => jsoncodescan())),
              child: Text('jsoncodescan'),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => Navigator.of(context).push(
                  MaterialPageRoute(builder: (context) => openFoodFacts())),
              child: Text('openFoodFacts'),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                // Appel de la fonction pour obtenir les données du site web
                getWebsiteData();
              },
              child: Text('Obtenir les données du site web'),
            ),
            SizedBox(height: 20),
            Text(
              'Résultats :',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10),
            Expanded(
              child: SingleChildScrollView(
                child: Text(
                  resultText,
                  style: TextStyle(fontSize: 16),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
