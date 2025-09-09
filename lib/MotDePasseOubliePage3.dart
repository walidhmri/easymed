import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:convert';
import 'package:crypto/crypto.dart';

class MotDePasseOubliePage3 extends StatelessWidget {
  final TextEditingController passwordController = TextEditingController();

  MotDePasseOubliePage3({super.key});

  Future<void> _updatePassword(BuildContext context) async {
    final newPassword = passwordController.text.trim();
    final user = FirebaseAuth.instance.currentUser;

    if (newPassword.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Veuillez entrer un mot de passe.")),
      );
      return;
    }

    if (user == null || user.phoneNumber == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Aucun utilisateur connecté.")),
      );
      return;
    }

    final phone = user.phoneNumber;

    try {
      // 🔥 Met à jour dans la collection "users"
      final snapshot = await FirebaseFirestore.instance
          .collection('users')
          .where('phone', isEqualTo: phone)
          .get();

      if (snapshot.docs.isNotEmpty) {
        for (final doc in snapshot.docs) {
          final hashedPassword = sha256
              .convert(utf8.encode(newPassword))
              .toString();
          await doc.reference.update({'password': hashedPassword});
        }

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Mot de passe mis à jour avec succès !"),
          ),
        );

        // 🔁 Retour à la première page
        Navigator.popUntil(context, (route) => route.isFirst);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Utilisateur introuvable.")),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Erreur : ${e.toString()}")));
    }
  }

  void _showConfirmationDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Confirmer"),
        content: const Text(
          "Voulez-vous vraiment changer votre mot de passe ?",
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(), // Fermer
            child: const Text("Annuler"),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop(); // Fermer la popup
              _updatePassword(context); // Mettre à jour
            },
            child: const Text("Confirmer"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          children: [
            // 🔹 Bandeau supérieur avec image et logo
            Container(
              width: MediaQuery.of(context).size.width,
              height: MediaQuery.of(context).size.height * 0.35,
              decoration: const BoxDecoration(
                borderRadius: BorderRadius.only(
                  bottomRight: Radius.circular(50),
                ),
                image: DecorationImage(
                  image: AssetImage("assets/images/gloves.jpg"),
                  fit: BoxFit.cover,
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

            const Text(
              "Mettez à jour votre mot de passe",
              style: blueTitle.customStyle,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 14),

            Padding(
              padding: EdgeInsets.symmetric(
                horizontal: MediaQuery.of(context).size.width * 0.08,
              ),
              child: Column(
                children: [
                  const Text(
                    "Entrez votre nouveau mot de passe ci-dessous",
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 20),

                  TextField(
                    controller: passwordController,
                    obscureText: true,
                    decoration: const InputDecoration(
                      labelText: "Nouveau mot de passe",
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.lock),
                    ),
                  ),

                  const SizedBox(height: 20),

                  ElevatedButton(
                    onPressed: () => _showConfirmationDialog(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFf11477),
                      minimumSize: Size(MediaQuery.of(context).size.width, 50),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(5),
                      ),
                    ),
                    child: const Text("Valider", style: button.customStyle),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// 🔹 Styles
class blueTitle {
  static const TextStyle customStyle = TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.w900,
    color: Color(0xFF1170AD),
  );
}

class button {
  static const TextStyle customStyle = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w700,
    color: Colors.white,
  );
}
