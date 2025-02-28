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
        title: Text("User Profile"),
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator()) // Show loading indicator
          : errorMessage.isNotEmpty
              ? Center(
                  child: Text(
                      errorMessage)) // Show error message if there's an issue
              : Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Name: $name",
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      SizedBox(height: 10),
                      Text(
                        "Username: $username",
                        style: TextStyle(fontSize: 18),
                      ),
                      SizedBox(height: 10),
                      Text(
                        "Email: $email",
                        style: TextStyle(fontSize: 18),
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
