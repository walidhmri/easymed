import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:easy_malade/AppBar.dart';
import 'package:easy_malade/user_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'AppBar.dart';

class Politique_de_confidentialite extends StatefulWidget {
  const Politique_de_confidentialite({super.key});
  @override
  _Politique_de_confidentialiteState createState() =>
      _Politique_de_confidentialiteState();
}

class _Politique_de_confidentialiteState
    extends State<Politique_de_confidentialite> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  void _validateInputs() {}
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
            userName = userDoc["name"];
            userPhone = userDoc["phone"];
            userProfilePic = userDoc["profileImage"];
          });
        } else {
          setState(() {
            userName = "Utilisateur introuvable";
            userPhone = "utilisateur introuvable";
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
        userProfilePic =
            "https://firebasestorage.googleapis.com/v0/b/easy-med-c3f69.firebasestorage.app/o/profile_images%2Favatar-simple.jpg?alt=media&token=cbf516b6-ad37-4c50-852d-58f0b83564d5";
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(),
      body: const Center(
        child: Padding(
          padding: EdgeInsets.only(left: 20, right: 20),
          child: Column(
            children: [
              SizedBox(height: 40),
              Text(
                "Politique de confidentialité",
                textAlign: TextAlign.center,
                style: blueTitle.customStyle,
              ),
              SizedBox(height: 20),
              Text(
                "EasyMed respecte votre vie privée. Nous collectons uniquement les informations nécessaires (comme votre nom, numéro de téléphone, localisation et adresses) afin de vous connecter avec des soignants et transporteurs pour vos soins et analyses à domicile.",
                textAlign: TextAlign.center,
                style: normalText.customStyle,
              ),
              SizedBox(height: 15),
              Text(
                "Vos données ne sont jamais partagées avec des tiers, sauf pour fournir le service demandé ou si la loi l’exige. Elles sont conservées en toute sécurité et uniquement pour la durée nécessaire.",
                textAlign: TextAlign.center,
                style: normalText.customStyle,
              ),
              SizedBox(height: 15),
            ],
          ),
        ),
      ),
    );
  }
}

class blueTitle {
  static const TextStyle customStyle = TextStyle(
    fontSize: 26,
    fontWeight: FontWeight.bold,
    color: Color(0xFF1170AD),
  );
}

class normalText {
  static const TextStyle customStyle = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w700,
    color: Colors.black,
  );
}
