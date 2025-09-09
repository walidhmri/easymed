import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:easy_malade/AppBar.dart';
import 'package:easy_malade/user_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'Soins_medicaux_2.dart';

class Soins_medicaux extends StatefulWidget {
  const Soins_medicaux({super.key});

  @override
  State<Soins_medicaux> createState() => _Soins_medicauxState();
}

class _Soins_medicauxState extends State<Soins_medicaux> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final TextEditingController observationController = TextEditingController();
  final TextEditingController searchController = TextEditingController();
  final FocusNode _focusNode = FocusNode();

  List<Map<String, dynamic>> allSoins = [];
  List<String> filteredItems = [];
  List<String> selectedItems = [];
  Map<String, double> selectedPrices = {};
  bool showDropdown = false;
  bool isLoading = true;

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
    fetchSoins(); // Nouvelle fonction pour charger les données
    _focusNode.addListener(() {
      setState(() => showDropdown = _focusNode.hasFocus);
    });
  }

  // Fonction pour récupérer les soins et leurs prix depuis Firestore
  Future<void> fetchSoins() async {
    try {
      final doc = await FirebaseFirestore.instance
          .collection("prix")
          .doc("Soins")
          .get();

      if (doc.exists && doc.data() != null) {
        final data = doc.data() as Map<String, dynamic>;
        List<Map<String, dynamic>> loadedSoins = [];
        data.forEach((key, value) {
          double price = 0.0;
          if (value is num) {
            price = value.toDouble();
          } else if (value is String) {
            price = double.tryParse(value) ?? 0.0;
          }
          loadedSoins.add({'name': key, 'price': price});
        });

        setState(() {
          allSoins = loadedSoins;
          filteredItems = loadedSoins.map((c) => c['name'].toString()).toList();
          isLoading = false;
        });
      } else {
        setState(() {
          isLoading = false;
        });
      }
    } catch (e) {
      print("Erreur lors du chargement des soins: $e");
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
      filteredItems = allSoins
          .where((item) => item['name'].toLowerCase().contains(lowerQuery))
          .map((item) => item['name'].toString())
          .toList();
    });
  }

  Future<void> updateSelectedPrices() async {
    Map<String, double> updatedPrices = {};
    for (final item in selectedItems) {
      final soin = allSoins.firstWhere(
        (c) => c['name'] == item,
        orElse: () => {'name': item, 'price': 0.0},
      );
      updatedPrices[item] = soin['price'];
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
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 20),
                    const Text(
                      "Veuillez choisir le type de soin que vous cherchez",
                      style: TextStyle(fontSize: 16),
                    ),
                    const SizedBox(height: 10),
                    TextField(
                      focusNode: _focusNode,
                      controller: searchController,
                      onChanged: filterItems,
                      decoration: InputDecoration(
                        labelText: "Rechercher un service",
                        border: OutlineInputBorder(),
                        prefixIcon: const Icon(Icons.search),
                      ),
                    ),
                    const SizedBox(height: 5),
                    if (showDropdown)
                      Container(
                        constraints: const BoxConstraints(maxHeight: 200),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey.shade400),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Scrollbar(
                          thumbVisibility: true,
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
                      ),
                    const SizedBox(height: 20),
                    if (selectedItems.isNotEmpty)
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Divider(),
                          const Text(
                            "Récapitulatif :",
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Color(0xFFF11477),
                            ),
                          ),
                          const SizedBox(height: 10),
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
                                "Total :",
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
                        hintText:
                            "Veuillez indiquer tout type de détail que vous souhaitez partager avec le soignant",
                      ),
                    ),
                    const SizedBox(height: 20),
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
                          onPressed: () async {
                            if (selectedItems.isEmpty) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text(
                                    "Veuillez sélectionner au moins un type de soin",
                                  ),
                                ),
                              );
                              return;
                            }
                            await updateSelectedPrices();
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => Soins_medicaux_2(
                                  selectedSoins: selectedItems.join(', '),
                                  observation: observationController.text
                                      .trim(),
                                  price: selectedPrices.values
                                      .fold(0.0, (a, b) => a + b)
                                      .toStringAsFixed(2),
                                ),
                              ),
                            );
                          },
                          child: const Text(
                            "Confirmer",
                            style: TextStyle(fontSize: 16, color: Colors.white),
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
