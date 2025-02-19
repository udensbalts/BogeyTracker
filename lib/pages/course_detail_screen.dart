import 'package:flutter/material.dart';
import 'package:test_app/models/course_model.dart';
import 'package:test_app/services/firebase_service.dart';

class CourseDetailScreen extends StatefulWidget {
  final Course course;

  CourseDetailScreen({required this.course});

  @override
  _CourseDetailScreenState createState() => _CourseDetailScreenState();
}

class _CourseDetailScreenState extends State<CourseDetailScreen> {
  late TextEditingController nameController;

  @override
  void initState() {
    super.initState();
    nameController = TextEditingController(text: widget.course.name);
  }

  void updateCourse() async {
    Course updatedCourse = Course(
      id: widget.course.id,
      name: nameController.text,
      totalBaskets: widget.course.totalBaskets,
      baskets: widget.course.baskets,
    );

    await FirebaseService().updateCourse(widget.course.id, updatedCourse);
    Navigator.pop(context, true); // Refresh list on return
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Edit Course')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: nameController,
              decoration: InputDecoration(labelText: 'Course Name'),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: updateCourse,
              child: Text('Update Course'),
            ),
          ],
        ),
      ),
    );
  }
}
