import 'package:cached_network_image/cached_network_image.dart';
import 'package:calendar_timeline/calendar_timeline.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pretty_qr_code/pretty_qr_code.dart';
import 'package:ticket_widget/ticket_widget.dart';

class QRCodePage extends StatelessWidget {
  final Map<String, dynamic> currentUserData;

  const QRCodePage({
    Key? key,
    required this.currentUserData,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final email = currentUserData['email'];
    final userImageUrl = currentUserData['avatar'];
    final userName = currentUserData['displayName'];
    final id = currentUserData['id'];
    return Scaffold(
      appBar: AppBar(
        title: Text('Mon Code QR'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(18.0),
        child: TicketWidget(
          width: 1000,
          height: 600,
          color: Theme.of(context).secondaryHeaderColor,
          isCornerRounded: true,
          // Coins arrondis
          // shadow: [
          //   BoxShadow(
          //     color: Colors.black.withOpacity(0.3),
          //     blurRadius: 5.0,
          //     offset: Offset(0, 2),
          //   ),
          // ],
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  SizedBox(
                    height: 15,
                  ),
                  Card(
                    child: ListTile(
                      leading: CircleAvatar(
                        backgroundImage:
                            CachedNetworkImageProvider(userImageUrl),
                      ),
                      title: Text(userName.toString().toUpperCase()),
                      subtitle: Text(email.toString()),
                    ),
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  Text(
                    'Présentez Votre Code QR au Point de Vente Pour Recharge Rapide et Sécurisé CASH'
                        .capitalize(),
                    style: TextStyle(
                      fontSize: 18,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  Text(
                    'قدّم رمز الاستجابة السريعة الخاص بك في نقطة البيع للشحن السريع والآمن نقدا',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.cairo(
                      color: Colors.black45,
                      fontWeight: FontWeight.w600,
                      fontSize: 18,
                    ),
                  ),
                  Text(
                    '-------------------------',
                    style: TextStyle(fontSize: 30),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        vertical: 25, horizontal: 40),
                    child: Hero(
                      tag:
                          'qrCodeHero', // Utilisez le même tag que dans le ListTile
                      child: PrettyQrView.data(
                        data: id,
                        decoration: PrettyQrDecoration(
                          shape: const PrettyQrSmoothSymbol(
                            roundFactor: 0,
                            color: Colors.black,
                          ),
                          image: PrettyQrDecorationImage(
                            scale: 0.2,
                            padding: EdgeInsets.all(10),
                            image: CachedNetworkImageProvider(userImageUrl),
                            position: PrettyQrDecorationImagePosition.embedded,
                          ),
                        ),
                      ),
                    ),
                  ),

                  // Center(
                  //     child: FittedBox(
                  //   child: Text(
                  //     id.toUpperCase(),
                  //     style: TextStyle(fontSize: 15, color: Colors.white),
                  //   ),
                  // )),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
