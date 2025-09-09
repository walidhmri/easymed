import 'package:flutter/material.dart';

class Equipement extends StatelessWidget {
  const Equipement({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(60), // Hauteur du header
        child: AppBar(
          iconTheme: const IconThemeData(
            color: Colors
                .white, // Changer la couleur de l'icône de retour en blanc
          ),
          backgroundColor:
              Colors.transparent, // Transparent pour voir l’image de fond
          elevation: 0, // Supprime l'ombre
          flexibleSpace: Container(
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/images/pink_header_3.png'),
                fit: BoxFit.cover, // Couvre tout l’espace
                alignment: Alignment.bottomCenter, // Centre le bas de l’image
              ),
            ),
          ),
          title: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Texte centré
              const Text(
                "Bonjour, [Utilisateur]",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),

              // Avatar à droite
              Container(
                width: 50, // Taille de l’avatar
                height: 50,
                decoration: BoxDecoration(
                  shape: BoxShape.circle, // Rend l’image ronde
                  border: Border.all(
                      color: Colors.white, width: 2), // Bordure blanche
                  image: const DecorationImage(
                    image: AssetImage("assets/images/avatar.jpg"),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      body: const Center(
        child: Text("Équipements"),
      ),
    );
  }
}
