import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;
import 'package:country_flags/country_flags.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class FlagDetector extends StatefulWidget {
  final String barcode;

  const FlagDetector({Key? key, required this.barcode}) : super(key: key);

  @override
  _FlagDetectorState createState() => _FlagDetectorState();
}

class _FlagDetectorState extends State<FlagDetector> {
  late Future<List<dynamic>> countries;
  String _detectedCountry = "Inconnu";
  String _detectedIsoCode = "";

  @override
  void initState() {
    super.initState();
    countries = loadCountries();
    detectCountry(widget.barcode);
  }

  @override
  void didUpdateWidget(FlagDetector oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.barcode != oldWidget.barcode) {
      detectCountry(widget.barcode);
    }
  }

  Future<List<dynamic>> loadCountries() async {
    String jsonString = await rootBundle.loadString('assets/countries.json');
    Map<String, dynamic> jsonResponse = jsonDecode(jsonString);
    if (jsonResponse['pays'] != null) {
      return jsonResponse['pays'];
    }
    return [];
  }

  void detectCountry(String barcode) {
    countries.then((data) {
      setState(() {
        String prefix = barcode.length >= 3 ? barcode.substring(0, 3) : barcode;
        Map<String, String> result = findCountry(prefix, data);
        _detectedCountry = result['name'] ?? "Inconnu";
        _detectedIsoCode = result['iso'] ?? "";
      });
    });
  }

  Map<String, String> findCountry(String prefix, List<dynamic> countries) {
    if (prefix.isEmpty) {
      return {'name': "Inconnu", 'iso': ""};
    }
    int code = int.tryParse(prefix) ?? -1;
    if (code == -1) {
      return {'name': "Inconnu", 'iso': ""};
    }
    for (var country in countries) {
      for (String range in country['prefixes']) {
        if (range.contains('-')) {
          List<String> parts = range.split('-');
          int start = int.parse(parts[0]);
          int end = int.parse(parts[1]);
          if (code >= start && code <= end) {
            return {'name': country['nom'], 'iso': country['iso']};
          }
        } else {
          if (code == int.parse(range)) {
            return {'name': country['nom'], 'iso': country['iso']};
          }
        }
      }
    }
    return {'name': "Inconnu", 'iso': ""};
  }

  @override
  Widget build(BuildContext context) {
    return CountryDisplay(
      country: _detectedCountry,
      isoCode: _detectedIsoCode,
    );
  }
}

class CountryDisplay extends StatelessWidget {
  final String country;
  final String isoCode;
  const CountryDisplay({
    Key? key,
    required this.country,
    required this.isoCode,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        isoCode.isNotEmpty
            ? CountryFlag.fromCountryCode(
                isoCode,
                height: 30,
                width: 50,
                shape: const RoundedRectangle(6),
              )
            : Container(
                height: 30,
                width: 50,
                child: Icon(FontAwesomeIcons.globe, color: Colors.black54)),
        const SizedBox(width: 10),
        FittedBox(
          child: Text(
            'Made in ' + country,
            style: const TextStyle(fontSize: 20, color: Colors.black54),
          ),
        ),
      ],
    );
  }
}
