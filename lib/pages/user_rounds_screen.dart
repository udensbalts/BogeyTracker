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

  @override
  Widget build(BuildContext context) {
    User? user = _auth.currentUser;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          "My Rounds",
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
      body: user == null
          ? Center(child: Text("User not logged in"))
          : StreamBuilder<QuerySnapshot>(
              stream: _firestore.collection('rounds').snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                }

                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return Center(child: Text("No rounds found."));
                }

                String userId = user.uid;

                // Filter rounds where playerId matches the current userId
                List<DocumentSnapshot> userRounds =
                    snapshot.data!.docs.where((round) {
                  var roundData = round.data() as Map<String, dynamic>;

                  // Ensure "playerScores" field exists before accessing it
                  if (!roundData.containsKey('playerScores')) return false;

                  List<dynamic> playerScores = roundData['playerScores'];
                  return playerScores
                      .any((player) => player['playerId'] == userId);
                }).toList();

                if (userRounds.isEmpty) {
                  return Center(
                      child: Text("You haven't played any rounds yet."));
                }

                return ListView.builder(
                  itemCount: userRounds.length,
                  itemBuilder: (context, index) {
                    var roundData =
                        userRounds[index].data() as Map<String, dynamic>;
                    String courseName = roundData['courseName'];
                    var dateData = roundData['date'];

                    DateTime dateTime;
                    if (dateData is Timestamp) {
                      dateTime = dateData
                          .toDate(); // Convert Firestore Timestamp to DateTime
                    } else if (dateData is String) {
                      dateTime = DateTime.tryParse(dateData) ??
                          DateTime.now(); // Parse String date
                    } else {
                      dateTime = DateTime.now();
                    }

                    String formattedDate = DateFormat('MMM d, yyyy').format(
                        dateTime); // Convert Firestore Timestamp to DateTime

                    return Card(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      color: Colors.grey[850],
                      elevation: 4,
                      margin: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                      child: ListTile(
                        contentPadding:
                            EdgeInsets.symmetric(vertical: 10, horizontal: 15),
                        leading: CircleAvatar(
                          backgroundColor: Colors.red,
                          child: Icon(Icons.sports_golf, color: Colors.white),
                        ),
                        title: Text(
                          courseName,
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                            fontSize: 18,
                          ),
                        ),
                        subtitle: Text(
                          "Date: $formattedDate",
                          style: TextStyle(
                            color: Colors.white70,
                            fontSize: 16,
                          ),
                        ),
                        trailing: Icon(Icons.arrow_forward_ios,
                            color: Colors.white54, size: 18),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => RoundDetailsScreen(
                                  roundId: userRounds[index].id),
                            ),
                          );
                        },
                      ),
                    );
                  },
                );
              },
            ),
    );
  }
}
