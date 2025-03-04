import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:test_app/pages/round_details_screen.dart';

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
        title: Text("My Rounds"),
      ),
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
                    String date = roundData['date'];

                    return Card(
                      margin: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                      child: ListTile(
                        title: Text(courseName,
                            style: TextStyle(fontWeight: FontWeight.bold)),
                        subtitle: Text("Date: $date"),
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
