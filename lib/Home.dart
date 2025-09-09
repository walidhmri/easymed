import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'Soins_medicaux.dart';
import 'Transport.dart';
import 'Equipement.dart';
import 'Analyses_medicales.dart';
import 'Hospitalisation.dart';
import 'Consultations.dart';
import 'Garde_malade.dart';
import 'user_provider.dart';
import 'Consultations.dart';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:carousel_slider/carousel_slider.dart';

import 'widgets/Drawer_menu.dart';

class Home extends StatefulWidget {
  Home({super.key});
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final String defaultAvatarUrl =
      "https://firebasestorage.googleapis.com/v0/b/easy-med-c3f69.firebasestorage.app/o/profile_images%2Favatar-simple.jpg?alt=media&token=cbf516b6-ad37-4c50-852d-58f0b83564d5";

  String userName = "...";
  String userProfilePic = "";
  String userId = "";

  @override
  void initState() {
    super.initState();
    Provider.of<UserProvider>(context, listen: false).fetchUserData();
    getUserData();
  }

  Future<void> getUserData() async {
    final prefs = await SharedPreferences.getInstance();
    String? storedUserId = prefs.getString("user_id");

    if (storedUserId != null) {
      setState(() {
        userId =
            storedUserId; // Stocke l'ID pour d'autres utilisations si besoin
      });

      try {
        DocumentSnapshot userDoc = await FirebaseFirestore.instance
            .collection("users")
            .doc(userId)
            .get();

        if (userDoc.exists) {
          setState(() {
            userName = userDoc["name"];

            final image = userDoc["profileImage"];
            userProfilePic =
                (image != null && image.toString().trim().isNotEmpty)
                ? image
                : defaultAvatarUrl;
          });
        } else {
          setState(() {
            userName = "Utilisateur introuvable";
          });
        }
      } catch (e) {
        print("Erreur lors de la récupération de l'utilisateur: $e");
        setState(() {
          userName = "case1";
          userProfilePic = "";
        });
      }
    } else {
      setState(() {
        userName = "case2";
        userProfilePic = "";
      });
    }
  }

  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(60), // Hauteur du header
        child: AppBar(
          backgroundColor:
              Colors.transparent, // Transparent pour voir l’image de fond
          elevation: 0, // Supprime l'ombre
          flexibleSpace: Container(
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/images/pink_header_3.png'),
                fit: BoxFit.cover, // Couvre tout l’espace
                alignment: Alignment.bottomCenter, // Centre le bas de l’image
              ),
            ),
          ),
          title: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Icône à gauche
              GestureDetector(
                onTap: () {
                  _scaffoldKey.currentState
                      ?.openDrawer(); // Ouvre le Drawer quand on clique
                },
                child: const Icon(Icons.menu, color: Colors.white, size: 30),
              ),

              Text(
                "Bonjour $userName",
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),

              // Avatar à droite
              Container(
                width: 50, // Taille de l’avatar
                height: 50,
                decoration: BoxDecoration(
                  shape: BoxShape.circle, // Rend l’image ronde
                  border: Border.all(
                    color: Colors.white,
                    width: 2,
                  ), // Bordure blanche
                  image: DecorationImage(
                    image:
                        userProfilePic.startsWith('http') ||
                            userProfilePic.startsWith('https')
                        ? NetworkImage(userProfilePic)
                        : AssetImage(userProfilePic) as ImageProvider,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            ],
          ),
          automaticallyImplyLeading: false,
        ),
      ),
      body: Center(
        child: Column(
          children: [
            const SizedBox(height: 20),
            const SlideBanner(),
            const SizedBox(height: 20),
            const Text(
              "Choisissez une catégorie",
              style: TextStyle(
                color: Colors.black,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                GestureDetector(
                  onTap: () {
                    // Lorsque le container est cliqué, on navigue vers la page Soinsmedicaux
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const Soins_medicaux(),
                      ),
                    );
                  },
                  child: Container(
                    width: MediaQuery.of(context).size.width * 0.35,
                    height: 100,
                    decoration: BoxDecoration(
                      color: Colors.white, // Couleur du fond
                      borderRadius: BorderRadius.circular(
                        10,
                      ), // Coins arrondis (facultatif)
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(
                            0.2,
                          ), // Couleur de l'ombre
                          spreadRadius: 5, // Étendue de l'ombre
                          blurRadius: 7, // Flou de l'ombre
                          offset: const Offset(
                            0,
                            3,
                          ), // Décalage de l'ombre (horizontal, vertical)
                        ),
                      ],
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SizedBox(
                          height: 50, // 90% de l'écran
                          child: Image.asset(
                            'assets/images/soin_medical.png',
                            fit: BoxFit.cover,
                          ),
                        ),
                        const SizedBox(height: 5),
                        const Text(
                          "Soins médicaux",
                          style: subTitle.customStyle,
                        ),
                      ],
                    ),
                  ),
                ),
                SizedBox(width: MediaQuery.of(context).size.width * 0.1),
                GestureDetector(
                  onTap: () {
                    // Lorsque le container est cliqué, on navigue vers la page Soinsmedicaux
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const Transport(),
                      ),
                    );
                  },
                  child: Container(
                    width: MediaQuery.of(context).size.width * 0.35,
                    height: 100,
                    decoration: BoxDecoration(
                      color: Colors.white, // Couleur du fond
                      borderRadius: BorderRadius.circular(
                        10,
                      ), // Coins arrondis (facultatif)
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(
                            0.2,
                          ), // Couleur de l'ombre
                          spreadRadius: 5, // Étendue de l'ombre
                          blurRadius: 7, // Flou de l'ombre
                          offset: const Offset(
                            0,
                            3,
                          ), // Décalage de l'ombre (horizontal, vertical)
                        ),
                      ],
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SizedBox(
                          height: 50,
                          child: Image.asset(
                            'assets/images/transport.png',
                            fit: BoxFit.cover,
                          ),
                        ),
                        const SizedBox(height: 5),
                        const Text("Transport", style: subTitle.customStyle),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 15),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                GestureDetector(
                  onTap: () {
                    // Lorsque le container est cliqué, on navigue vers la page Soinsmedicaux
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => Consultations()),
                    );
                  },
                  child: Container(
                    width: MediaQuery.of(context).size.width * 0.35,
                    height: 100,
                    decoration: BoxDecoration(
                      color: Colors.white, // Couleur du fond
                      borderRadius: BorderRadius.circular(
                        10,
                      ), // Coins arrondis (facultatif)
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(
                            0.2,
                          ), // Couleur de l'ombre
                          spreadRadius: 5, // Étendue de l'ombre
                          blurRadius: 7, // Flou de l'ombre
                          offset: const Offset(
                            0,
                            3,
                          ), // Décalage de l'ombre (horizontal, vertical)
                        ),
                      ],
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SizedBox(
                          height: 50, // 90% de l'écran
                          child: Image.asset(
                            'assets/images/consultation.png',
                            fit: BoxFit.cover,
                          ),
                        ),
                        const SizedBox(height: 5),
                        const Text(
                          "Consultations",
                          style: subTitle.customStyle,
                        ),
                      ],
                    ),
                  ),
                ),
                SizedBox(width: MediaQuery.of(context).size.width * 0.1),
                GestureDetector(
                  onTap: () {
                    // Lorsque le container est cliqué, on navigue vers la page Soinsmedicaux
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const Analyses_medicales(),
                      ),
                    );
                  },
                  child: Container(
                    width: MediaQuery.of(context).size.width * 0.35,
                    height: 100,
                    decoration: BoxDecoration(
                      color: Colors.white, // Couleur du fond
                      borderRadius: BorderRadius.circular(
                        10,
                      ), // Coins arrondis (facultatif)
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(
                            0.2,
                          ), // Couleur de l'ombre
                          spreadRadius: 5, // Étendue de l'ombre
                          blurRadius: 7, // Flou de l'ombre
                          offset: const Offset(
                            0,
                            3,
                          ), // Décalage de l'ombre (horizontal, vertical)
                        ),
                      ],
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SizedBox(
                          height: 50,
                          child: Image.asset(
                            'assets/images/analyses.jpg',
                            fit: BoxFit.cover,
                          ),
                        ),

                        const SizedBox(height: 5),
                        const Text(
                          "Analyses médicales",
                          style: subTitleGrey.customStyle,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 40),
            const Text("Prochainement", style: blueTitle.customStyle),
            Column(
              children: [
                const SizedBox(height: 10),
                GestureDetector(
                  onTap: () {
                    // Lorsque le container est cliqué, on navigue vers la page Soinsmedicaux
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const Garde_malade(),
                      ),
                    );
                  },
                  child: Container(
                    padding: const EdgeInsets.all(8.0),
                    width: MediaQuery.of(context).size.width * 0.8,
                    decoration: BoxDecoration(
                      // Couleur du fond
                      color: const Color(0xFFF11477),
                      borderRadius: BorderRadius.circular(
                        10,
                      ), // Coins arrondis (facultatif)
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(
                            0.1,
                          ), // Couleur de l'ombre
                          spreadRadius: 3, // Étendue de l'ombre
                          blurRadius: 5, // Flou de l'ombre
                          offset: const Offset(
                            0,
                            3,
                          ), // Décalage de l'ombre (horizontal, vertical)
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SizedBox(
                          height: 20,
                          child: Image.asset(
                            'assets/images/icons/help.png',
                            fit: BoxFit.cover,
                          ),
                        ),
                        const SizedBox(width: 15),
                        const Text(
                          "Garde malade",
                          style: whiteTitle.customStyle,
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                GestureDetector(
                  onTap: () {
                    // Lorsque le container est cliqué, on navigue vers la page Soinsmedicaux
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const Hospitalisation(),
                      ),
                    );
                  },
                  child: Container(
                    padding: const EdgeInsets.all(8.0),
                    width: MediaQuery.of(context).size.width * 0.8,
                    decoration: BoxDecoration(
                      // Couleur du fond
                      color: const Color(0xFFF11477),
                      borderRadius: BorderRadius.circular(
                        10,
                      ), // Coins arrondis (facultatif)
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(
                            0.1,
                          ), // Couleur de l'ombre
                          spreadRadius: 3, // Étendue de l'ombre
                          blurRadius: 5, // Flou de l'ombre
                          offset: const Offset(
                            0,
                            3,
                          ), // Décalage de l'ombre (horizontal, vertical)
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SizedBox(
                          height: 20,
                          child: Image.asset(
                            'assets/images/icons/hospital.png',
                            fit: BoxFit.cover,
                          ),
                        ),
                        const SizedBox(width: 15),
                        const Text(
                          "Hospitalisation",
                          style: whiteTitle.customStyle,
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                GestureDetector(
                  onTap: () {
                    // Lorsque le container est cliqué, on navigue vers la page Soinsmedicaux
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => Consultations()),
                    );
                  },
                  child: Container(
                    padding: const EdgeInsets.all(8.0),
                    width: MediaQuery.of(context).size.width * 0.8,
                    decoration: BoxDecoration(
                      // Couleur du fond
                      color: const Color(0xFFC2BABE),
                      borderRadius: BorderRadius.circular(
                        10,
                      ), // Coins arrondis (facultatif)
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(
                            0.1,
                          ), // Couleur de l'ombre
                          spreadRadius: 3, // Étendue de l'ombre
                          blurRadius: 5, // Flou de l'ombre
                          offset: const Offset(
                            0,
                            3,
                          ), // Décalage de l'ombre (horizontal, vertical)
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SizedBox(
                          height: 20,
                          child: Image.asset(
                            'assets/images/icons/doctor.png',
                            fit: BoxFit.cover,
                          ),
                        ),
                        const SizedBox(width: 15),
                        const Text(
                          "Consultation spécialisée",
                          style: whiteTitle.customStyle,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
      drawer: const Drawer_menu(),
    );
  }
}

class SlideBanner extends StatefulWidget {
  const SlideBanner({super.key});

  @override
  State<SlideBanner> createState() => _SlideBannerState();
}

class _SlideBannerState extends State<SlideBanner> {
  List<String> imageUrls = [];

  @override
  void initState() {
    super.initState();
    fetchSlides();
  }

  Future<void> fetchSlides() async {
    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('slides')
          .get();
      final urls = snapshot.docs
          .map((doc) => doc['slide_url'] as String)
          .where((url) => url.isNotEmpty)
          .toList();

      setState(() {
        imageUrls = urls;
      });
    } catch (e) {
      print('Erreur de chargement des slides : $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    if (imageUrls.isEmpty) {
      return const SizedBox(
        height: 100,
        child: Center(child: CircularProgressIndicator()),
      );
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: CarouselSlider(
        options: CarouselOptions(
          height: 100,
          autoPlay: true,
          autoPlayInterval: const Duration(seconds: 5),
          viewportFraction: 1.0,
          enlargeCenterPage: false,
        ),
        items: imageUrls.map((url) {
          return Builder(
            builder: (BuildContext context) {
              return ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: Image.network(
                  url,
                  fit: BoxFit.cover,
                  width: MediaQuery.of(context).size.width,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      color: Colors.grey[200],
                      child: const Center(child: Text("Erreur d'image")),
                    );
                  },
                ),
              );
            },
          );
        }).toList(),
      ),
    );
  }
}

class subTitle {
  static const TextStyle customStyle = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.bold,
    color: Colors.black,
  );
}

class subTitleGrey {
  static const TextStyle customStyle = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.bold,
    color: Color(0xFF000000),
  );
}

class blueTitle {
  static const TextStyle customStyle = TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.w900,
    color: Color(0xFF1170AD),
  );
}

class whiteTitle {
  static const TextStyle customStyle = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w600,
    color: Color(0xFFFFFFFF),
  );
}
