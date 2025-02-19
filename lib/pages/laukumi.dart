import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:test_app/pages/create_course_screen.dart';
import 'package:test_app/services/firestore.dart';

class LaukumiList extends StatelessWidget {
  final FireStoreService fireStoreService = FireStoreService();
  final TextEditingController textController = TextEditingController();
  final TextEditingController grozuController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color(0xFF53354A),
        title: Text(
          'Laukumi',
          style: TextStyle(
            fontSize: 25,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
        centerTitle: true,
      ),
      backgroundColor: Color(0xFF2B2E4A),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('laukumi').snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Something went wrong!'));
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(child: Text('No laukumi available.'));
          }

          var laukumi = snapshot.data!.docs;

          return ListView.builder(
            itemCount: laukumi.length,
            itemBuilder: (context, index) {
              var laukums = laukumi[index];
              var grozi = laukumi[index];
              return Card(
                elevation: 5,
                margin: EdgeInsets.symmetric(vertical: 10, horizontal: 15),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
                child: ListTile(
                  title: Text(
                    laukums['laukums'],
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                  subtitle: Text(
                    "Grozu skaits: " + grozi['grozi'],
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: const Color.fromARGB(255, 250, 250, 250),
                    ),
                  ),
                  tileColor: Color(0xFF53354A),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  minVerticalPadding: 30.0,
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            PageRouteBuilder(
              pageBuilder: (context, animation, secondaryAnimation) =>
                  CreateCourseScreen(),
              transitionsBuilder:
                  (context, animation, secondaryAnimation, child) {
                return ScaleTransition(
                  scale: animation,
                  child: child,
                );
              },
            ),
          );
        },
        child: Icon(Icons.add),
      ),
    );
  }
}
