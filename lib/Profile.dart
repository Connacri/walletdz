import 'dart:io';

import 'package:avatar_glow/avatar_glow.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:path/path.dart' as Path;
import 'package:provider/provider.dart';

import '../Oauth/Ogoogle/googleSignInProvider.dart';

class Profile extends StatefulWidget {
  const Profile({Key? key}) : super(key: key);

  @override
  State<Profile> createState() => _ProfileState();
}

class _ProfileState extends State<Profile> with TickerProviderStateMixin {
  late TabController _tabController;
  final userGoo = FirebaseAuth.instance.currentUser;
  late firebase_storage.Reference ref;

  List<XFile>? _mediaFileList = [];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  final picker = ImagePicker();

  PickedFile? _imageFile;
  String? _imageUrl;

  // Future pickImage(ImageSource source) async {
  //   final pickedFile = await picker.getImage(
  //     source: source,
  //     maxHeight: 1080,
  //     maxWidth: 1920,
  //     imageQuality: 40,
  //   );
  //   setState(() {
  //     _imageFile = pickedFile;
  //   });
  // }
  Future<void> pickImage(ImageSource source) async {
    try {
      final ImagePicker _picker = ImagePicker();

      final pickedFile = await _picker.pickImage(
        source: source,
        maxWidth: 1920,
        maxHeight: 1080,
        imageQuality: 40,
      );

      if (pickedFile != null) {
        // Traitez le fichier sélectionné ici, par exemple, affichez-le dans une image.
        // Vous pouvez également enregistrer le fichier ou effectuer d'autres actions en fonction de vos besoins.
        setState(() {
          _mediaFileList!.add(pickedFile);
        });
      } else {
        // L'utilisateur a annulé la sélection d'image.
      }
    } catch (e) {
      // Gérez les erreurs ici, par exemple, affichez un message d'erreur.
      print('Erreur lors de la sélection de l\'image : $e');
    }
  }

  Future uploadOneImage(String field) async {
    if (_imageFile == null) {
      return;
    }
    //final fileName = DateTime.now().millisecondsSinceEpoch.toString();
    final firebaseStorageRef = FirebaseStorage.instance
        .ref()
        .child('Users/${Path.basename(_imageFile!.path)}');
    final uploadTask = firebaseStorageRef.putFile(File(_imageFile!.path));
    final snapshot = await uploadTask.whenComplete(() {});
    final downloadUrl = await snapshot.ref.getDownloadURL();
    setState(() {
      _imageUrl = downloadUrl;
      saveImage(field);
    });
  }

  Future saveImage(String field) async {
    if (_imageUrl == null) {
      return;
    }
    //final timestamp = DateTime.now().millisecondsSinceEpoch.toString();
    final firestoreRef =
        FirebaseFirestore.instance.collection('Users').doc(userGoo!.uid);
    await firestoreRef.update({field: _imageUrl});
  }

  @override
  Widget build(BuildContext context) {
    TabController _tabController = TabController(length: 2, vsync: this);
    return Scaffold(
      backgroundColor: Colors.white,
      body: FutureBuilder<DocumentSnapshot>(
        future: FirebaseFirestore.instance
            .collection('Users')
            .doc(userGoo!.uid)
            .get(),
        builder:
            (BuildContext context, AsyncSnapshot<DocumentSnapshot> snapshot) {
          if (snapshot.hasError) {
            return Icon(Icons.error);
          }

          if (snapshot.hasData && !snapshot.data!.exists) {
            return Icon(Icons.account_box);
          }

          if (snapshot.connectionState == ConnectionState.done) {
            Map<String, dynamic> data =
                snapshot.data!.data() as Map<String, dynamic>;
            bool uploading = false;
            return CustomScrollView(slivers: <Widget>[
              SliverAppBar(
                actions: [
                  IconButton(
                      onPressed: () async {
                        FirebaseAuth.instance.signOut();
                        final provider = Provider.of<googleSignInProvider>(
                            context,
                            listen: false);
                        await provider.logout();
                        Navigator.of(context).pop();
                        //Navigator.pop(context, true);
                      },
                      icon: ClipOval(
                        child: Container(
                          color: Colors.black87,
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Icon(
                              Icons.logout,
                              color: Colors.red,
                            ),
                          ),
                        ),
                      )),
                ],
                expandedHeight: 220.0,
                floating: true,
                pinned: true,
                snap: true,
                elevation: 50,
                backgroundColor: Colors.black38,
                flexibleSpace: FlexibleSpaceBar(
                  titlePadding: EdgeInsets.symmetric(vertical: 0),
                  centerTitle: true,
                  title: Row(
                    //crossAxisAlignment: CrossAxisAlignment.end,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      data['plan'] == 'premium'
                          ? Padding(
                              padding: const EdgeInsets.only(left: 15),
                              child: const Icon(
                                Icons.workspace_premium,
                                color: Colors.amber,
                                size: 20,
                              ))
                          : Padding(
                              padding: const EdgeInsets.only(left: 15),
                              child: Icon(
                                Icons.spa,
                                size: 14,
                                color: Colors.lightBlue,
                              ),
                            ),
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.only(left: 5),
                          child: Text(
                            data['displayName'].toString().toUpperCase(),
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.w500),
                          ),
                        ),
                      ),

                      IconButton(
                        icon: uploading == false
                            ? Icon(
                                Icons.add_a_photo,
                                color: Colors.white70,
                                size: 15,
                              )
                            : CircularProgressIndicator(),
                        color: Colors.black,
                        onPressed: () {
                          showModalBottomSheet(
                            context: context,
                            builder: (BuildContext context) {
                              return SafeArea(
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: <Widget>[
                                    ListTile(
                                      leading: Icon(
                                        Icons.camera_alt,
                                      ),
                                      title: Text('Camera'),
                                      onTap: () {
                                        pickImage(ImageSource.camera).then(
                                          (value) {
                                            uploadOneImage('timeline');
                                          },
                                        );

                                        Navigator.of(context).pop();
                                      },
                                    ),
                                    ListTile(
                                      leading: Icon(Icons.photo_album),
                                      title: Text('Gallery'),
                                      onTap: () {
                                        pickImage(ImageSource.gallery).then(
                                          (value) {
                                            // if (uploading) return;
                                            // setState(() => uploading = true);
                                            uploadOneImage('timeline');
                                          },
                                        );
                                        Navigator.of(context).pop();
                                      },
                                    ),
                                  ],
                                ),
                              );
                            },
                          );
                        },
                      ),

                      // Padding(
                      //   padding: const EdgeInsets.symmetric(
                      //       horizontal: 10, vertical: 2),
                      //   child: Text(
                      //     data['email'],
                      //     style: TextStyle(fontSize: 8),
                      //   ),
                      // ),
                    ],
                  ),
                  background: ShaderMask(
                    shaderCallback: (rect) {
                      return const LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomLeft,
                        colors: [Colors.transparent, Colors.black],
                      ).createShader(
                          Rect.fromLTRB(0, 0, rect.width, rect.height));
                    },
                    blendMode: BlendMode.darken,
                    child: CachedNetworkImage(
                      fit: BoxFit.cover,
                      imageUrl: data['timeline'] ??
                          'https://source.unsplash.com/random?sig=20*3+1',
                      errorWidget: (context, url, error) => const Icon(
                        Icons.error,
                        color: Colors.red,
                      ),
                    ),
                  ),
                ),
              ),
              SliverList(
                  delegate: SliverChildListDelegate([
                Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Wallet',
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                              color: Colors.brown,
                              fontSize: 20,
                              fontWeight: FontWeight.w500),
                        ),
                        Text(
                          'Coins : ',
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                              color: Colors.brown,
                              fontSize: 20,
                              fontWeight: FontWeight.w300),
                        ),
                        Text(
                          NumberFormat.currency(symbol: '', decimalDigits: 2)
                              .format(data['coins']),
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                              color: Colors.black54,
                              fontSize: 20,
                              fontWeight: FontWeight.w400),
                        ),
                      ],
                    ),
                    Stack(
                      children: [
                        AvatarGlow(
                          glowColor: Colors.black54,
                          child: Material(
                            elevation: 8.0,
                            shape: CircleBorder(),
                            child: CircleAvatar(
                              backgroundImage: NetworkImage(data['avatar']),
                              radius: 30.0,
                            ),
                          ),
                        ),
                        Positioned(
                          right: 27,
                          bottom: 27,
                          child: Icon(
                            Icons.check_circle,
                            color: Colors.blue,
                          ),
                        ),
                        Positioned(
                          right: 15,
                          top: 10,
                          child: IconButton(
                            icon: Icon(
                              Icons.add_a_photo,
                              color: Colors.black,
                              size: 20,
                            ),
                            onPressed: () {
                              showModalBottomSheet(
                                context: context,
                                builder: (BuildContext context) {
                                  return SafeArea(
                                    child: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      children: <Widget>[
                                        ListTile(
                                          leading: Icon(Icons.camera_alt),
                                          title: Text('Camera'),
                                          onTap: () {
                                            pickImage(ImageSource.camera).then(
                                              (value) =>
                                                  uploadOneImage('avatar'),
                                            );
                                            Navigator.of(context).pop();
                                          },
                                        ),
                                        ListTile(
                                          leading: Icon(Icons.photo_album),
                                          title: Text('Gallery'),
                                          onTap: () {
                                            pickImage(ImageSource.gallery).then(
                                              (value) =>
                                                  uploadOneImage('avatar'),
                                            );
                                            Navigator.of(context).pop();
                                          },
                                        ),
                                      ],
                                    ),
                                  );
                                },
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          data['displayName'].toString(),
                          style: TextStyle(fontSize: 30),
                        ),
                        SizedBox(
                          width: 5,
                        ),
                        GestureDetector(
                          onTap: () {
                            // Navigator.of(context).push(MaterialPageRoute(
                            //   builder: (context) => profile_edit(
                            //     userDoc: data,
                            //   ), //MainPageAuth(),
                            //   //  AuthPage(),
                            // ));
                          },
                          child: Icon(
                            Icons.mode_edit,
                            size: 16,
                          ),
                        ),
                      ],
                    ),
                    data['email'] == 'forslog@gmail.com'
                        ? Padding(
                            padding: EdgeInsets.symmetric(
                                horizontal: 10, vertical: 10),
                            child: Column(
                              children: [
                                IconButton(
                                  icon: Icon(
                                    Icons.add_box_rounded,
                                    color: Colors.blue,
                                  ),
                                  onPressed: () async {
                                    // Navigator.of(context)
                                    //     .push(MaterialPageRoute(
                                    //   builder: (context) => uploading_functions(
                                    //     userDoc: data,
                                    //   ), //upload_random(),
                                    // ));
                                  },
                                ),
                              ],
                            ),
                          )
                        : Container(),
                    Padding(
                      padding: const EdgeInsets.only(top: 5.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          userGoo?.emailVerified == true
                              ? Icon(
                                  Icons.check_circle,
                                  color: Colors.blue,
                                )
                              : Icon(
                                  Icons.not_interested_outlined,
                                  color: Colors.red,
                                ),
                          Text(userGoo!.email.toString()),
                        ],
                      ),
                    ),
                    userGoo?.emailVerified != true
                        ? Text('Email Not Verified')
                        : Container(),
                    data['phone'] == null || data['phone'] == 0
                        ? Container()
                        : Center(
                            child: data['phone'] == null
                                ? Text(
                                    '${userGoo!.phoneNumber ?? ' '.toUpperCase()}',
                                    style: const TextStyle())
                                : Text('+213 ${data['phone']}'),
                          ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: NumbersWidget(
                        data: data,
                      ),
                    ),
                  ],
                ),
//                 Padding(
//                   padding:
//                       const EdgeInsets.symmetric(vertical: 20, horizontal: 100),
//                   child: ElevatedButton.icon(
//                     style: ElevatedButton.styleFrom(
//                         backgroundColor: Colors.red,
//                         shape: RoundedRectangleBorder(
//                             borderRadius: BorderRadius.circular(15)),
//                         elevation: 4.0,
//                         minimumSize: const Size.fromHeight(50)),
//                     icon: Icon(
//                       Icons.logout,
//                       color: Colors.white,
//                     ),
//                     label: const Text(
//                       'Deconnexion',
//                       style: TextStyle(color: Colors.white),
//                     ),
//                     onPressed: () async {
//                       FirebaseAuth.instance.signOut();
//                       final provider = Provider.of<googleSignInProvider>(
//                           context,
//                           listen: false);
//                       await provider.logouta();
// // Navigator.of(context).pop();
//                       Navigator.pop(context, true);
//                     },
//                   ),
//                 ),
//                 data['email'] == 'forslog@gmail.com'
//                     ? Padding(
//                         padding: const EdgeInsets.symmetric(
//                             horizontal: 20.0, vertical: 10),
//                         child: GestureDetector(
//                           //onTap: () => getFcm(),
//                           onTap: () => Navigator.of(context).push(
//                             MaterialPageRoute(
//                               builder: (context) => //GranttChartScreen2(),
//                                   gantt_chart(),
//                             ),
//                           ),
//                           child: Card(
//                             // margin: const EdgeInsets.all(5),
//                             shape: RoundedRectangleBorder(
//                                 borderRadius: BorderRadius.circular(15)),
//                             clipBehavior: Clip.antiAliasWithSaveLayer,
//                             elevation: 2,
//                             child: Stack(
//                               alignment: Alignment.center,
//                               children: [
//                                 ShaderMask(
//                                   shaderCallback: (rect) {
//                                     return const LinearGradient(
//                                       begin: Alignment.topCenter,
//                                       end: Alignment.bottomLeft,
//                                       colors: [
//                                         Colors.transparent,
//                                         Colors.black
//                                       ],
//                                     ).createShader(Rect.fromLTRB(
//                                         0, 0, rect.width, rect.height));
//                                   },
//                                   blendMode: BlendMode.darken,
//                                   child: Container(
//                                     height: 50,
//                                     decoration: BoxDecoration(
//                                       image: DecorationImage(
//                                         image: CachedNetworkImageProvider(
//                                           'https://firebasestorage.googleapis.com/v0/b/adventure-eb4ca.appspot.com/o/wall%2Fwall%20(3).jpg?alt=media&token=c5c01dca-4b32-4b9d-88fe-717e976ac2f5',
//                                         ),
//                                         fit: BoxFit.cover,
//                                         alignment: Alignment.topCenter,
//                                       ),
//                                     ),
//                                   ),
//                                 ),
//                                 Center(
//                                   child: Row(
//                                     mainAxisAlignment: MainAxisAlignment.center,
//                                     children: [
//                                       Text(
//                                         'Go To ',
//                                         textAlign: TextAlign.start,
//                                         style: TextStyle(
//                                             shadows: [
//                                               Shadow(
//                                                 blurRadius: 10.0, // shadow blur
//                                                 color: Colors
//                                                     .black54, // shadow color
//                                                 offset: Offset(2.0,
//                                                     2.0), // how much shadow will be shown
//                                               ),
//                                             ],
//                                             fontStyle: FontStyle.italic,
//                                             fontSize: 20,
//                                             fontWeight: FontWeight.bold,
//                                             color: Colors.red),
//                                       ),
//                                       Text(
//                                         'Gantt Chart Hotel',
//                                         textAlign: TextAlign.start,
//                                         style: TextStyle(
//                                             shadows: [
//                                               Shadow(
//                                                 blurRadius: 10.0, // shadow blur
//                                                 color: Colors
//                                                     .black54, // shadow color
//                                                 offset: Offset(2.0,
//                                                     2.0), // how much shadow will be shown
//                                               ),
//                                             ],
//                                             fontStyle: FontStyle.italic,
//                                             fontSize: 20,
//                                             fontWeight: FontWeight.bold,
//                                             color: Colors.white),
//                                       ),
//                                     ],
//                                   ),
//                                 ),
//                               ],
//                             ),
//                           ),
//                         ),
//                       )
//                     : Container(),
                data['email'] == 'forslog@gmail.com'
                    ? Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 20.0, vertical: 10),
                        child: GestureDetector(
                          //onTap: () => getFcm(),
                          // onTap: () => Navigator.of(context).push(
                          //   MaterialPageRoute(
                          //     builder: (context) => //GranttChartScreen2(),
                          //         BookingAAA(),
                          //   ),
                          // ),
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
                                      colors: [
                                        Colors.transparent,
                                        Colors.black
                                      ],
                                    ).createShader(Rect.fromLTRB(
                                        0, 0, rect.width, rect.height));
                                  },
                                  blendMode: BlendMode.darken,
                                  child: Container(
                                    height: 50,
                                    decoration: BoxDecoration(
                                      image: DecorationImage(
                                        image: CachedNetworkImageProvider(
                                          'https://firebasestorage.googleapis.com/v0/b/adventure-eb4ca.appspot.com/o/wall%2Fwall%20(3).jpg?alt=media&token=c5c01dca-4b32-4b9d-88fe-717e976ac2f5',
                                        ),
                                        fit: BoxFit.cover,
                                        alignment: Alignment.topCenter,
                                      ),
                                    ),
                                  ),
                                ),
                                Center(
                                  child: Text(
                                    'Testl',
                                    textAlign: TextAlign.start,
                                    style: TextStyle(
                                        shadows: [
                                          Shadow(
                                            blurRadius: 10.0, // shadow blur
                                            color:
                                                Colors.black54, // shadow color
                                            offset: Offset(2.0,
                                                2.0), // how much shadow will be shown
                                          ),
                                        ],
                                        fontStyle: FontStyle.italic,
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      )
                    : Container(),
              ])),
              SliverToBoxAdapter(
                child: Column(
                  children: [
                    TabBar(controller: _tabController, tabs: [
                      Tab(
                          text: 'Items',
                          icon: Icon(Icons.production_quantity_limits)),
                      Tab(text: 'Posts', icon: Icon(Icons.post_add)),
                    ]),
                    Container(
                      height: MediaQuery.of(context).size.height,
                      child: TabBarView(
                        controller: _tabController,
                        children: [
                          PostListOfMyProfil(
                            userID: userGoo!.uid,
                            collection: 'Products',
                          ),
                          PostListOfMyProfil(
                            userID: userGoo!.uid,
                            collection: 'Instalives',
                          ),
                        ],
                        //),
                      ),
                    ),
                  ],
                ),
              ),
              // SliverToBoxAdapter(
              //   child: Padding(
              //     padding: const EdgeInsets.only(bottom: 20),
              //     child: Center(
              //       child: GestureDetector(
              //         onTap: () {
              //           Navigator.of(context).push(MaterialPageRoute(
              //             builder: (context) =>
              //                 Privacy_Policy(), //MainPageAuth(),
              //             //  AuthPage(),
              //           ));
              //         },
              //         child: Padding(
              //           padding: const EdgeInsets.all(8.0),
              //           child: Text('Privacy Policy'),
              //         ),
              //       ),
              //     ),
              //   ),
              // )
            ]);
          }

          return Text("loading");
        },
      ),
    );
  }
}

class NumbersWidget extends StatelessWidget {
  final data;

  NumbersWidget({
    Key? key,
    required this.data,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    //final birthday = data['birthday'];

    // final int age =
    //     ((DateTime.now().difference(birthday.toDate()).inDays) / 365).toInt();
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        buildButton(context, data['levelUser'].toString(), 'Niveau'),
        buildDivider(),
        buildButton(context, data['role'].toString(), 'Role'),
        buildDivider(),
        buildButton(context, data['plan'].toString(), 'Plan'),
      ],
    );
  }

  Widget buildDivider() => Container(
        height: 24,
        child: VerticalDivider(),
      );

  Widget buildButton(BuildContext context, String value, String text) =>
      MaterialButton(
        padding: EdgeInsets.symmetric(vertical: 4),
        onPressed: () {},
        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            Text(
              value,
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 24),
            ),
            SizedBox(height: 2),
            Text(
              text,
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ],
        ),
      );
}

class PostListOfMyProfil extends StatelessWidget {
  const PostListOfMyProfil({
    Key? key,
    required this.userID,
    required this.collection,
  }) : super(key: key);

  final userID;
  final String collection;

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<QuerySnapshot>(
      future: FirebaseFirestore.instance
          .collection(collection)
          .where('userID', isEqualTo: userID)
          //.limit(3)
          //.orderBy('createdAt', descending: true)
          .get(),
      builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
        if (snapshot.hasError) {
          return const Text('Something went wrong');
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          return Container();
        }
        return Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: 18,
          ),
          child: ListView(
            shrinkWrap: true,
            scrollDirection: Axis.vertical,
            physics: const NeverScrollableScrollPhysics(),
            children: snapshot.data!.docs.map((DocumentSnapshot document) {
              Map<String, dynamic> data =
                  document.data()! as Map<String, dynamic>;
              if (data.length >= 6) {
                print('vous devez acheter premium');
              }
              final userm = FirebaseAuth.instance.currentUser;
              return Card(
                clipBehavior: Clip.antiAlias,
                elevation: 1,
                child: ListTile(
                  minVerticalPadding: 20.0,
                  minLeadingWidth: 0,
                  visualDensity: VisualDensity.compact,
                  //contentPadding: EdgeInsets.zero,
                  leading: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(5),
                      child: CachedNetworkImage(
                        imageUrl: data['themb'],
                        height: 40,
                        width: 40,
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  title: Text(
                    data['Description'].toString().toUpperCase(),
                    overflow: TextOverflow.ellipsis,
                    textAlign: isArabic(data['Description'])
                        ? TextAlign.right
                        : TextAlign.left,
                    style: isArabic(data['Description'])
                        ? GoogleFonts.cairo(
                            color: Colors.black45,
                            fontWeight: FontWeight.normal,
                            fontSize: 15,
                          )
                        : TextStyle(
                            color: Colors.black45,
                            fontWeight: FontWeight.normal,
                            fontSize: 15,
                          ),
                  ),

                  subtitle: collection == 'Instalives'
                      ? null
                      : Text(
                          '${data['price']}.00 DZD',
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: Colors.green,
                            fontWeight: FontWeight.bold,
                            fontSize: 15,
                          ),
                        ),
                  isThreeLine: collection == 'Instalives' ? false : true,
                  dense: true,
                  trailing: userm!.uid != userID
                      ? Text('')
                      : collection == 'Products'
                          ? IconButton(
                              icon: Icon(Icons.delete),
                              onPressed: () {
                                FirebaseFirestore.instance
                                    .collection('Users')
                                    .doc(userID)
                                    .update({
                                  'userItemsNbr': FieldValue.increment(-1)
                                }).whenComplete(() => FirebaseFirestore.instance
                                        .collection(collection)
                                        .doc(document.id)
                                        .delete());
                                //Navigator.pop(context, true);
                              },
                            )
                          : IconButton(
                              icon: Icon(Icons.delete),
                              onPressed: () {
                                FirebaseFirestore.instance
                                    .collection(collection)
                                    .doc(document.id)
                                    .delete();
                                //Navigator.pop(context, true);
                              },
                            ),
                  onTap: () async {
                    // await Navigator.push(context,
                    //     MaterialPageRoute(builder: (BuildContext) {
                    //   return Hero(
                    //     tag: 'Hero_Items',
                    //     child: SilverdetailItem(
                    //       data: data,
                    //       idDoc: document.id,
                    //       isLiked:
                    //           data['usersLike'].toString().contains(userm.uid),
                    //     ),
                    //   );
                    // }));
                  },
                ),
              );
            }).toList(),
          ),
        );
      },
    );
  }

  bool isArabic(String text) {
    return RegExp(r'[\u0600-\u06FF]').hasMatch(text);
  }
}

Future<bool?> showConfirmationDialog(BuildContext context, String documentID) {
  return showDialog<bool>(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: Text('Confirmation'),
        content: Text('Etes Vous Sur De Proceder à La Supression?'),
        actions: <Widget>[
          ElevatedButton(
            child: Text('No'),
            onPressed: () => Navigator.of(context).pop(false),
          ),
          ElevatedButton(
            child: Text('Yes'),
            onPressed: () async {
              await FirebaseFirestore.instance
                  .collection('Products')
                  .doc(documentID)
                  .delete()
                  .whenComplete(
                    () => Navigator.of(context).pop(),
                  );
            },
          ),
        ],
      );
    },
  );
}
