import 'dart:async';

import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_in_app_messaging/firebase_in_app_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/date_symbol_data_local.dart'; // Importez cette ligne
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'Oauth/Ogoogle/googleSignInProvider.dart';
import 'Oauth/verifi_auth2.dart';
import 'firebase_options.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  initializeDateFormatting(
      'fr_FR', null); // Initialisez la localisation française
  //MobileAds.instance.initialize(); ////////////////////////////////ads
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  await Supabase.initialize(
    url: 'https://tdffooqjxxmfeaiofksk.supabase.co',
    anonKey:
        'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InRkZmZvb3FqeHhtZmVhaW9ma3NrIiwicm9sZSI6ImFub24iLCJpYXQiOjE3MTUwODMzNzQsImV4cCI6MjAzMDY1OTM3NH0.A2aDxudEsT0SYvC3rjZBOp-vRq6pe4HvRy24iqXhvyM',
  );
  // splash.FlutterNativeSplash.removeAfter(initialization);
  //WidgetsBinding widgetsBinding = WidgetsFlutterBinding.ensureInitialized();
  //splash.FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);
  SystemChrome.setEnabledSystemUIMode(
      SystemUiMode.edgeToEdge, //.immersiveSticky,
      overlays: [SystemUiOverlay.top, SystemUiOverlay.bottom]);
  runApp(
    //MyMainTest(),
    MyApp(),
  );
}

//FlutterNativeSplash.remove();

Future initialization(BuildContext? context) async {
  Future.delayed(Duration(seconds: 5));
}

final navigatorKey = GlobalKey<NavigatorState>();

class MyApp extends StatelessWidget {
  MyApp({super.key});

  static FirebaseAnalytics analytics = FirebaseAnalytics.instance;
  static FirebaseInAppMessaging fiam = FirebaseInAppMessaging.instance;

  final GoogleUser2 = FirebaseAuth.instance.currentUser;

  // This widget is the root of your application.

  static const String _title = 'DZ Wallet';

  //final GlobalKey<NavigatorState> _navigatorKey = GlobalKey<NavigatorState>();

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => googleSignInProvider(),
      //lazy: true,
      child: MaterialApp(
        theme: ThemeData(
            colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
            useMaterial3: true,
            fontFamily: 'OSWALD'),
        locale: const Locale('fr', 'CA'),

        //scaffoldMessengerKey: Utils.messengerKey,
        navigatorKey: navigatorKey,
        debugShowCheckedModeBanner: false,
        title: _title,
        themeMode: ThemeMode.dark,
        home: //AuthPage(),
            verifi_auth2(), //MyWalletApp(), //const MyHomePage(title: 'Flutter Demo Home Page'),
      ),
    );
  }
}
