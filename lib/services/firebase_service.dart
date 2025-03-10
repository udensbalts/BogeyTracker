import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:test_app/models/basket_model.dart';
import 'package:test_app/models/course_model.dart';

class FirebaseService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // Fetch courses from Firestore
  Future<List<Course>> getCourses() async {
    QuerySnapshot snapshot = await _db.collection('courses').get();

    return snapshot.docs.map((doc) {
      return Course.fromFirestore(doc);
    }).toList();
  }

  // Save a new course
  Future<void> saveCourse(Course course) async {
    await _db.collection('courses').add(course.toMap());
  }

  // Update course data
  Future<void> updateCourse(String docId, Course updatedCourse) async {
    await _db.collection('courses').doc(docId).update(updatedCourse.toMap());
  }

  // Delete course
  Future<void> deleteCourse(String docId) async {
    await _db.collection('courses').doc(docId).delete();
  }

  Future<List<BasketModel>> getBaskets(String courseId) async {
    try {
      DocumentSnapshot courseSnapshot =
          await _db.collection('courses').doc(courseId).get();

      if (courseSnapshot.exists) {
        List<dynamic> basketsData = courseSnapshot['baskets'];
        return basketsData.map((data) => BasketModel.fromMap(data)).toList();
      } else {
        return [];
      }
    } catch (e) {
      print("Error fetching baskets: $e");
      return [];
    }
  }
}
