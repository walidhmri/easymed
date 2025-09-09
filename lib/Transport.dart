import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:easy_malade/user_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'Transport_2.dart';

class Transport extends StatefulWidget {
  const Transport({super.key});

  @override
  State<Transport> createState() => _TransportState();
}

class _TransportState extends State<Transport> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final TextEditingController observationController = TextEditingController();

  String userName = "... chargement";

  String userProfilePic = "...";
  String userPhone = "...";

  String userId = "";
  String? selectedTransport; // Stocke la sélection
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
        userId = storedUserId;
      });

      try {
        DocumentSnapshot userDoc = await FirebaseFirestore.instance
            .collection("users")
            .doc(userId)
            .get();

        if (userDoc.exists) {
          setState(() {
            userName = userDoc["name"];

            userProfilePic = userDoc["profileImage"];
          });
        }
      } catch (e) {
        setState(() {
          userName = "Erreur de chargement";

          userProfilePic = defaultAvatarUrl;
        });
      }
    } else {
      setState(() {
        userName = "Utilisateur non connecté";

        userProfilePic = defaultAvatarUrl;
      });
    }
  }

  final String defaultAvatarUrl =
      "https://firebasestorage.googleapis.com/v0/b/easy-med-c3f69.firebasestorage.app/o/profile_images%2Favatar-simple.jpg?alt=media&token=cbf516b6-ad37-4c50-852d-58f0b83564d5";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(60),
        child: AppBar(
          iconTheme: const IconThemeData(color: Colors.white),
          backgroundColor: Colors.transparent,
          elevation: 0,
          flexibleSpace: Container(
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/images/pink_header_3.png'),
                fit: BoxFit.cover,
                alignment: Alignment.bottomCenter,
              ),
            ),
          ),
          title: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Bonjour $userName",
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 2),
                  image: DecorationImage(
                    image: userProfilePic.startsWith('http')
                        ? NetworkImage(userProfilePic)
                        : AssetImage(userProfilePic) as ImageProvider,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 20),
            const Text(
              "Veuillez choisir le type de transport que vous cherchez",
              style: TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 20),
            RadioListTile<String>(
              title: const Text("Transport paramédicalisé"),
              value: "simple",
              groupValue: selectedTransport,
              onChanged: (value) {
                setState(() {
                  selectedTransport = value;
                });
              },
            ),
            RadioListTile<String>(
              title: const Text("Transport médicalisé"),
              value: "équipé",
              groupValue: selectedTransport,
              onChanged: (value) {
                setState(() {
                  selectedTransport = value;
                });
              },
            ),
            const SizedBox(height: 40),

            const Text(
              "Observation (facultatif)",
              style: TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: observationController,
              maxLines: 3,
              decoration: InputDecoration(
                border: OutlineInputBorder(),
                hintText:
                    "Veuillez indique tous type de détail que vous souhaitez partager avec le transporteur",
              ),
            ),
            const SizedBox(height: 20),
            Center(
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 15),
                    backgroundColor: const Color(
                      0xFF1170AD,
                    ), // Bleu personnalisé
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(4), // Radius 4
                    ),
                  ),
                  onPressed: () {
                    if (selectedTransport != null) {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => Transport2(
                            transportType: selectedTransport!,
                            observation: observationController.text.trim(),
                          ),
                        ),
                      );
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text(
                            "Veuillez sélectionner un type de transport.",
                          ),
                        ),
                      );
                    }
                  },
                  child: const Text(
                    "Confirmer",
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.white, // Texte blanc
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
