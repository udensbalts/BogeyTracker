import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class UserProfile extends StatefulWidget {
  const UserProfile({Key? key}) : super(key: key);

  @override
  _UserProfileState createState() => _UserProfileState();
}

class _UserProfileState extends State<UserProfile> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  late String name;
  late String username;
  late String email;
  int totalRounds = 0;
  int totalThrows = 0;
  List bestRounds = [];

  bool isLoading = true;
  String errorMessage = "";

  @override
  void initState() {
    super.initState();
    _getUserProfile();
  }

  // Method to fetch user profile data from Firestore
  _getUserProfile() async {
    try {
      User? user = _auth.currentUser;
      if (user != null) {
        // Fetch user data from Firestore using the current user's UID
        DocumentSnapshot userDoc =
            await _firestore.collection('users').doc(user.uid).get();

        if (userDoc.exists) {
          setState(() {
            name = userDoc['name'];
            username = userDoc['username'];
            email = userDoc['email'];
            isLoading = false;
          });
          _getTotalRounds(user.uid);
          _getTotalThrows(user.uid);
          _getBestRounds(user.uid);
        }
      } else {
        setState(() {
          errorMessage = "User not logged in.";
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        errorMessage = "Failed to load user data: $e";
        isLoading = false;
      });
    }
  }

  //Fetch total rounds
  Future<void> _getTotalRounds(String playerId) async {
    try {
      QuerySnapshot roundsSnapshot =
          await _firestore.collection('rounds').get();

      int count = 0;
      for (var doc in roundsSnapshot.docs) {
        var data = doc.data() as Map<String, dynamic>;
        List<dynamic> playerScores = data['playerScores'] ?? [];

        bool playerFound =
            playerScores.any((player) => player['playerId'] == playerId);
        if (playerFound) count++;
      }

      setState(() {
        totalRounds = count;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        errorMessage = "Failed to load rounds: $e";
        isLoading = false;
      });
    }
  }

  Future<void> _getTotalThrows(String playerId) async {
    // Fetch total throws
    try {
      QuerySnapshot throwsSnapshot =
          await _firestore.collection('rounds').get();
      int totalCount = 0;
      for (var doc in throwsSnapshot.docs) {
        var data = doc.data() as Map<String, dynamic>;
        List<dynamic> playerScores = data['playerScores'] ?? [];

        //Find players scores
        for (var player in playerScores) {
          if (player['playerId'] == playerId) {
            List<dynamic> basketScores = player['basketScores'] ?? [];

            //Sum all scores
            for (var basket in basketScores) {
              totalCount += (basket['score'] ?? 0) as int;
            }
          }
        }
      }
      setState(() {
        totalThrows = totalCount;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        errorMessage = "Failed to load throws: $e";
        isLoading = false;
      });
    }
  }

  Future<void> _getBestRounds(String playerId) async {
    try {
      QuerySnapshot roundsSnapshot =
          await _firestore.collection('rounds').get();

      Map<String, Map<String, dynamic>> bestRoundsByCourse = {};

      for (var doc in roundsSnapshot.docs) {
        var data = doc.data() as Map<String, dynamic>;
        String courseId = data['courseId'];
        String courseName = data['courseName'];
        List<dynamic> playerScores = data['playerScores'] ?? [];

        for (var player in playerScores) {
          if (player['playerId'] == playerId) {
            List<dynamic> basketScores = player['basketScores'] ?? [];

            int totalScore = basketScores.fold(
                0, (sum, basket) => sum + (basket['score'] ?? 0) as int);

            // If the course is not in the map or this round has a lower score, update it
            if (!bestRoundsByCourse.containsKey(courseId) ||
                totalScore < bestRoundsByCourse[courseId]!['totalScore']) {
              bestRoundsByCourse[courseId] = {
                'courseId': courseId,
                'courseName': courseName,
                'totalScore': totalScore
              };
            }
          }
        }
      }

      // Convert map to list for displaying in UI
      setState(() {
        bestRounds = bestRoundsByCourse.values.toList();
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        errorMessage = "Failed to load best rounds: $e";
        isLoading = false;
      });
    }
  }

  void _logout() async {
    await _auth.signOut();
    if (mounted) {
      Navigator.pushReplacementNamed(
          context, '/login'); // Redirect to login page
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "User Profile",
          style: TextStyle(
            fontSize: 25,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.black,
      ),
      backgroundColor: Colors.grey[900],
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : errorMessage.isNotEmpty
              ? Center(child: Text(errorMessage))
              : Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Profile Picture
                      CircleAvatar(
                        radius: 75,
                        backgroundColor: Colors.brown.shade800,
                        child: const Text('AH'),
                      ),
                      SizedBox(height: 10),
                      // Column with user info
                      Text(
                        "Name: $name",
                        style: TextStyle(
                            fontSize: 25,
                            fontWeight: FontWeight.bold,
                            color: Colors.white),
                      ),
                      SizedBox(height: 10),
                      Text(
                        "@$username",
                        style: TextStyle(fontSize: 18, color: Colors.red),
                      ),
                      SizedBox(height: 20), // Space before row

                      // New Row with two children
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Column(
                            children: [
                              Text("$totalRounds",
                                  style: TextStyle(
                                      fontSize: 22,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.red)),
                              Text("Rounds",
                                  style: TextStyle(
                                      fontSize: 16,
                                      color: const Color.fromARGB(
                                          255, 255, 255, 255))),
                            ],
                          ),
                          SizedBox(width: 40), // Space between items
                          Column(
                            children: [
                              Text("$totalThrows",
                                  style: TextStyle(
                                      fontSize: 22,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.red)),
                              Text("Throws",
                                  style: TextStyle(
                                      fontSize: 16,
                                      color: const Color.fromARGB(
                                          255, 255, 255, 255))),
                            ],
                          ),
                        ],
                      ),
                      SizedBox(height: 20),

                      // Best Rounds Section
                      Text(
                        "Best Rounds",
                        style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: Colors.white),
                      ),
                      SizedBox(height: 10),

                      // List of Best Rounds
                      bestRounds.isEmpty
                          ? Text(
                              "No best rounds available",
                              style: TextStyle(
                                  color: Colors.white70, fontSize: 16),
                            )
                          : SizedBox(
                              height: 250,
                              child: ListView.builder(
                                shrinkWrap: true,
                                itemCount: bestRounds.length,
                                itemBuilder: (context, index) {
                                  final round = bestRounds[index];
                                  return Card(
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(
                                          15), // Rounded corners
                                    ),
                                    color: Colors.grey[850],
                                    elevation: 4, // Adds a shadow effect
                                    margin: EdgeInsets.symmetric(
                                        vertical: 6,
                                        horizontal:
                                            12), // More balanced spacing
                                    child: ListTile(
                                      contentPadding: EdgeInsets.symmetric(
                                          vertical: 10, horizontal: 15),
                                      title: Text(
                                        round['courseName'],
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 18,
                                        ),
                                      ),
                                      subtitle: Text(
                                        "Score: ${round['totalScore']}",
                                        style: TextStyle(
                                          color: Colors.white70,
                                          fontSize: 16,
                                        ),
                                      ),
                                      leading: CircleAvatar(
                                        backgroundColor: Colors.red,
                                        child: Icon(Icons.sports_golf,
                                            color: Colors.white),
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ),
                    ],
                  ),
                ),
      floatingActionButton: FloatingActionButton(
        onPressed: _logout,
        backgroundColor: Colors.red,
        child: Icon(Icons.logout),
        tooltip: "Log Out",
      ),
    );
  }
}
