import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:walletdz/wallet_3/mainLocal.dart';

import 'Ogoogle/googleSignInProvider.dart';

class CheckRole extends StatelessWidget {
  final String userId;

  CheckRole(this.userId);

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<DocumentSnapshot>(
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
          return Center(child: Text("Error: ${snapshot.error}"));
        }

        // Document exists, retrieve data
        var data = snapshot.data;
        if (data!.exists) {
          var userRole = data['role'];
          // Check user role
          //  if (userRole == "admin") {
          //   return adminLoggedPage(); // Normalement Tani Premium Page
          // } else {
          return MyWallet3(userId: userId ,); /*home2();*/ // MyWalletApp(); //MyWalletApp();
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
    );
  }
}
