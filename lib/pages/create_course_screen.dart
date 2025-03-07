import 'package:flutter/material.dart';
import 'package:test_app/models/course_model.dart';
import 'package:test_app/services/firebase_service.dart';

class CreateCourseScreen extends StatefulWidget {
  @override
  _CreateCourseScreenState createState() => _CreateCourseScreenState();
}

class _CreateCourseScreenState extends State<CreateCourseScreen> {
  final TextEditingController courseNameController = TextEditingController();
  final TextEditingController basketCountController = TextEditingController();
  List<TextEditingController> parControllers = [];
  List<TextEditingController> distanceControllers = [];

  List<Basket> baskets = [];

  // Generates input fields dynamically when basket count changes
  void generateBasketFields() {
    int basketCount = int.tryParse(basketCountController.text) ?? 0;
    if (basketCount <= 0) return;

    parControllers.clear();
    distanceControllers.clear();
    baskets.clear();

    for (int i = 0; i < basketCount; i++) {
      parControllers.add(TextEditingController());
      distanceControllers.add(TextEditingController());
    }

    setState(() {});
  }

  void saveCourse() async {
    String courseName = courseNameController.text.trim();
    int totalBaskets = int.tryParse(basketCountController.text) ?? 0;

    if (courseName.isEmpty || totalBaskets <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Please enter valid course details."),
          backgroundColor: Colors.redAccent,
        ),
      );
      return;
    }

    baskets.clear();
    for (int i = 0; i < totalBaskets; i++) {
      int par = int.tryParse(parControllers[i].text) ?? 0;
      double distance = double.tryParse(distanceControllers[i].text) ?? 0.0;

      baskets.add(Basket(basketNumber: i + 1, par: par, distance: distance));
    }

    Course course = Course(
      name: courseName,
      totalBaskets: totalBaskets,
      baskets: baskets,
      id: '',
    );

    await FirebaseService().saveCourse(course);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text("Course saved successfully!"),
        backgroundColor: Colors.green,
      ),
    );

    courseNameController.clear();
    basketCountController.clear();
    setState(() {
      parControllers.clear();
      distanceControllers.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Create Disc Golf Course',
          style: TextStyle(
            fontSize: 25,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        backgroundColor: Colors.black,
      ),
      backgroundColor: Colors.grey[900],
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildTextField(courseNameController, "Course Name", Icons.flag),
            SizedBox(height: 16),
            _buildTextField(
                basketCountController, "Total Baskets", Icons.looks_one,
                keyboardType: TextInputType.number,
                onChanged: (_) => generateBasketFields()),

            SizedBox(height: 16),

            if (parControllers.isNotEmpty)
              Text(
                "Basket Details",
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold),
              ),

            SizedBox(height: 10),

            // Baskets List
            ListView.builder(
              shrinkWrap: true,
              physics: NeverScrollableScrollPhysics(),
              itemCount: parControllers.length,
              itemBuilder: (context, index) {
                return Card(
                  color: Colors.grey[800],
                  margin: EdgeInsets.symmetric(vertical: 6),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10)),
                  child: Padding(
                    padding: const EdgeInsets.all(10.0),
                    child: Column(
                      children: [
                        Text(
                          'Basket ${index + 1}',
                          style: TextStyle(
                              color: Colors.white, fontWeight: FontWeight.bold),
                        ),
                        SizedBox(height: 8),
                        _buildTextField(
                            parControllers[index], "Par", Icons.golf_course,
                            keyboardType: TextInputType.number),
                        SizedBox(height: 8),
                        _buildTextField(distanceControllers[index],
                            "Distance (meters)", Icons.straighten,
                            keyboardType: TextInputType.number),
                      ],
                    ),
                  ),
                );
              },
            ),

            SizedBox(height: 20),

            // Save Button
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.redAccent,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
                padding: EdgeInsets.symmetric(vertical: 14),
                minimumSize: Size(double.infinity, 50),
              ),
              onPressed: saveCourse,
              child: Text(
                'Save Course',
                style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField(
    TextEditingController controller,
    String label,
    IconData icon, {
    TextInputType keyboardType = TextInputType.text,
    void Function(String)? onChanged,
  }) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      style: TextStyle(color: Colors.white),
      onChanged: onChanged,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(color: Colors.white70),
        prefixIcon: Icon(icon, color: Colors.redAccent),
        filled: true,
        fillColor: Colors.grey[800],
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }
}
