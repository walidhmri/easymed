import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:convert';
import 'package:crypto/crypto.dart';

import 'Verification_tel.dart';
import 'Connexion.dart';

class Inscription extends StatefulWidget {
  const Inscription({super.key});

  @override
  _InscriptionState createState() => _InscriptionState();
}

class _InscriptionState extends State<Inscription> {
  bool _isLoading = false; // État de chargement

  TextEditingController nameController = TextEditingController();
  TextEditingController telController = TextEditingController();
  TextEditingController passwordController = TextEditingController();

  // Firestore instance
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  @override
  void dispose() {
    nameController.dispose();
    telController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  String hashPassword(String password) {
    var bytes = utf8.encode(password);
    var digest = sha256.convert(bytes);
    return digest.toString();
  }

  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<void> _saveUserData() async {
    setState(() {
      _isLoading = true;
    });
    String name = nameController.text.trim();
    String phone = "+213${telController.text.trim()}";
    String password = passwordController.text.trim();
    String hashedPassword = hashPassword(password);
    if (name.isEmpty || phone.isEmpty || password.isEmpty) {
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Tous les champs doivent être remplis")),
      );
      return;
    }
    if (password.length < 6) {
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Tous les champs doivent être remplis")),
      );
      return;
    }

    try {
      // Check if the phone number already exists
      QuerySnapshot querySnapshot = await _firestore
          .collection("users")
          .where("phone", isEqualTo: phone)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        setState(() {
          _isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Ce numéro est déjà utilisé.")),
        );

        return;
      }
      // Envoyer le code de vérification
      await _auth.verifyPhoneNumber(
        phoneNumber: phone,
        verificationCompleted: (PhoneAuthCredential credential) async {
          await _auth.signInWithCredential(credential);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Connexion automatique réussie !")),
          );
          setState(() {
            _isLoading = false;
          });
        },
        verificationFailed: (FirebaseAuthException e) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("Échec de l'envoi du code : ${e.message}")),
          );
        },
        codeSent: (String verificationId, int? resendToken) {
          setState(() {
            _isLoading = false;
          });
          // Aller vers l'écran de vérification
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => Verification_tel(
                verificationId: verificationId,
                phone: phone,
                name: name,
                hashedPassword: hashedPassword,
              ),
            ),
          );
        },
        codeAutoRetrievalTimeout: (String verificationId) {
          setState(() {
            _isLoading = false;
          });
        },
      );
    } catch (e) {
      print("Error saving data: $e");

      setState(() {
        _isLoading = false;
      });
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
              const Text("Inscription", style: blueTitle.customStyle),
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
                        controller: nameController,
                        decoration: const InputDecoration(
                          contentPadding: EdgeInsets.symmetric(
                            vertical: 10,
                            horizontal: 10,
                          ),
                          hintText: "Nom et prénom",
                          prefixIcon: Icon(Icons.person),
                          border:
                              OutlineInputBorder(), // Optional: Adds a border // Placeholder text
                        ),
                      ),
                      const SizedBox(height: 20),
                      TextField(
                        controller: telController,
                        keyboardType: TextInputType.phone,
                        decoration: const InputDecoration(
                          contentPadding: EdgeInsets.symmetric(
                            vertical: 10,
                            horizontal: 10,
                          ),
                          prefixIcon: Padding(
                            padding: const EdgeInsets.only(left: 10, right: 8),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: const [
                                Icon(Icons.phone), // couleur manuelle
                                SizedBox(width: 6),
                                Text(
                                  '+213',
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: Colors.black87,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          hintText: "Numéro de téléphone",
                          border: OutlineInputBorder(),
                          // Optional: Adds a border // Placeholder text
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
                      _isLoading
                          ? const CircularProgressIndicator(
                              color: Color(0xFFf11477),
                            )
                          : ElevatedButton(
                              onPressed: _saveUserData,
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
                                  Size(
                                    MediaQuery.of(context).size.width * 1,
                                    50,
                                  ),
                                ), // Width & Height
                              ),
                              child: const Text(
                                "Je m'inscris",
                                style: button.customStyle,
                              ),
                            ),
                      TextButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => Connexion(),
                            ),
                          );
                        },
                        child: const Text(
                          "Se connecter",
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
