import 'package:flutter/material.dart';
import 'package:test_app/models/course_model.dart';
import 'package:test_app/pages/course_detail_screen.dart';
import 'package:test_app/services/firebase_service.dart';

class CourseCard extends StatelessWidget {
  final Course course;
  final VoidCallback onDelete;

  CourseCard({required this.course, required this.onDelete});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      margin: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      child: ListTile(
        title: Text(
          course.name,
          style: TextStyle(
              fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
        ),
        subtitle: Text(
          'Total Baskets: ${course.totalBaskets}',
          style: TextStyle(fontSize: 15, color: Colors.white),
        ),
        trailing: PopupMenuButton<String>(
          iconColor: Colors.white,
          onSelected: (value) {
            if (value == 'edit') {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => CourseDetailScreen(course: course),
                ),
              );
            } else if (value == 'delete') {
              _confirmDelete(context);
            }
          },
          itemBuilder: (context) => [
            PopupMenuItem(value: 'edit', child: Text('Edit')),
            PopupMenuItem(value: 'delete', child: Text('Delete')),
          ],
        ),
        tileColor: Color(0xFF53354A),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
    );
  }

  void _confirmDelete(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: Text("Delete Course"),
          content: Text("Are you sure you want to delete '${course.name}'?"),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: Text("Cancel"),
            ),
            TextButton(
              onPressed: () {
                FirebaseService().deleteCourse(course.id);
                onDelete();
                Navigator.pop(dialogContext);
              },
              child: Text("Delete", style: TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    );
  }
}
