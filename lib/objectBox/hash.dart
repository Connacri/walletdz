import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/material.dart';
import 'package:crypto/crypto.dart';
import 'dart:convert';
import 'dart:io' show Platform, Process, ProcessResult;
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:network_info_plus/network_info_plus.dart';
import 'package:pretty_qr_code/pretty_qr_code.dart';
import 'package:pincode_input_fields/pincode_input_fields.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';

class hashPage extends StatefulWidget {
  @override
  _hashPageState createState() => _hashPageState();
}

class _hashPageState extends State<hashPage> {
  String _deviceIdentifier = '';
  String _hash512 = '';
  String _shortHash = '';
  String _numHash = '';
  String _enteredHash = '';
  String _p4ssw0rd = "Oran2024";
  bool _isShowMessage = false;

  @override
  void initState() {
    super.initState();
    _initDeviceIdentifier();
  }

  Future<void> _initDeviceIdentifier() async {
    String? identifier = await getDeviceIdentifier();
    if (identifier != null) {
      setState(() {
        _deviceIdentifier = identifier;
        _hash512 = generateHash(_deviceIdentifier, _p4ssw0rd);
        _shortHash = generateShortHash(_deviceIdentifier, _p4ssw0rd);
        _numHash = generateNumHash(_deviceIdentifier, _p4ssw0rd);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Licence App'),
        actions: [
          IconButton(
            onPressed: () async {
              await getDeviceIdentifier();
            },
            icon: Icon(
              Icons.verified,
              color: Colors.blue,
            ),
          ),
          Platform.isAndroid || Platform.isIOS
              ? IconButton(
                  onPressed: () {
                    Navigator.of(context)
                        .push(MaterialPageRoute(builder: (ctx) => HashAdmin()));
                  },
                  icon: Icon(Icons.add_chart_rounded),
                )
              : Container(),
          SizedBox(
            width: 50,
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Text("Hash SHA-512 (QR code):"),
            Spacer(),
            _hash512.isNotEmpty
                ? Center(
                    child: PrettyQr(
                      data: _hash512.toString(),
                      size: 200.0,
                      elementColor: Theme.of(context).hintColor,
                    ),
                  )
                : CircularProgressIndicator(),
            Spacer(),
            SelectableText(_deviceIdentifier),
            SelectableText(
                utf8.encode(_deviceIdentifier + _p4ssw0rd).toString()),
            SelectableText(generateHash(_deviceIdentifier, _p4ssw0rd)),
            SelectableText(generateShortHash(_deviceIdentifier, _p4ssw0rd)),
            SelectableText(generateNumHash(_deviceIdentifier, _p4ssw0rd)),
            Spacer(),
            Text("Entrer le PIN (depuis l'application mobile):"),
            Spacer(),
            Center(
              child: PincodeInputFields(
                onChanged: (value) {
                  // Met à jour le hash saisi à chaque changement
                  setState(() {
                    _enteredHash = value;
                  });
                },
                onInputComplete: () {
                  // Valide le hash après avoir rempli les champs
                  if (validateNumHash(
                      _enteredHash, _deviceIdentifier, _p4ssw0rd)) {
                    setState(() {
                      _isShowMessage = true;
                    });

                    // Ouvrir l'application
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text("Licence Numerique validée!"),
                        backgroundColor: Colors.green,
                      ),
                    );
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text("num Hash incorrect!"),
                        backgroundColor: Colors.red,
                      ),
                    );
                  }
                },
                autoFocus: true,
                length: 10,
                heigth: 54,
                width: 51,
                borderRadius: BorderRadius.circular(9),
                unfocusBorder: Border.all(
                  width: 1,
                  color: const Color(0xFF5B6774),
                ),
                focusBorder: Border.all(
                  width: 1,
                  color: const Color(0xFF9B71F4),
                ),
                cursorColor: Colors.white,
                cursorWidth: 2,
                focusFieldColor: const Color(0xFF2A2B32),
                unfocusFieldColor: const Color(0xFF2A2B32),
                textStyle: const TextStyle(
                  color: Colors.white,
                  fontSize: 21,
                ),
              ),
            ),
            _isShowMessage
                ? Center(
                    child: Text(
                    "Licence Numerique validée!",
                    style: const TextStyle(
                      color: Colors.green,
                      fontSize: 24,
                    ),
                  ))
                : Center(
                    child: Text(
                    "num Hash incorrect!",
                    style: const TextStyle(
                      color: Colors.red,
                      fontSize: 24,
                    ),
                  )),
            Spacer(),
            Text("Entrer le hash court (depuis l'application mobile):"),
            Spacer(),
            Container(
              width:
                  Platform.isIOS || Platform.isAndroid ? double.infinity : 400,
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: TextFormField(
                  //  keyboardType: TextInputType.number,
                  textAlign: TextAlign.center,
                  decoration: InputDecoration(
                    labelStyle: TextStyle(),

                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8.0),
                      borderSide: BorderSide.none, // Supprime le contour
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8.0),
                      borderSide:
                          BorderSide.none, // Supprime le contour en état normal
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8.0),
                      borderSide:
                          BorderSide.none, // Supprime le contour en état focus
                    ),
                    //border: InputBorder.none,
                    filled: true,
                    contentPadding: EdgeInsets.all(15),
                  ),
                  onChanged: (value) {
                    setState(() {
                      _enteredHash = value;
                    });
                  },
                ),
              ),
            ),
            Spacer(),
            ElevatedButton(
              onPressed: () {
                if (validateHash(_enteredHash, _deviceIdentifier, _p4ssw0rd)) {
                  // Ouvrir l'application
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                    content: Text("Licence validée!"),
                    backgroundColor: Colors.green,
                  ));
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                    content: Text("Hash incorrect!"),
                    backgroundColor: Colors.redAccent,
                  ));
                }
              },
              child: Text("Valider"),
            ),
            Spacer(),
          ],
        ),
      ),
    );
  }
}

Future<String?> getDeviceIdentifier() async {
  DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();

  if (Platform.isAndroid) {
    AndroidDeviceInfo androidInfo = await deviceInfo.androidInfo;
    return androidInfo.id; // Utilisez Android ID
  } else if (Platform.isIOS) {
    IosDeviceInfo iosInfo = await deviceInfo.iosInfo;
    return iosInfo
        .identifierForVendor; // Utilisez l'identifiant pour fournisseur
  } else if (Platform.isLinux) {
    LinuxDeviceInfo linuxInfo = await deviceInfo.linuxInfo;
    return linuxInfo.machineId; // Identifiant unique pour Linux
  } else if (Platform.isMacOS) {
    MacOsDeviceInfo macInfo = await deviceInfo.macOsInfo;
    return macInfo.systemGUID; // Identifiant unique pour macOS
  } else if (Platform.isWindows) {
    WindowsDeviceInfo windowsInfo = await deviceInfo.windowsInfo;
    print(windowsInfo.deviceId);
    return windowsInfo.deviceId; // Identifiant unique pour Windows
  } else if (kIsWeb) {
    // Pour Flutter Web
    WebBrowserInfo webInfo = await deviceInfo.webBrowserInfo;
    return webInfo
        .userAgent; // Utilisez le User Agent comme identifiant (limité sur le Web)
  } else {
    // Autres plateformes comme Fuchsia
    return "Unsupported platform";
  }
}

String generateHash(String deviceIdentifier, String password) {
  var bytes = utf8.encode(deviceIdentifier + password);
  var digest = sha512.convert(bytes);
  return digest.toString();
}

String generateShortHash(String deviceIdentifier, String password) {
  var bytes = utf8.encode(deviceIdentifier + password);
  var digest = sha1.convert(bytes);
  return digest.toString();
}

String generateNumHash(String deviceIdentifier, String password) {
  return generateNumericCode(deviceIdentifier, password);
}

bool validateHash(
    String enteredHash, String deviceIdentifier, String password) {
  var calculatedHash = generateShortHash(deviceIdentifier, password);
  return enteredHash == calculatedHash;
}

bool validateNumHash(
    String enteredHash, String deviceIdentifier, String password) {
  var calculatedHash = generateNumHash(deviceIdentifier, password);
  return enteredHash == calculatedHash;
}

String generateNumericCode(String deviceIdentifier, String password) {
  var bytes = utf8.encode(deviceIdentifier + password);
  var digest = sha256.convert(bytes); // Utilisation de SHA-256
  var hexString = digest.toString();

  // Convertir le hash hexadécimal en un grand entier
  BigInt bigInt = BigInt.parse(hexString, radix: 16);

  // Extraire les 10 premiers chiffres
  String numericCode = bigInt.toString().substring(0, 10);

  return numericCode;
}

class HashAdmin extends StatefulWidget {
  @override
  _HashAdminState createState() => _HashAdminState();
}

class _HashAdminState extends State<HashAdmin> {
  final GlobalKey qrKey = GlobalKey(debugLabel: 'QR');
  QRViewController? controller;
  String? qrCodeHash;
  String _p4ssw0rd = "Oran2024";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Scanner de QR Code'),
      ),
      body: Column(
        children: <Widget>[
          Expanded(
            flex: 3,
            child: QRView(
              key: qrKey,
              onQRViewCreated: _onQRViewCreated,
            ),
          ),
          if (qrCodeHash != null)
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                children: [
                  Text('Hash QR code: $qrCodeHash'),
                  Text('Licence: ' +
                      _validateHash(qrCodeHash!, _p4ssw0rd).toString()),
                  ElevatedButton(
                    onPressed: () {
                      if (_validateHash(qrCodeHash!, _p4ssw0rd)) {
                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                            content: Text("Licence validée avec succès!")));
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                            content:
                                Text("Hash incorrect, licence invalide!")));
                      }
                    },
                    child: Text('Valider la licence'),
                  ),
                ],
              ),
            )
        ],
      ),
    );
  }

  void _onQRViewCreated(QRViewController controller) {
    this.controller = controller;
    controller.scannedDataStream.listen((scanData) {
      setState(() {
        qrCodeHash = _generateHash(scanData.code!);
      });
    });
  }

  String _generateHash(String data) {
    var bytes = utf8.encode(data + _p4ssw0rd);
    var digest = sha512.convert(bytes);
    return digest.toString();
  }

  bool _validateHash(String enteredHash, String password) {
    var calculatedHash = _generateHash(password);
    return enteredHash == calculatedHash;
  }

  @override
  void dispose() {
    controller?.dispose();
    super.dispose();
  }
}
