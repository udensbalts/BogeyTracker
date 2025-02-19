import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:test_app/pages/forgot.dart';
import 'package:test_app/pages/signup.dart';
import 'package:get/get.dart';

class Login extends StatefulWidget {
  const Login({super.key});

  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> {
  TextEditingController email = TextEditingController();
  TextEditingController password = TextEditingController();

  signIn() async {
    await FirebaseAuth.instance
        .signInWithEmailAndPassword(email: email.text, password: password.text);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color(0xFF53354A),
        title: Text(
          "Login",
          style: TextStyle(
            color: const Color(0xFFFFFFFF),
            fontSize: 30.0,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      backgroundColor: Color(0xFF2B2E4A),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            TextField(
              style: TextStyle(
                color: const Color(0xFFFFFFFF),
                fontSize: 16.0,
                fontWeight: FontWeight.bold,
              ),
              controller: email,
              decoration: InputDecoration(
                hintText: "Ievadi epastu",
                prefixIcon: Icon(
                  Icons.email_rounded,
                  color: Color(0xFFFFFFFF),
                ),
              ),
            ),
            TextField(
              controller: password,
              decoration: InputDecoration(
                hintText: "Ievadi paroli",
                border: OutlineInputBorder(),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.blue, width: 2.0),
                ),
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(
                    color: Color(0xFFFFFFFF),
                  ),
                ),
                prefixIcon: Icon(
                  Icons.password_outlined,
                  color: Color(0xFFFFFFFF),
                ),
              ),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                foregroundColor: Colors.white,
                backgroundColor: Color(0xFF53354A),
              ),
              onPressed: (() => signIn()),
              child: Text("Pieslegties"),
            ),
            SizedBox(height: 30),
            ElevatedButton(
                style: ElevatedButton.styleFrom(
                  foregroundColor: Colors.white,
                  backgroundColor: Color(0xFF53354A),
                ),
                onPressed: (() => Get.to(Signup())),
                child: Text("Registreties")),
            SizedBox(height: 30),
            ElevatedButton(
                style: ElevatedButton.styleFrom(
                  foregroundColor: Colors.white,
                  backgroundColor: Color(0xFF53354A),
                ),
                onPressed: (() => Get.to(Forgot())),
                child: Text("Aizmirsu paroli"))
          ],
        ),
      ),
    );
  }
}
