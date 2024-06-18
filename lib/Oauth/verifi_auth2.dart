import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../1/objectBox/classeObjectBox.dart';
import 'AuthPage.dart';
import 'CheckRole.dart';
import 'VerifyEmailPage.dart';

class verifi_auth2 extends StatelessWidget {
  const verifi_auth2({
    Key? key,
    /*required this.objectBox*/
  }) : super(key: key);
//  final ObjectBox objectBox;
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const CircularProgressIndicator();
        } else if (snapshot.hasError) {
          return const Center(child: Text('Probleme de Connexion'));
        } else if (snapshot.hasData) {
          final user = snapshot.data;
          if (user!.emailVerified) {
            // Email is verified, navigate to home page
            return CheckRole(
              userId: user.uid,
              // objectBox: objectBox,
            );
          } else {
            // Email is not verified, navigate to resend email page
            return VerifyEmailPage();
          }
        } else {
          // User is not logged in, navigate to login page
          return AuthPage();
        }
      },
    );
  }
}
