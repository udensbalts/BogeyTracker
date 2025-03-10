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
    if (input.isNotEmpty) {
      Navigator.pop(context, int.parse(input));
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      bottom: true,
      child: FractionallySizedBox(
        heightFactor: 1.3,
        child: Container(
          padding: EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.grey[900],
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                "Enter Score",
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              SizedBox(height: 12),
              Container(
                padding: EdgeInsets.symmetric(vertical: 12, horizontal: 24),
                decoration: BoxDecoration(
                  color: Colors.grey[800],
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  input.isEmpty ? "-" : input,
                  style: TextStyle(
                    fontSize: 40,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
              SizedBox(height: 20),
              Expanded(
                child: GridView.count(
                  crossAxisCount: 3,
                  mainAxisSpacing: 12,
                  crossAxisSpacing: 12,
                  childAspectRatio: 1.2,
                  children: _buildKeypadButtons(),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  List<Widget> _buildKeypadButtons() {
    List<String> buttons = [
      "1",
      "2",
      "3",
      "4",
      "5",
      "6",
      "7",
      "8",
      "9",
      "+",
      "0",
      "-",
    ];

    return buttons.map((label) {
      if (label.isEmpty) return SizedBox();
      if (label == "-") {
        return _buildIconButton(
            Icons.backspace, Colors.redAccent, deleteNumber);
      } else if (label == "+") {
        return _buildIconButton(Icons.check, Colors.green, submitScore);
      } else {
        return _buildButton(label, Colors.grey, () => enterNumber(label));
      }
    }).toList();
  }

  Widget _buildButton(String text, Color color, VoidCallback onPressed) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        padding: EdgeInsets.all(16),
        backgroundColor: color,
        elevation: 4,
      ),
      onPressed: onPressed,
      child: Text(
        text,
        style: TextStyle(
            fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white),
      ),
    );
  }

  Widget _buildIconButton(IconData icon, Color color, VoidCallback onPressed) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        padding: EdgeInsets.all(16),
        backgroundColor: color,
        elevation: 4,
      ),
      onPressed: onPressed,
      child: Icon(icon, color: Colors.white, size: 28),
    );
  }
}
