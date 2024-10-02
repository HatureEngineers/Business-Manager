import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../home_screen.dart';

class PinSetupScreen extends StatefulWidget {
  final Function toggleTheme;
  final bool isDarkTheme;

  PinSetupScreen({required this.toggleTheme, required this.isDarkTheme});

  @override
  _PinSetupScreenState createState() => _PinSetupScreenState();
}

class _PinSetupScreenState extends State<PinSetupScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final TextEditingController _pinController = TextEditingController();

  // Save the PIN to Firestore
  void _savePin() async {
    String pin = _pinController.text.trim();
    if (pin.length == 4) {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(_auth.currentUser?.uid)
          .set({'pin': pin}, SetOptions(merge: true));

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => HomeScreen(
            toggleTheme: widget.toggleTheme,
            isDarkTheme: widget.isDarkTheme,
          ),
        ),
      );
    } else {
      _showSnackBar('Please enter a valid 4-digit PIN');
    }
  }

  // Show SnackBar for messages
  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Set Up PIN')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _pinController,
              decoration: InputDecoration(labelText: 'Enter 4-digit PIN'),
              keyboardType: TextInputType.number,
              maxLength: 4,
              obscureText: true, // Hide the pin input
            ),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: _savePin,
              child: Text('Save PIN'),
            ),
          ],
        ),
      ),
    );
  }
}
