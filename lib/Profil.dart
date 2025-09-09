import 'package:easy_malade/user_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:crypto/crypto.dart';
import 'dart:convert';
import 'AppBar.dart'; // adapter si besoin
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

class Profil extends StatefulWidget {
  const Profil({super.key});

  @override
  State<Profil> createState() => _ProfilState();
}

class _ProfilState extends State<Profil> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  late String userId;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    final prefs = await SharedPreferences.getInstance();
    userId = prefs.getString("user_id") ?? '';

    if (userId.isNotEmpty) {
      DocumentSnapshot userDoc = await FirebaseFirestore.instance
          .collection("users")
          .doc(userId)
          .get();

      if (userDoc.exists) {
        nameController.text = userDoc["name"] ?? '';
        phoneController.text = userDoc["phone"] ?? '';

        // Met à jour le provider
        final userProvider = Provider.of<UserProvider>(context, listen: false);
        userProvider.setName(userDoc["name"] ?? '');
        userProvider.setPhone(userDoc["phone"] ?? '');
        userProvider.setProfileImage(userDoc["profileImage"] ?? '');
      }
    }
  }

  Future<void> updateUserData() async {
    try {
      final updatedName = nameController.text;
      final updatedPhone = phoneController.text;
      final updatedPassword = passwordController.text;

      final dataToUpdate = {"name": updatedName, "phone": updatedPhone};

      if (updatedPassword.isNotEmpty) {
        dataToUpdate["password"] = sha256
            .convert(utf8.encode(updatedPassword))
            .toString();
      }

      await FirebaseFirestore.instance
          .collection("users")
          .doc(userId)
          .update(dataToUpdate);

      // Mettre à jour le UserProvider
      final userProvider = Provider.of<UserProvider>(context, listen: false);
      userProvider.setName(updatedName);
      userProvider.setPhone(updatedPhone);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Profil mis à jour avec succès")),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Erreur lors de la mise à jour")),
      );
    }
  }

  Future<void> _pickAndUploadImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      final File file = File(pickedFile.path);
      final fileName = "images/$userId.jpg";

      try {
        final ref = FirebaseStorage.instance.ref().child(fileName);
        await ref.putFile(file);

        final imageUrl = await ref.getDownloadURL();

        await FirebaseFirestore.instance.collection("users").doc(userId).update(
          {"profileImage": imageUrl},
        );

        // Met à jour le UserProvider
        final userProvider = Provider.of<UserProvider>(context, listen: false);
        userProvider.setProfileImage(imageUrl);

        setState(() {}); // Pour recharger l'avatar affiché

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Photo de profil mise à jour")),
        );
      } catch (e) {
        print("Erreur d'upload : $e");
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Erreur lors de l'upload de l'image")),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context);

    return Scaffold(
      appBar: CustomAppBar(),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            const SizedBox(height: 20),
            Center(
              child: Stack(
                children: [
                  GestureDetector(
                    onTap: _pickAndUploadImage,
                    child: CircleAvatar(
                      radius: 50,
                      backgroundImage: userProvider.profileImage.isNotEmpty
                          ? NetworkImage(userProvider.profileImage)
                          : const AssetImage("assets/images/user.png")
                                as ImageProvider,
                    ),
                  ),
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: Container(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white,
                        border: Border.all(color: Colors.grey.shade300),
                      ),
                      padding: const EdgeInsets.all(4),
                      child: const Icon(
                        Icons.edit,
                        size: 20,
                        color: Color(0xFFF11477),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),
            TextFormField(
              controller: nameController,
              decoration: const InputDecoration(labelText: "Nom complet"),
            ),
            const SizedBox(height: 10),
            TextFormField(
              controller: phoneController,
              decoration: const InputDecoration(labelText: "Téléphone"),
              keyboardType: TextInputType.phone,
            ),
            const SizedBox(height: 10),
            TextFormField(
              controller: passwordController,
              decoration: const InputDecoration(
                labelText: "Nouveau mot de passe",
              ),
              obscureText: true,
            ),
            const SizedBox(height: 30),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFF11477),
                foregroundColor: Colors.white,
              ),
              onPressed: updateUserData,
              child: const Text("Enregistrer"),
            ),
          ],
        ),
      ),
    );
  }
}
