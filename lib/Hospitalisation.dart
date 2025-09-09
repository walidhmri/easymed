import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:easy_malade/AppBar.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'Hospitalisation_success.dart';

class Hospitalisation extends StatefulWidget {
  const Hospitalisation({super.key});

  @override
  State<Hospitalisation> createState() => _HospitalisationState();
}

class _HospitalisationState extends State<Hospitalisation> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController ageController = TextEditingController();
  final TextEditingController besoinsSpecifiquesController =
      TextEditingController();
  final TextEditingController horaireDebutController = TextEditingController();
  final TextEditingController horaireFinController = TextEditingController();
  final TextEditingController dureeJoursController =
      TextEditingController(); // Nouveau contrôleur pour le nombre de jours

  String? _sexe;

  Future<void> _submitRequest() async {
    if (_formKey.currentState!.validate()) {
      final prefs = await SharedPreferences.getInstance();
      String? userId = prefs.getString("user_id");

      if (userId == null) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Utilisateur non connecté.")),
          );
        }
        return;
      }

      try {
        await FirebaseFirestore.instance
            .collection('demandes_hospitalisation')
            .add({
              'userId': userId,
              'sexe': _sexe,
              'age': ageController.text,
              'besoinsSpecifiques': besoinsSpecifiquesController.text,
              'duree_en_jours':
                  dureeJoursController.text, // Nouveau champ pour la durée
              'horaire_debut': horaireDebutController.text,
              'horaire_fin': horaireFinController.text,
              'createdAt': FieldValue.serverTimestamp(),
              'status': 'pending',
            });

        if (context.mounted) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => Hospitalisation_success()),
          );
        }
      } catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("Erreur lors de l'envoi de la demande: $e")),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(showBackButton: true),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Demande d'hospitalisation",
                  style: TextStyle(
                    color: Color(0xFFF11477),
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 20),
                const Text(
                  "Sexe",
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                Row(
                  children: [
                    Expanded(
                      child: RadioListTile<String>(
                        title: const Text("Homme"),
                        value: "Homme",
                        groupValue: _sexe,
                        onChanged: (value) {
                          setState(() => _sexe = value);
                        },
                      ),
                    ),
                    Expanded(
                      child: RadioListTile<String>(
                        title: const Text("Femme"),
                        value: "Femme",
                        groupValue: _sexe,
                        onChanged: (value) {
                          setState(() => _sexe = value);
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                TextFormField(
                  controller: ageController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: "Âge",
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return "Veuillez entrer l'âge";
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 20),
                TextFormField(
                  controller: besoinsSpecifiquesController,
                  maxLines: 4,
                  decoration: const InputDecoration(
                    labelText: "Besoins spécifiques / Handicaps",
                    border: OutlineInputBorder(),
                    hintText: "Décrivez vos besoins ou conditions spécifiques",
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return "Veuillez décrire vos besoins";
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 20),
                // Nouveau champ pour la durée
                TextFormField(
                  controller: dureeJoursController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: "Durée de l'hospitalisation (en jours)",
                    border: OutlineInputBorder(),
                    hintText: "Exemple: 7",
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return "Veuillez entrer le nombre de jours";
                    }
                    if (int.tryParse(value) == null) {
                      return "Veuillez entrer un nombre valide";
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 20),
                const Text(
                  "Horaires",
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: horaireDebutController,
                        decoration: const InputDecoration(
                          labelText: "De",
                          hintText: "ex: 08:00",
                          border: OutlineInputBorder(),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return "Obligatoire";
                          }
                          return null;
                        },
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: TextFormField(
                        controller: horaireFinController,
                        decoration: const InputDecoration(
                          labelText: "À",
                          hintText: "ex: 18:00",
                          border: OutlineInputBorder(),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return "Obligatoire";
                          }
                          return null;
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 40),
                Center(
                  child: SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 15),
                        backgroundColor: const Color(0xFF1170AD),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                      onPressed: _submitRequest,
                      child: const Text(
                        "Confirmer la demande",
                        style: TextStyle(fontSize: 16, color: Colors.white),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
