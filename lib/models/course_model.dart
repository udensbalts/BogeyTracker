import 'package:cloud_firestore/cloud_firestore.dart';

class Course {
  final String id; // Firestore Document ID
  final String name;
  final int totalBaskets;
  final List<Basket> baskets;

  Course({
    required this.id,
    required this.name,
    required this.totalBaskets,
    required this.baskets,
  });

  // Convert Firestore document to Course object
  factory Course.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;

    List<Basket> basketsList =
        (data['baskets'] as List).asMap().entries.map((entry) {
      int index = entry.key; // Get the index as basketNumber
      Map<String, dynamic> item = entry.value;
      return Basket.fromMap(item, index);
    }).toList();

    return Course(
      id: doc.id,
      name: data['name'],
      totalBaskets: data['totalBaskets'] ?? basketsList.length,
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
  final int basketNumber;
  final int par;
  final double distance;

  Basket({
    required this.basketNumber,
    required this.par,
    required this.distance,
  });

  factory Basket.fromMap(Map<String, dynamic> data, int index) {
    return Basket(
      basketNumber: index,
      par: data['par'] ?? 3,
      distance: (data['distance'] as num).toDouble(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'basketNumber': basketNumber,
      'par': par,
      'distance': distance,
    };
  }
}
