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
import '1/objectBox/MyApp.dart';
import 'Oauth/Ogoogle/googleSignInProvider.dart';
import 'Oauth/verifi_auth2.dart';
import 'firebase_options.dart';
import 'package:timeago/timeago.dart' as timeago;

//late ObjectBox objectbox;
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  initializeDateFormatting(
      'fr_FR', null); // Initialisez la localisation française
  //MobileAds.instance.initialize(); ////////////////////////////////ads
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  //final objectBox = await ObjectBox.create();
  await Supabase.initialize(
    url: 'https://wirxpjoeahuvjoocdnbk.supabase.co',
    anonKey:
        'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Indpcnhwam9lYWh1dmpvb2NkbmJrIiwicm9sZSI6ImFub24iLCJpYXQiOjE3MTYxNjI0MzAsImV4cCI6MjAzMTczODQzMH0.MQpp7i2TdH3Q5aPEbMq5qvUwbuYpIX8RccW_GH64r1U',
  );
  // await Supabase.initialize(
  //   url: 'https://wirxpjoeahuvjoocdnbk.supabase.co',
  //   anonKey:
  //       'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Indpcnhwam9lYWh1dmpvb2NkbmJrIiwicm9sZSI6ImFub24iLCJpYXQiOjE3MTYxNjI0MzAsImV4cCI6MjAzMTczODQzMH0.MQpp7i2TdH3Q5aPEbMq5qvUwbuYpIX8RccW_GH64r1U',
  // );

  // splash.FlutterNativeSplash.removeAfter(initialization);
  //WidgetsBinding widgetsBinding = WidgetsFlutterBinding.ensureInitialized();
  //splash.FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);
  timeago.setLocaleMessages('fr', timeago.FrMessages());
  timeago.setLocaleMessages('fr_short', timeago.FrShortMessages());

  SystemChrome.setEnabledSystemUIMode(
      SystemUiMode.edgeToEdge, //.immersiveSticky,
      overlays: [SystemUiOverlay.top, SystemUiOverlay.bottom]);
  runApp(
    MyApp(
        // objectBox: objectBox,
        ),
  );
}

// Future<Database> initsembastDatabase() async {
//   final appDocumentDir = await getApplicationDocumentsDirectory();
//   final dbPath = p.join(appDocumentDir.path, 'my_sembast_database.db');
//   final database = await databaseFactoryIo.openDatabase(dbPath);
//   return database;
// }
//FlutterNativeSplash.remove();

Future initialization(BuildContext? context) async {
  Future.delayed(Duration(seconds: 5));
}

final navigatorKey = GlobalKey<NavigatorState>();

class MyApp extends StatelessWidget {
  MyApp({
    super.key,
    /*required this.objectBox*/
  });
//  final ObjectBox objectBox;
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
          home: MyMainO()
          // verifi_auth2(
          //     // objectBox: objectBox,
          //     ),
          ),
    );
  }
}
