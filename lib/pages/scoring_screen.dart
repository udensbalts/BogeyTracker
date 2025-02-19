import 'package:flutter/material.dart';
import 'package:test_app/services/round_services.dart';
import 'package:test_app/widgets/score_input.dart';

class ScoringScreen extends StatefulWidget {
  final String roundId;
  final String courseId;
  final List<String> players;

  ScoringScreen({
    required this.roundId,
    required this.courseId,
    required this.players,
  });

  @override
  _ScoringScreenState createState() => _ScoringScreenState();
}

class _ScoringScreenState extends State<ScoringScreen> {
  final RoundService _roundService = RoundService();
  int currentHole = 1;
  Map<String, int> scores = {};

  void updateScore(String playerId, int score) {
    setState(() {
      scores[playerId] = score;
    });

    // 🔥 Fix: Firestore uses 0-based indexing for holes
    _roundService.updateScore(widget.roundId, currentHole - 1, playerId, score);
  }

  void nextHole() {
    if (currentHole < 18) {
      setState(() {
        currentHole++;
        scores.clear();
      });
    } else {
      // 🔥 Use pushReplacement to prevent going back to an empty screen
      Navigator.pushReplacementNamed(context, '/home');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Hole $currentHole")),
      body: Column(
        children: [
          ...widget.players.map((player) => ListTile(
                title: Text(player),
                trailing: Text(scores[player]?.toString() ?? "-"),
                onTap: () async {
                  int? newScore = await showModalBottomSheet<int>(
                    context: context,
                    builder: (_) => ScoreInput(),
                  );
                  if (newScore != null) updateScore(player, newScore);
                },
              )),
          ElevatedButton(
            onPressed: nextHole,
            child: Text(currentHole < 18 ? "Next Hole" : "Finish Round"),
          ),
        ],
      ),
    );
  }
}
