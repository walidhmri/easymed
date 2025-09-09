import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';

class UserProvider with ChangeNotifier {
  String _userId = "";
  String _name = "...";
  String _phone = "";
  String _profileImage = "";
  String _type = "";

  // 🔸 Getters
  String get userId => _userId;
  String get name => _name;
  String get phone => _phone;
  String get profileImage => _profileImage;
  String get type => _type;

  // 🔹 Récupère les données utilisateur depuis Firestore via userId stocké en SharedPreferences
  Future<void> fetchUserData() async {
    final prefs = await SharedPreferences.getInstance();
    _userId = prefs.getString("user_id") ?? "";

    if (_userId.isNotEmpty) {
      DocumentSnapshot doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(_userId)
          .get();

      if (doc.exists) {
        final data = doc.data() as Map<String, dynamic>;

        _name = data['name'] ?? "Nom inconnu";
        _phone = data['phone'] ?? "";
        _profileImage = data['profileImage'] ?? "";
        _type = data['type'] ?? "";
        notifyListeners(); // 🔄 Notifie les widgets qui écoutent ce provider
      }
    }
  }

  void setName(String name) {
    _name = name;
    notifyListeners();
  }

  void setPhone(String phone) {
    _phone = phone;
    notifyListeners();
  }

  void setProfileImage(String image) {
    _profileImage = image;
    notifyListeners();
  }
}
