import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:html/parser.dart' as htmlParser;
import 'package:html/dom.dart' as htmlDom;

class openFoodFacts extends StatefulWidget {
  @override
  _openFoodFactsState createState() => _openFoodFactsState();
}

class _openFoodFactsState extends State<openFoodFacts> {
  List<String> extractedData = [];

  @override
  void initState() {
    super.initState();
    fetchData();
  }

  Future<void> fetchData() async {
    final response = await http.get(Uri.parse('https://dz.openfoodfacts.org/'));

    if (response.statusCode == 200) {
      final document = htmlParser.parse(response.body);
      final elements = document.querySelectorAll(
          '#products_match_all > li:nth-child(6) > a > div > div.list_product_name.v-space-tiny'); // Remplacez 'votre-classe-css'

      setState(() {
        extractedData = elements.map((element) => element.text).toList();
      });
    } else {
      print('Erreur de réseau : ${response.statusCode}');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Extraction de données'),
      ),
      body: ListView.builder(
        itemCount: extractedData.length,
        itemBuilder: (context, index) {
          return ListTile(
            title: Text(extractedData[index]),
          );
        },
      ),
    );
  }
}
