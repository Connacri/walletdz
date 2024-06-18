import 'package:animated_flip_counter/animated_flip_counter.dart';
import 'package:avatar_glow/avatar_glow.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart' as intl;
import 'package:lottie/lottie.dart';
import 'package:provider/provider.dart';

import 'UserListPageCoins.dart';
import 'models1.dart';
import 'providers.dart';

// class TransactionPage1 extends StatelessWidget {
//   final String scannedUserId;
//
//   TransactionPage1({required this.scannedUserId});
//   @override
//   Widget build(BuildContext context) {
//     // Accéder à l'instance de UserProviderFire
//     final userProvider = UserProviderFire();
//
//     return Scaffold(
//       body: StreamBuilder<UserModele?>(
//         stream:
//             userProvider.userStream, // Utiliser le flux de données utilisateur
//         builder: (context, snapshot) {
//           if (snapshot.connectionState == ConnectionState.waiting) {
//             return Center(
//                 child:
//                     CircularProgressIndicator()); // Indicateur de chargement pendant l'attente
//           }
//
//           if (snapshot.hasError) {
//             return Center(
//                 child: Text("Erreur : ${snapshot.error}")); // Gérer les erreurs
//           }
//
//           final userData = snapshot.data; // Obtenir les données utilisateur
//
//           if (userData == null) {
//             return Center(
//                 child: Text(
//                     "Utilisateur introuvable")); // Gérer le cas où aucune donnée n'est disponible
//           }
//
//           // Utilisation des données utilisateur pour afficher du contenu
//           return Center(
//             child: Text(
//                 "Bienvenue, ${userData.name}!"), // Exemples d'utilisation des données utilisateur
//           );
//         },
//       ),
//     );
//   }
// }

class TransactionPage1 extends StatefulWidget {
  final String scannedUserId;

  TransactionPage1({required this.scannedUserId});

  @override
  State<TransactionPage1> createState() => _TransactionPage1State();
}

class _TransactionPage1State extends State<TransactionPage1> {
  final TextEditingController amountController = TextEditingController();
  final GlobalKey<FormState> _formCoinsKey = GlobalKey<FormState>();
  bool _isSubmitting = false;
  final currentUser = FirebaseAuth.instance.currentUser!.uid;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }

  @override
  void dispose() {
    amountController.dispose(); // Détruire le contrôleur de texte
    super.dispose(); // Appeler la méthode dispose du super
  }

  @override
  Widget build(BuildContext context) {
    final userProvider = UserProviderFire();
    return Scaffold(
      appBar: AppBar(
        title: Text('User Profile'),
      ),
      body: StreamBuilder<UserModele?>(
        stream:
            userProvider.userStream, // Utiliser le flux de données utilisateur
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
                child:
                    CircularProgressIndicator()); // Indicateur de chargement pendant l'attente
          }

          if (snapshot.hasError) {
            return Center(
                child: Text("Erreur : ${snapshot.error}")); // Gérer les erreurs
          }

          final userData = snapshot.data; // Obtenir les données utilisateur

          if (userData == null) {
            return Center(
                child: Text(
                    "Utilisateur introuvable")); // Gérer le cas où aucune donnée n'est disponible
          }

          // Utilisation des données utilisateur pour afficher du contenu
          return ListView(
            children: [
              // IconButton(
              //     onPressed: () => Navigator.of(context).push(
              //         MaterialPageRoute(
              //             builder: (context) => TotalCoinsWidget())),
              //     icon: Icon(FontAwesomeIcons.moneyBill)),
              SizedBox(
                height: 30,
              ),
              TotalCoinsWidget(),
              SizedBox(
                height: 30,
              ),
              ListTile(
                dense: true,
                leading: CircleAvatar(
                  backgroundImage: NetworkImage(
                    userData.avatar ??
                        "https://source.unsplash.com/featured/300x201",
                  ),
                ),
                title: Text(
                  'MON SOLDE : ',
                  style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                      color: Colors.black54),
                ),
                subtitle: AnimatedFlipCounter(
                  value: userData.coins,
                  // Utilisez la partie entière de priceValue.
                  //prefix: "DZD ",
                  suffix: ' DZD',
                  fractionDigits: 2,
                  mainAxisAlignment: MainAxisAlignment.start,
                  duration: const Duration(milliseconds: 800),
                  textStyle: TextStyle(
                    fontFamily: 'OSWALD',
                    color: Colors.green,
                    fontSize: 30,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              IncrementCoinsRow(
                userId: userData.uid,
              ),
              ScannedConsumer(
                scannedUserId: widget.scannedUserId,
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(8, 0, 8, 40),
                child: Text(
                  'Scanned User: ${widget.scannedUserId}'.toUpperCase(),
                  style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w300,
                      color: Colors.black),
                ),
              ),
              TransactionSubmitButton(
                userData: userData.toMap(),
                scannedUserId: widget.scannedUserId,
                formKey: _formCoinsKey,
                amountController: amountController,
                avatar: '',
                displayName: '',
                direction: true,
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(0, 50, 0, 20),
                child: ElevatedButton(
                    onPressed: () {
                      Navigator.of(context).push(MaterialPageRoute(
                          builder: (context) => UserListPageCoins(
                                userId: widget.scannedUserId, //userData.uid,
                              )));
                    },
                    child: Text('Users')),
              )
            ],
          );
        },
      ),
    );
  }
}

class PriceWidget extends StatelessWidget {
  const PriceWidget({
    super.key,
    required this.price,
  });

  final double price;

  @override
  Widget build(BuildContext context) {
    return Text(
      intl.NumberFormat.currency(
        locale: 'fr_FR',
        symbol: 'DZD',
        decimalDigits: 2,
      ).format(price),
      overflow: TextOverflow.ellipsis,
      style: TextStyle(
        color: Colors.blue,
        fontSize: 20,
        fontWeight: FontWeight.w400,
      ),
    );
  }
}

class IncrementCoinsRow extends StatefulWidget {
  final String
      userId; // L'ID de l'utilisateur dont vous voulez incrémenter les coins

  IncrementCoinsRow({required this.userId});

  @override
  _IncrementCoinsRowState createState() => _IncrementCoinsRowState();
}

class _IncrementCoinsRowState extends State<IncrementCoinsRow> {
  TextEditingController _amountController = TextEditingController();
  double _amountToAdd = 0.0;
  final GlobalKey<FormState> _formCoinsLKey = GlobalKey<FormState>();
  bool _isSubmitting = false;

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Form(
          key: _formCoinsLKey,
          child: Expanded(
            child: Padding(
              padding: EdgeInsets.fromLTRB(15, 15, 015, 15),
              child: TextFormField(
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 18,
                ),
                keyboardType: TextInputType.number,
                controller: _amountController,
                decoration: InputDecoration(
                  suffixIcon: InkWell(
                    onTap: _isSubmitting
                        ? null
                        : () async {
                            // Vérifiez si le formulaire est déjà en cours de soumission
                            if (_isSubmitting) return;

                            if (_formCoinsLKey.currentState!.validate()) {
                              // Mettez à jour l'état pour indiquer que la soumission est en cours
                              setState(() {
                                _isSubmitting = true;
                              });

                              DocumentReference userRef = FirebaseFirestore
                                  .instance
                                  .collection('Users')
                                  .doc(widget.userId);

                              try {
                                // Utilisez une transaction Firestore pour incrémenter les coins
                                FirebaseFirestore.instance
                                    .runTransaction((transaction) async {
                                  DocumentSnapshot userSnapshot =
                                      await transaction.get(userRef);

                                  if (userSnapshot.exists) {
                                    // Récupérez les coins actuels de l'utilisateur
                                    double currentCoins =
                                        userSnapshot['coins'] ?? 0.0;

                                    // Incrémente les coins
                                    double newCoins =
                                        currentCoins + _amountToAdd;

                                    // Mettez à jour les coins dans le document de l'utilisateur
                                    transaction.set(
                                        userRef,
                                        {
                                          'coins': newCoins,
                                          'dialogShown': false
                                        },
                                        SetOptions(merge: true));
                                    // Réinitialisez l'état pour indiquer que la soumission est terminée
                                    setState(() {
                                      _isSubmitting = false;
                                    });
                                  }
                                });

                                // Effacez le champ de texte après avoir effectué la transaction
                                _amountController.clear();
                                FocusScope.of(context).unfocus();

                                // Effectuez d'autres actions après une transaction réussie ici
                              } catch (e) {
                                // Gestion des erreurs de transaction
                                print('Erreur lors de la transaction : $e');
                                // Vous pouvez afficher un message d'erreur ici
                              }
                            }
                          },
                    child: _isSubmitting
                        ? FittedBox(
                            child: Lottie.asset(
                              'assets/lotties/1 (3).json',
                              animate: true,
                              repeat: true,
                              width: 150,
                              height: 150,
                            ),
                          )
                        : Icon(
                            Icons.send,
                            color: Color.fromARGB(255, 0, 127, 232),
                            size: 25,
                          ),
                  ),
                  filled: _isSubmitting ? true : false,
                  //<-- SEE HERE
                  fillColor: _isSubmitting ? Colors.grey.shade200 : null,
                  hintStyle: TextStyle(color: Colors.black38),
                  hintText: 'Alimentation Personnel',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(7.0),
                  ),
                  contentPadding: EdgeInsets.all(15),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Entrer Le Montant';
                  }
                  return null;
                },
                onChanged: (value) {
                  setState(() {
                    _amountToAdd = double.tryParse(value) ?? 0.0;
                  });
                },
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class ScannedConsumer extends StatelessWidget {
  const ScannedConsumer({
    super.key,
    required this.scannedUserId,
  });

  final String scannedUserId;

  @override
  Widget build(BuildContext context) {
    Provider.of<UserProviderFire>(context, listen: false)
        .fetchScannedUserData(scannedUserId);
    return Consumer<UserProviderFire>(
      builder: (context, dataProvider, child) {
        final userData = dataProvider.scannedUserData;

        if (userData!.uid.isEmpty) {
          // Display a loading indicator while data is being fetched.
          return Center(
              //child: CircularProgressIndicator(),
              );
        } else {
          final displayName = userData.name;
          final email = userData.email;
          final coins = userData.coins;

          return Center(
            child: Card(
              child: ListTile(
                dense: true,
                leading: CircleAvatar(
                  backgroundImage: NetworkImage(userData.avatar ??
                      "https://source.unsplash.com/featured/300x203"),
                ),
                title: Text(
                  displayName,
                  overflow: TextOverflow.ellipsis,
                  maxLines: 2,
                  textAlign: TextAlign.left,
                  style: isArabic(
                    displayName,
                  )
                      ? GoogleFonts.cairo(
                          fontSize: 16,
                          color: Colors.black54,
                          fontWeight: FontWeight.w700)
                      : TextStyle(
                          color: Colors.black54,
                          fontSize: 16,
                        ),
                ),
                subtitle: FittedBox(
                  child: Text(
                    email!,
                    style: TextStyle(color: Colors.black54),
                  ),
                ),
                trailing: PriceWidget(
                  price: coins,
                ),
              ),
            ),
          );
        }
      },
    );
  }

  bool isArabic(String text) {
    return RegExp(r'[\u0600-\u06FF]').hasMatch(text);
  }
}

class TransactionSubmitButton extends StatefulWidget {
  final Map<String, dynamic> userData;
  final String scannedUserId;
  final GlobalKey<FormState> formKey;
  final TextEditingController amountController;
  final String avatar;
  final bool? direction;
  final String displayName;

  TransactionSubmitButton({
    required this.userData,
    required this.scannedUserId,
    required this.formKey,
    required this.amountController,
    required this.avatar,
    required this.displayName,
    required this.direction,
  });

  @override
  _TransactionSubmitButtonState createState() =>
      _TransactionSubmitButtonState();
}

class _TransactionSubmitButtonState extends State<TransactionSubmitButton> {
  bool _isSubmitting = false;
  final TextEditingController _amountController = TextEditingController();

  String? _validateAmount(String? value) {
    if (value == null || value.isEmpty) {
      return 'Entrez un montant';
    }
    double? amount = double.tryParse(value);
    if (amount == null || amount <= 0 || amount > 5000) {
      return 'Le Montant invalide\nMontant doit etre superieur à 0 et inferieur à 5000';
    }

    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: widget.formKey,
      child: Padding(
        padding: EdgeInsets.fromLTRB(20, 0, 20, 0),
        child: TextFormField(
          readOnly: _isSubmitting ? true : false,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 35,
          ),
          inputFormatters: [
            LengthLimitingTextInputFormatter(4), // Limite à 4 caractères
          ],
          keyboardType: TextInputType.number,
          controller: widget.amountController,
          decoration: InputDecoration(
            suffixIcon: InkWell(
              onTap: _isSubmitting
                  ? null
                  : () async {
                      if (_isSubmitting) return;
                      if (widget.formKey.currentState!.validate()) {
                        setState(() {
                          _isSubmitting = true;
                        });
                        // Récupérez le montant saisi par l'utilisateur depuis le champ de texte
                        String amountStr = widget.amountController.text;
                        double amount = double.tryParse(amountStr) ?? 0.0;

                        // Vérifiez que le montant est supérieur à zéro
                        if (amount <= 0) {
                          // Montant invalide, affichez un message d'erreur
                          // Vous pouvez afficher un dialogue d'erreur ou un message d'erreur ici
                          print('Montant invalide');
                          setState(() {
                            _isSubmitting = false;
                          });
                          return;
                        }

                        // Calculez la commission de 3.5%
                        double commission = amount * 3.5 / 100;

                        try {
                          // Effectuez la transaction Firestore
                          await FirebaseFirestore.instance
                              .runTransaction((transaction) async {
                            // Récupérez les références des documents des deux utilisateurs
                            DocumentReference senderRef = FirebaseFirestore
                                .instance
                                .collection('Users')
                                .doc(widget.userData['id']);
                            DocumentReference receiverRef = FirebaseFirestore
                                .instance
                                .collection('Users')
                                .doc(widget.scannedUserId);

                            // Récupérez les données actuelles des deux utilisateurs
                            DocumentSnapshot senderSnapshot =
                                await transaction.get(senderRef);
                            DocumentSnapshot receiverSnapshot =
                                await transaction.get(receiverRef);

                            // Vérifiez si l'utilisateur a suffisamment de coins à envoyer (incluant la commission)
                            double senderCoins = senderSnapshot['coins'] ?? 0.0;

                            // Vérifiez si l'utilisateur a suffisamment de coins à envoyer (incluant la commission)
                            if (senderCoins < (amount + commission)) {
                              // L'utilisateur n'a pas suffisamment de coins, annulez la transaction
                              print('Solde insuffisant');
                              // Affichez un message d'erreur ici
                              showDialog(
                                context: context,
                                builder: (BuildContext context) {
                                  return AlertDialog(
                                    backgroundColor: Colors.red,
                                    title: Text(
                                      "ALERT",
                                      style: TextStyle(color: Colors.white),
                                    ),
                                    content: Text(
                                      "Votre Solde est Insuffisant \nVeuillez Recharger Votre Compte`\n "
                                      "Tu ne peux pas envoyer plus que ${(senderCoins - commission).toStringAsFixed(2)} DZD",
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 20,
                                      ),
                                    ),
                                  );
                                },
                              );
                              return;
                            }

                            // Enregistrez la transaction dans la sous-collection de l'utilisateur envoyeur
                            transaction.set(
                              senderRef
                                  .collection('transactions')
                                  .doc(), // Générez un nouvel ID de document
                              {
                                'id': widget.scannedUserId,
                                'amount': amount,
                                'description': 'Transaction envoyée',
                                'direction': widget.direction,
                                'state': 'completed',
                                'timestamp': FieldValue.serverTimestamp(),
                                'avatar': widget.avatar,
                                'displayName': widget.displayName,
                              },
                            );

                            // Enregistrez la transaction dans la sous-collection de l'utilisateur destinataire
                            transaction.set(
                              receiverRef
                                  .collection('transactions')
                                  .doc(), // Générez un nouvel ID de document
                              {
                                'id': widget.userData['id'],
                                'amount': amount,
                                'description': 'Transaction reçue',
                                'direction': widget.direction,
                                'state': 'completed',
                                'timestamp': FieldValue.serverTimestamp(),
                                'avatar': widget.avatar,
                                'displayName': widget.displayName,
                              },
                            );

                            // Mettez à jour les soldes des deux utilisateurs
                            transaction.set(
                              senderRef,
                              {
                                'coins': senderCoins - (amount + commission),
                                'dialogShown': false,
                              },
                              SetOptions(merge: true),
                            );

                            double receiverCoins =
                                receiverSnapshot['coins'] ?? 0.0;

                            transaction.set(
                              receiverRef,
                              {
                                'coins': receiverCoins + amount,
                                'dialogShown': false,
                              },
                              SetOptions(merge: true),
                            );

                            // Enregistrez la transaction dans la collection "gaines"
                            await FirebaseFirestore.instance
                                .collection('gaines')
                                .add({
                              'percentage': 10,
                              'coins': commission,
                              'fromUserId': widget.userData['id'],
                              'toUserId': widget.scannedUserId,
                            });

                            showCongratulationsDialog(
                              context,
                              amount,
                              receiverCoins + amount,
                            );
                            addTransactionToFirestore(
                                widget.userData['id'],
                                widget.scannedUserId,
                                'description',
                                false,
                                'state',
                                amount,
                                FieldValue.serverTimestamp(),
                                'avatar',
                                'displayName');
                          });

                          // Réinitialisez l'état après la transaction réussie
                          widget.amountController.clear();
                          FocusScope.of(context).unfocus();
                        } catch (e) {
                          // Gestion des erreurs de transaction
                          print('Erreur lors de la transaction : $e');
                          // Affichez un message d'erreur ici
                        }

                        setState(() {
                          _isSubmitting = false;
                        });
                        widget.amountController.clear();
                        FocusScope.of(context).unfocus();
                      }
                    },
              child: _isSubmitting
                  ? Stack(
                      alignment: Alignment.center,
                      children: [
                        FittedBox(
                          child: Lottie.asset(
                            'assets/lotties/1 (30).json',
                            // repeat: false,
                          ),
                        ),
                        Text(
                          widget.amountController.text,
                          style: TextStyle(fontSize: 25),
                        ),
                      ],
                    )
                  : Icon(
                      Icons.send,
                      color: Color.fromARGB(255, 0, 127, 232),
                      size: 25,
                    ),
            ),
            filled: _isSubmitting ? true : false,
            //<-- SEE HERE
            fillColor: _isSubmitting ? Colors.grey.shade200 : null,
            hintStyle: TextStyle(
              fontSize: 35,
              color: Colors.black38,
            ),
            hintText: 'Montant à Envoyer',
            // border: OutlineInputBorder(
            //   borderRadius: BorderRadius.circular(10.0),
            // ),

            //contentPadding: EdgeInsets.all(25),
          ),
          validator: _validateAmount,
          //     (value) {
          //   if (value == null || value.isEmpty) {
          //     return 'Entrer Le Montant';
          //   }
          //   return null;
          // },

          maxLength: 4,
        ),
      ),
    );
  }
}

void showCongratulationsDialog(
    BuildContext context, double Coins, double total) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: Text("Félicitations !"),
        content: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            AvatarGlow(
              glowColor: Colors.blue,
              duration: Duration(milliseconds: 2000),
              repeat: true,
              child: Material(
                // Replace this child with your own
                elevation: 8.0,
                shape: CircleBorder(),
                child: CircleAvatar(
                  backgroundColor: Colors.grey[100],
                  child: Lottie.asset(
                    'assets/lotties/1 (13).json',
                    height: 60,
                    width: 60,
                    repeat: true,
                  ),
                  radius: 40.0,
                ),
              ),
            ),
            FittedBox(
              child: Text(
                'Envoyer : ' +
                    intl.NumberFormat.currency(
                      locale: 'fr_FR',
                      symbol: 'DZD',
                      decimalDigits: 2,
                    ).format(Coins),
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: Colors.green,
                  fontSize: 30,
                  fontWeight: FontWeight.w400,
                ),
              ),
            ),
            Lottie.asset(
              'assets/lotties/1 (33).json',
              // Chemin vers votre animation Lottie
              width: 150,
              height: 150,
              repeat: true,
              animate: true,
            ),
            SizedBox(height: 20),
            Text(
              'Beneficier Solde : '.toString(),
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: Colors.blue,
                fontSize: 20,
                fontWeight: FontWeight.w400,
              ),
            ),
            Text(
              intl.NumberFormat.currency(
                locale: 'fr_FR',
                symbol: 'DZD',
                decimalDigits: 2,
              ).format(total),
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: Colors.blue,
                fontSize: 20,
                fontWeight: FontWeight.w400,
              ),
            ),
            Text("La transaction a réussi !".toString()),
          ],
        ),
        actions: [
          Center(
            child: TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Fermez la boîte de dialogue
              },
              child: Text("Fermer"),
            ),
          ),
        ],
      );
    },
  );
}

void showTransactionErrorDialog(BuildContext context, String errorMessage) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: Text("Erreur de transaction"),
        content: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              height: 100,
            ),
            AvatarGlow(
              glowColor: Colors.blue,
              duration: Duration(milliseconds: 2000),
              repeat: true,
              child: Material(
                // Replace this child with your own
                elevation: 8.0,
                shape: CircleBorder(),
                child: CircleAvatar(
                  backgroundColor: Colors.grey[100],
                  child: Lottie.asset(
                    'assets/lotties/1 (23).json',
                    height: 60,
                    width: 60,
                  ),
                  radius: 40.0,
                ),
              ),
            ),
            Lottie.asset(
              'assets/lotties/1 (33).json',
              // Chemin vers votre animation Lottie
              width: 150,
              height: 150,
              repeat: false,
              animate: true,
            ),
            SizedBox(height: 20),
            Text("Erreur de la transaction!".toString()),
          ],
        ),
        actions: [
          Center(
            child: TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Fermez la boîte de dialogue
              },
              child: Text("Fermer"),
            ),
          ),
        ],
      );
    },
  );
}

void addTransactionToFirestore(
    String senderUserId,
    String receiverUserId,
    description,
    bool direction,
    state,
    double amount,
    timestamp,
    avatar,
    displayName) async {
  try {
    final Timestamp timestamp = Timestamp.now();
    final Transactionss transaction = Transactionss(
        id: receiverUserId,
        amount: amount,
        description: description,
        direction: direction,
        state: state,
        timestamp: timestamp,
        avatar: avatar,
        displayName: displayName);
    // final TransactionModel transaction = TransactionModel(
    //   senderUserId: senderUserId,
    //   receiverUserId: receiverUserId,
    //   amount: amount,
    //   timestamp: timestamp,
    // );

    final DocumentReference transactionRef =
        FirebaseFirestore.instance.collection('transactions').doc();

    await transactionRef.set(transaction.toMap());
    print('Transaction réussie et ajoutée à la collection Firestore.');
  } catch (e) {
    print('Erreur lors de l\'ajout de la transaction à Firestore : $e');
  }
}

class TotalCoinsWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final gainesStream =
        Provider.of<UserProviderFire>(context, listen: false).gainesStream;

    return StreamBuilder<List<Gaine>>(
      stream: gainesStream,
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          // Afficher un indicateur de chargement si les données ne sont pas encore disponibles.
          return Center(
              child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 10),
            child: Lottie.asset('assets/lotties/1 (31).json'),
            // LinearProgressIndicator(),
          ));
        }

        final gaines = snapshot.data;

        if (gaines == null || gaines.isEmpty) {
          // Si la liste des "gaines" est vide ou nulle, affichez un message approprié.
          return Center(
            child: FittedBox(
              child: Lottie.asset('assets/lotties/1 (5).json', height: 100),
              // Text(
              //   "Gaines Indisponible.",
              //   style: TextStyle(
              //     color: Colors.red,
              //   ),
              // ),
            ),
          );
        }

        // Calculez le total des "gaines"
        double totalGaines = 0;
        for (var gaine in gaines) {
          totalGaines += gaine.coins;
        }

        return Center(
          child: InkWell(
            onTap: () async {
              try {
                await deleteAllDocumentsInCollection('gaines');
              } catch (e) {
                print('Erreur lors de la mise à jour des coins : $e');
                // Gestion de l'erreur ici
              }
            },
            child: Stack(
              alignment: Alignment.center,
              children: [
                // Lottie.asset(
                //     'assets/lotties/127466-glassmorphism-ellipse-lottie-animation.json'),
                AnimatedFlipCounter(
                  value: totalGaines,
                  // Utilisez la partie entière de priceValue.
                  prefix: "Gaines : ",
                  suffix: ' DZD',
                  fractionDigits: 2,
                  mainAxisAlignment: MainAxisAlignment.start,
                  duration: const Duration(milliseconds: 800),
                  textStyle: TextStyle(
                    fontFamily: 'OSWALD',
                    color: Colors.teal,
                    fontSize: 18,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
            // Text( assets/lotties/127466-glassmorphism-ellipse-lottie-animation.json
            //   'Gaines: ${totalGaines.toStringAsFixed(2)}',
            //   style: TextStyle(fontSize: 18, color: Colors.teal),
            // ),
          ),
        );
      },
    );
  }
}

Future<void> deleteAllDocumentsInCollection(String collectionName) async {
  try {
    final CollectionReference collectionReference =
        FirebaseFirestore.instance.collection(collectionName);

    final QuerySnapshot querySnapshot = await collectionReference.get();

    for (QueryDocumentSnapshot document in querySnapshot.docs) {
      await collectionReference.doc(document.id).delete();
    }

    print(
        'Tous les documents de la collection $collectionName ont été supprimés.');
    Fluttertoast();
  } catch (e) {
    print('Erreur lors de la suppression des documents : $e');
  }
}
