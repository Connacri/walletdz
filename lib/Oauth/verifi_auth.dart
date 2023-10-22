import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'AuthPage.dart';
import 'CheckRole.dart';
import 'VerifyEmailPage.dart';

class verifi_auth extends StatefulWidget {
  const verifi_auth({Key? key}) : super(key: key);

  @override
  State<verifi_auth> createState() => _verifi_authState();
}

class _verifi_authState extends State<verifi_auth> {
  @override
  Widget build(BuildContext context) => Scaffold(
        body: StreamBuilder<User?>(
          stream: FirebaseAuth.instance.authStateChanges(),
          builder: (context, snapshot) {
            // if (snapshot.connectionState == ConnectionState.waiting) {
            //   return const CircularProgressIndicator();
            // } else
            if (snapshot.hasError) {
              return const Center(child: Text('Probleme de Connexion'));
            }
            if (snapshot.hasData) {
              final userD = snapshot.data!.uid;
              User? user = snapshot.data;
              if (user!.emailVerified) {
                // Email is verified, navigate to home page
                return CheckRole(userD); //MultiProviderWidget();
              } else {
                // Email is not verified, navigate to resend email page
                return VerifyEmailPage();
              }
            } else {
              return unloggedHome(); //unloggedPublicPage();
            }
          },
        ),
      );
}

class unloggedHome extends StatelessWidget {
  const unloggedHome({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        foregroundColor: Colors.transparent,
        onPressed: () {
          Navigator.push(context, MaterialPageRoute(builder: (_) {
            return AuthPage();
          }));
        },
        child: const Icon(
          FontAwesomeIcons.add,
          color: Colors.black54,
        ),
      ),
      body: Center(
        child: Column(
          children: [
            Text('unloggedHome'),
            SizedBox(
              height: 100,
            ),
            Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10),
              child: GestureDetector(
                // //onTap: () => getFcm(),
                onTap: () {
                  Navigator.push(context, MaterialPageRoute(builder: (_) {
                    return AuthPage();
                  }));
                },
                child: Card(
                  // margin: const EdgeInsets.all(5),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15)),
                  clipBehavior: Clip.antiAliasWithSaveLayer,
                  elevation: 2,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      ShaderMask(
                        shaderCallback: (rect) {
                          return const LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomLeft,
                            colors: [Colors.transparent, Colors.black],
                          ).createShader(
                              Rect.fromLTRB(0, 0, rect.width, rect.height));
                        },
                        blendMode: BlendMode.darken,
                        child: Container(
                          height: 50,
                          decoration: BoxDecoration(
                            image: DecorationImage(
                              image: CachedNetworkImageProvider(
                                'https://source.unsplash.com/random/?city,night',
                              ),
                              fit: BoxFit.cover,
                              alignment: Alignment.topCenter,
                            ),
                          ),
                        ),
                      ),
                      Center(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              'Aya',
                              textAlign: TextAlign.start,
                              style: TextStyle(
                                  shadows: [
                                    Shadow(
                                      blurRadius: 10.0, // shadow blur
                                      color: Colors.black54, // shadow color
                                      offset: Offset(2.0,
                                          2.0), // how much shadow will be shown
                                    ),
                                  ],
                                  fontStyle: FontStyle.italic,
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.red),
                            ),
                            Text(
                              ' Bismillah',
                              textAlign: TextAlign.start,
                              style: TextStyle(
                                  shadows: [
                                    Shadow(
                                      blurRadius: 10.0, // shadow blur
                                      color: Colors.black54, // shadow color
                                      offset: Offset(2.0,
                                          2.0), // how much shadow will be shown
                                    ),
                                  ],
                                  fontStyle: FontStyle.italic,
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
