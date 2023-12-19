import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'deleteCollection.dart';

class JsonTest extends StatefulWidget {
  @override
  _JsonTestState createState() => _JsonTestState();
}

class _JsonTestState extends State<JsonTest> {
  TextEditingController barcodeController = TextEditingController();
  String resultMessage = '';
  List<String> barcodeList = [];
  List<String> notFoundBarcodeList = [];

  String documentCountFoodProds = 'Chargement...';
  String documentCountNonTrouve = 'Chargement...';
  String documentCountRequeteError = 'Chargement...';
  String documentCountTraitementError = 'Chargement...';

  @override
  void initState() {
    super.initState();
    _loadBarcodeList();
    _loadAndCountBarcodes();
    _startListeningToCollection('FoodPods', () {
      setState(() {
        documentCountFoodProds = 'Documents dans FoodProds: $documentCount';
      });
    });
    _startListeningToCollection('non_trouve', () {
      setState(() {
        documentCountNonTrouve = 'Documents dans non_trouve: $documentCount';
      });
    });
    _startListeningToCollection('requeteError', () {
      setState(() {
        documentCountRequeteError =
            'Documents dans requeteError: $documentCount';
      });
    });
    _startListeningToCollection('traitementError', () {
      setState(() {
        documentCountTraitementError =
            'Documents dans traitementError: $documentCount';
      });
    });
  }

  @override
  void dispose() {
    _stopListeningToCollection();
    super.dispose();
  }

  void _startListeningToCollection(String collectionName, Function callback) {
    CollectionReference collectionReference =
        FirebaseFirestore.instance.collection(collectionName);

    collectionReference.snapshots().listen((QuerySnapshot querySnapshot) {
      setState(() {
        documentCount = querySnapshot.size.toString();
        callback();
      });
    });
  }

  void _stopListeningToCollection() {
    // Arrête l'écoute du flux lorsque le widget est détruit
    // Ceci est important pour éviter des fuites de mémoire
    // si ce widget est utilisé ailleurs dans l'application
    // et qu'il est retiré de l'arbre des widgets.
  }

  String documentCount = 'Chargement...';

  Future<void> _loadBarcodeList() async {
    final jsonString = await rootBundle.loadString('assets/listcode.json');
    final List<dynamic> decodedJson = json.decode(jsonString);
    setState(() {
      barcodeList = List<String>.from(decodedJson);
    });
  }

  Future<void> _loadAndCountBarcodes() async {
    final jsonString = await rootBundle.loadString('assets/listcode.json');
    final List<dynamic> decodedJson = json.decode(jsonString);

    Map<String, int> barcodeCount = {};
    List<String> repeatedBarcodes = [];

    for (String barcode in decodedJson) {
      barcodeCount[barcode] = (barcodeCount[barcode] ?? 0) + 1;

      // Vérifier si le code-barres se répète
      if (barcodeCount[barcode] == 2) {
        repeatedBarcodes.add(barcode);
      }
    }

    // Construire la chaîne de caractères avec les codes-barres qui se répètent
    String resultText = 'Codes-barres répétés :\n';
    for (String barcode in repeatedBarcodes) {
      resultText +=
          'Code-barres : $barcode, Occurrences : ${barcodeCount[barcode]}\n';
    }

    // Mettre à jour l'état pour afficher la chaîne de caractères dans le widget Text
    setState(() {
      barcodeCountText = resultText;
    });
  }

  String barcodeCountText = 'Chargement...';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Barcode Tester'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Center(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SizedBox(
                height: 30,
              ),
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Center(
                  child: Text(
                    barcodeCountText,
                    style: TextStyle(fontSize: 16),
                  ),
                ),
              ),
              Text('$documentCountFoodProds'),
              Text('$documentCountNonTrouve'),
              Text('$documentCountRequeteError'),
              Text('$documentCountTraitementError'),
              SizedBox(
                height: 30,
              ),
              ElevatedButton(
                onPressed: () => Navigator.of(context).push(MaterialPageRoute(
                    builder: (context) => deleteCollection())),
                child: Text('DeleteCollection'),
              ),
              SizedBox(
                height: 30,
              ),
              ElevatedButton(
                onPressed: () async {
                  await _onTestBarcodesPressed();
                },
                child: Text('Tester les codes-barres de la liste'),
              ),
              SizedBox(height: 16),
              Expanded(
                child: SingleChildScrollView(
                  child: Text(
                    resultMessage,
                    // Stylez le texte selon vos préférences
                    style: TextStyle(fontSize: 16),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _onTestBarcodesPressed() async {
    List<String> barcodesToTest = List.from(barcodeList);

    // Ajoutez les codes-barres qui n'ont pas été trouvés lors de la première exécution
    barcodesToTest.addAll(notFoundBarcodeList);

    for (String barcode in barcodesToTest) {
      await _processBarcode(barcode);
    }
  }

  Future<void> _processBarcode(String barcode) async {
    final apiUrl =
        "https://world.openfoodfacts.org/api/v2/product/$barcode.json";

    try {
      final response = await http.get(Uri.parse(apiUrl));

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);

        if (jsonData['status'] == 1) {
          final isBarcodeExist = await _checkIfBarcodeExists(barcode);

          if (!isBarcodeExist) {
            // Extraire les attributs spécifiques du JSON
            final productData = _extractProductData(jsonData);

            await _saveToFirestore(barcode, productData);
            setState(() {
              resultMessage +=
                  'Le produit pour le code-barres $barcode a été enregistré dans Firestore.\n';
            });
          } else {
            setState(() {
              resultMessage +=
                  'Le produit pour le code-barres $barcode existe déjà dans la collection "FoodPoducts".\n';
            });
          }
        } else {
          await _saveToNotFoundCollection(barcode);
          setState(() {
            resultMessage +=
                'Aucun produit trouvé pour le code-barres $barcode. Enregistré dans la collection "non_trouve".\n';
          });
        }
      } else {
        await _saveToErrorCollection(barcode, 'requeteError');
        setState(() {
          resultMessage +=
              'Erreur lors de la requête pour le code-barres $barcode : ${response.statusCode}\n';
        });
      }
    } catch (e) {
      await _saveToErrorCollection(barcode, 'traitementError');
      setState(() {
        resultMessage +=
            'Erreur lors du traitement du code-barres $barcode : $e\n';
      });
    }
  }

  // Extraire les attributs spécifiques du JSON
  Map<String, dynamic> _extractProductData(Map<String, dynamic> jsonData) {
    return {
      'code': jsonData['code'],
      'allergens_from_ingredients': jsonData['product']
          ['allergens_from_ingredients'],
      'brands': jsonData['product']['brands'],
      'categories': jsonData['product']['categories'],
      'countries': jsonData['product']['countries'],
      'manufacturing_places': jsonData['product']['manufacturing_places'],
      'image_front_url': jsonData['product']['image_front_url'],
      'image_ingredients_url': jsonData['product']['image_ingredients_url'],
      'image_nutrition_small_url': jsonData['product']
          ['image_nutrition_small_url'],
      'image_nutrition_url': jsonData['product']['image_nutrition_url'],
      'image_url': jsonData['product']['image_url'],
      'ingredients': jsonData['product']['ingredients'],
      'ingredients_text': jsonData['product']['ingredients_text'],
    };
  }

  Future<bool> _checkIfBarcodeExists(String barcode) async {
    final firestore = FirebaseFirestore.instance;
    CollectionReference products = firestore.collection('FoodPoducts');

    final docSnapshot = await products.doc(barcode).get();

    return docSnapshot.exists;
  }

  Future<void> _saveToNotFoundCollection(String barcode) async {
    final firestore = FirebaseFirestore.instance;
    CollectionReference notFoundCollection = firestore.collection('non_trouve');

    await notFoundCollection.doc(barcode).set({
      'status': 'not_found',
      'barcode': barcode,
    });

    // Ajoutez le code-barres à la liste des codes-barres non trouvés
    notFoundBarcodeList.add(barcode);
  }

  Future<void> _saveToErrorCollection(String barcode, String collection) async {
    final firestore = FirebaseFirestore.instance;
    CollectionReference notFoundCollection = firestore.collection(collection);

    await notFoundCollection.doc(barcode).set({
      'status': collection,
      'barcode': barcode,
    });

    // Ajoutez le code-barres à la liste des codes-barres non trouvés
    notFoundBarcodeList.add(barcode);
  }

  Future<void> _saveToFirestore(
      String barcode, Map<String, dynamic> productData) async {
    final firestore = FirebaseFirestore.instance;
    CollectionReference products = firestore.collection('FoodPods');

    await products.doc(barcode).set(productData);
  }
}
