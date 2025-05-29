import 'package:flutter/material.dart';
import 'package:test_app/models/basket_model.dart';
import 'package:test_app/pages/new_round_screen.dart';
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

  Color _getParColor(int par) {
    return par == 3
        ? Colors.blue[800]!
        : par == 4
            ? Colors.green[800]!
            : Colors.orange[800]!;
  }

  String _calculateTotalDistance(List<BasketModel> baskets) {
    double total = baskets.fold(0, (sum, basket) => sum + basket.distance);
    return '${total.toStringAsFixed(0)}m';
  }

  String _calculateTotalPar(List<BasketModel> baskets) {
    int total = baskets.fold(0, (sum, basket) => sum + basket.par);
    return total.toString();
  }

  Widget _buildSummaryChip(IconData icon, String text) {
    return Chip(
      avatar: Icon(icon, size: 18, color: Colors.white),
      label: Text(text, style: const TextStyle(color: Colors.white)),
      backgroundColor: Colors.grey[700],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.courseName,
          style: const TextStyle(
            fontSize: 25,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        backgroundColor: Colors.black,
        elevation: 0,
      ),
      backgroundColor: Colors.grey[900],
      body: FutureBuilder<List<BasketModel>>(
        future: _basketsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No baskets found'));
          }

          final baskets = snapshot.data!;

          return Column(
            children: [
              // Course summary header
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.grey[800],
                  borderRadius: const BorderRadius.vertical(
                    bottom: Radius.circular(20),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _buildSummaryChip(
                        Icons.golf_course, '${baskets.length} Baskets'),
                    _buildSummaryChip(Icons.straighten,
                        'Total: ${_calculateTotalDistance(baskets)}'),
                    _buildSummaryChip(Icons.paragliding,
                        'Par: ${_calculateTotalPar(baskets)}'),
                  ],
                ),
              ),

              // Basket list
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.all(12),
                  itemCount: baskets.length,
                  itemBuilder: (context, index) {
                    final basket = baskets[index];
                    return Card(
                      color: Colors.grey[800],
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      margin: const EdgeInsets.symmetric(vertical: 8),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'Basket ${basket.basketNumber}',
                                  style: const TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 4,
                                  ),
                                  decoration: BoxDecoration(
                                    color: _getParColor(basket.par),
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: Text(
                                    'Par ${basket.par}',
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            Row(
                              children: [
                                const Icon(
                                  Icons.straighten,
                                  size: 20,
                                  color: Colors.redAccent,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  '${basket.distance}m',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 16,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.push(
            context,
            PageRouteBuilder(
              pageBuilder: (context, animation, secondaryAnimation) =>
                  NewRoundScreen(),
              transitionsBuilder:
                  (context, animation, secondaryAnimation, child) {
                return ScaleTransition(
                  scale: animation,
                  child: child,
                );
              },
            ),
          );
        },
        icon: const Icon(Icons.play_arrow),
        label: const Text('Start Round'),
        backgroundColor: Colors.redAccent,
      ),
    );
  }
}
