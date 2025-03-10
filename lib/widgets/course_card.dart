import 'package:flutter/material.dart';
import 'package:test_app/models/course_model.dart';
import 'package:test_app/pages/basket_list.dart';
import 'package:test_app/pages/course_detail_screen.dart';
import 'package:test_app/services/firebase_service.dart';

class CourseCard extends StatelessWidget {
  final Course course;
  final VoidCallback onDelete;

  CourseCard({required this.course, required this.onDelete});

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      color: Colors.grey[850],
      margin: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      child: ListTile(
        contentPadding: EdgeInsets.symmetric(vertical: 10, horizontal: 15),
        leading: CircleAvatar(
          backgroundColor: Colors.red,
          child: Icon(Icons.map, color: Colors.white),
        ),
        title: Text(
          course.name,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.white,
            fontSize: 18,
          ),
        ),
        subtitle: Text(
          'Total Baskets: ${course.totalBaskets}',
          style: TextStyle(
            color: Colors.white70,
            fontSize: 16,
          ),
        ),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => BasketList(
                courseId: course.id,
                courseName: course.name,
              ),
            ),
          );
        },
        trailing: PopupMenuButton<String>(
          icon: Icon(Icons.more_vert, color: Colors.white54),
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
      ),
    );
  }

  void _confirmDelete(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          backgroundColor: Colors.grey[850],
          title: Text(
            "Delete Course",
            style: TextStyle(color: Colors.white),
          ),
          content: Text(
            "Are you sure you want to delete '${course.name}'?",
            style: TextStyle(color: Colors.white70),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: Text("Cancel", style: TextStyle(color: Colors.blue)),
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
