import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:easy_malade/user_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'AppBar.dart';

class Demande extends StatefulWidget {
  final String demandeId;
  final String soignantId;

  const Demande({super.key, required this.demandeId, required this.soignantId});

  @override
  _DemandeState createState() => _DemandeState();
}

class _DemandeState extends State<Demande> {
  late Future<DocumentSnapshot> demandeFuture;
  late Future<DocumentSnapshot> soignantFuture;

  @override
  void initState() {
    super.initState();
    demandeFuture = FirebaseFirestore.instance
        .collection('demandes')
        .doc(widget.demandeId)
        .get();

    soignantFuture = FirebaseFirestore.instance
        .collection('soignants')
        .doc(widget.soignantId)
        .get();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(),
      body: FutureBuilder(
        future: Future.wait([demandeFuture, soignantFuture]),
        builder: (context, AsyncSnapshot<List<DocumentSnapshot>> snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          final demandeData = snapshot.data![0].data() as Map<String, dynamic>?;
          final soignantData =
              snapshot.data![1].data() as Map<String, dynamic>?;

          if (demandeData == null || soignantData == null) {
            return const Center(child: Text('Données non trouvées'));
          }

          final transportType = demandeData['transportType'] ?? '';
          final startAddress = demandeData['startAddress'] ?? '';
          final endAddress = demandeData['endAddress'] ?? '';
          final timestamp = demandeData['timestamp']?.toDate();
          final prix = demandeData['prix'] ?? '';

          final soignantName = soignantData['name'] ?? '';
          final soignantImage =
              soignantData['profileImage'] ??
              'https://firebasestorage.googleapis.com/v0/b/easy-med-c3f69.firebasestorage.app/o/profile_images%2Favatar-simple.jpg?alt=media&token=cbf516b6-ad37-4c50-852d-58f0b83564d5';

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Card(
              elevation: 6,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(20),
                      child: Image.network(
                        soignantImage,

                        width: double.infinity,
                        fit: BoxFit.cover,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      soignantName,
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFFF11477),
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 24),

                    _buildInfoRow('Type de transport', transportType),
                    const SizedBox(height: 12),
                    _buildInfoRow('Adresse de départ', startAddress),
                    const SizedBox(height: 12),
                    _buildInfoRow('Adresse d\'arrivée', endAddress),
                    const SizedBox(height: 12),
                    _buildInfoRow(
                      'Date',
                      timestamp != null
                          ? "${timestamp.day}/${timestamp.month}/${timestamp.year}"
                          : 'N/A',
                    ),
                    const SizedBox(height: 12),
                    _buildInfoRow('Prix', '$prix DZD'),

                    const SizedBox(height: 30),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text('$label :', style: details_title.customStyle),
        Expanded(
          child: Text(
            value,
            style: details.customStyle,
            textAlign: TextAlign.right,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}

// Styles personnalisés
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
