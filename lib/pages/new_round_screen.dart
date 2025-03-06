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
          'baskets': (doc['baskets'] as List<dynamic>?)
                  ?.map((b) => Map<String, dynamic>.from(b as Map))
                  .toList() ??
              [],
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
    if (selectedCourseId == null) {
      return;
    }

    if (selectedPlayers.isEmpty) {
      return;
    }

    var selectedCourse = courses.firstWhere((c) => c['id'] == selectedCourseId,
        orElse: () => {});

    if (selectedCourse.isEmpty) {
      return;
    }

    // Ensure baskets exist and are properly formatted
    if (selectedCourse['baskets'] == null ||
        selectedCourse['baskets'] is! List) {
      return;
    }

    List<BasketScore> basketScores =
        (selectedCourse['baskets'] as List<dynamic>).map((basket) {
      var basketMap = basket as Map<String, dynamic>? ?? {};
      return BasketScore(
        basketNumber: (basketMap['basketNumber'] as num?)?.toInt() ?? 0,
        par: (basketMap['par'] as num?)?.toInt() ?? 3,
        distance: (basketMap['distance'] as num?)?.toInt() ?? 0,
      );
    }).toList();

    for (var player in selectedPlayers) {
      player.basketScores = List.from(basketScores); // Ensure separate copies
    }

    String? roundId = await RoundService().createRound(
      selectedCourseId!,
      selectedPlayers.map((p) => p.playerId).toList(),
    );

    if (roundId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Failed to create round")),
      );
      return;
    }

    // Pass data to the next screen
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => ScoringScreen(
          roundId: roundId,
          courseId: selectedCourseId!,
          players: selectedPlayers
              .map((p) => {
                    'playerId': p.playerId,
                    'playerName': p.playerName ?? "",
                  })
              .toList(),
          baskets: selectedCourse['baskets']
                  ?.map<Map<String, dynamic>>((b) => {
                        'basketNumber': b['basketNumber'],
                        'par': b['par'],
                        'distance': b['distance'],
                      })
                  .toList() ??
              [], // Ensure baskets are passed correctly
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[900],
      appBar: AppBar(
        title: Text(
          "New Round",
          style: TextStyle(
            fontSize: 25,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        backgroundColor: Colors.black,
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Select Course",
              style: TextStyle(
                fontSize: 25,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            DropdownButton<String>(
              value: selectedCourseId,
              items: courses.map<DropdownMenuItem<String>>((course) {
                return DropdownMenuItem<String>(
                  value: course['id'],
                  child: Text(course['name']),
                );
              }).toList(),
              onChanged: (String? newValue) {
                if (newValue == null) return;
                setState(() {
                  selectedCourseId = newValue;
                  selectedCourseName =
                      courses.firstWhere((c) => c['id'] == newValue)['name'];
                });
              },
            ),
            SizedBox(height: 20),
            Text(
              "Select Players",
              style: TextStyle(
                fontSize: 25,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
              selectionColor: Colors.white,
            ),
            Expanded(
              child: ListView(
                children: users.map((user) {
                  bool isSelected =
                      selectedPlayers.any((p) => p.playerId == user['id']);
                  return ListTile(
                    title: Text(
                      user['name'],
                      style: TextStyle(
                        fontSize: 20,
                        color: Colors.white,
                      ),
                    ),
                    trailing: Icon(
                      isSelected
                          ? Icons.check_box
                          : Icons.check_box_outline_blank,
                      color: isSelected ? Colors.red : null,
                    ),
                    onTap: () => togglePlayer(user),
                  );
                }).toList(),
              ),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                startRound();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                padding: EdgeInsets.symmetric(vertical: 12),
              ),
              child: Center(
                child: Text(
                  "Start Round",
                  style: TextStyle(
                      color: const Color.fromARGB(255, 255, 255, 255),
                      fontSize: 18),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
