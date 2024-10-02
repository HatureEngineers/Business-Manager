import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../home_screen.dart';

class PinVerificationScreen extends StatefulWidget {
  final Function toggleTheme;
  final bool isDarkTheme;

  PinVerificationScreen({required this.toggleTheme, required this.isDarkTheme});

  @override
  _PinVerificationScreenState createState() => _PinVerificationScreenState();
}

class _PinVerificationScreenState extends State<PinVerificationScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final TextEditingController _pinController = TextEditingController();
  User? _currentUser;

  @override
  void initState() {
    super.initState();
    _getCurrentUser();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
  }

  // Get the current user
  void _getCurrentUser() {
    _currentUser = _auth.currentUser;
    if (_currentUser == null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _showSnackBar('No user logged in. Please log in first.');
      });
    }
  }

  // Verify the PIN from Firestore
  void _verifyPin() async {
    if (_currentUser == null) {
      _showSnackBar('No user logged in');
      return;
    }

    String enteredPin = _pinController.text.trim();
    DocumentSnapshot userDoc = await FirebaseFirestore.instance
        .collection('users')
        .doc(_currentUser?.uid)
        .get();

    if (userDoc.exists) {
      String storedPin = userDoc['pin'];
      if (enteredPin == storedPin) {
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
        _showSnackBar('Incorrect PIN');
      }
    } else {
      _showSnackBar('No PIN found. Please set up a PIN first.');
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
      appBar: AppBar(title: Text('Enter PIN')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _pinController,
              decoration: InputDecoration(labelText: 'Enter your PIN'),
              keyboardType: TextInputType.number,
              maxLength: 4,
              obscureText: true,
            ),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: _verifyPin,
              child: Text('Verify PIN'),
            ),
          ],
        ),
      ),
    );
  }
}
