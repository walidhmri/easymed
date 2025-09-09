import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class UpdateScreen extends StatelessWidget {
  final String updateUrl;

  const UpdateScreen({Key? key, required this.updateUrl}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white, // Couleur de fond changée en blanc
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.system_update_alt,
                size: 100,
                color: Color(0xFF1170AD), // Couleur de l'icône changée en bleu
              ),
              const SizedBox(height: 20),
              const Text(
                'Mise à jour obligatoire',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Color(0xFF1170AD), // Couleur du texte changée en bleu
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 10),
              const Text(
                'Une nouvelle version de l\'application est disponible. Veuillez la télécharger pour continuer.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.black54,
                  fontSize: 16,
                ), // Couleur du texte changée en gris foncé
              ),
              const SizedBox(height: 40),
              ElevatedButton(
                onPressed: () async {
                  if (await canLaunchUrl(Uri.parse(updateUrl))) {
                    await launchUrl(
                      Uri.parse(updateUrl),
                      mode: LaunchMode.externalApplication,
                    );
                  } else {
                    // Gérer l'erreur si l'URL ne peut pas être lancée.
                    print('Impossible de lancer l\'URL : $updateUrl');
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(
                    0xFFF11477,
                  ), // Conserve la couleur rose du bouton
                  padding: const EdgeInsets.symmetric(
                    horizontal: 50,
                    vertical: 15,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
                child: const Text(
                  'Mettre à jour maintenant',
                  style: TextStyle(
                    fontSize: 18,
                    color: Colors.white,
                  ), // Conserve la couleur blanche du texte
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
