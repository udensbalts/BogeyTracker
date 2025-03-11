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
      appBar: AppBar(
        title: Text("Round Details",
            style: TextStyle(
                fontSize: 25,
                fontWeight: FontWeight.bold,
                color: Colors.white)),
        centerTitle: true,
        backgroundColor: Colors.black,
      ),
      backgroundColor: Colors.grey[900],
      body: FutureBuilder<DocumentSnapshot>(
        future: _firestore.collection('rounds').doc(widget.roundId).get(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator(color: Colors.red));
          }

          if (!snapshot.hasData || !snapshot.data!.exists) {
            return Center(
                child: Text("Round data not found.",
                    style: TextStyle(color: Colors.white, fontSize: 18)));
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
          int totalBaskets = playerList.isNotEmpty
              ? playerList.first['basketScores'].length
              : 0;

          return Padding(
            padding: const EdgeInsets.all(12.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(courseName,
                    style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Colors.white)),
                SizedBox(height: 5),
                Text("Date: $date",
                    style: TextStyle(fontSize: 16, color: Colors.grey)),
                SizedBox(height: 20),
                Expanded(
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: DataTable(
                      columnSpacing: 15,
                      headingRowColor:
                          MaterialStateProperty.all(Colors.redAccent),
                      columns: [
                        DataColumn(
                            label: Text("Player", style: _headerStyle())),
                        ...List.generate(
                            totalBaskets,
                            (index) => DataColumn(
                                label: Text("${index + 1}",
                                    style: _headerStyle()))),
                        DataColumn(label: Text("Total", style: _headerStyle())),
                      ],
                      rows: playerList.map((player) {
                        return DataRow(cells: [
                          DataCell(Text(player['playerName'],
                              style: _cellStyle(bold: true))),
                          ...List.generate(totalBaskets, (index) {
                            var score =
                                player['basketScores'][index]['score'] ?? "-";
                            return DataCell(
                                Text(score.toString(), style: _cellStyle()));
                          }),
                          DataCell(Text(player['totalScore'].toString(),
                              style: _cellStyle(bold: true))),
                        ]);
                      }).toList(),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  TextStyle _headerStyle() {
    return TextStyle(
        fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white);
  }

  TextStyle _cellStyle({bool bold = false}) {
    return TextStyle(
        fontSize: bold ? 15 : 14,
        fontWeight: bold ? FontWeight.bold : FontWeight.normal,
        color: Colors.white);
  }
}
