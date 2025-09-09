import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:easy_malade/AppBar.dart';
import 'package:easy_malade/user_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'Analyses_medicales_2.dart';

class Analyses_medicales extends StatefulWidget {
  const Analyses_medicales({super.key});

  @override
  State<Analyses_medicales> createState() => _Analyses_medicalesState();
}

class _Analyses_medicalesState extends State<Analyses_medicales> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final TextEditingController observationController = TextEditingController();
  final TextEditingController searchController = TextEditingController();
  final FocusNode _focusNode = FocusNode();

  // Remplace les listes statiques
  List<Map<String, dynamic>> allAnalyses = [];
  List<String> filteredItems = [];
  List<String> selectedItems = [];
  Map<String, double> selectedPrices = {};

  bool showDropdown = false;
  bool isLoading = true; // Ajout d'un état de chargement

  String userName = "... chargement";
  String userProfilePic = "...";
  String userId = "";

  final String defaultAvatarUrl =
      "https://firebasestorage.googleapis.com/v0/b/easy-med-c3f69.firebasestorage.app/o/profile_images%2Favatar-simple.jpg?alt=media&token=cbf516b6-ad37-4c50-852d-58f0b83564d5";

  @override
  void initState() {
    super.initState();
    Provider.of<UserProvider>(context, listen: false).fetchUserData();
    getUserData();
    fetchAnalyses(); // Nouvelle fonction pour charger les données
    _focusNode.addListener(() {
      setState(() => showDropdown = _focusNode.hasFocus);
    });
  }

  // Fonction pour récupérer les analyses et leurs prix depuis Firestore
  Future<void> fetchAnalyses() async {
    try {
      final doc = await FirebaseFirestore.instance
          .collection("prix")
          .doc("Analyses")
          .get();

      if (doc.exists && doc.data() != null) {
        final data = doc.data() as Map<String, dynamic>;
        List<Map<String, dynamic>> loadedAnalyses = [];
        data.forEach((key, value) {
          double price = 0.0;
          if (value is num) {
            price = value.toDouble();
          } else if (value is String) {
            price = double.tryParse(value) ?? 0.0;
          }
          loadedAnalyses.add({'name': key, 'price': price});
        });

        setState(() {
          allAnalyses = loadedAnalyses;
          filteredItems = loadedAnalyses
              .map((c) => c['name'].toString())
              .toList();
          isLoading = false;
        });
      } else {
        setState(() {
          isLoading = false;
        });
      }
    } catch (e) {
      print("Erreur lors du chargement des analyses: $e");
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> getUserData() async {
    final prefs = await SharedPreferences.getInstance();
    String? storedUserId = prefs.getString("user_id");

    if (storedUserId != null) {
      setState(() => userId = storedUserId);
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
      } catch (_) {
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

  void filterItems(String query) {
    final lowerQuery = query.toLowerCase();
    setState(() {
      filteredItems = allAnalyses
          .where((item) => item['name'].toLowerCase().contains(lowerQuery))
          .map((item) => item['name'].toString())
          .toList();
    });
  }

  // Met à jour les prix des éléments sélectionnés
  Future<void> updateSelectedPrices() async {
    Map<String, double> updatedPrices = {};
    for (final item in selectedItems) {
      final analysis = allAnalyses.firstWhere(
        (c) => c['name'] == item,
        orElse: () => {'name': item, 'price': 0.0},
      );
      updatedPrices[item] = analysis['price'];
    }
    setState(() => selectedPrices = updatedPrices);
  }

  void removeItem(String itemToRemove) {
    setState(() {
      selectedItems.remove(itemToRemove);
      selectedPrices.remove(itemToRemove);
    });
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
        setState(() => showDropdown = false);
      },
      child: Scaffold(
        key: _scaffoldKey,
        appBar: CustomAppBar(showBackButton: true),
        body: isLoading
            ? const Center(child: CircularProgressIndicator())
            : SingleChildScrollView(
                // Ajout d'un SingleChildScrollView pour éviter les erreurs de débordement
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 20),
                    const Text(
                      "Veuillez choisir les analyses médicales",
                      style: TextStyle(fontSize: 16),
                    ),
                    const SizedBox(height: 10),
                    TextField(
                      focusNode: _focusNode,
                      controller: searchController,
                      onChanged: filterItems,
                      decoration: const InputDecoration(
                        labelText: "Rechercher vos analyses",
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.search),
                      ),
                    ),
                    if (showDropdown)
                      Container(
                        constraints: const BoxConstraints(maxHeight: 200),
                        child: ListView.builder(
                          shrinkWrap: true,
                          itemCount: filteredItems.length,
                          itemBuilder: (context, index) {
                            final item = filteredItems[index];
                            return ListTile(
                              title: Text(item),
                              onTap: () async {
                                if (!selectedItems.contains(item)) {
                                  selectedItems.add(item);
                                  await updateSelectedPrices();
                                }
                                searchController.clear();
                                FocusScope.of(context).unfocus();
                                setState(() => showDropdown = false);
                              },
                            );
                          },
                        ),
                      ),
                    const SizedBox(height: 40),
                    if (selectedItems.isNotEmpty)
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            "Récapitulatif des analyses choisies:",
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Color(0xFFF11477),
                            ),
                          ),
                          const SizedBox(height: 10),
                          // Affichage sans défilement
                          ...selectedItems.map(
                            (item) => Padding(
                              padding: const EdgeInsets.only(bottom: 8.0),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Expanded(child: Text(item)),
                                  Text(
                                    "${selectedPrices[item]?.toStringAsFixed(2) ?? "..."} DA",
                                  ),
                                  IconButton(
                                    icon: const Icon(
                                      Icons.close,
                                      size: 16,
                                      color: Colors.red,
                                    ),
                                    onPressed: () => removeItem(item),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const Divider(),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text(
                                "Total:",
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFFF11477),
                                ),
                              ),
                              Text(
                                selectedPrices.values
                                        .fold(0.0, (a, b) => a + b)
                                        .toStringAsFixed(2) +
                                    " DA",
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 20),
                        ],
                      ),
                    const Text(
                      "Observation (facultatif)",
                      style: TextStyle(fontSize: 16),
                    ),
                    const SizedBox(height: 10),
                    TextField(
                      controller: observationController,
                      maxLines: 3,
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        hintText: "Détail à partager avec le soignant",
                      ),
                    ),
                    const SizedBox(height: 20),
                    Center(
                      child: SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF1170AD),
                            padding: const EdgeInsets.symmetric(vertical: 15),
                          ),
                          onPressed: () async {
                            if (selectedItems.isEmpty) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text(
                                    "Veuillez sélectionner au moins une analyse",
                                  ),
                                ),
                              );
                              return;
                            }
                            await updateSelectedPrices();
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => Analyses_medicales_2(
                                  analyses: selectedItems.join(', '),
                                  price: selectedPrices.values
                                      .fold(0.0, (a, b) => a + b)
                                      .toStringAsFixed(2),
                                  observation: observationController.text
                                      .trim(),
                                ),
                              ),
                            );
                          },
                          child: const Text(
                            "Confirmer",
                            style: TextStyle(color: Colors.white, fontSize: 16),
                          ),
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
