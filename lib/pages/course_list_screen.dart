import 'package:flutter/material.dart';
import 'package:test_app/models/course_model.dart';
import 'package:test_app/pages/create_course_screen.dart';
import 'package:test_app/services/firebase_service.dart';
import 'package:test_app/widgets/course_card.dart';

class CourseListScreen extends StatefulWidget {
  @override
  _CourseListScreenState createState() => _CourseListScreenState();
}

class _CourseListScreenState extends State<CourseListScreen> {
  late Future<List<Course>> coursesFuture;

  @override
  void initState() {
    super.initState();
    coursesFuture = FirebaseService().getCourses();
  }

  void refreshCourses() {
    setState(() {
      coursesFuture = FirebaseService().getCourses();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color(0xFF2B2E4A),
        title: Text(
          'Laukumi',
          style: TextStyle(
            fontSize: 25,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        centerTitle: true,
      ),
      backgroundColor: Color(0xFF2B2E4A),
      body: FutureBuilder<List<Course>>(
        future: coursesFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text('No courses available'));
          }

          List<Course> courses = snapshot.data!;

          return ListView.builder(
            itemCount: courses.length,
            itemBuilder: (context, index) {
              return CourseCard(
                course: courses[index],
                onDelete: refreshCourses,
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
