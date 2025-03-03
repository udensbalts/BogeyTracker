import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:test_app/pages/course_list_screen.dart';
import 'package:test_app/pages/login.dart';
import 'package:google_nav_bar/google_nav_bar.dart';
import 'package:test_app/pages/new_round_screen.dart';
import 'package:test_app/pages/profile.dart';
import 'package:test_app/pages/user_rounds_screen.dart';
import 'package:test_app/pages/userprofile.dart';

class Wrapper extends StatefulWidget {
  const Wrapper({super.key});

  @override
  State<Wrapper> createState() => _MyWidgetState();
}

class _MyWidgetState extends State<Wrapper> {
  int _selectedIndex = 0;

  // List of screens that should correspond to each tab
  final List<Widget> _widgetOptions = <Widget>[
    NewRoundScreen(),
    CourseListScreen(),
    UserRoundsScreen(),
    UserProfile(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StreamBuilder<User?>(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, snapshot) {
          // Check if the user is authenticated
          if (snapshot.hasData) {
            // Show the selected screen from _widgetOptions list
            return _widgetOptions.elementAt(_selectedIndex);
          } else {
            // Show the login screen if not authenticated
            return Login();
          }
        },
      ),
      bottomNavigationBar: Container(
        color: Colors.black,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 20),
          child: GNav(
            backgroundColor: Colors.black,
            color: Colors.white,
            activeColor: Colors.white,
            tabBackgroundColor: Colors.grey.shade800,
            padding: EdgeInsets.all(16),
            gap: 5,
            tabs: const [
              GButton(icon: Icons.home, text: "Home"),
              GButton(icon: Icons.golf_course, text: "Laukumi"),
              GButton(icon: Icons.notes_rounded, text: "Statistika"),
              GButton(icon: Icons.person_2_outlined, text: "Profils"),
            ],
            selectedIndex: _selectedIndex,
            onTabChange: (index) {
              setState(() {
                _selectedIndex = index; // Update the selected tab index
              });
            },
          ),
        ),
      ),
    );
  }
}
