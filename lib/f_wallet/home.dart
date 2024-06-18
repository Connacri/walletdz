import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart' as intl;
import 'package:intl/intl.dart';
import 'package:lottie/lottie.dart';
import 'package:pretty_qr_code/pretty_qr_code.dart';
import 'package:provider/provider.dart';
import 'package:ticket_widget/ticket_widget.dart';

import '../MyListLotties.dart';
import '../Profile.dart';
import '../f_wallet/main.dart';
import '../f_wallet/payment.dart';
import '../f_wallet/qr_scanner.dart';
import '../f_wallet/usersList.dart';
import 'models.dart';

class HomeScreen extends StatelessWidget {
  final String userId = FirebaseAuth.instance.currentUser!.uid;

  @override
  Widget build(BuildContext context) {
    final userDataProvider = Provider.of<UserDataProvider>(context);
    userDataProvider.fetchCurrentUserData();
    final currentUserDatas = userDataProvider.currentUserData;
    return Scaffold(
      resizeToAvoidBottomInset: false,
      drawer: MyDrawer(),
      body: CustomScrollView(
        //   primary: false,
        shrinkWrap: true,
        slivers: [
          // SliverAppBar(
          //   backgroundColor: Theme.of(context).scaffoldBackgroundColor,
          //   centerTitle: true,
          //   expandedHeight: 170,
          //   //pinned: true,
          //   stretch: true,
          //   automaticallyImplyLeading: true, // hides leading widget
          //   flexibleSpace: FlexibleSpaceBar(
          //     titlePadding: EdgeInsets.zero,
          //     centerTitle: true,
          //     collapseMode: CollapseMode.pin,
          //     stretchModes: const <StretchMode>[StretchMode.zoomBackground],
          //     background: Stack(
          //       alignment: Alignment.center,
          //       children: [
          //         Lottie.asset(
          //           'assets/lotties/1 (5).json',
          //           fit: BoxFit.cover,
          //         ),
          //         MyTotalCoins(
          //           currentUserDatas: currentUserDatas,
          //           fontsize: 30,
          //           colorCoins: Colors.lightGreenAccent,
          //         ),
          //       ],
          //     ),
          //     expandedTitleScale: 1.5,
          //     // title: Padding(
          //     //   padding: const EdgeInsets.all(8.0),
          //     //   child: Row(
          //     //     mainAxisAlignment: MainAxisAlignment.spaceAround,
          //     //     children: [
          //     //       SizedBox(
          //     //         width: 10,
          //     //       ),
          //     //       Consumer<UserDataProvider>(
          //     //         builder: (context, userDataProvider, _) {
          //     //           final currentUserData =
          //     //               userDataProvider.currentUserData;
          //     //           final avatar = currentUserData['avatar'];
          //     //
          //     //           if (avatar == null) {
          //     //             return Icon(Icons.account_circle_rounded);
          //     //           }
          //     //           return InkWell(
          //     //             onTap: () => Navigator.of(context).push(
          //     //                 MaterialPageRoute(
          //     //                     builder: (context) => Profile())),
          //     //             child: CircleAvatar(
          //     //               backgroundImage: CachedNetworkImageProvider(avatar),
          //     //               radius: 10,
          //     //             ),
          //     //           );
          //     //         },
          //     //       ),
          //     //       SizedBox(
          //     //           width: 10.0), // Espacement entre l'avatar et le titre
          //     //       Expanded(
          //     //         child: Consumer<UserDataProvider>(
          //     //           builder: (context, userDataProvider, _) {
          //     //             final currentUserData =
          //     //                 userDataProvider.currentUserData;
          //     //             final displayName =
          //     //                 currentUserData['displayName'] ?? '';
          //     //
          //     //             return Text(
          //     //               displayName.toString(),
          //     //               overflow: TextOverflow.ellipsis,
          //     //               style: TextStyle(
          //     //                 color: Colors.lightBlue.shade200,
          //     //                 fontSize: 15,
          //     //                 fontWeight: FontWeight.w600,
          //     //               ),
          //     //             );
          //     //           },
          //     //         ),
          //     //       ),
          //     //       SizedBox(
          //     //           width: 10.0), // Espacement entre l'avatar et le titre
          //     //       MyTotalCoins(
          //     //         currentUserDatas: currentUserDatas,
          //     //         fontsize: 15,
          //     //         colorCoins: Colors.black87,
          //     //       ),
          //     //     ],
          //     //   ),
          //     // ),
          //   ),
          //   // bottom: PreferredSize(
          //   //
          //   //   preferredSize: Size.fromHeight(
          //   //       10), // Ajustez la hauteur préférée en conséquence
          //   //   child: Container(
          //   //     padding: EdgeInsets.fromLTRB(
          //   //         20, 0, 20, 8), // Ajustez le padding selon vos préférences
          //   //     child: Row(
          //   //       mainAxisAlignment: MainAxisAlignment.start,
          //   //       children: [
          //   //         Consumer<UserDataProvider>(
          //   //           builder: (context, userDataProvider, _) {
          //   //             final currentUserData =
          //   //                 userDataProvider.currentUserData;
          //   //             final avatar = currentUserData['avatar'];
          //   //
          //   //             if (avatar == null) {
          //   //               return Icon(Icons.account_circle_rounded);
          //   //             }
          //   //             return InkWell(
          //   //               onTap: () => Navigator.of(context).push(
          //   //                   MaterialPageRoute(
          //   //                       builder: (context) => Profile())),
          //   //               child: CircleAvatar(
          //   //                 backgroundImage: CachedNetworkImageProvider(avatar),
          //   //               ),
          //   //             );
          //   //           },
          //   //         ),
          //   //         SizedBox(
          //   //             width: 10.0), // Espacement entre l'avatar et le titre
          //   //         Expanded(
          //   //           child: Consumer<UserDataProvider>(
          //   //             builder: (context, userDataProvider, _) {
          //   //               final currentUserData =
          //   //                   userDataProvider.currentUserData;
          //   //               final displayName =
          //   //                   currentUserData['displayName'] ?? '';
          //   //
          //   //               return Text(
          //   //                 displayName.toString(),
          //   //                 overflow: TextOverflow.ellipsis,
          //   //                 style: TextStyle(
          //   //                   color: Colors.lightBlue.shade200,
          //   //                   fontSize: 20,
          //   //                   fontWeight: FontWeight.w600,
          //   //                 ),
          //   //               );
          //   //             },
          //   //           ),
          //   //         ),
          //   //         SizedBox(
          //   //             width: 10.0), // Espacement entre l'avatar et le titre
          //   //         MyTotalCoins(
          //   //           currentUserDatas: currentUserDatas,
          //   //           fontsize: 20,
          //   //           colorCoins: Colors.black87,
          //   //         ),
          //   //       ],
          //   //     ),
          //   //   ),
          //   // ),
          // ),
          SliverPersistentHeader(
            pinned: true,
            delegate: NetworkingPageHeader(),
          ),
          SliverToBoxAdapter(
            child: MyGaines(
              currentUserDatas: currentUserDatas,
            ),
            //TotalCoinsWidget(),
          ),
          //           SliverToBoxAdapter(
          //             child: GestureDetector(
          //               onTap: () => Navigator.of(context)
          //                   .push(MaterialPageRoute(builder: (context) => Historique())),
          //               child: Container(
          // //                color: Colors.yellow,
          //                 height: 250,
          //                 child: Stack(
          //                   alignment: Alignment.center,
          //                   children: [
          //                     // Ajoutez l'animation Lottie en arrière-plan
          //                     Lottie.asset(
          //                       width: MediaQuery.of(context).size.width * 0.8,
          //                       height: 300,
          //                       'assets/lotties/animation_lnekrur4.json', // Remplacez par le chemin de votre fichier d'animation Lottie
          //                       fit: BoxFit
          //                           .contain, // Ajustez le mode d'ajustement selon vos préférences
          //                     ),
          //
          //                     MyTotalCoins(currentUserDatas: currentUserDatas)
          //                     // Contenu de la carte (texte, boutons, etc.) va au-dessus de l'animation Lottie
          //                   ],
          //                 ),
          //               ),
          //             ),
          //           ),
          SliverToBoxAdapter(
            child: TransactionList(),
          ),
          SliverToBoxAdapter(
            child: Container(
              height: 150,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Card(
                      child: GestureDetector(
                          onTap: () {
                            Navigator.of(context).push(MaterialPageRoute(
                                builder: (context) => QrScanner()));
                          },
                          child: Lottie.asset(
                              'assets/lotties/animation_qr1.json',
                              fit: BoxFit.cover)),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Card(
                      child: GestureDetector(
                          onTap: () {
                            Navigator.of(context).push(MaterialPageRoute(
                                builder: (context) => UserListPageCoins()));
                          },
                          child: Lottie.asset(
                              'assets/lotties/animation_lneit2vo.json',
                              fit: BoxFit.cover)),
                    ),
                  ),
                ],
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Container(
              height: 150,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Card(
                      child: GestureDetector(
                          // onTap: () {
                          //   Navigator.of(context).push(MaterialPageRoute(
                          //       builder: (context) => QrScanner()));
                          // },
                          child: Lottie.asset(
                              'assets/lotties/animation_lnejodtw.json',
                              fit: BoxFit.cover)),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Card(
                      child: GestureDetector(
                          // onTap: () {
                          //   Navigator.of(context).push(MaterialPageRoute(
                          //       builder: (context) => UserListPageCoins()));
                          // },
                          child: Lottie.asset(
                              'assets/lotties/animation_lnejdoi9.json',
                              fit: BoxFit.cover)),
                    ),
                  ),
                ],
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Container(
              height: 150,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Card(
                      child: GestureDetector(
                          // onTap: () {
                          //   Navigator.of(context).push(MaterialPageRoute(
                          //       builder: (context) => QrScanner()));
                          // },
                          child: Lottie.asset(
                              'assets/lotties/animation_lnejodtw.json',
                              fit: BoxFit.cover)),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Card(
                      child: GestureDetector(
                          // onTap: () {
                          //   Navigator.of(context).push(MaterialPageRoute(
                          //       builder: (context) => UserListPageCoins()));
                          // },
                          child: Lottie.asset(
                              'assets/lotties/animation_lnejdoi9.json',
                              fit: BoxFit.cover)),
                    ),
                  ),
                ],
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Container(
              height: 150,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Card(
                      child: GestureDetector(
                          // onTap: () {
                          //   Navigator.of(context).push(MaterialPageRoute(
                          //       builder: (context) => QrScanner()));
                          // },
                          child: Lottie.asset(
                              'assets/lotties/animation_lnejodtw.json',
                              fit: BoxFit.cover)),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Card(
                      child: GestureDetector(
                          // onTap: () {
                          //   Navigator.of(context).push(MaterialPageRoute(
                          //       builder: (context) => UserListPageCoins()));
                          // },
                          child: Lottie.asset(
                              'assets/lotties/animation_lnejdoi9.json',
                              fit: BoxFit.cover)),
                    ),
                  ),
                ],
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Container(
              height: 150,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Card(
                      child: GestureDetector(
                          // onTap: () {
                          //   Navigator.of(context).push(MaterialPageRoute(
                          //       builder: (context) => QrScanner()));
                          // },
                          child: Lottie.asset(
                              'assets/lotties/animation_lnejodtw.json',
                              fit: BoxFit.cover)),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Card(
                      child: GestureDetector(
                          // onTap: () {
                          //   Navigator.of(context).push(MaterialPageRoute(
                          //       builder: (context) => UserListPageCoins()));
                          // },
                          child: Lottie.asset(
                              'assets/lotties/animation_lnejdoi9.json',
                              fit: BoxFit.cover)),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class MyTotalCoins extends StatelessWidget {
  const MyTotalCoins({
    super.key,
    required this.currentUserDatas,
    required this.fontsize,
    required this.colorCoins,
  });

  final Map<String, dynamic> currentUserDatas;
  final double fontsize;
  final Color colorCoins;

  @override
  Widget build(BuildContext context) {
    return FittedBox(
      child: Container(
        // height: 200,
        // width: 150,
        child: Consumer<UserDataProvider>(
          builder: (context, userDataProvider, _) {
            final coins = currentUserDatas['coins'];
            final formattedCoins = intl.NumberFormat.currency(
              locale: 'fr_FR',
              symbol: 'DZD',
              decimalDigits: 2,
            ).format(coins ??
                0); // Utilisation de ?? pour éviter une erreur si coins est null
            return Padding(
              padding: const EdgeInsets.all(12.0),
              child: FittedBox(
                child: Text(
                  formattedCoins,
                  style: TextStyle(
                    color: colorCoins,
                    fontSize: fontsize,
                    fontWeight: FontWeight.w600,
                    shadows: <Shadow>[
                      // Shadow(
                      //   color: Colors.black,
                      //   offset: Offset(2.0, 2.0),
                      //   blurRadius: 2.0,
                      // ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

class MyGaines extends StatelessWidget {
  const MyGaines({
    super.key,
    required this.currentUserDatas,
  });

  final Map<String, dynamic> currentUserDatas;

  @override
  Widget build(BuildContext context) {
    return Container(
      // height: 200,
      // width: 150,
      child: Consumer<UserDataProvider>(
        builder: (context, userDataProvider, _) {
          final String role = currentUserDatas['role'] ?? '';
          if (role == 'owner') {
            return TotalCoinsWidget();
          } else {
            return SizedBox();
          }
        },
      ),
    );
  }
}

class MyDrawer extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Consumer<UserDataProvider>(
        builder: (context, userDataProvider, _) {
          final currentUserData = userDataProvider.currentUserData;

          // Vérifiez si le currentUserData est vide (non connecté)
          if (currentUserData.isEmpty) {
            return Center(
                child: FittedBox(child: Text("Utilisateur\nnon connecté")));
          }

          // Récupérez les informations nécessaires
          final email = currentUserData['email'];
          final coins = currentUserData['coins'];
          final userImageUrl = currentUserData['avatar'];
          final usertimeline = currentUserData['timeline'];
          final userName = currentUserData['displayName'];
          final id = currentUserData['id'];
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Stack(
                alignment: Alignment.bottomRight,
                children: [
                  UserAccountsDrawerHeader(
                    accountName: Text(
                      userName.toUpperCase(),
                      style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w600,
                          color: Colors.white),
                    ),
                    accountEmail: Text(
                      email,
                      style: TextStyle(
                          fontWeight: FontWeight.w600, color: Colors.white),
                    ),
                    currentAccountPicture: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: CircleAvatar(
                        backgroundImage:
                            CachedNetworkImageProvider(userImageUrl),
                      ),
                    ),
                    decoration: BoxDecoration(
                      image: DecorationImage(
                        image: CachedNetworkImageProvider(
                          usertimeline,
                        ),
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(0, 0, 15, 25),
                    child: Hero(
                      tag: 'qrCodeHero',
                      child: GestureDetector(
                        onTap: () {
                          // Naviguez vers une autre page où vous afficherez le code QR en utilisant le même tag
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (context) => QRCodePage(
                                currentUserData: currentUserData,
                              ),
                            ),
                          );
                        },
                        child: Container(
                          color: Colors.white,
                          height: 120,
                          width: 120,
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: PrettyQrView.data(
                                data: id,
                                decoration: PrettyQrDecoration(
                                  shape: PrettyQrSmoothSymbol(
                                      roundFactor: 0, color: Colors.black),
                                  image: PrettyQrDecorationImage(
                                    scale: 0.2,
                                    padding: EdgeInsets.all(50),
                                    image: CachedNetworkImageProvider(
                                        userImageUrl),
                                    position: PrettyQrDecorationImagePosition
                                        .embedded,
                                  ),
                                )),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              Center(
                child: InkWell(
                  // onTap: () => Navigator.of(context).push(MaterialPageRoute(
                  //   builder: (context) => UserProfileWidget(),
                  // )),
                  child: Card(
                      color: Colors.teal,
                      child: Padding(
                          padding: const EdgeInsets.all(18.0),
                          child: FittedBox(
                            child: Text(
                              intl.NumberFormat.currency(
                                locale: 'fr_FR',
                                symbol: 'DZD',
                                decimalDigits: 2,
                              ).format(coins),
                              //overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 30,
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                          ))),
                ),
              ),
              // TotalCoinsWidget(),
              Padding(
                padding: const EdgeInsets.all(10.0),
                child: Center(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 18),
                    child: Text(
                      'Hey, ' + userName.toUpperCase(),
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ),
              Center(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 18),
                  child: Text(
                    'What flavor do you want today?',
                    style: TextStyle(
                      fontSize: 16,
                    ),
                  ),
                ),
              ),
              Center(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 18),
                  child: Text('ما هي النكهة التي تريدها اليوم؟',
                      style: GoogleFonts.cairo(
                        color: Colors.black45,
                        fontWeight: FontWeight.w600,
                        fontSize: 16,
                      )),
                ),
              ),
              SizedBox(height: 20),
              ListTile(
                leading: Icon(
                  Icons.qr_code_2_sharp,
                  size: 35,
                ),
                title: Text("Payer"),
                onTap: () {
                  Navigator.of(context).push(
                      MaterialPageRoute(builder: (context) => QrScanner()));
                },
              ),
              ListTile(
                leading: Icon(
                  Icons.send_sharp,
                  size: 35,
                ),
                title: Text("Virement"),
                onTap: () {
                  Navigator.of(context).push(MaterialPageRoute(
                      builder: (context) => UserListPageCoins()));
                },
              ),
              ListTile(
                leading: Icon(
                  FontAwesomeIcons.alipay,
                  size: 35,
                ),
                title: Text('Mes Lotties'),
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => LottieListPage(),
                    ),
                  );
                },
              ),
              ListTile(
                leading: Icon(
                  FontAwesomeIcons.chargingStation,
                  size: 35,
                ),
                title: Text("Recharger"),
                onTap: () {
                  // Afficher une boîte de dialogue avec un code QR
                  showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return SizedBox(
                        width: 300.0, // Largeur souhaitée
                        height: 200.0,
                        child: AlertDialog(
                          title: Center(child: Text('Mon Code QR')),
                          content: SingleChildScrollView(
                            child: Column(
                              children: [
                                Center(
                                  child: PrettyQrView.data(
                                    data: id,
                                    decoration: PrettyQrDecoration(
                                      shape: PrettyQrSmoothSymbol(
                                          roundFactor: 0, color: Colors.black),
                                      image: PrettyQrDecorationImage(
                                        scale: 0.2,
                                        padding: EdgeInsets.all(50),
                                        image: CachedNetworkImageProvider(
                                            userImageUrl),
                                        position:
                                            PrettyQrDecorationImagePosition
                                                .embedded,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          // actions: <Widget>[
                          //   Center(
                          //     child: Padding(
                          //       padding: const EdgeInsets.all(8.0),
                          //       child: TextButton(
                          //         onPressed: () {
                          //           Navigator.of(context).pop();
                          //         },
                          //         child: Text('Fermer'),
                          //       ),
                          //     ),
                          //   ),
                          // ],
                        ),
                      );
                    },
                  );
                },
              ),
            ],
          );
        },
      ),
    );
  }

  bool isArabic(String text) {
    return RegExp(r'[\u0600-\u06FF]').hasMatch(text);
  }
}

class QRCodePage extends StatelessWidget {
  final Map<String, dynamic> currentUserData;

  const QRCodePage({
    Key? key,
    required this.currentUserData,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final email = currentUserData['email'];
    final coins = currentUserData['coins'];
    final userImageUrl = currentUserData['avatar'];
    final usertimeline = currentUserData['timeline'];
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
                    'Présentez Votre Code QR au Point de Vente Pour Recharge Rapide et Sécurisé CASH',
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
                          shape: PrettyQrSmoothSymbol(
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

class listMove extends StatelessWidget {
  const listMove(
      {Key? key, required this.scrollController, required this.images})
      : super(key: key);
  final ScrollController scrollController;
  final List images;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 120,
      child: ListView.builder(
        controller: scrollController,
        scrollDirection: Axis.horizontal,
        shrinkWrap: true,
        itemCount: images.length,
        itemBuilder: (context, index) {
          return Container(
            margin: EdgeInsets.all(25),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(25),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(25),
              child: CachedNetworkImage(
                imageUrl: '',
                fit: BoxFit.cover,
                width: 150,
              ),
            ),
          );
        },
      ),
    );
  }
}

class NetworkingPageHeader extends SliverPersistentHeaderDelegate {
  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    final opacity = (shrinkOffset < 1) ? 1.0 : 0.0;
    final opacity2 = (shrinkOffset > 1) ? 1.0 : 0.0;
    return Stack(
      alignment: Alignment.bottomCenter,
      fit: StackFit.expand,
      children: [
        Lottie.asset(
          'assets/lotties/1 (5).json',
          fit: BoxFit.fill,
        ),
        AnimatedOpacity(
          opacity: opacity,
          duration: Duration(milliseconds: 300), // Durée de l'animation
          child: Center(
            child: Consumer<UserDataProvider>(
              builder: (context, userDataProvider, _) {
                final currentUserData = userDataProvider.currentUserData;
                final coins = currentUserData['coins'];
                final formattedCoins = intl.NumberFormat.currency(
                  locale: 'fr_FR',
                  symbol: 'DZD',
                  decimalDigits: 2,
                ).format(coins ?? 0);

                return Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: FittedBox(
                    child: Text(
                      formattedCoins,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 50,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ),
        Align(
          alignment: Alignment.bottomCenter,
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: ListTile(
              leading: Consumer<UserDataProvider>(
                builder: (context, userDataProvider, _) {
                  final currentUserData = userDataProvider.currentUserData;
                  final avatar = currentUserData['avatar'];

                  if (avatar == null) {
                    return Icon(Icons.account_circle_rounded);
                  }
                  return InkWell(
                    onTap: () => Navigator.of(context).push(
                      MaterialPageRoute(builder: (context) => Profile()),
                    ),
                    child: CircleAvatar(
                      backgroundImage: CachedNetworkImageProvider(avatar),
                    ),
                  );
                },
              ),
              title: Consumer<UserDataProvider>(
                builder: (context, userDataProvider, _) {
                  final currentUserData = userDataProvider.currentUserData;
                  final displayName = currentUserData['displayName'] ?? '';

                  return Text(
                    displayName.toString().toUpperCase(),
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: Colors.lightBlue,
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                    ),
                  );
                },
              ),
              trailing: AnimatedOpacity(
                opacity: opacity2,
                duration: Duration(milliseconds: 300),
                child: Consumer<UserDataProvider>(
                  builder: (context, userDataProvider, _) {
                    final currentUserData = userDataProvider.currentUserData;
                    final coins = currentUserData['coins'];
                    final formattedCoins = intl.NumberFormat.currency(
                      locale: 'fr_FR',
                      symbol: 'DZD',
                      decimalDigits: 2,
                    ).format(coins ?? 0);

                    return Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: FittedBox(
                        child: Text(
                          formattedCoins,
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  @override
  double maxExtent = 300.0;

  @override
  double minExtent = 100.0;

  @override
  bool shouldRebuild(covariant SliverPersistentHeaderDelegate oldDelegate) =>
      false;
}

class TransactionList extends StatelessWidget {
  get _color => Colors.white;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('Users')
          .doc(FirebaseAuth.instance.currentUser!.uid)
          .collection('transactions')
          .orderBy('timestamp', descending: true)
          .snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return Center(child: CircularProgressIndicator());
        }

        List<TransactionData> transactions = snapshot.data!.docs.map((doc) {
          Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
          return TransactionData(
            id: data['id'],
            amount: data['amount'],
            state: data['state'],
            description: data['description'],
            timestamp: data['timestamp'],
          );
        }).toList();
// Triez vos transactions par date décroissante.
        transactions.sort((a, b) {
          final DateTime dateA = a.timestamp.toDate();
          final DateTime dateB = b.timestamp.toDate();
          return dateB.compareTo(dateA);
        });

// Sélectionnez uniquement les trois dernières transactions.
        final latestTransactions = transactions.take(3).toList();

        return ListView.builder(
          shrinkWrap: true,
          itemCount: latestTransactions.length,
          itemBuilder: (BuildContext context, int index) {
            final transactionData = transactions[index];
            final userId = transactionData.id; // Obtenez l'ID de l'utilisateur

            return FutureBuilder(
              future: FirebaseFirestore.instance
                  .collection('Users')
                  .doc(userId)
                  .get(),
              builder: (context, snap) {
                if (snap.hasError) {
                  // Gérer les erreurs ici si nécessaire.
                  return Text("Une erreur s'est produite: ${snap.error}");
                } else if (!snap.hasData) {
                  // Gérer le cas où les données sont absentes.
                  return Text("Données non trouvées");
                } else {
                  // Les données sont disponibles, affichez-les.
                  final userData = snap.data!;

                  return ListTile(
                    dense: true,
                    leading: Container(
                      width: 70,
                      child: Row(
                        children: [
                          CircleAvatar(
                            backgroundImage: NetworkImage(userData['avatar']),
                          ),
                          transactionData.description == 'reçu'
                              ? Icon(Icons.arrow_upward, color: Colors.green)
                              : transactionData.description == 'envoyer'
                                  ? Icon(Icons.arrow_downward,
                                      color: Colors.red)
                                  : Icon(Icons.arrow_circle_left,
                                      color: Colors.grey),
                        ],
                      ),
                    ),
                    subtitle: Text(
                      dateText(transactionData.timestamp),
                      style: TextStyle(
                        color: Colors.black45,
                        fontSize: 13,
                      ),
                    ),
                    title: Text(
                      userData['displayName'].toString().toUpperCase(),
                      overflow: TextOverflow.ellipsis,
                    ),
                    trailing: Text(
                      intl.NumberFormat.currency(
                        locale: 'fr_FR',
                        symbol: 'DZD ',
                        decimalDigits: 2,
                      ).format(transactionData.amount),
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: transactionData.description == 'reçu'
                            ? Colors.green
                            : transactionData.description == 'envoyer'
                                ? Colors.red
                                : Colors.grey,
                        fontSize: 18,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  );

                  //   ListTile(
                  //   leading: CircleAvatar(
                  //     backgroundImage: NetworkImage(userData['avatar']),
                  //   ),
                  //   title: Text(userData['displayName']),
                  //   trailing: PriceWidget(
                  //     price: transactionData.amount,
                  //   ),
                  // );
                }
              },
            );
          },
        );
      },
    );
  }

  String dateText(Timestamp? timestamp) {
    if (timestamp != null) {
      final dateTime = timestamp.toDate();
      final dateFormatter = DateFormat('dd MMM yyyy HH:mm');
      return dateFormatter.format(dateTime);
    } else {
      return '';
    }
  }
}
