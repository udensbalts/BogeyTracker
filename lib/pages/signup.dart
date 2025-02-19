import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:test_app/pages/wrapper.dart';
import 'package:get/get.dart';

class Signup extends StatefulWidget {
  const Signup({super.key});

  @override
  State<Signup> createState() => _SignupState();
}

class _SignupState extends State<Signup> {
  TextEditingController email = TextEditingController();
  TextEditingController password = TextEditingController();
  TextEditingController name = TextEditingController();
  TextEditingController username = TextEditingController();

  signup() async {
    try {
      UserCredential userCredential = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(
              email: email.text, password: password.text);

      // Get the UID of the new user
      String uid = userCredential.user!.uid;

      // Store additional user data in Firestore
      await FirebaseFirestore.instance.collection('users').doc(uid).set({
        'name': name.text,
        'username': username.text,
        'email': email.text,
        'createdAt': Timestamp.now(),
      });

      // Navigate to the next page after successful signup
      Get.offAll(() => Wrapper());
    } catch (e) {
      print('Signup error: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Signup"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            TextField(
              controller: name,
              decoration: InputDecoration(hintText: "Enter your name"),
            ),
            TextField(
              controller: username,
              decoration: InputDecoration(hintText: "Enter a username"),
            ),
            TextField(
              controller: email,
              decoration: InputDecoration(hintText: "Enter your email"),
            ),
            TextField(
              controller: password,
              obscureText: true, // Hide the password
              decoration: InputDecoration(hintText: "Enter your password"),
            ),
            ElevatedButton(
              onPressed: signup,
              child: Text("Create Account"),
            ),
          ],
        ),
      ),
    );
  }
}
