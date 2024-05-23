import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'chat_page.dart';
import 'constants.dart';
import 'login_page.dart';
import 'classes.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({Key? key, required this.isRegistering}) : super(key: key);

  static Route<void> route({bool isRegistering = false}) {
    return MaterialPageRoute(
      builder: (context) => RegisterPage(isRegistering: isRegistering),
    );
  }

  final bool isRegistering;

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final bool _isLoading = false;

  final _formKey = GlobalKey<FormState>();

  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _usernameController = TextEditingController();

  // Future<void> saveUserProfile(Profile profile) async {
  //   bool supabaseSuccess = false;
  //   bool firestoreSuccess = false;
  //   bool realtimeDatabaseSuccess = false;
  //
  //   try {
  //     // Sauvegarde sur Supabase
  //     final supabaseResponse =
  //         await supabase.from('profiles').insert(profile.toMap());
  //
  //     if (supabaseResponse.error != null) {
  //       throw Exception(
  //           'Erreur lors de l\'enregistrement sur Supabase : ${supabaseResponse.error.message}');
  //     }
  //     supabaseSuccess = true;
  //
  //     // Sauvegarde sur Firestore
  //     await FirebaseFirestore.instance.runTransaction((transaction) async {
  //       final profileRef = FirebaseFirestore.instance
  //           .collection('profiles')
  //           .doc(profile.profileId);
  //       transaction.set(profileRef, profile.toMap());
  //     });
  //     firestoreSuccess = true;
  //
  //     // Sauvegarde sur Firebase Realtime Database
  //     await FirebaseDatabase.instance
  //         .reference()
  //         .child('profiles')
  //         .child(profile.profileId)
  //         .set(profile.toMap());
  //     realtimeDatabaseSuccess = true;
  //
  //     print('Profil enregistré avec succès dans toutes les bases de données');
  //   } catch (e) {
  //     _showErrorSnackBar('Erreur lors de l\'enregistrement du profil : $e');
  //
  //     // Rollback en cas d'échec
  //     if (supabaseSuccess) {
  //       await supabase
  //           .from('profiles')
  //           .delete()
  //           .eq('profile_id', profile.profileId);
  //     }
  //     if (firestoreSuccess) {
  //       await FirebaseFirestore.instance
  //           .collection('profiles')
  //           .doc(profile.profileId)
  //           .delete();
  //     }
  //     if (realtimeDatabaseSuccess) {
  //       await FirebaseDatabase.instance
  //           .reference()
  //           .child('profiles')
  //           .child(profile.profileId)
  //           .remove();
  //     }
  //   }
  // }
  Future<void> saveUserProfile(Profile profile) async {
    bool supabaseSuccess = false;
    bool firestoreSuccess = false;
    bool realtimeDatabaseSuccess = false;

    try {
      print('Début de la sauvegarde sur Supabase');
      // Sauvegarde sur Supabase
      //final supabaseResponse =
      await supabase.from('profiles').insert(profile.toMap());

      //if (supabaseResponse.error != null) {
      //   print(
      //       'Erreur lors de l\'enregistrement sur Supabase : ${supabaseResponse.error.message}');
      //   throw Exception(
      //       'Erreur lors de l\'enregistrement sur Supabase : ${supabaseResponse.error.message}');
      // }
      supabaseSuccess = true;
      print('Sauvegarde sur Supabase réussie');
    } catch (e) {
      print('Exception capturée lors de l\'enregistrement sur Supabase : $e');
    }

    try {
      print('Début de la sauvegarde sur Firestore');
      // Sauvegarde sur Firestore
      await FirebaseFirestore.instance.runTransaction((transaction) async {
        final profileRef = FirebaseFirestore.instance
            .collection('profiles')
            .doc(profile.profileId);
        transaction.set(profileRef, profile.toMap());
      });
      firestoreSuccess = true;
      print('Sauvegarde sur Firestore réussie');
    } catch (e) {
      print('Erreur lors de l\'enregistrement sur Firestore : $e');
    }

    try {
      print('Début de la sauvegarde sur Firebase Realtime Database');
      // Sauvegarde sur Firebase Realtime Database
      await FirebaseDatabase.instance
          .reference()
          .child('profiles')
          .child(profile.profileId)
          .set(profile.toMap());
      realtimeDatabaseSuccess = true;
      print('Sauvegarde sur Firebase Realtime Database réussie');
    } catch (e) {
      print(
          'Erreur lors de l\'enregistrement sur Firebase Realtime Database : $e');
    }

    if (supabaseSuccess && firestoreSuccess && realtimeDatabaseSuccess) {
      print('Profil enregistré avec succès dans toutes les bases de données');
    } else {
      print('Échec de l\'enregistrement sur au moins une des bases de données');
      _showErrorSnackBar(
          'Échec de l\'enregistrement sur au moins une des bases de données');

      // Rollback en cas d'échec
      if (supabaseSuccess) {
        print('Début du rollback sur Supabase');
        try {
          await supabase
              .from('profiles')
              .delete()
              .eq('profile_id', profile.profileId);
          print('Rollback sur Supabase réussi');
        } catch (e) {
          print('Erreur lors du rollback sur Supabase : $e');
        }
      }
      if (firestoreSuccess) {
        print('Début du rollback sur Firestore');
        try {
          await FirebaseFirestore.instance
              .collection('profiles')
              .doc(profile.profileId)
              .delete();
          print('Rollback sur Firestore réussi');
        } catch (e) {
          print('Erreur lors du rollback sur Firestore : $e');
        }
      }
      if (realtimeDatabaseSuccess) {
        print('Début du rollback sur Firebase Realtime Database');
        try {
          await FirebaseDatabase.instance
              .reference()
              .child('profiles')
              .child(profile.profileId)
              .remove();
          print('Rollback sur Firebase Realtime Database réussi');
        } catch (e) {
          print('Erreur lors du rollback sur Firebase Realtime Database : $e');
        }
      }
    }
  }

  // Méthode pour afficher une Snackbar d'erreur
  void _showErrorSnackBar(String message) {
    if (!mounted) return; // Vérifier que le widget est monté
    final snackBar = SnackBar(content: Text(message));
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }

  Future<void> _signUp() async {
    final isValid = _formKey.currentState!.validate();
    if (!isValid) {
      return;
    }

    final email = _emailController.text;
    final password = _passwordController.text;
    final username = _usernameController.text;

    try {
      // Inscription de l'utilisateur
      final response = await supabase.auth.signUp(
        email: email,
        password: password,
        data: {'username': username},
      );

      if (response.user == null) {
        _showErrorSnackBar('Inscription échouée : ${response}');
        return;
      }

      Navigator.of(context).pushAndRemoveUntil(
        ChatPage.route(),
        (route) => false,
      );

      final userId = response.user?.id;
      if (userId != null) {
        final profile = Profile(
          profileId: userId,
          email: email,
          username: username,
          createdAt: DateTime.now(),
          idTiers: '',
          send: false,
          status: false,
          avatar: '',
          timeline: '',
          amount: 0.0,
        );

        await saveUserProfile(profile);
      } else {
        _showErrorSnackBar(
            'Erreur : l\'ID utilisateur est null après l\'inscription');
      }
    } catch (error) {
      if (!mounted) return; // Vérifier que le widget est monté
      _showErrorSnackBar('Erreur lors de l\'inscription : $error');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Register'),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: formPadding,
          children: [
            TextFormField(
              controller: _emailController,
              decoration: const InputDecoration(
                label: Text('Email'),
              ),
              validator: (val) {
                if (val == null || val.isEmpty) {
                  return 'Required';
                }
                return null;
              },
              keyboardType: TextInputType.emailAddress,
            ),
            formSpacer,
            TextFormField(
              controller: _passwordController,
              obscureText: true,
              decoration: const InputDecoration(
                label: Text('Password'),
              ),
              validator: (val) {
                if (val == null || val.isEmpty) {
                  return 'Required';
                }
                if (val.length < 6) {
                  return '6 characters minimum';
                }
                return null;
              },
            ),
            formSpacer,
            TextFormField(
              controller: _usernameController,
              decoration: const InputDecoration(
                label: Text('Username'),
              ),
              validator: (val) {
                if (val == null || val.isEmpty) {
                  return 'Required';
                }
                final isValid = RegExp(r'^[A-Za-z0-9_]{3,24}$').hasMatch(val);
                if (!isValid) {
                  return '3-24 long with alphanumeric or underscore';
                }
                return null;
              },
            ),
            formSpacer,
            ElevatedButton(
              onPressed: _isLoading ? null : _signUp,
              child: const Text('Register'),
            ),
            formSpacer,
            TextButton(
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => LoginPage(),
                  ),
                );
              },
              child: const Text('I already have an account'),
            )
          ],
        ),
      ),
    );
  }
}
