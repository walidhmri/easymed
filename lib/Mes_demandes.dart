import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:easy_malade/user_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'AppBar.dart';

import 'Demande.dart';

class Mes_demandes extends StatefulWidget {
  const Mes_demandes({super.key});
  @override
  _Mes_demandesState createState() => _Mes_demandesState();
}

class _Mes_demandesState extends State<Mes_demandes> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  String userId = '';
  bool isLoading = true;
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<UserProvider>(context, listen: false).fetchUserData();
    });
  }

  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context);
    final userId = userProvider.userId;
    return Scaffold(
      key: _scaffoldKey,
      appBar: CustomAppBar(),
      body: userId.isEmpty
          ? const Center(child: Text("Chargement des demandes..."))
          : Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Center(
                  child: Padding(
                    padding: EdgeInsets.fromLTRB(16, 16, 16, 0),
                    child: Text("Mes demandes", style: blueTitle.customStyle),
                  ),
                ),
                const SizedBox(height: 8),
                Expanded(
                  child: StreamBuilder<QuerySnapshot>(
                    stream: FirebaseFirestore.instance
                        .collection('demandes')
                        .where('maladeId', isEqualTo: userId)
                        .where('status', isEqualTo: 'validé_malade')
                        .snapshots(),
                    builder: (context, snapshot) {
                      if (!snapshot.hasData) {
                        return const Center(child: CircularProgressIndicator());
                      }

                      final demandes = snapshot.data!.docs;

                      if (demandes.isEmpty) {
                        return const Center(
                          child: Text("Aucune demande terminée."),
                        );
                      }

                      return ListView.builder(
                        padding: EdgeInsets.all(12),
                        itemCount: demandes.length,
                        itemBuilder: (context, index) {
                          final demande =
                              demandes[index].data() as Map<String, dynamic>;
                          final transportType = demande['transportType'] ?? '';
                          final startAddress = demande['startAddress'] ?? '';
                          final endAddress = demande['endAddress'] ?? '';
                          final timestamp = demande['timestamp']?.toDate();
                          final prix = demande['prix'] ?? '';
                          final soignantId = demande['soignantId'];

                          return FutureBuilder<DocumentSnapshot>(
                            future: FirebaseFirestore.instance
                                .collection('soignants')
                                .doc(soignantId)
                                .get(),
                            builder: (context, soignantSnapshot) {
                              if (!soignantSnapshot.hasData) {
                                return const SizedBox.shrink();
                              }

                              final soignantData =
                                  soignantSnapshot.data!.data()
                                      as Map<String, dynamic>?;

                              final soignantName =
                                  soignantData?['name'] ?? '...';
                              final soignantImage =
                                  soignantData?['profileImage'] ??
                                  'https://firebasestorage.googleapis.com/v0/b/easy-med-c3f69.firebasestorage.app/o/profile_images%2Favatar-simple.jpg?alt=media&token=cbf516b6-ad37-4c50-852d-58f0b83564d5';

                              return GestureDetector(
                                onTap: () {
                                  final demandeId = demandes[index]
                                      .id; // 🔹 l'ID du document Firestore
                                  final soignantId =
                                      demande['soignantId']; // 🔹 l'ID du soignant dans la demande
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => Demande(
                                        demandeId: demandes[index].id,
                                        soignantId: soignantId,
                                      ),
                                    ),
                                  );
                                },
                                child: Container(
                                  margin: const EdgeInsets.only(bottom: 16),
                                  padding: const EdgeInsets.all(16),
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(16),
                                    color: Colors.white,
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withOpacity(0.05),
                                        blurRadius: 10,
                                        offset: const Offset(0, 4),
                                      ),
                                    ],
                                  ),
                                  child: Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      ClipRRect(
                                        borderRadius: BorderRadius.circular(30),
                                        child: Image.network(
                                          soignantImage,
                                          width: 60,
                                          height: 60,
                                          fit: BoxFit.cover,
                                        ),
                                      ),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              transportType,
                                              style: cat_title.customStyle,
                                            ),
                                            const SizedBox(height: 4),
                                            Text(
                                              soignantName,
                                              style: details_title.customStyle,
                                            ),
                                            const SizedBox(height: 4),
                                            Row(
                                              children: [
                                                Text(
                                                  "Date: ",
                                                  style:
                                                      details_title.customStyle,
                                                ),
                                                Text(
                                                  timestamp != null
                                                      ? "${timestamp.day}/${timestamp.month}/${timestamp.year}"
                                                      : "N/A",
                                                  style: details.customStyle,
                                                ),
                                              ],
                                            ),
                                            Row(
                                              children: [
                                                Text(
                                                  prix.toString(),
                                                  style:
                                                      details_title.customStyle,
                                                ),
                                                Text(
                                                  "DZD",
                                                  style: details.customStyle,
                                                ),
                                              ],
                                            ),
                                            const SizedBox(height: 6),
                                            Text(
                                              "Voir plus de détail",
                                              style: pink_link.customStyle,
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          );
                        },
                      );
                    },
                  ),
                ),
              ],
            ),
    );
  }
}

class blueTitle {
  static const TextStyle customStyle = TextStyle(
    fontSize: 26,
    fontWeight: FontWeight.bold,
    color: Color(0xFF1170AD),
  );
}

class cat_title {
  static const TextStyle customStyle = TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.bold,
    color: Color(0xFF1170AD),
  );
}

class details {
  static const TextStyle customStyle = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w700,
    color: Color(0xFF888888),
  );
}

class details_title {
  static const TextStyle customStyle = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.bold,
    color: Colors.black,
  );
}

class pink_link {
  static const TextStyle customStyle = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w700,
    color: Color(0xFFF11477),
  );
}
