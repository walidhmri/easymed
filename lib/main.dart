import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'Connexion.dart';
import 'Home.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'user_provider.dart'; // Importation de la classe séparée

import 'firebase_options.dart';
import 'Home.dart';
import 'Connexion.dart';
import 'Demarrage.dart';
import 'package:firebase_app_check/firebase_app_check.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  await FirebaseAppCheck.instance.activate(
    androidProvider: AndroidProvider.debug,
  );

  runApp(
    ChangeNotifierProvider(
      create: (context) => UserProvider()..fetchUserData(),
      child: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Minimal',
      home: Demarrage(), // Utilisation de la classe séparée
    );
  }
}
