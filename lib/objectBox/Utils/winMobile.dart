import 'dart:io';

import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:window_manager/window_manager.dart';

class WinMobile extends StatefulWidget {
  // Enlever le const puisque nous avons un champ non-final
  const WinMobile({super.key});

  @override
  State<WinMobile> createState() => _WinMobileState();
}

class _WinMobileState extends State<WinMobile> {
  bool isPhoneSize = false;
  // Initialiser IconSign avec une valeur par défaut
  IconData iconSign = FontAwesomeIcons.mobile; // Valeur initiale

  @override
  void initState() {
    super.initState();
    // Optionnel : initialiser iconSign dans initState si nécessaire
    iconSign = isPhoneSize ? FontAwesomeIcons.desktop : FontAwesomeIcons.mobile;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Platform.isIOS || Platform.isAndroid
          ? Container()
          : IconButton(
              onPressed: _toggleWindowSize,
              icon: Icon(iconSign),
            ),
    );
  }

  Future<void> _toggleWindowSize() async {
    if (isPhoneSize) {
      // Passer en mode Desktop
      await windowManager.setSize(const Size(1920, 1080));
      setState(() {
        isPhoneSize = false;
        iconSign = FontAwesomeIcons.mobile;
      });
    } else {
      // Passer en mode Mobile
      await windowManager.setSize(const Size(375, 812));
      setState(() {
        isPhoneSize = true;
        iconSign = FontAwesomeIcons.desktop;
      });
    }
  }
}
