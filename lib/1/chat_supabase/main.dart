import 'package:flutter/material.dart';

import 'constants.dart';
import 'splash_page.dart';

class Supabase extends StatelessWidget {
  const Supabase({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'My Chat App',
      theme: appTheme,
      home: const SplashPage(),
    );
  }
}
