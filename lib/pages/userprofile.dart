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
                              Text("153",
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
