import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:easy_malade/user_provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../Profil.dart';
import '../Politique_de_confidentialite.dart';
import '../Mes_demandes.dart';
import '../Connexion.dart';

class Drawer_menu extends StatefulWidget {
  const Drawer_menu({super.key});
  @override
  _Drawer_menuState createState() => _Drawer_menuState();
}

class _Drawer_menuState extends State<Drawer_menu> {
  final String defaultProfilePic =
      "https://firebasestorage.googleapis.com/v0/b/easy-med-c3f69.firebasestorage.app/o/profile_images%2Favatar-simple.jpg?alt=media&token=cbf516b6-ad37-4c50-852d-58f0b83564d5";

  String userName = "... chargement";
  String userPhone = "...";
  String userProfilePic = "...";
  String userId = "";
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
            userName =
                userDoc["name"]; // 🔥 Assure-toi que le champ est bien "name"
            userPhone = userDoc["phone"];
            String? profileImage = userDoc["profileImage"];
            userProfilePic =
                (profileImage == null || profileImage.trim().isEmpty)
                ? defaultProfilePic
                : profileImage;
          });
        } else {
          setState(() {
            userName = "Utilisateur introuvable";
            userPhone = "Numéro de téléphone";
            userProfilePic =
                "https://firebasestorage.googleapis.com/v0/b/easy-med-c3f69.firebasestorage.app/o/profile_images%2Favatar-simple.jpg?alt=media&token=cbf516b6-ad37-4c50-852d-58f0b83564d5";
          });
        }
      } catch (e) {
        print("Erreur lors de la récupération de l'utilisateur: $e");
        setState(() {
          userName = "Erreur de chargement";
          userPhone = "Erreur de chargement";
          userProfilePic =
              "https://firebasestorage.googleapis.com/v0/b/easy-med-c3f69.firebasestorage.app/o/profile_images%2Favatar-simple.jpg?alt=media&token=cbf516b6-ad37-4c50-852d-58f0b83564d5";
        });
      }
    } else {
      setState(() {
        userName = "Utilisateur non connecté";
        userPhone = "Utilisateur non connecté";
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Stack(
        children: [
          Positioned(
            top: 0,
            left: 0,
            child: Container(
              width: MediaQuery.of(context).size.width * 1,
              height: MediaQuery.of(context).size.height * 0.25,
              decoration: const BoxDecoration(
                image: DecorationImage(
                  image: AssetImage("assets/images/header_menu_pink.png"),
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ),
          Positioned(
            top: MediaQuery.of(context).size.height * 0.15,
            width: MediaQuery.of(context).size.width * 0.8,
            left: 0,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width:
                      MediaQuery.of(context).size.width *
                      0.4, // Taille de l’avatar
                  height: MediaQuery.of(context).size.width * 0.4,
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
          ),
          Positioned(
            top: MediaQuery.of(context).size.height * 0.38,
            left: 0,
            width: MediaQuery.of(context).size.width * 0.8,
            child: Center(child: Text("$userName", style: name.customStyle)),
          ),
          Positioned(
            top: MediaQuery.of(context).size.height * 0.45,
            left: 0,
            width: MediaQuery.of(context).size.width * 0.8,
            child: Center(
              child: Text("$userPhone", style: contact.customStyle),
            ),
          ),
          Positioned(
            child: ListView(
              padding: EdgeInsets.only(
                top:
                    MediaQuery.of(context).size.height *
                    0.5, // 50% of the screen height
              ),
              children: [
                ListTile(
                  leading: const Icon(Icons.person, color: Colors.black),
                  title: const Text("Profil", style: menu_link.customStyle),
                  onTap: () {
                    Navigator.pop(context); // Ferme le Drawer
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const Profil(),
                      ), // Navigate to Profil screen
                    );
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.security, color: Colors.black),
                  title: const Text(
                    "Politique de confidentialité",
                    style: menu_link.customStyle,
                  ),
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            const Politique_de_confidentialite(),
                      ),
                    );
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.assignment, color: Colors.black),
                  title: const Text(
                    "Mes demandes",
                    style: menu_link.customStyle,
                  ),
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const Mes_demandes(),
                      ), // Navigate to Profil screen
                    );
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.exit_to_app, color: Colors.black),
                  title: const Text(
                    "Se déconnecter",
                    style: menu_link.customStyle,
                  ),
                  onTap: () async {
                    Navigator.pop(context); // Ferme le Drawer

                    // 🔐 Déconnexion Firebase
                    await FirebaseAuth.instance.signOut();

                    // 🧹 Optionnel : vider SharedPreferences
                    final prefs = await SharedPreferences.getInstance();
                    await prefs.remove("user_id");

                    // 🚪 Redirection vers l'écran de connexion
                    Navigator.of(context).pushAndRemoveUntil(
                      MaterialPageRoute(builder: (context) => Connexion()),
                      (Route<dynamic> route) =>
                          false, // Supprime toutes les routes précédentes
                    );
                  },
                ),
              ],
            ),
          ),
          Positioned(
            bottom: 0,
            right: 0,
            child: Container(
              width: MediaQuery.of(context).size.width * 0.5,
              height: MediaQuery.of(context).size.width * 0.5,
              decoration: const BoxDecoration(
                image: DecorationImage(
                  image: AssetImage("assets/images/icone-bas.png"),
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class name {
  static const TextStyle customStyle = TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.bold,
    color: Colors.black,
  );
}

class contact {
  static const TextStyle customStyle = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.bold,
    color: Color(0xFF888888),
  );
}

class menu_link {
  static const TextStyle customStyle = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.bold,
    color: Colors.black,
  );
}
