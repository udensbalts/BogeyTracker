import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class RoundDetailsScreen extends StatefulWidget {
  final String roundId;

  const RoundDetailsScreen({Key? key, required this.roundId}) : super(key: key);

  @override
  _RoundDetailsScreenState createState() => _RoundDetailsScreenState();
}

class _RoundDetailsScreenState extends State<RoundDetailsScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  String _formatDate(dynamic date) {
    try {
      if (date == null) return "Unknown Date";

      if (date is Timestamp) {
        return DateFormat('MMM dd, yyyy - hh:mm a').format(date.toDate());
      } else if (date is String) {
        DateTime parsedDate = DateTime.parse(date);
        return DateFormat('MMM dd, yyyy - hh:mm a').format(parsedDate);
      }
      return "Invalid Date";
    } catch (e) {
      return "Invalid Date";
    }
  }

  String _formatScoreToPar(int totalScore, int totalPar) {
    final difference = totalScore - totalPar;
    return difference > 0 ? '+$difference' : difference.toString();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Round Details",
            style: TextStyle(
                fontSize: 25,
                fontWeight: FontWeight.bold,
                color: Colors.white)),
        centerTitle: true,
        backgroundColor: Colors.black,
        elevation: 0,
      ),
      backgroundColor: Colors.grey[900],
      body: FutureBuilder<DocumentSnapshot>(
        future: _firestore.collection('rounds').doc(widget.roundId).get(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
                child: CircularProgressIndicator(color: Colors.redAccent));
          }

          if (!snapshot.hasData || !snapshot.data!.exists) {
            return Center(
                child: Text("Round data not found.",
                    style: TextStyle(color: Colors.white, fontSize: 18)));
          }

          var roundData = snapshot.data!.data() as Map<String, dynamic>;
          String courseName = roundData['courseName'] ?? "Unknown Course";
          dynamic date = roundData['date'];
          String formattedDate = _formatDate(date);
          List<dynamic> playerScores = roundData['playerScores'] ?? [];

          List<Map<String, dynamic>> playerList = playerScores.map((player) {
            List<dynamic> basketScores = player['basketScores'] ?? [];
            int totalScore = basketScores.fold<int>(
              0,
              (sum, basket) => sum + ((basket['score'] ?? 0) as int),
            );

            int totalPar = basketScores.fold<int>(
              0,
              (sum, basket) => sum + ((basket['par'] ?? 3) as int),
            );

            int pars = 0, birdies = 0, bogeys = 0;
            for (var basket in basketScores) {
              int score = basket['score'] ?? 0;
              int par = basket['par'] ?? 3;
              if (score == par)
                pars++;
              else if (score < par)
                birdies++;
              else if (score > par) bogeys++;
            }

            return {
              'playerName': player['playerName'] ?? "Unknown Player",
              'playerId': player['playerId'],
              'basketScores': basketScores,
              'totalScore': totalScore,
              'totalPar': totalPar,
              'scoreToPar': _formatScoreToPar(totalScore, totalPar),
              'pars': pars,
              'birdies': birdies,
              'bogeys': bogeys,
            };
          }).toList();

          playerList.sort((a, b) => a['totalScore'].compareTo(b['totalScore']));
          int totalBaskets = playerList.isNotEmpty
              ? playerList.first['basketScores'].length
              : 0;

          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.grey[800],
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(courseName,
                          style: const TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              color: Colors.white)),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Icon(Icons.calendar_today,
                              size: 18, color: Colors.grey[400]),
                          const SizedBox(width: 8),
                          Text(formattedDate,
                              style: TextStyle(
                                  fontSize: 16, color: Colors.grey[400])),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                Expanded(
                  child: Column(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        decoration: BoxDecoration(
                          color: Colors.redAccent,
                          borderRadius:
                              BorderRadius.vertical(top: Radius.circular(12)),
                        ),
                        child: Row(
                          children: [
                            SizedBox(
                                width: 100,
                                child: Text("Player", style: _headerStyle())),
                            Expanded(
                              child: SingleChildScrollView(
                                scrollDirection: Axis.horizontal,
                                child: Row(
                                  children: List.generate(
                                    totalBaskets,
                                    (index) => SizedBox(
                                      width: 40,
                                      child: Center(
                                          child: Text("${index + 1}",
                                              style: _headerStyle())),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            SizedBox(
                                width: 50,
                                child: Center(
                                    child:
                                        Text("Total", style: _headerStyle()))),
                            SizedBox(
                                width: 50,
                                child: Center(
                                    child: Text("+/-", style: _headerStyle()))),
                          ],
                        ),
                      ),
                      Expanded(
                        child: ListView.builder(
                          itemCount: playerList.length,
                          itemBuilder: (context, index) {
                            final player = playerList[index];
                            return Container(
                              decoration: BoxDecoration(
                                border: Border(
                                  bottom: BorderSide(
                                      color: Colors.grey[800]!, width: 1),
                                ),
                              ),
                              child: Row(
                                children: [
                                  SizedBox(
                                    width: 100,
                                    child: Padding(
                                      padding: const EdgeInsets.symmetric(
                                          vertical: 12),
                                      child: Text(
                                        player['playerName'],
                                        style: _cellStyle(bold: true),
                                      ),
                                    ),
                                  ),
                                  Expanded(
                                    child: SingleChildScrollView(
                                      scrollDirection: Axis.horizontal,
                                      child: Row(
                                        children: List.generate(
                                          totalBaskets,
                                          (basketIndex) => SizedBox(
                                            width: 40,
                                            child: Center(
                                              child: Text(
                                                player['basketScores']
                                                        [basketIndex]['score']
                                                    .toString(),
                                                style: _scoreStyle(
                                                    player['basketScores']
                                                        [basketIndex]['score'],
                                                    player['basketScores']
                                                                [basketIndex]
                                                            ['par'] ??
                                                        3),
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                  SizedBox(
                                    width: 50,
                                    child: Center(
                                      child: Text(
                                          player['totalScore'].toString(),
                                          style: _cellStyle(bold: true)),
                                    ),
                                  ),
                                  SizedBox(
                                    width: 50,
                                    child: Center(
                                      child: Text(
                                        player['scoreToPar'],
                                        style: _scoreToParStyle(
                                            player['totalScore'] -
                                                player['totalPar']),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
                if (playerList.isNotEmpty) ...[
                  const SizedBox(height: 20),
                  Text("Performance Summary",
                      style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.white)),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: playerList.map((player) {
                      return Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                            color: Colors.grey[800],
                            borderRadius: BorderRadius.circular(12)),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(player['playerName'],
                                style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white)),
                            const SizedBox(height: 8),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                _buildStatChip(Icons.golf_course, "Birdies",
                                    player['birdies'], Colors.green),
                                _buildStatChip(Icons.equalizer, "Pars",
                                    player['pars'], Colors.blue),
                                _buildStatChip(Icons.warning, "Bogeys",
                                    player['bogeys'], Colors.orange),
                              ],
                            ),
                            const SizedBox(height: 8),
                            _buildStatChip(
                                Icons.score,
                                "To Par",
                                player['scoreToPar'],
                                _getScoreToParColor(
                                    player['totalScore'] - player['totalPar'])),
                          ],
                        ),
                      );
                    }).toList(),
                  ),
                ],
              ],
            ),
          );
        },
      ),
    );
  }

  Color _getScoreToParColor(int difference) {
    if (difference < 0) return Colors.green[400]!;
    if (difference > 0) return Colors.red[400]!;
    return Colors.blue[400]!;
  }

  TextStyle _scoreToParStyle(int difference) {
    return TextStyle(
      color: _getScoreToParColor(difference),
      fontWeight: FontWeight.bold,
      fontSize: 16,
    );
  }

  Widget _buildStatChip(
      IconData icon, String label, dynamic value, Color color) {
    return Chip(
      avatar: Icon(icon, size: 18, color: color),
      label: Text("$label: $value", style: TextStyle(color: Colors.white)),
      backgroundColor: Colors.grey[700],
    );
  }

  TextStyle _headerStyle() {
    return const TextStyle(
        fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white);
  }

  TextStyle _cellStyle({bool bold = false}) {
    return TextStyle(
        fontSize: bold ? 15 : 14,
        fontWeight: bold ? FontWeight.bold : FontWeight.normal,
        color: Colors.white);
  }

  TextStyle _scoreStyle(int score, int par) {
    if (score < par)
      return TextStyle(color: Colors.green[400], fontWeight: FontWeight.bold);
    if (score > par)
      return TextStyle(color: Colors.red[400], fontWeight: FontWeight.bold);
    return TextStyle(color: Colors.blue[400], fontWeight: FontWeight.bold);
  }
}
