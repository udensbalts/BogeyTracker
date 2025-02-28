import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class RoundDetailsScreen extends StatefulWidget {
  final String roundId;

  const RoundDetailsScreen({Key? key, required this.roundId}) : super(key: key);

  @override
  _RoundDetailsScreenState createState() => _RoundDetailsScreenState();
}

class _RoundDetailsScreenState extends State<RoundDetailsScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Round Details")),
      body: FutureBuilder<DocumentSnapshot>(
        future: _firestore.collection('rounds').doc(widget.roundId).get(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || !snapshot.data!.exists) {
            return Center(child: Text("Round data not found."));
          }

          var roundData = snapshot.data!.data() as Map<String, dynamic>;
          String courseName = roundData['courseName'] ?? "Unknown Course";
          String date = roundData['date'] ?? "Unknown Date";
          List<dynamic> playerScores = roundData['playerScores'] ?? [];

          // Calculate total score for each player
          List<Map<String, dynamic>> playerList = playerScores.map((player) {
            List<dynamic> basketScores = player['basketScores'] ?? [];
            int totalScore = basketScores.fold<int>(
              0,
              (sum, basket) => sum + ((basket['score'] ?? 0) as int),
            );

            return {
              'playerName': player['playerName'] ?? "Unknown Player",
              'basketScores': basketScores,
              'totalScore': totalScore,
            };
          }).toList();

          // Sort players by total score (lowest score first)
          playerList.sort((a, b) => a['totalScore'].compareTo(b['totalScore']));

          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(courseName,
                    style:
                        TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                SizedBox(height: 5),
                Text("Date: $date",
                    style: TextStyle(fontSize: 16, color: Colors.grey)),
                SizedBox(height: 20),
                Expanded(
                  child: ListView.builder(
                    itemCount: playerList.length,
                    itemBuilder: (context, index) {
                      var player = playerList[index];
                      String playerName = player['playerName'];
                      int totalScore = player['totalScore'];
                      List<dynamic> basketScores = player['basketScores'];

                      return Card(
                        margin: EdgeInsets.symmetric(vertical: 8),
                        child: ExpansionTile(
                          title: Text(
                            "$playerName - Total Score: $totalScore",
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          children: basketScores.map<Widget>((basket) {
                            return ListTile(
                              title: Text("Basket ${basket['basketNumber']}"),
                              subtitle: Text(
                                "Par: ${basket['par']} | Distance: ${basket['distance']}m | Score: ${basket['score']}",
                              ),
                            );
                          }).toList(),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
