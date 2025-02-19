import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:test_app/pages/scoring_screen.dart';
import 'package:test_app/services/round_services.dart';
import '../models/round_model.dart';

class NewRoundScreen extends StatefulWidget {
  @override
  _NewRoundScreenState createState() => _NewRoundScreenState();
}

class _NewRoundScreenState extends State<NewRoundScreen> {
  List<Map<String, dynamic>> courses = [];
  List<Map<String, dynamic>> users = [];
  String? selectedCourseId;
  String? selectedCourseName;
  List<PlayerScore> selectedPlayers = [];

  @override
  void initState() {
    super.initState();
    fetchCourses();
    fetchUsers();
  }

  Future<void> fetchCourses() async {
    var snapshot = await FirebaseFirestore.instance.collection('courses').get();
    setState(() {
      courses = snapshot.docs.map((doc) {
        return {
          'id': doc.id,
          'name': doc['name'],
          'baskets': List<Map<String, dynamic>>.from(doc['baskets'] ?? []),
        };
      }).toList();
    });
  }

  Future<void> fetchUsers() async {
    var snapshot = await FirebaseFirestore.instance.collection('users').get();
    setState(() {
      users = snapshot.docs.map((doc) {
        return {
          'id': doc.id,
          'name': doc['name'],
        };
      }).toList();
    });
  }

  void togglePlayer(Map<String, dynamic> user) {
    setState(() {
      if (selectedPlayers.any((p) => p.playerId == user['id'])) {
        selectedPlayers.removeWhere((p) => p.playerId == user['id']);
      } else {
        selectedPlayers.add(PlayerScore(
          playerId: user['id'],
          playerName: user['name'],
          basketScores: [],
        ));
      }
    });
  }

  Future<void> startRound() async {
    if (selectedCourseId == null || selectedPlayers.isEmpty) return;

    var selectedCourse = courses.firstWhere((c) => c['id'] == selectedCourseId);
    List<BasketScore> basketScores = selectedCourse['baskets']
        .map<BasketScore>((basket) => BasketScore(
              basketNumber: basket['basketNumber'] ?? 0,
              par: basket['par'] ?? 3,
              distance: basket['distance'] ?? 0,
            ))
        .toList();

    for (var player in selectedPlayers) {
      player.basketScores = List.from(basketScores); // Ensure separate copies
    }

    String? roundId = await RoundService().createRound(
      selectedCourseId!,
      selectedPlayers.map((p) => p.playerId).toList(),
    );

    if (roundId != null) {
      // ✅ Navigate to ScoringScreen and pass roundId + selectedPlayers
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => ScoringScreen(
            roundId: roundId,
            courseId: '',
            players: [],
          ),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Failed to create round")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("New Round")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Select Course", style: TextStyle(fontSize: 18)),
            DropdownButton<String>(
              value: selectedCourseId,
              items: courses.map<DropdownMenuItem<String>>((course) {
                return DropdownMenuItem<String>(
                  value: course['id'],
                  child: Text(course['name']),
                );
              }).toList(),
              onChanged: (String? newValue) {
                setState(() {
                  selectedCourseId = newValue;
                  selectedCourseName =
                      courses.firstWhere((c) => c['id'] == newValue)['name'];
                });
              },
            ),
            SizedBox(height: 20),
            Text("Select Players", style: TextStyle(fontSize: 18)),
            Expanded(
              child: ListView(
                children: users.map((user) {
                  bool isSelected =
                      selectedPlayers.any((p) => p.playerId == user['id']);
                  return ListTile(
                    title: Text(user['name']),
                    trailing: Icon(
                      isSelected
                          ? Icons.check_box
                          : Icons.check_box_outline_blank,
                      color: isSelected ? Colors.purple : null,
                    ),
                    onTap: () => togglePlayer(user),
                  );
                }).toList(),
              ),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: startRound,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.purple,
                padding: EdgeInsets.symmetric(vertical: 12),
              ),
              child: Center(
                child: Text(
                  "Start Round",
                  style: TextStyle(color: Colors.white, fontSize: 18),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
