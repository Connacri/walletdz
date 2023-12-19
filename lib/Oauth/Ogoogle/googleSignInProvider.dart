import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';

class googleSignInProvider extends ChangeNotifier {
  final GoogleSignIn googleSignIn = GoogleSignIn();

  GoogleSignInAccount? _user;

  GoogleSignInAccount get user => _user!;

  Future googleLogin() async {
    try {
      final googleUser = await googleSignIn.signIn();
      if (googleUser == null) return;
      _user = googleUser;

      final googleAuth = await googleUser.authentication;
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final userGoo =
          await FirebaseAuth.instance.signInWithCredential(credential);
      checkAndHandleFirestore(userGoo.user!);
      print(userGoo);
    } catch (e) {
      print("Google Login Error: $e");
    }
  }

  Future logout() async {
    await googleSignIn.disconnect();
    await FirebaseAuth.instance.signOut();
    _user = null;
    notifyListeners();
  }

  Future checkAndHandleFirestore(User userGoo) async {
    final docExists = await checkIfDocExists(userGoo.uid);

    if (docExists) {
      updateUserDoc(userGoo);
    } else {
      setUserDoc(userGoo);
    }

    notifyListeners();
  }

  Future<bool> checkIfDocExists(String uid) async {
    try {
      final collectionRef = FirebaseFirestore.instance.collection('Users');
      final doc = await collectionRef.doc(uid).get();
      return doc.exists;
    } catch (e) {
      print("Firestore Error: $e");
      return false;
    }
  }

  Future setUserDoc(User userGoo) async {
    CollectionReference userRef =
        FirebaseFirestore.instance.collection('Users');

    String userID = userGoo.uid;
    String? userEmail = userGoo.email;
    String? userAvatar = userGoo.photoURL;
    String? userDisplayName = userGoo.displayName;
    //String? userPhone = userGoo.phoneNumber;
    //int? phone = int.parse(userPhone!);
    String? userRole = 'public';
    bool userState = true;

    userRef.doc(userGoo.uid).set({
      'lastActive': Timestamp.now(),
      'id': userID,
      'phone': 0, // attention hna
      'email': userEmail,
      'avatar': userAvatar,
      'timeline': userAvatar,
      'createdAt': Timestamp.now(),
      'displayName': userDisplayName,
      'state': userState,
      'role': userRole,
      'plan': 'free',
      'coins': 0.0,
      'levelUser': 'begin',
      'stars': 0.0,
      'userItemsNbr': 0,
    }, SetOptions(merge: true));
  }

  Future updateUserDoc(User userGoo) async {
    CollectionReference userRef =
        FirebaseFirestore.instance.collection('Users');

    userRef.doc(userGoo.uid).update(
      {
        'lastActive': Timestamp.now(),
      },
    );
  }
}
