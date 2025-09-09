import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'MotDePasseOubliePage2.dart';

class MotDePasseOublie extends StatelessWidget {
  final TextEditingController phoneController = TextEditingController();

  MotDePasseOublie({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          children: [
            // 🔹 Image en haut avec le logo, comme Connexion
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
              "Récupération de mot de passe",
              style: blueTitle.customStyle,
            ),
            const SizedBox(height: 14),

            Padding(
              padding: EdgeInsets.symmetric(
                horizontal: MediaQuery.of(context).size.width * 0.08,
              ),
              child: Column(
                children: [
                  TextField(
                    controller: phoneController,
                    keyboardType: TextInputType.phone,
                    decoration: const InputDecoration(
                      contentPadding: EdgeInsets.symmetric(
                        vertical: 10,
                        horizontal: 10,
                      ),
                      prefixText: '+213',
                      hintText: "Numéro de téléphone",
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.phone),
                    ),
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () async {
                      final phoneNumber = "+213${phoneController.text.trim()}";
                      // Désactivation de reCAPTCHA pour les tests
                      await FirebaseAuth.instance.setSettings(
                        appVerificationDisabledForTesting: true,
                      );
                      await FirebaseAuth.instance.verifyPhoneNumber(
                        phoneNumber: phoneNumber,
                        verificationCompleted:
                            (PhoneAuthCredential credential) {},
                        verificationFailed: (FirebaseAuthException e) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text("Erreur : ${e.message}")),
                          );
                        },
                        codeSent: (String verificationId, int? resendToken) {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => MotDePasseOubliePage2(
                                verificationId: verificationId,
                              ),
                            ),
                          );
                        },
                        codeAutoRetrievalTimeout: (String verificationId) {},
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFf11477),
                    ),
                    child: const Text(
                      "Envoyer un code de récupération",
                      style: button.customStyle,
                    ),
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
