import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'Home.dart';

class Choisir_photo extends StatefulWidget {
  final String userId;

  const Choisir_photo({super.key, required this.userId});

  @override
  State<Choisir_photo> createState() => _Choisir_photoState();
}

class _Choisir_photoState extends State<Choisir_photo> {
  File? _selectedImage;
  bool _uploading = false;

  final picker = ImagePicker();

  Future<void> _pickImage(ImageSource source) async {
    final pickedFile = await picker.pickImage(source: source, imageQuality: 70);
    if (pickedFile != null) {
      setState(() {
        _selectedImage = File(pickedFile.path);
      });
    }
  }

  Future<void> _uploadImage() async {
    if (_selectedImage == null) return;

    setState(() {
      _uploading = true;
    });

    try {
      final storageRef = FirebaseStorage.instance.ref().child(
        'profile_images/${DateTime.now().millisecondsSinceEpoch}.jpg',
      );
      await storageRef.putFile(_selectedImage!);
      final downloadUrl = await storageRef.getDownloadURL();

      final userId = widget.userId;

      await FirebaseFirestore.instance.collection("users").doc(userId).set({
        "profileImage": downloadUrl,
      }, SetOptions(merge: true));

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Photo enregistrée avec succès.")),
      );

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => Home()),
      );
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Erreur : ${e.toString()}")));
    } finally {
      setState(() {
        _uploading = false;
      });
    }
  }

  void _showImageSourceDialog() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Choisir une source"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.camera),
              title: const Text("Caméra"),
              onTap: () {
                Navigator.pop(context);
                _pickImage(ImageSource.camera);
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo),
              title: const Text("Galerie"),
              onTap: () {
                Navigator.pop(context);
                _pickImage(ImageSource.gallery);
              },
            ),
          ],
        ),
      ),
    );
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
              const Text("Ajouter une photo", style: blueTitle.customStyle),
              const SizedBox(height: 20),
              GestureDetector(
                onTap: _showImageSourceDialog,
                child: CircleAvatar(
                  radius: 60,
                  backgroundImage: _selectedImage != null
                      ? FileImage(_selectedImage!)
                      : null,
                  backgroundColor: const Color(0xFF1170AD),
                  child: _selectedImage == null
                      ? const Icon(
                          Icons.camera_alt,
                          size: 40,
                          color: Colors.white,
                        )
                      : null,
                ),
              ),
              const SizedBox(height: 30),
              Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: MediaQuery.of(context).size.width * 0.08,
                ),
                child: ElevatedButton(
                  onPressed: _selectedImage != null && !_uploading
                      ? _uploadImage
                      : null,
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
                      Size(MediaQuery.of(context).size.width * 1, 50),
                    ),
                  ),
                  child: _uploading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text(
                          "Enregistrer l'image",
                          style: button.customStyle,
                        ),
                ),
              ),
              TextButton(
                onPressed: () {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (context) => Home()),
                  );
                },
                child: const Text(
                  "Passer",
                  style: TextStyle(
                    color: Colors.grey,
                    fontSize: 14,
                    decoration: TextDecoration.underline,
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
