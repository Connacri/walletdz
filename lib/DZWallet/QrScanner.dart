import 'dart:developer';
import 'dart:io';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:lottie/lottie.dart';
import 'package:provider/provider.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';
import 'payment.dart';
import 'MoneyTransferPage.dart';
import 'providers.dart';

class QrScanner extends StatefulWidget {
  const QrScanner({
    super.key,
    required this.currentUser,
  });
  final String currentUser;
  @override
  _QrScannerState createState() => _QrScannerState();
}

class _QrScannerState extends State<QrScanner> {
  @override
  void initState() {
    super.initState();
    FirebaseFirestore.instance.collection('Users');

    //resumecam();
  }

  Barcode? result;
  QRViewController? controller;
  final GlobalKey qrKey = GlobalKey(debugLabel: 'QR');

  @override
  void reassemble() {
    super.reassemble();
    if (Platform.isAndroid) {
      controller!.pauseCamera();
    }
    controller!.resumeCamera();
  }

  Color color3 = const Color.fromARGB(255, 228, 122, 170);
  Color color2 = const Color.fromARGB(255, 253, 177, 149);
  Color color1 = const Color.fromARGB(255, 33, 4, 64);

  @override
  Widget build(BuildContext context) {
    // final userModel = Provider.of<UserProvider>(context);
    // userModel.fetchUserAndWatchCoins(widget.currentUser);

    return Scaffold(
      body: Column(
        children: <Widget>[
          Expanded(flex: 1, child: _buildQrView(context)),
          Expanded(
            //  flex: 1,
            child: result != null
                ? result!.code!.contains('/')
                    ? UnacceptableCharacter(context)
                    :
                    // Consumer<UserProvider>(
                    //             builder: (context, userProvider, _) {
                    //   return FutureBuilder<bool>(
                    //     future: checkIfDocExists(result!.code),
                    //     builder: (context, snapshotdoc) {
                    //       if (snapshotdoc.hasData) {
                    //         if (snapshotdoc.data!) {
                    //           SchedulerBinding.instance
                    //               .addPostFrameCallback((_) {
                    //             Navigator.push(
                    //               context,
                    //               MaterialPageRoute(
                    //                 builder: (context) => MoneyTransferPage(
                    //                   fromAccount: widget.currentUser,
                    //                   toAccount: result!.code.toString(),
                    //                 ),
                    //               ),
                    //             );
                    //           });
                    //         }
                    //         return Container(); // Ne rien afficher si on navigue
                    //       }
                    //       return Center(
                    //         child: Padding(
                    //           padding: const EdgeInsets.all(28.0),
                    //           child: LinearProgressIndicator(),
                    //         ),
                    //       );
                    //     },
                    //   );
                    // })
                    // return
                    ListView(
                        shrinkWrap: true,
                        children: [
                          FutureBuilder<bool>(
                            future: checkIfDocExists(result!.code),
                            builder: (context, snapshotdoc) {
                              if (snapshotdoc.hasData) {
                                if (snapshotdoc.data!) {
                                  return Column(
                                    children: [
                                      // FutureBuilderScannedItem(
                                      //     result: result!.code.toString()),
                                      FutureBuilderScannedItemSingle(
                                          currentUser: widget.currentUser,
                                          result: result!.code.toString()),
                                    ],
                                  );
                                }
                                return ItemDontExist(result!.code);
                              }
                              return Center(
                                child: Padding(
                                  padding: const EdgeInsets.all(28.0),
                                  child: LinearProgressIndicator(),
                                ),
                              );
                            },
                          ),
                        ],
                        //   );
                        // }
                      )
                : Stack(
                    alignment: Alignment.topCenter,
                    children: [
                      Center(
                        child: Lottie.asset(
                          "assets/lotties/1 (26).json",
                          fit: BoxFit.contain,
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(28.0),
                        child: Text(
                          'Wainting To Scan...',
                          style: Theme.of(context).textTheme.headlineSmall,
                        ),
                      ),
                    ],
                  ),
          ),

          //),
        ],
      ),
    );
  }

  Center UnacceptableCharacter(BuildContext context) {
    return Center(
        child: Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          result!.code.toString(),
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.headlineSmall,
        ),
        Text(
          'Code Content \n Unacceptable Character!!!',
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.headlineSmall,
        ),
      ],
    ));
  }

  ItemDontExist(code) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Stack(
          alignment: Alignment.center,
          children: [
            Padding(
              padding: const EdgeInsets.all(40.0),
              child: Lottie.asset(
                'assets/lotties/1 (18).json',
              ),
            ),
            Positioned(
              top: 0,
              child: Center(
                child: Text(
                    'CodeBar : ${result!.code}\nItem Don\'t Exist In Our Base',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 18, color: Colors.red)

                    //snapshot.data!.docs.length.toString()
                    ),
              ),
            ),
            // Positioned(
            //   bottom: 0,
            //   child: ElevatedButton(
            //     onPressed: () {
            //       // Navigator.of(context).push(MaterialPageRoute(
            //       //   builder: (context) => Addingitems(
            //       //     code: code,
            //       //   ),
            //       // ));
            //     },
            //     child: Text('Add New Item'),
            //   ),
            // ),
          ],
        ),
      ],
    );
  }

  Widget _buildQrView(BuildContext context) {
    var scanArea = (MediaQuery.of(context).size.width < 400 ||
            MediaQuery.of(context).size.height < 400)
        ? 250.0
        : 300.0;

    return Stack(
      alignment: AlignmentDirectional.bottomCenter,
      children: [
        QRView(
          key: qrKey,
          onQRViewCreated: _onQRViewCreated,
          overlay: QrScannerOverlayShape(
              borderColor: Colors.red,
              borderRadius: 5,
              borderLength: 30,
              borderWidth: 5,
              cutOutSize: scanArea),
          onPermissionSet: (ctrl, p) => _onPermissionSet(context, ctrl, p),
          formatsAllowed: const <BarcodeFormat>[
            BarcodeFormat.codabar,
            BarcodeFormat.aztec,
            BarcodeFormat.code39,
            BarcodeFormat.code93,
            BarcodeFormat.code128,
            BarcodeFormat.pdf417,
            BarcodeFormat.ean8,
            BarcodeFormat.ean13,
            BarcodeFormat.qrcode,
            BarcodeFormat.upcEanExtension,
            BarcodeFormat.upcE,
            BarcodeFormat.upcA,
            BarcodeFormat.unknown,
            BarcodeFormat.rssExpanded,
            BarcodeFormat.rss14,
            BarcodeFormat.maxicode,
            BarcodeFormat.itf,
            BarcodeFormat.dataMatrix,
          ],
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            // Container(
            //   margin: const EdgeInsets.all(8),
            //   child: IconButton(
            //     color: Colors.white,
            //     onPressed: () async {
            //       await controller?.pauseCamera();
            //     },
            //     icon: Icon(Icons.pause),
            //     //child: const Text('pause', style: TextStyle(fontSize: 20)),
            //   ),
            // ),
            Padding(
              padding: const EdgeInsets.only(bottom: 18.0),
              child: GestureDetector(
                onTap: () async {
                  await controller?.toggleFlash();

                  setState(() {});
                },
                child: FutureBuilder(
                  future: controller?.getFlashStatus(),
                  builder: (context, snapshot) {
                    bool? onoff = snapshot.data;
                    return onoff == true
                        ? const Icon(
                            Icons.light_mode,
                            color: Colors.yellow,
                          )
                        : const Icon(Icons.flash_off, color: Colors.white);
                    //Text('ON') : Text('OFF');
                    //Text('Flash: ${snapshot.data}');
                  },
                ),
              ),
            ),
            widget011(
              controller: controller,
            ),
          ],
        ),
      ],
    );
  }

  Future _onQRViewCreated(QRViewController controller) async {
    setState(() {
      this.controller = controller;
    });
    await controller.resumeCamera();

    controller.scannedDataStream.listen((scanData) async {
      setState(() {
        result = scanData;
      });
      await controller.pauseCamera();
      //
      // AwesomeDialog(
      //   context: context,
      //   dialogType: DialogType.INFO,
      //   animType: AnimType.BOTTOMSLIDE,
      //   title: scanData.code.toString(),
      //   desc: 'Dialog description here.............',
      //   btnCancelOnPress: () {},
      //   btnOkOnPress: () {},
      // )
      //  .show();

      //controller.resumeCamera();
    });

    //await controller.pauseCamera();
  }

  void _onPermissionSet(BuildContext context, QRViewController ctrl, bool p) {
    log('${DateTime.now().toIso8601String()}_onPermissionSet $p');
    if (!p) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('no Permission')),
      );
    }
  }

  void resumecam() async {
    await controller?.resumeCamera();
  }

  @override
  void dispose() {
    controller?.dispose();
    super.dispose();
  }

  /// Check If Document Exists
  Future<bool> checkIfDocExists(String? docId) async {
    //bool innerVal = false;
    DocumentSnapshot<Map<String?, dynamic>> document =
        await FirebaseFirestore.instance.collection('Users').doc(docId).get();

    if (document.exists) {
      return true; //innerVal;
    } else {
      return false; //innerVal;
    }
  }
}

class widget011 extends StatefulWidget {
  const widget011({Key? key, required this.controller}) : super(key: key);
  final QRViewController? controller;

  @override
  State<widget011> createState() => _widget011State();
}

class _widget011State extends State<widget011>
    with SingleTickerProviderStateMixin {
  bool _isPlay = false;
  late AnimationController _controller;

  @override
  void initState() {
    _controller = AnimationController(
        duration: const Duration(milliseconds: 300), vsync: this);
    super.initState();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
        onTap: () {
          if (_isPlay == false) {
            setState(() {
              _controller.forward();
              _isPlay = true;
              widget.controller?.resumeCamera();
            });
          } else {
            setState(() {
              _controller.reverse();
              _isPlay = false;
              widget.controller?.pauseCamera();
            });
          }
        },
        child: Padding(
          padding: const EdgeInsets.only(bottom: 18.0),
          child: AnimatedIcon(
            color: Colors.white,
            icon: AnimatedIcons.play_pause,
            progress: _controller,
            size: 30,
          ),
        ));
  }
}

class FutureBuilderScannedItemSingle extends StatefulWidget {
  const FutureBuilderScannedItemSingle({
    Key? key,
    required this.currentUser,
    required this.result,
  }) : super(key: key);

  final String currentUser;
  final String result;

  @override
  State<FutureBuilderScannedItemSingle> createState() =>
      _FutureBuilderScannedItemSingleState();
}

class _FutureBuilderScannedItemSingleState
    extends State<FutureBuilderScannedItemSingle> {
  final GlobalKey<FormState> _formKeyQty = GlobalKey<FormState>();
  final TextEditingController _qtyController =
      TextEditingController(text: '01');

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: FirebaseFirestore.instance
            .collection('Users')
            .doc(widget.result)
            .get(),
        builder: (BuildContext, AsyncSnapshot snapshot) {
          if (snapshot.connectionState == ConnectionState.none) {
            return Text(
              'Error!!!',
              style: Theme.of(context).textTheme.headlineSmall,
            );
          }
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
              child: Padding(
                  padding: const EdgeInsets.all(60.0),
                  child: Lottie.asset('assets/lotties/1 (20).json')
                  //CircularProgressIndicator(),
                  ),
            );
          }
          if (snapshot.connectionState == ConnectionState.done) {
            if (snapshot.hasData) {
              // Future.delayed(Duration(milliseconds: 100), () {
              //  Navigator.of(context).pushReplacement(
              //   MaterialPageRoute(
              //    builder: (context) =>
              // TransactionPage(scannedUserId: dataid.toString()),
              //  ),
              //   );
              // });

              var data = snapshot.data;
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 18.0),
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundImage: CachedNetworkImageProvider(data['avatar']),
                  ),
                  title: Text(data['displayName'],
                      style: const TextStyle(
                        color: Colors.black87,
                        fontWeight: FontWeight.w500,
                      )),
                  subtitle: Text(data['email'],
                      style: const TextStyle(
                        color: Colors.black87,
                        fontWeight: FontWeight.w500,
                      )),
                  trailing: IconButton(
                    onPressed: () {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (context) => TransactionPage(
                            scannedUserId: widget.result,
                          ),
                        ),
                      );

                      // Navigator.push(
                      //   context,
                      //   MaterialPageRoute(
                      //       builder: (context) => TransactionPage(
                      //             scannedUserId: widget.result.toString(),
                      //           )
                      //       //     MoneyTransferPage(
                      //       //   fromAccount: widget.currentUser,
                      //       //   toAccount: widget.result.toString(),
                      //       // ),
                      //       ),
                      // );
                    },
                    icon: Icon(Icons.send),
                  ),
                ),
              );
            }
          }
          return Text('');
        });
  }

  Future addToDevisDialog(dataid, data) => showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Center(
            child: FittedBox(
              child: data['stock'] <= 5
                  ? data['stock'] != 0
                      ? Text(
                          'Item : ${data['model'].toString()}\n Left-Over : ${data['stock'].toString()}'
                              .toUpperCase(),
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Colors.orange, // Colors.orange,
                          ),
                        )
                      : Text(
                          'Item : ${data['model'].toString()}'.toUpperCase(),
                          style: TextStyle(
                            color: Colors.red, // Colors.orange,
                          ),
                        )
                  : Text(
                      'Item : ${data['model'].toString()}'.toUpperCase(),
                      style: TextStyle(
                        color: Colors.blue, // Colors.orange,
                      ),
                    ),
            ),
          ),
          actions: [
            Center(
              child: ElevatedButton(
                  onPressed: () {
                    // Validate returns true if the form is valid, or false otherwise.
                    if (!_formKeyQty.currentState!.validate()) {
                      return;
                    } else if (data['stock'] >=
                        int.parse(_qtyController.text)) {
                      // FirebaseFirestore.instance
                      //     .collection('Market')
                      //     .doc(dataid)
                      //     .update({
                      //   'stock': FieldValue.increment(
                      //       -int.parse(_qtyController.text))
                      // });
                      setState(() {
                        addItemsToDevis2(dataid, data, _qtyController.text);
                        print(dataid.toString());
                        _qtyController.clear();
                      });
                    } else {
                      return;
                    }
                    Navigator.pop(context, false);
                  },
                  child: Text(
                    'Add to Estimate'.toUpperCase(),
                    style: const TextStyle(fontSize: 15, color: Colors.black54),
                  )),
            )
          ],
          content: Form(
            key: _formKeyQty,
            child: TextFormField(
              autofocus: true,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 25,
              ),
              keyboardType: TextInputType.number,
              controller: _qtyController,
              validator: (valueQty) =>
                  valueQty!.isEmpty || int.tryParse(valueQty.toString()) == 0
                      ? 'Cant be 0 or Empty'
                      : null,
              decoration: const InputDecoration(
                border: InputBorder.none,
                filled: true,
                contentPadding: EdgeInsets.fromLTRB(20.0, 10.0, 20.0, 10.0),

                hintText: 'Quantity',
                fillColor: Colors.white,
                //filled: true,
              ),
            ),
          ), // availibility,
        ),
      );

  Future<void> addItemsToDevis2(dataid, data, qty) async {
    CollectionReference devisitem =
        FirebaseFirestore.instance.collection('Estimate');

    CollectionReference incrementQty =
        FirebaseFirestore.instance.collection('Adventure');

    DocumentSnapshot<Map<String?, dynamic>> document = await FirebaseFirestore
        .instance
        .collection('Estimate')
        .doc(dataid)
        .get();

    if (!document.exists) {
      return devisitem
          .doc(dataid)
          .set({
            'createdAt': Timestamp.now().toDate(),
            'category': data['category'],
            'model': data['model'],
            'description': data['description'],
            'size': data['size'],
            'prixAchat': data['prixAchat'],
            'prixVente': data['prixVente'],
            'stock': data['stock'],
            'codebar': data['codebar'],
            'oldStock': data['oldStock'],
            'origine': data['origine'],
            'user': data['user'],
            'qty': int.parse(qty),
          }, SetOptions(merge: true))
          .then((value) => print("Item Added to Devis"))
          .catchError((error) => print("Failed to add Item to Devis: $error"))
          .whenComplete(() => incrementQty
              .doc(dataid)
              .update({'stock': FieldValue.increment(-int.parse(qty))}));
    } else {
      print('kayen deja/////////////////////');
      return devisitem
          .doc(dataid)
          .update({'qty': FieldValue.increment(int.parse(qty))})
          .then((value) => print("Item update to Estimate"))
          .catchError(
              (error) => print("Failed to update Item to Estimate: $error"))
          .whenComplete(() => incrementQty
              .doc(dataid)
              .update({'stock': FieldValue.increment(-int.parse(qty))}))
          .then((value) =>
              print('**********************************update c bon'));
    }
  }

  Column buildIfPriceEmptyorNull(BuildContext context) {
    return Column(
      children: [
        Center(
          child: Text(
            'Item Exist In Our Base But \nNot Have Dealer & Prices',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.headlineSmall,
          ),
        ),
        Center(
          child: Lottie.asset("assets/123750-creepy-cat.json",
              fit: BoxFit.contain, height: 150),
        ),
        ElevatedButton(
            onPressed: () {
              // int itemcount = availibility.length;
              // uploadItems(itemcount);
              // Navigator.of(context).push(MaterialPageRoute(
              //   builder: (context) => AddingDealerPrice(
              //     code: widget.result.toString(),
              //   ),
              // ));
            },
            child: Text('Add Dealer & Price to this Item'))
      ],
    );
  }

  Future<void> addItemsToDevis(dataid, data, qty) async {
    CollectionReference Pneux =
        FirebaseFirestore.instance.collection('Estimate');
    // Call the user's CollectionReference to add a new user
    return Pneux.add({
      'dataid': dataid,
      'model': data['model'],
      'retail': data['retail'],
      'dealer': data['dealer'],
      'size': data['size'],
      'description': data['description'],
      //'createdAt': Timestamp.now().toDate(),
      'sale': data['sale'],
      'qty': int.parse(qty),
    })
        .then((value) => print("Item Added to Devis"))
        .catchError((error) => print("Failed to add Item to Devis: $error"));
  }
}
