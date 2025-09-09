import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:easy_malade/AppBar.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'Garde_malade_success.dart';

class Garde_malade extends StatefulWidget {
  const Garde_malade({super.key});

  @override
  State<Garde_malade> createState() => _Garde_maladeState();
}

enum Duree { uneJournee, leWeekend, certainNombreDeJours, tousLesJours }

class _Garde_maladeState extends State<Garde_malade> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController ageController = TextEditingController();
  final TextEditingController besoinsSpecifiquesController =
      TextEditingController();
  final TextEditingController horaireDebutController = TextEditingController();
  final TextEditingController horaireFinController = TextEditingController();

  String? _sexe;
  Duree? _duree = Duree.uneJournee;
  List<DateTime> _selectedDates = [];

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

      if (_selectedDates.isEmpty && _duree == Duree.uneJournee) {
        // Handle case where user selects "Une journée" but no date
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Veuillez sélectionner une date.")),
          );
        }
        return;
      }

      try {
        String dureeText;
        List<String> joursSelectionnes = [];

        switch (_duree) {
          case Duree.uneJournee:
            dureeText = "Une journée";
            if (_selectedDates.isNotEmpty) {
              joursSelectionnes = [_selectedDates.first.toIso8601String()];
            }
            break;
          case Duree.leWeekend:
            dureeText = "Le weekend";
            break;
          case Duree.certainNombreDeJours:
            dureeText = "Un certain nombre de jours";
            joursSelectionnes = _selectedDates
                .map((d) => d.toIso8601String())
                .toList();
            break;
          case Duree.tousLesJours:
            dureeText = "Tous les jours";
            break;
          default:
            dureeText = "Non spécifié";
        }

        await FirebaseFirestore.instance
            .collection('demandes_garde_malade')
            .add({
              'userId': userId,
              'sexe': _sexe,
              'age': ageController.text,
              'besoinsSpecifiques': besoinsSpecifiquesController.text,
              'duree': dureeText,
              'jours_selectionnes': joursSelectionnes,
              'horaire_debut': horaireDebutController.text,
              'horaire_fin': horaireFinController.text,
              'createdAt': FieldValue.serverTimestamp(),
              'status': 'pending',
            });

        if (context.mounted) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => Garde_malade_success()),
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

  Future<void> _selectDates() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      helpText: 'Sélectionner des jours',
      cancelText: 'Annuler',
      confirmText: 'Confirmer',
    );
    if (picked != null) {
      setState(() {
        if (_duree == Duree.uneJournee) {
          _selectedDates = [picked];
        } else {
          _selectedDates.add(picked);
        }
      });
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
                  "Demande de garde malade",
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
                const Text(
                  "Durée de la garde",
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                RadioListTile<Duree>(
                  title: const Text("Une journée"),
                  value: Duree.uneJournee,
                  groupValue: _duree,
                  onChanged: (value) {
                    setState(() {
                      _duree = value;
                      _selectedDates.clear();
                    });
                  },
                ),
                RadioListTile<Duree>(
                  title: const Text("Le weekend (Vendredi & Samedi)"),
                  value: Duree.leWeekend,
                  groupValue: _duree,
                  onChanged: (value) {
                    setState(() => _duree = value);
                  },
                ),
                RadioListTile<Duree>(
                  title: const Text("Un certain nombre de jours"),
                  value: Duree.certainNombreDeJours,
                  groupValue: _duree,
                  onChanged: (value) {
                    setState(() => _duree = value);
                  },
                ),
                RadioListTile<Duree>(
                  title: const Text("Tous les jours"),
                  value: Duree.tousLesJours,
                  groupValue: _duree,
                  onChanged: (value) {
                    setState(() => _duree = value);
                  },
                ),
                const SizedBox(height: 10),
                if (_duree == Duree.uneJournee ||
                    _duree == Duree.certainNombreDeJours)
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "Jours sélectionnés :",
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      Wrap(
                        spacing: 8.0,
                        children: _selectedDates
                            .map(
                              (date) => Chip(
                                label: Text(
                                  DateFormat('d MMMM y').format(date),
                                ),
                                onDeleted: () {
                                  setState(() {
                                    _selectedDates.remove(date);
                                  });
                                },
                              ),
                            )
                            .toList(),
                      ),
                      const SizedBox(height: 10),
                      Center(
                        child: OutlinedButton.icon(
                          icon: const Icon(Icons.calendar_today),
                          label: Text(
                            _duree == Duree.uneJournee
                                ? "Sélectionner une date"
                                : "Ajouter un jour",
                          ),
                          onPressed: _selectDates,
                        ),
                      ),
                    ],
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
