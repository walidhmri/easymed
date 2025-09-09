import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:crypto/crypto.dart';

import 'Home.dart';
import 'Inscription.dart';
import 'MotDePasseOublie.dart';

class Connexion extends StatefulWidget {
  const Connexion({super.key});

  @override
  _ConnexionState createState() => _ConnexionState();
}

class _ConnexionState extends State<Connexion> {
  TextEditingController telController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  @override
  void initState() {
    super.initState();
    _checkLoginStatus();
  }

  void _checkLoginStatus() async {
    final prefs = await SharedPreferences.getInstance();
    String? userId = prefs.getString("user_id");

    if (userId != null) {
      // 🔹 Redirection automatique si l'utilisateur est déjà connecté
      Future.microtask(() {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => Home()),
        );
      });
    }
  }

  @override
  void dispose() {
    telController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  String hashPassword(String password) {
    var bytes = utf8.encode(password);
    var digest = sha256.convert(bytes);
    return digest.toString();
  }

  void _login() async {
    String phone = "+213${telController.text.trim()}";
    String password = passwordController.text.trim();

    if (phone.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Tous les champs doivent être remplis")),
      );
      return;
    }

    try {
      QuerySnapshot querySnapshot = await FirebaseFirestore.instance
          .collection('users')
          .where('phone', isEqualTo: phone)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        var userDoc = querySnapshot.docs.first;
        String storedHashedPassword = userDoc['password'];
        String enteredHashedPassword = hashPassword(password);

        if (storedHashedPassword == enteredHashedPassword) {
          String userId = userDoc.id;

          // 🔹 Stocker l'ID utilisateur dans SharedPreferences
          final prefs = await SharedPreferences.getInstance();
          await prefs.setString("user_id", userId);

          // 🔹 Vérifier si l'ID est bien enregistré
          print("🔹 ID utilisateur stocké: ${prefs.getString("user_id")}");
          // 🔹 Rediriger vers Home
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => Home()),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Mot de passe incorrect")),
          );
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Numéro de téléphone non trouvé")),
        );
      }
    } catch (e) {
      print("Erreur de connexion: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Une erreur est survenue, réessayez plus tard"),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.only(left: 0, right: 0, top: 0, bottom: 0),
          child: Column(
            children: [
              Container(
                width: MediaQuery.of(context).size.width * 1,
                height: MediaQuery.of(context).size.height * 0.35,
                decoration: const BoxDecoration(
                  borderRadius: BorderRadius.only(
                    bottomRight: Radius.circular(
                      50,
                    ), // Arrondi uniquement en bas à droite
                  ),
                  image: DecorationImage(
                    image: AssetImage(
                      "assets/images/gloves.jpg",
                    ), // Image depuis les assets
                    fit: BoxFit.cover, // Ajustement de l'image
                  ),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Container(
                      padding: const EdgeInsets.only(right: 25),
                      height: 50,
                      child: Image.asset(
                        'assets/images/logo.png',
                        fit: BoxFit.cover,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 40),
              const Text("Connexion", style: blueTitle.customStyle),
              const SizedBox(height: 20),
              Container(
                child: Padding(
                  padding: EdgeInsets.only(
                    left: MediaQuery.of(context).size.width * 0.08,
                    right: MediaQuery.of(context).size.width * 0.08,
                  ),
                  child: Column(
                    children: [
                      TextField(
                        controller: telController,
                        keyboardType: TextInputType.phone,
                        decoration: const InputDecoration(
                          contentPadding: EdgeInsets.symmetric(
                            vertical: 10,
                            horizontal: 10,
                          ),
                          prefixText: '+213 ',
                          hintText: "Numéro de téléphone",
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(
                            Icons.phone,
                          ), // Optional: Adds a border // Placeholder text
                        ),
                      ),
                      const SizedBox(height: 20),
                      TextField(
                        controller: passwordController,
                        obscureText: true,
                        decoration: const InputDecoration(
                          contentPadding: EdgeInsets.symmetric(
                            vertical: 10,
                            horizontal: 10,
                          ),
                          hintText: "Mot de passe",
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(
                            Icons.lock,
                          ), // Optional: Adds a border // Placeholder text
                        ),
                      ),
                      const SizedBox(height: 20),
                      ElevatedButton(
                        onPressed: _login,
                        style: ButtonStyle(
                          backgroundColor: MaterialStateProperty.all(
                            const Color(0xFFf11477),
                          ), // Change button color
                          shape: MaterialStateProperty.all(
                            RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(5),
                            ),
                          ),
                          minimumSize: MaterialStateProperty.all(
                            Size(MediaQuery.of(context).size.width * 1, 50),
                          ), // Width & Height
                        ),
                        child: const Text(
                          "Connexion",
                          style: button.customStyle,
                        ),
                      ),
                      TextButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => Inscription(),
                            ),
                          );
                        },
                        child: const Text(
                          "Créer un compte",
                          style: TextStyle(
                            color: Color(0xFF1170AD),
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      TextButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => MotDePasseOublie(),
                            ),
                          );
                        },
                        child: const Text(
                          "J'ai oublié mon mot de passe",
                          style: TextStyle(
                            color: Color(0xFF1170AD),
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class blueTitle {
  static const TextStyle customStyle = TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.w900,
    color: Color(0xFF1170AD),
  );
}

class button {
  static const TextStyle customStyle = TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.w700,
    color: Colors.white,
  );
}
