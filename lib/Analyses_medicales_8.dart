import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'AppBar.dart';
import 'Home.dart';

class Analyses_medicales_8 extends StatefulWidget {
  final Map<String, dynamic> soignant;

  const Analyses_medicales_8({Key? key, required this.soignant})
    : super(key: key);

  @override
  _Analyses_medicales_8State createState() => _Analyses_medicales_8State();
}

class _Analyses_medicales_8State extends State<Analyses_medicales_8> {
  double rating = 0;
  String comment = '';
  bool isSubmitting = false;

  final TextEditingController _commentController = TextEditingController();

  double _calculateDistance(GeoPoint start, GeoPoint end) {
    const R = 6371;
    final lat1 = start.latitude * pi / 180;
    final lon1 = start.longitude * pi / 180;
    final lat2 = end.latitude * pi / 180;
    final lon2 = end.longitude * pi / 180;
    final dlat = lat2 - lat1;
    final dlon = lon2 - lon1;
    final a =
        pow(sin(dlat / 2), 2) + cos(lat1) * cos(lat2) * pow(sin(dlon / 2), 2);
    final c = 2 * atan2(sqrt(a), sqrt(1 - a));
    return R * c;
  }

  int calculateEstimatedTime(double distanceInKm) {
    const realismFactor = 1.5;
    const averageSpeedKmPerHour = 30;
    final realDistance = distanceInKm * realismFactor;
    final timeInHours = realDistance / averageSpeedKmPerHour;
    return (timeInHours * 60).round();
  }

  int _calculatePrice(double distance) {
    if (distance <= 10) return 500;
    if (distance <= 30) return 750;
    return 1200;
  }

  Future<void> _submitReview() async {
    if (rating == 0) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Merci de donner une note.')));
      return;
    }

    setState(() {
      isSubmitting = true;
    });

    try {
      final demandeId = widget.soignant['demandeId'];
      final soignantId = widget.soignant['id'];

      await FirebaseFirestore.instance.collection('avis').add({
        'soignantId': soignantId,
        'demandeId': demandeId,
        'rating': rating,
        'comment': comment.isNotEmpty ? comment : null,
        'timestamp': Timestamp.now(),
      });

      await FirebaseFirestore.instance
          .collection('demandes')
          .doc(demandeId)
          .update({
            'status': 'validé_malade',
            'note': rating,
            'commentaire': comment.isNotEmpty ? comment : null,
          });

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Merci pour votre avis !')));

      Future.delayed(Duration(milliseconds: 300), () {
        if (mounted) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => Home()),
          );
        }
      });
    } catch (e) {
      print('Erreur lors de l’envoi de l’avis : $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erreur lors de l’envoi de l’avis.')),
      );
    } finally {
      setState(() {
        isSubmitting = false;
      });
    }
  }

  Future<void> _validateWithoutReview() async {
    setState(() {
      isSubmitting = true;
    });

    try {
      final demandeId = widget.soignant['demandeId'];

      await FirebaseFirestore.instance
          .collection('demandes')
          .doc(demandeId)
          .update({'status': 'validé_malade', 'note': '', 'commentaire': ''});

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Demande validée sans note.')));

      Future.delayed(Duration(milliseconds: 300), () {
        if (mounted) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => Home()),
          );
        }
      });
    } catch (e) {
      print('Erreur validation sans note : $e');
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Erreur de validation.')));
    } finally {
      setState(() {
        isSubmitting = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final start = widget.soignant["startCoordinates"] as GeoPoint?;
    final end = widget.soignant["endCoordinates"] as GeoPoint?;

    double distance = 0.0;
    int price = 0;
    int time = 0;

    if (start != null && end != null) {
      distance = _calculateDistance(start, end);
      price = _calculatePrice(distance);
      time = calculateEstimatedTime(distance);
    }

    return Scaffold(
      appBar: CustomAppBar(),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              '🎉 🎉Votre demande est terminée avec succès 🎉🎉',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1170AD),
              ),
            ),
            SizedBox(height: 25),
            Text(
              "Donnez une note à votre soignant",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10),
            RatingBar.builder(
              initialRating: rating,
              minRating: 1,
              direction: Axis.horizontal,
              allowHalfRating: false,
              itemCount: 5,
              itemPadding: EdgeInsets.symmetric(horizontal: 4),
              itemBuilder: (context, _) =>
                  Icon(Icons.star, color: Colors.amber),
              onRatingUpdate: (value) {
                setState(() {
                  rating = value;
                });
              },
            ),
            SizedBox(height: 20),
            Text(
              "Laissez un commentaire",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10),
            TextField(
              controller: _commentController,
              onChanged: (value) => comment = value,
              maxLines: 4,
              decoration: InputDecoration(
                hintText: "Votre commentaire...",
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: isSubmitting ? null : _submitReview,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xFFF11477),
                  padding: EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
                child: isSubmitting
                    ? CircularProgressIndicator(color: Colors.white)
                    : Text(
                        "Envoyer",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
              ),
            ),
            SizedBox(height: 10),
            TextButton(
              onPressed: isSubmitting ? null : _validateWithoutReview,
              child: Text(
                "Valider sans la note",
                style: TextStyle(color: Color(0xFF1170AD), fontSize: 16),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
