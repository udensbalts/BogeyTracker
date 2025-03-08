import 'package:flutter/material.dart';
import 'package:test_app/services/round_services.dart';
import 'package:test_app/widgets/score_input.dart';

class ScoringScreen extends StatefulWidget {
  final String roundId;
  final String courseId;
  final List<Map<String, dynamic>> players;
  final List<Map<String, dynamic>> baskets;

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
  Map<int, Map<String, int>> scores = {};

  void updateScore(String playerId, int score) {
    setState(() {
      scores[currentHoleIndex] ??= {};
      scores[currentHoleIndex]![playerId] = score;
    });
    _roundService.updateScore(
        widget.roundId, currentHoleIndex, playerId, score);
  }

  int getTotalScore(String playerId) {
    return scores.values.fold(
        0, (total, playerScores) => total + (playerScores[playerId] ?? 0));
  }

  int getRelativeScore(String playerId, int upToHoleIndex) {
    int relativeTotal = 0;
    for (int i = 0; i <= upToHoleIndex; i++) {
      int par = widget.baskets[i]['par'];
      int score = scores[i]?[playerId] ?? par;
      relativeTotal += (score - par);
    }
    return relativeTotal;
  }

  void nextHole() {
    if (currentHoleIndex < widget.baskets.length - 1) {
      setState(() => currentHoleIndex++);
    } else {
      Navigator.pushReplacementNamed(context, '/home');
    }
  }

  void previousHole() {
    if (currentHoleIndex > 0) {
      setState(() => currentHoleIndex--);
    }
  }

  @override
  Widget build(BuildContext context) {
    final basket = widget.baskets[currentHoleIndex];

    return Scaffold(
      backgroundColor: Colors.grey[900],
      appBar: AppBar(
        title: Text(
          "Hole ${currentHoleIndex + 1} of ${widget.baskets.length}",
          style: TextStyle(
            fontSize: 25,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.black,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              "Par: ${basket['par']} | Distance: ${basket['distance']}m",
              style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white),
            ),
            SizedBox(height: 20),
            Expanded(
              child: Table(
                border: TableBorder.all(color: Colors.white24),
                columnWidths: const {
                  0: FlexColumnWidth(3),
                  1: FlexColumnWidth(2),
                  2: FlexColumnWidth(2),
                  3: FlexColumnWidth(2),
                },
                children: [
                  TableRow(
                    decoration: BoxDecoration(color: Colors.redAccent),
                    children: _buildTableHeaders(),
                  ),
                  ...widget.players
                      .map((player) => _buildPlayerRow(player))
                      .toList(),
                ],
              ),
            ),
            SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _navigationButton(
                    "Previous Hole", previousHole, currentHoleIndex > 0),
                _navigationButton(
                  currentHoleIndex < widget.baskets.length - 1
                      ? "Next Hole"
                      : "Finish Round",
                  nextHole,
                  true,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  List<Widget> _buildTableHeaders() {
    return ["Player", "Score", "Total", "+/-"]
        .map((title) => Padding(
              padding: EdgeInsets.all(12.0),
              child: Center(
                child: Text(title,
                    style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.white)),
              ),
            ))
        .toList();
  }

  TableRow _buildPlayerRow(Map<String, dynamic> player) {
    int? score = scores[currentHoleIndex]?[player['playerId']];
    int totalScore = getTotalScore(player['playerId']);
    int relativeScore = getRelativeScore(player['playerId'], currentHoleIndex);

    return TableRow(
      children: [
        _tableCell(player['playerName']),
        GestureDetector(
          onTap: () async {
            int? newScore = await showModalBottomSheet<int>(
              context: context,
              builder: (_) => ScoreInput(),
            );
            if (newScore != null) updateScore(player['playerId'], newScore);
          },
          child: _tableCell(score != null ? "$score" : "-", center: true),
        ),
        _tableCell("$totalScore", center: true),
        _tableCell(
            relativeScore == 0
                ? "E"
                : "${relativeScore > 0 ? '+' : ''}$relativeScore",
            center: true),
      ],
    );
  }

  Widget _tableCell(String text, {bool center = false}) {
    return Padding(
      padding: const EdgeInsets.all(12.0),
      child: Center(
          child:
              Text(text, style: TextStyle(fontSize: 16, color: Colors.white))),
    );
  }

  Widget _navigationButton(String text, VoidCallback onPressed, bool enabled) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: enabled ? Colors.redAccent : Colors.grey,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        padding: EdgeInsets.symmetric(horizontal: 20, vertical: 14),
      ),
      onPressed: enabled ? onPressed : null,
      child: Text(text,
          style: TextStyle(
              fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
    );
  }
}
