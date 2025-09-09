import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'Choisir_photo.dart'; // ← adapte le nom si besoin

class Verification_tel extends StatefulWidget {
  final String verificationId;
  final String phone;
  final String name;
  final String hashedPassword;

  const Verification_tel({
    super.key,
    required this.verificationId,
    required this.phone,
    required this.name,
    required this.hashedPassword,
  });

  @override
  _VerificationScreenState createState() => _VerificationScreenState();
}

class _VerificationScreenState extends State<Verification_tel> {
  bool isLoading = false;

  final TextEditingController codeController = TextEditingController();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> _verifyCode() async {
    String code = codeController.text.trim();
    if (code.isEmpty || code.length < 6) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Entrez un code valide")));
      return;
    }
    setState(() {
      isLoading = true;
    });
    try {
      // ✅ Étape 1 : Vérifier le code
      PhoneAuthCredential credential = PhoneAuthProvider.credential(
        verificationId: widget.verificationId,
        smsCode: code,
      );

      // ✅ Authentification avec Firebase
      UserCredential userCredential = await _auth.signInWithCredential(
        credential,
      );

      String uid = userCredential.user!.uid;

      // ✅ Étape 2 : Enregistrer dans Firestore avec le même UID
      await _firestore.collection("users").doc(uid).set({
        "name": widget.name,
        "phone": widget.phone,
        "password": widget.hashedPassword,
        "createdAt": FieldValue.serverTimestamp(),
        "profileImage": "",
      });

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Inscription réussie !")));

      // ✅ Rediriger vers Choisir_photo avec l’UID
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString("user_id", uid);
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => Choisir_photo(userId: uid)),
      );
    } catch (e) {
      debugPrint("Erreur lors de la vérification ou Firestore: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Code invalide ou erreur interne")),
      );
    } finally {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
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
              const Text("Vérification du code", style: blueTitle.customStyle),
              const SizedBox(height: 20),
              Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: MediaQuery.of(context).size.width * 0.08,
                ),
                child: Column(
                  children: [
                    Text(
                      "Un code a été envoyé à ${widget.phone}",
                      style: const TextStyle(fontSize: 16),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 20),
                    TextField(
                      controller: codeController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        contentPadding: EdgeInsets.symmetric(
                          vertical: 10,
                          horizontal: 10,
                        ),
                        labelText: "Entrez le code",
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.lock),
                      ),
                    ),
                    const SizedBox(height: 20),
                    isLoading
                        ? const CircularProgressIndicator(
                            color: Color(0xFFf11477),
                          )
                        : ElevatedButton(
                            onPressed: _verifyCode,
                            style: ButtonStyle(
                              backgroundColor: MaterialStateProperty.all(
                                Color(0xFFf11477),
                              ),
                              shape: MaterialStateProperty.all(
                                RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(5),
                                ),
                              ),
                              minimumSize: MaterialStateProperty.all(
                                Size(MediaQuery.of(context).size.width * 1, 50),
                              ),
                            ),
                            child: const Text(
                              "Vérifier",
                              style: button.customStyle,
                            ),
                          ),
                  ],
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
