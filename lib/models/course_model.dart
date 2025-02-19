import 'package:cloud_firestore/cloud_firestore.dart';

class Course {
  final String id; // Firestore Document ID
  final String name;
  final int totalBaskets;
  final List<Basket> baskets;

  Course(
      {required this.id,
      required this.name,
      required this.totalBaskets,
      required this.baskets});

  // Convert Firestore document to Course object
  factory Course.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;

    List<Basket> basketsList =
        (data['baskets'] as List).map((item) => Basket.fromMap(item)).toList();

    return Course(
      id: doc.id, // Assign Firestore document ID
      name: data['name'],
      totalBaskets: data['totalBaskets'],
      baskets: basketsList,
    );
  }

  // Convert Course object to Map (for Firestore)
  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'totalBaskets': totalBaskets,
      'baskets': baskets.map((b) => b.toMap()).toList(),
    };
  }
}

class Basket {
  final int par;
  final double distance;

  Basket({required this.par, required this.distance});

  factory Basket.fromMap(Map<String, dynamic> data) {
    return Basket(
      par: data['par'],
      distance: data['distance'].toDouble(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'par': par,
      'distance': distance,
    };
  }
}
