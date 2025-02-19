import 'package:flutter/material.dart';
import 'package:test_app/models/course_model.dart'; // Import the course models
import 'package:test_app/services/firebase_service.dart'; // Firebase service to save course data

class CreateCourseScreen extends StatefulWidget {
  @override
  _CreateCourseScreenState createState() => _CreateCourseScreenState();
}

class _CreateCourseScreenState extends State<CreateCourseScreen> {
  final TextEditingController courseNameController = TextEditingController();
  final TextEditingController basketCountController = TextEditingController();
  List<TextEditingController> parControllers = [];
  List<TextEditingController> distanceControllers = [];

  // This will store the basket details once entered
  List<Basket> baskets = [];

  // Generate input fields for baskets
  void generateBasketFields() {
    int basketCount = int.parse(basketCountController.text);

    // Clear existing controllers if basket count changes
    parControllers.clear();
    distanceControllers.clear();
    baskets.clear();

    // Create new controllers based on basket count
    for (int i = 0; i < basketCount; i++) {
      parControllers.add(TextEditingController());
      distanceControllers.add(TextEditingController());
    }

    setState(() {}); // Rebuild the UI with new input fields
  }

  void saveCourse() async {
    String courseName = courseNameController.text;
    int totalBaskets = int.parse(basketCountController.text);

    // Convert the par and distance inputs into Basket objects
    for (int i = 0; i < totalBaskets; i++) {
      int par = int.parse(parControllers[i].text);
      double distance = double.parse(distanceControllers[i].text);

      baskets.add(Basket(par: par, distance: distance));
    }

    Course course = Course(
      name: courseName,
      totalBaskets: totalBaskets,
      baskets: baskets,
      id: '',
    );

    // Save to Firestore (Use FirebaseService)
    FirebaseService().saveCourse(course);
    courseNameController.clear();
    basketCountController.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Create Disc Golf Course')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Course Name Input
            TextField(
              controller: courseNameController,
              decoration: InputDecoration(
                labelText: 'Course Name',
              ),
            ),
            SizedBox(height: 16),

            // Total Baskets Input
            TextField(
              controller: basketCountController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: 'Total Baskets',
              ),
              onChanged: (value) {
                if (value.isNotEmpty) {
                  generateBasketFields(); // Generate fields when basket count is entered
                }
              },
            ),
            SizedBox(height: 16),

            // Dynamically generated basket input fields
            Expanded(
              child: ListView.builder(
                itemCount: parControllers.length,
                itemBuilder: (context, index) {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Basket ${index + 1}'),
                      TextField(
                        controller: parControllers[index],
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(labelText: 'Par'),
                      ),
                      TextField(
                        controller: distanceControllers[index],
                        keyboardType: TextInputType.number,
                        decoration:
                            InputDecoration(labelText: 'Distance (in meters)'),
                      ),
                      SizedBox(height: 16),
                    ],
                  );
                },
              ),
            ),

            // Save Course Button
            ElevatedButton(
              onPressed: saveCourse,
              child: Text('Save Course'),
            ),
          ],
        ),
      ),
    );
  }
}
