import 'package:flutter/material.dart';
import 'package:test_app/models/basket_model.dart';
import 'package:test_app/services/firebase_service.dart';

class BasketList extends StatefulWidget {
  final String courseId;
  final String courseName;

  const BasketList({Key? key, required this.courseId, required this.courseName})
      : super(key: key);

  @override
  State<BasketList> createState() => _CourseInfoState();
}

class _CourseInfoState extends State<BasketList> {
  late Future<List<BasketModel>> _basketsFuture;

  @override
  void initState() {
    super.initState();
    _basketsFuture = FirebaseService().getBaskets(widget.courseId);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Baskets',
          style: TextStyle(
            fontSize: 25,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        backgroundColor: Colors.black,
      ),
      backgroundColor: Colors.grey[900],
      body: FutureBuilder<List<BasketModel>>(
        future: _basketsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text("Error: ${snapshot.error}"));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text("No baskets found."));
          }

          List<BasketModel> baskets = snapshot.data!;

          return ListView.builder(
            itemCount: baskets.length,
            itemBuilder: (context, index) {
              BasketModel basket = baskets[index];
              return Card(
                color: Colors.grey[800],
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10)),
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: Column(
                    children: [
                      Text(
                        "Basket ${basket.basketNumber}",
                        style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 18),
                      ),
                      SizedBox(height: 8),
                      Row(
                        children: [
                          Icon(Icons.sports_golf, color: Colors.redAccent),
                          Text(
                            "Par: ${basket.par}",
                            style: TextStyle(
                              color: Colors.white70,
                              fontSize: 18,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(
                        height: 8,
                      ),
                      Row(
                        children: [
                          Icon(Icons.straighten, color: Colors.redAccent),
                          Text(
                            " Distance: ${basket.distance}m",
                            style: TextStyle(
                              color: Colors.white70,
                              fontSize: 18,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
