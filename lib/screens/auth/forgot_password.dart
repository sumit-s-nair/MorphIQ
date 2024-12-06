import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';

class PasswordRecoveryScreen extends StatefulWidget {
  const PasswordRecoveryScreen({super.key});

  @override
  PasswordRecoveryScreenState createState() => PasswordRecoveryScreenState();
}

class PasswordRecoveryScreenState extends State<PasswordRecoveryScreen> {
  final TextEditingController _emailController = TextEditingController();
  bool _isLoading = false;
  String? _message;

  Future<void> _resetPassword() async {
    setState(() {
      _isLoading = true;
      _message = null;
    });
    try {
      await FirebaseAuth.instance.sendPasswordResetEmail(email: _emailController.text.trim());
      setState(() {
        _message = 'Password reset link sent to your email!';
      });
    } on FirebaseAuthException catch (e) {
      setState(() {
        _message = e.message;
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Animated Brand Name
                Text(
                  'MorphIQ',
                  style: GoogleFonts.montserrat(
                    color: Colors.white,
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 32),

                // Email Input
                _buildTextField(
                  controller: _emailController,
                  hintText: 'Enter your email',
                  icon: FontAwesomeIcons.envelope,
                  isPassword: false,
                ),
                const SizedBox(height: 16),

                // Reset Button
                _buildButton(
                  label: 'Reset Password',
                  onPressed: _isLoading ? null : _resetPassword,
                ),
                const SizedBox(height: 12),

                // Message
                if (_message != null)
                  Text(
                    _message!,
                    style: TextStyle(color: _message == 'Password reset link sent to your email!' ? Colors.green : Colors.redAccent, fontSize: 14),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Widget to build text input fields
  Widget _buildTextField({
    required TextEditingController controller,
    required String hintText,
    required IconData icon,
    required bool isPassword,
  }) {
    return Container(
      width: double.infinity, // Ensures full-width input
      constraints: const BoxConstraints(maxWidth: 400), // Max width for larger screens
      child: TextField(
        controller: controller,
        obscureText: isPassword ? true : false,
        decoration: InputDecoration(
          prefixIcon: Icon(icon, color: Colors.white),
          hintText: hintText,
          hintStyle: const TextStyle(color: Colors.grey),
          filled: true,
          fillColor: Colors.grey[900],
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide.none,
          ),
        ),
        style: const TextStyle(color: Colors.white),
      ),
    );
  }

  // Widget to build buttons (Reset, etc.)
  Widget _buildButton({
    required String label,
    required VoidCallback? onPressed,
  }) {
    return Container(
      width: double.infinity, // Ensures full-width button
      constraints: const BoxConstraints(maxWidth: 400), // Max width for larger screens
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.blueAccent,
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 32),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
        child: Text(
          label,
          style: const TextStyle(color: Colors.white), // Explicitly set white text color
        ),
      ),
    );
  }
}
