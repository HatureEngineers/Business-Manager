import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../home_screen.dart'; // Import your home screen

class LoginScreen extends StatefulWidget {
  final Function toggleTheme; // Add the toggleTheme parameter
  final bool isDarkTheme; // Add the isDarkTheme parameter

  LoginScreen({required this.toggleTheme, required this.isDarkTheme}); // Update the constructor

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _otpController = TextEditingController();

  String _verificationId = '';
  bool _isOtpSent = false;

  // Send OTP to the phone number
  Future<void> _sendOtp() async {
    final String phone = _phoneController.text.trim();

    if (phone.isNotEmpty) {
      await _auth.verifyPhoneNumber(
        phoneNumber: '+88$phone', // Assuming Bangladesh's country code
        verificationCompleted: (PhoneAuthCredential credential) async {
          // Auto-verification
          await _auth.signInWithCredential(credential);
          _navigateToHomeScreen();
        },
        verificationFailed: (FirebaseAuthException e) {
          _showSnackBar('Verification failed: ${e.message}');
        },
        codeSent: (String verificationId, int? resendToken) {
          setState(() {
            _verificationId = verificationId;
            _isOtpSent = true;
          });
        },
        codeAutoRetrievalTimeout: (String verificationId) {
          _verificationId = verificationId;
        },
      );
    } else {
      _showSnackBar('Please enter a valid phone number');
    }
  }

  // Verify OTP and navigate to home screen
  Future<void> _verifyOtp() async {
    final String otp = _otpController.text.trim();
    if (_verificationId.isNotEmpty && otp.isNotEmpty) {
      PhoneAuthCredential credential = PhoneAuthProvider.credential(
        verificationId: _verificationId,
        smsCode: otp,
      );
      try {
        await _auth.signInWithCredential(credential);
        _navigateToHomeScreen();
      } catch (e) {
        _showSnackBar('Invalid OTP');
      }
    } else {
      _showSnackBar('Please enter the OTP');
    }
  }

  // Show SnackBar
  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  // Navigate to home screen after successful login
  void _navigateToHomeScreen() {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (_) => HomeScreen(
          toggleTheme: widget.toggleTheme, // Pass the toggleTheme to HomeScreen
          isDarkTheme: widget.isDarkTheme, // Pass the isDarkTheme state to HomeScreen
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Login / Register')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            if (!_isOtpSent) ...[
              TextField(
                controller: _phoneController,
                decoration: InputDecoration(labelText: 'Phone Number'),
                keyboardType: TextInputType.phone,
              ),
              SizedBox(height: 16), // Add spacing
              ElevatedButton(
                onPressed: _sendOtp,
                child: Text('Send OTP'),
              ),
            ] else ...[
              TextField(
                controller: _otpController,
                decoration: InputDecoration(labelText: 'Enter OTP'),
                keyboardType: TextInputType.number,
              ),
              SizedBox(height: 16), // Add spacing
              ElevatedButton(
                onPressed: _verifyOtp,
                child: Text('Verify OTP'),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
