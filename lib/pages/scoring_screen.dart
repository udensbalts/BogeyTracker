import 'package:flutter/material.dart';
import 'package:test_app/services/round_services.dart';
import 'package:test_app/widgets/score_input.dart';

class ScoringScreen extends StatefulWidget {
  final String roundId;
  final String courseId;
  final List<Map<String, dynamic>> players; // Contains playerId and playerName
  final List<Map<String, dynamic>>
      baskets; // Contains basketNumber, par, distance

  ScoringScreen({
    required this.roundId,
    required this.courseId,
    required this.players,
    required this.baskets,
  });

  @override
  _ScoringScreenState createState() => _ScoringScreenState();
}

class _ScoringScreenState extends State<ScoringScreen> {
  final RoundService _roundService = RoundService();
  int currentHoleIndex = 0;

  // Store scores for each hole separately
  Map<int, Map<String, int>> scores = {}; // {holeIndex: {playerId: score}}

  void updateScore(String playerId, int score) {
    setState(() {
      scores[currentHoleIndex] ??= {};
      scores[currentHoleIndex]![playerId] = score;
    });

    _roundService
        .updateScore(widget.roundId, currentHoleIndex, playerId, score)
        .then((_) {
      setState(() {}); // Force UI refresh after Firestore update
    });
  }

  void nextHole() {
    if (currentHoleIndex < widget.baskets.length - 1) {
      setState(() {
        currentHoleIndex++;
      });
    } else {
      Navigator.pushReplacementNamed(context, '/home'); // Redirect to homepage
    }
  }

  void previousHole() {
    if (currentHoleIndex > 0) {
      setState(() {
        currentHoleIndex--;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final basket = widget.baskets[currentHoleIndex];

    return Scaffold(
      appBar: AppBar(title: Text("Hole ${currentHoleIndex + 1}")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Par: ${basket['par']}  |  Distance: ${basket['distance']}m",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            SizedBox(height: 20),
            Expanded(
              child: ListView(
                children: widget.players.map((player) {
                  return ListTile(
                    title: Text(player['playerName']),
                    subtitle: Text(
                        "Score: ${scores[currentHoleIndex]?[player['playerId']] ?? '-'}"),
                    onTap: () async {
                      int? newScore = await showModalBottomSheet<int>(
                        context: context,
                        builder: (_) => ScoreInput(),
                      );

                      if (newScore != null) {
                        updateScore(player['playerId'], newScore);
                      }
                    },
                  );
                }).toList(),
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                ElevatedButton(
                  onPressed: currentHoleIndex > 0 ? previousHole : null,
                  child: Text("Previous Hole"),
                ),
                ElevatedButton(
                  onPressed: nextHole,
                  child: Text(currentHoleIndex < widget.baskets.length - 1
                      ? "Next Hole"
                      : "Finish Round"),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
