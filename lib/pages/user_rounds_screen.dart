import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:test_app/pages/round_details_screen.dart';
import 'package:intl/intl.dart';

class UserRoundsScreen extends StatefulWidget {
  const UserRoundsScreen({Key? key}) : super(key: key);

  @override
  _UserRoundsScreenState createState() => _UserRoundsScreenState();
}

class _UserRoundsScreenState extends State<UserRoundsScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  String _currentFilter = 'recent';
  List<Map<String, dynamic>> _filteredRounds = [];

  @override
  Widget build(BuildContext context) {
    User? user = _auth.currentUser;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "My Rounds",
          style: TextStyle(
            fontSize: 25,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.black,
        elevation: 0,
      ),
      backgroundColor: Colors.grey[900],
      body: user == null
          ? const Center(
              child: Text(
              "Please sign in to view your rounds",
              style: TextStyle(color: Colors.white, fontSize: 18),
            ))
          : StreamBuilder<QuerySnapshot>(
              stream: _firestore.collection('rounds').snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                      child:
                          CircularProgressIndicator(color: Colors.redAccent));
                }

                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return const Center(
                      child: Text(
                    "No rounds found.",
                    style: TextStyle(color: Colors.white, fontSize: 18),
                  ));
                }

                String userId = user.uid;

                // Process all rounds
                List<Map<String, dynamic>> allRounds =
                    snapshot.data!.docs.where((round) {
                  var roundData = round.data() as Map<String, dynamic>;
                  if (!roundData.containsKey('playerScores')) return false;
                  List<dynamic> playerScores = roundData['playerScores'];
                  return playerScores
                      .any((player) => player['playerId'] == userId);
                }).map((round) {
                  var roundData = round.data() as Map<String, dynamic>;
                  var dateData = roundData['date'];
                  DateTime dateTime;

                  if (dateData is Timestamp) {
                    dateTime = dateData.toDate();
                  } else if (dateData is String) {
                    dateTime = DateTime.tryParse(dateData) ?? DateTime.now();
                  } else {
                    dateTime = DateTime.now();
                  }

                  // Calculate player's total score and par
                  List<dynamic> playerScores = roundData['playerScores'];
                  var playerData = playerScores
                      .firstWhere((player) => player['playerId'] == userId);
                  int totalScore = (playerData['basketScores'] as List)
                      .fold<int>(
                          0, (sum, basket) => sum + (basket['score'] as int));
                  int totalPar = (playerData['basketScores'] as List).fold<int>(
                      0, (sum, basket) => sum + (basket['par'] as int));

                  return {
                    'id': round.id,
                    'courseName': roundData['courseName'] ?? 'Unknown Course',
                    'date': dateTime,
                    'totalScore': totalScore,
                    'totalPar': totalPar,
                    'scoreToPar': totalScore - totalPar,
                  };
                }).toList();

                if (allRounds.isEmpty) {
                  return const Center(
                      child: Text(
                    "You haven't played any rounds yet.",
                    style: TextStyle(color: Colors.white, fontSize: 18),
                  ));
                }

                // Apply filter
                _filteredRounds = List.from(allRounds);
                if (_currentFilter == 'recent') {
                  _filteredRounds
                      .sort((a, b) => b['date'].compareTo(a['date']));
                } else if (_currentFilter == 'best') {
                  _filteredRounds.sort(
                      (a, b) => a['scoreToPar'].compareTo(b['scoreToPar']));
                }

                // Calculate stats
                final totalRounds = allRounds.length;
                final bestRound = allRounds.reduce(
                    (a, b) => a['scoreToPar'] < b['scoreToPar'] ? a : b);
                final averageScoreToPar = allRounds.fold(
                        0, (sum, round) => sum + round['scoreToPar'] as int) /
                    allRounds.length;

                return Column(
                  children: [
                    // Performance Summary Card
                    Card(
                      margin: const EdgeInsets.all(16),
                      color: Colors.grey[800],
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          children: [
                            const Text(
                              'Your Performance',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 12),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              children: [
                                _buildStatItem('Rounds', totalRounds.toString(),
                                    Icons.golf_course),
                                _buildStatItem(
                                    'Best',
                                    _formatScoreToPar(bestRound['scoreToPar']),
                                    Icons.emoji_events),
                                _buildStatItem(
                                    'Avg',
                                    _formatScoreToPar(
                                        averageScoreToPar.round()),
                                    Icons.trending_up),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),

                    // Filter Chips
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Row(
                        children: [
                          FilterChip(
                            label: const Text('Recent'),
                            selected: _currentFilter == 'recent',
                            selectedColor: Colors.redAccent,
                            checkmarkColor: Colors.white,
                            onSelected: (_) =>
                                setState(() => _currentFilter = 'recent'),
                          ),
                          const SizedBox(width: 8),
                          FilterChip(
                            label: const Text('Best Scores'),
                            selected: _currentFilter == 'best',
                            selectedColor: Colors.redAccent,
                            checkmarkColor: Colors.white,
                            onSelected: (_) =>
                                setState(() => _currentFilter = 'best'),
                          ),
                        ],
                      ),
                    ),

                    // Rounds List
                    Expanded(
                      child: ListView.builder(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        itemCount: _filteredRounds.length,
                        itemBuilder: (context, index) {
                          final round = _filteredRounds[index];
                          final formattedDate =
                              DateFormat('MMM d, yyyy').format(round['date']);
                          final scoreToPar = round['scoreToPar'];
                          final scoreToParText = _formatScoreToPar(scoreToPar);

                          return Container(
                            margin: const EdgeInsets.symmetric(
                                vertical: 6, horizontal: 16),
                            decoration: BoxDecoration(
                              color: Colors.grey[800],
                              borderRadius: BorderRadius.circular(12),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.2),
                                  blurRadius: 6,
                                  offset: const Offset(0, 3),
                                ),
                              ],
                            ),
                            child: ListTile(
                              contentPadding: const EdgeInsets.symmetric(
                                  vertical: 12, horizontal: 16),
                              leading: Container(
                                width: 50,
                                height: 50,
                                decoration: BoxDecoration(
                                  color: _getScoreColor(scoreToPar),
                                  shape: BoxShape.circle,
                                ),
                                child: Center(
                                  child: Text(
                                    scoreToParText,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                    ),
                                  ),
                                ),
                              ),
                              title: Text(
                                round['courseName'],
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                  fontSize: 18,
                                ),
                              ),
                              subtitle: Text(
                                formattedDate,
                                style: const TextStyle(
                                  color: Colors.white70,
                                  fontSize: 16,
                                ),
                              ),
                              trailing: const Icon(Icons.chevron_right,
                                  color: Colors.white54),
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => RoundDetailsScreen(
                                        roundId: round['id']),
                                  ),
                                );
                              },
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                );
              },
            ),
    );
  }

  String _formatScoreToPar(int scoreToPar) {
    return scoreToPar > 0 ? '+$scoreToPar' : scoreToPar.toString();
  }

  Widget _buildStatItem(String label, String value, [IconData? icon]) {
    return Column(
      children: [
        if (icon != null) Icon(icon, color: Colors.white70, size: 24),
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: const TextStyle(
            color: Colors.white70,
            fontSize: 14,
          ),
        ),
      ],
    );
  }

  Color _getScoreColor(int scoreToPar) {
    if (scoreToPar < 0) return Colors.green[800]!;
    if (scoreToPar > 0) return Colors.red[800]!;
    return Colors.blue[800]!;
  }
}
