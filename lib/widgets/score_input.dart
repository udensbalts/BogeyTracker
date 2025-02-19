import 'package:flutter/material.dart';

class ScoreInput extends StatefulWidget {
  @override
  _ScoreInputState createState() => _ScoreInputState();
}

class _ScoreInputState extends State<ScoreInput> {
  String input = "";

  void enterNumber(String value) {
    setState(() {
      if (input.length < 2) {
        input += value;
      }
    });
  }

  void deleteNumber() {
    setState(() {
      if (input.isNotEmpty) {
        input = input.substring(0, input.length - 1);
      }
    });
  }

  void submitScore() {
    Navigator.pop(context, int.tryParse(input) ?? 0);
  }

  @override
  Widget build(BuildContext context) {
    return FractionallySizedBox(
      heightFactor: 0.5,
      child: Container(
        padding: EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text("Enter Score",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            SizedBox(height: 12),
            Text(input.isEmpty ? "-" : input,
                style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold)),
            SizedBox(height: 12),
            GridView.builder(
              shrinkWrap: true,
              physics: NeverScrollableScrollPhysics(),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                mainAxisSpacing: 12,
                crossAxisSpacing: 12,
                childAspectRatio: 1.5,
              ),
              itemCount: 12,
              itemBuilder: (context, index) {
                if (index == 9) return SizedBox(); // Empty space
                if (index == 10) {
                  return ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      shape: CircleBorder(),
                      padding: EdgeInsets.all(20),
                      backgroundColor: Colors.redAccent,
                    ),
                    onPressed: deleteNumber,
                    child: Icon(Icons.backspace, color: Colors.white),
                  );
                }
                if (index == 11) {
                  return ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      shape: CircleBorder(),
                      padding: EdgeInsets.all(20),
                      backgroundColor: Colors.green,
                    ),
                    onPressed: submitScore,
                    child: Icon(Icons.check, color: Colors.white),
                  );
                }
                return ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    shape: CircleBorder(),
                    padding: EdgeInsets.all(20),
                    backgroundColor: Colors.blueAccent,
                  ),
                  onPressed: () =>
                      enterNumber((index == 10 ? 0 : index + 1).toString()),
                  child: Text((index == 10 ? 0 : index + 1).toString(),
                      style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.white)),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
