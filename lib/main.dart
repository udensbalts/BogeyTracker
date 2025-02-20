import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:test_app/pages/new_round_screen.dart';
import 'package:test_app/pages/wrapper.dart';
import 'package:get/get.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(MyWidget());
}

class MyWidget extends StatelessWidget {
  const MyWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      home: Wrapper(),
      routes: {
        '/home': (context) => Wrapper(),
      },
    );
  }
}
