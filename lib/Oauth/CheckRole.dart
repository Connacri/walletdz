import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:provider/provider.dart';
import 'package:walletdz/wallet_3/mainLocal.dart';

import '../1/home1.dart';
import '../DZWallet/home.dart';
import '../MyListLotties.dart';
import 'Ogoogle/googleSignInProvider.dart';

class CheckRole extends StatelessWidget {
  final String userId;

  CheckRole(this.userId);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StreamBuilder<DocumentSnapshot>(
        stream: FirebaseFirestore.instance
            .collection("Users")
            .doc(userId)
            .snapshots(),
        builder:
            (BuildContext context, AsyncSnapshot<DocumentSnapshot> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            // Handle error
            return ListView(
              children: [
                Center(
                  child: Lottie.asset("assets/lotties/1 (27).json",
                      fit: BoxFit.contain, height: 150),
                ),
                Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 30, vertical: 10),
                  child: ElevatedButton(
                      onPressed: () => Navigator.of(context).push(
                          MaterialPageRoute(
                              builder: (context) => LottieListPage())),
                      child: Text('Lotties')),
                ),
                Center(
                    child: Padding(
                  padding: const EdgeInsets.all(18.0),
                  child: Text(
                    // "Error: ${snapshot.error}",
                    "  Nous sommes désolés pour le dérangement causé par le dépassement du quota d'accès à notre base de données. Nous sommes actuellement en train de vérifier la base de données pour détecter toute intrusion ou utilisation illicite. Nous vous remercions de votre patience et vous demandons de revenir demain où le service sera à nouveau disponible pour votre sécurité. Nous sommes conscients de la nécessité de garder votre confiance en nous et en notre service. Nous utilisons des mesures technologiques et organisationnelles pour protéger votre information contre la perte, le vol, et l'accès non autorisé. Nous ne partageons jamais vos informations ou transactions avec des tiers sans votre consentement. Nous respectons strictement la confidentialité de vos données et utilisons des mesures de sécurité appropriées pour protéger vos informations. Nous avons également mis en place des politiques et des contrats pour garantir la sécurité de vos données. Si vous avez des questions supplémentaires ou des inquiétudes, n'hésitez pas à nous contacter. oran.inturk@gmail.com",
                    textAlign: TextAlign.justify,
                    style: TextStyle(fontSize: 15),
                  ),
                )),
              ],
            );
          }

          // Document exists, retrieve data
          var data = snapshot.data;
          if (data!.exists) {
            var userRole = data['role'];
            // Check user role
            //  if (userRole == "admin") {
            //   return adminLoggedPage(); // Normalement Tani Premium Page
            // } else {
            return home1();
            // mainDz(
            //   currentUser: userId,
            // );

            HomeWalletPage(
              currentUser: userId,
            ); //MyWallet3(userId: userId ,);
            // }
          } else
            return Scaffold(
              body: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text('Marhba Bik'),
                    // ElevatedButton(
                    //     onPressed: () => Navigator.pushNamedAndRemoveUntil(
                    //         context, '/', (_) => false),
                    //     child: Text('aya nebdou')),
                    Padding(
                      padding: const EdgeInsets.all(28.0),
                      child: ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.black54,
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(15)),
                            elevation: 4.0,
                            minimumSize: const Size.fromHeight(50)),
                        icon: Icon(
                          Icons.cancel,
                          color: Colors.red,
                        ),
                        label: const Text(
                          'Deconnexion',
                          style: TextStyle(fontSize: 24, color: Colors.white),
                        ),
                        onPressed: () async {
                          FirebaseAuth.instance.signOut();
                          final provider = Provider.of<googleSignInProvider>(
                              context,
                              listen: false);
                          await provider.logout();
                          // Navigator.of(context).pop();
                          // Navigator.pop(context, true);
                        },
                      ),
                    ),
                  ],
                ),
              ),
            );
        },
      ),
    );
  }
}
