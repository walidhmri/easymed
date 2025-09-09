import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'MotDePasseOubliePage3.dart';

class MotDePasseOubliePage2 extends StatelessWidget {
  final String verificationId;

  MotDePasseOubliePage2({required this.verificationId, super.key});
  final TextEditingController codeController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          children: [
            // 🔹 Bandeau supérieur avec image
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

            // 🔹 Titre bleu
            const Text("Code de vérification", style: blueTitle.customStyle),

            const SizedBox(height: 14),

            Padding(
              padding: EdgeInsets.symmetric(
                horizontal: MediaQuery.of(context).size.width * 0.08,
              ),
              child: Column(
                children: [
                  const Text(
                    "Mettez le code envoyé à votre numéro de téléphone",
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 20),

                  // 🔹 Champ de code
                  TextField(
                    controller: codeController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: "Code",
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.lock),
                    ),
                  ),

                  const SizedBox(height: 20),

                  // 🔹 Bouton rose avec vérification du code
                  ElevatedButton(
                    onPressed: () async {
                      final code = codeController.text.trim();

                      if (code.isEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text(
                              "Veuillez entrer le code de vérification",
                            ),
                          ),
                        );
                        return;
                      }

                      try {
                        final credential = PhoneAuthProvider.credential(
                          verificationId: verificationId,
                          smsCode: code,
                        );

                        await FirebaseAuth.instance.signInWithCredential(
                          credential,
                        );

                        // ✅ Rediriger vers l'étape suivante
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => MotDePasseOubliePage3(),
                          ),
                        );
                      } on FirebaseAuthException catch (e) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text("Code invalide ou expiré"),
                          ),
                        );
                      } catch (e) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text("Une erreur est survenue"),
                          ),
                        );
                      }
                    },
                    style: ButtonStyle(
                      backgroundColor: MaterialStateProperty.all(
                        const Color(0xFFf11477),
                      ),
                      shape: MaterialStateProperty.all(
                        RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(5),
                        ),
                      ),
                      minimumSize: MaterialStateProperty.all(
                        Size(MediaQuery.of(context).size.width, 50),
                      ),
                    ),
                    child: const Text("Valider", style: button.customStyle),
                  ),

                  const SizedBox(height: 10),

                  // 🔹 Liens bleus
                  const Text(
                    "Renvoyer le code",
                    style: TextStyle(
                      color: Color(0xFF1170AD),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 5),
                  const Text(
                    "Changer le numéro de téléphone",
                    style: TextStyle(
                      color: Color(0xFF1170AD),
                      fontWeight: FontWeight.w600,
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

// 🔹 Style du titre bleu
class blueTitle {
  static const TextStyle customStyle = TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.w900,
    color: Color(0xFF1170AD),
  );
}

// 🔹 Style du texte de bouton
class button {
  static const TextStyle customStyle = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w700,
    color: Colors.white,
  );
}
