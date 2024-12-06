import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:google_fonts/google_fonts.dart';

class LoginScreen extends StatefulWidget {
  final VoidCallback onSignUpPressed;

  const LoginScreen({super.key, required this.onSignUpPressed});

  @override
  LoginScreenState createState() => LoginScreenState();
}

class LoginScreenState extends State<LoginScreen>
    with SingleTickerProviderStateMixin {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _isLoading = false;
  String? _errorMessage;
  bool _obscurePassword = true;

  // Color palette
  final Color primaryColor = const Color(0xFF1E3A8A); // Dark Blue
  final Color accentColor = const Color(0xFF10B981); // Light Green
  final Color errorColor = Colors.redAccent;

  // Animation variables
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();

    // Initialize animations
    _controller = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeIn),
    );

    _scaleAnimation = Tween<double>(begin: 0.9, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
    );

    _controller.forward(); // Start the animations
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    setState(() => _isLoading = true);
    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );
      // Navigate to the main screen after login
    } on FirebaseAuthException catch (e) {
      setState(() => _errorMessage = e.message);
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _signInWithGoogle() async {
    setState(() => _isLoading = true);
    try {
      final GoogleSignIn googleSignIn = GoogleSignIn(
        clientId:
            '95411355053-lekorcvtk023dfai7n5h90tec992miuu.apps.googleusercontent.com', // Use your actual client ID here
      );
      final GoogleSignInAccount? googleUser = await googleSignIn.signIn();
      if (googleUser == null) return; // User canceled sign-in
      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      // Create Firebase credentials using Google token
      final AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      // Sign in with Firebase using the credentials
      await FirebaseAuth.instance.signInWithCredential(credential);
      Navigator.pushReplacementNamed(context, '/home');
    } on FirebaseAuthException catch (e) {
      setState(() => _errorMessage = e.message);
    } finally {
      setState(() => _isLoading = false);
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
                FadeTransition(
                  opacity: _fadeAnimation,
                  child: ScaleTransition(
                    scale: _scaleAnimation,
                    child: Text(
                      'MorphIQ',
                      style: GoogleFonts.montserrat(
                        color: Colors.white,
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 32),

                // Email Input
                _buildTextField(
                  controller: _emailController,
                  hintText: 'Email',
                  icon: FontAwesomeIcons.envelope,
                  isPassword: false,
                ),
                const SizedBox(height: 12),

                // Password Input
                _buildTextField(
                  controller: _passwordController,
                  hintText: 'Password',
                  icon: FontAwesomeIcons.lock,
                  isPassword: true,
                ),
                const SizedBox(height: 4),

                // Forgot Password Button (aligned to the right)
                Container(
                  constraints: const BoxConstraints(maxWidth: 400),
                  child: Align(
                    alignment: Alignment.centerRight,
                    child: TextButton(
                      onPressed: () {
                        Navigator.pushNamed(context, '/forgot-password');
                      },
                      child: const Text(
                        "Forgot password?",
                        style: TextStyle(color: Colors.blueAccent),
                      ),
                    ),
                  ),
                ),

                // Error message
                if (_errorMessage != null)
                  Text(
                    _errorMessage!,
                    style: TextStyle(color: errorColor, fontSize: 14),
                  ),

                const SizedBox(height: 16),

                // Login Button
                _buildButton(
                  label: 'Login',
                  onPressed: _isLoading ? null : _login,
                ),
                const SizedBox(height: 12),

                // OR Separator
                Container(
                  constraints: const BoxConstraints(maxWidth: 400),
                  child: const Row(
                    children: [
                      Expanded(child: Divider(color: Colors.white)),
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 8.0),
                        child: Text(
                          'OR',
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                      Expanded(child: Divider(color: Colors.white)),
                    ],
                  ),
                ),
                const SizedBox(height: 12),

                // Google Sign-In Button
                _buildButton(
                  label: 'Sign in with Google',
                  onPressed: _isLoading ? null : _signInWithGoogle,
                  icon: FontAwesomeIcons.google,
                  backgroundColor: accentColor,
                ),
                const SizedBox(height: 12),

                // Sign up Link
                TextButton(
                  onPressed: widget.onSignUpPressed,
                  child: Text(
                    "Don't have an account? Sign up",
                    style: GoogleFonts.montserrat(color: Colors.blueAccent),
                  ),
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
      constraints:
          const BoxConstraints(maxWidth: 400), // Max width for larger screens
      child: TextField(
        controller: controller,
        obscureText: isPassword ? _obscurePassword : false,
        decoration: InputDecoration(
          prefixIcon: Icon(icon, color: Colors.white),
          suffixIcon: isPassword
              ? IconButton(
                  icon: Icon(
                    _obscurePassword
                        ? FontAwesomeIcons.eyeSlash
                        : FontAwesomeIcons.eye,
                    color: Colors.white,
                  ),
                  onPressed: () {
                    setState(() {
                      _obscurePassword = !_obscurePassword;
                    });
                  },
                )
              : null,
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

  // Widget to build buttons (Login, Google sign-in)
  Widget _buildButton({
    required String label,
    required VoidCallback? onPressed,
    IconData? icon,
    Color backgroundColor = Colors.blueAccent,
  }) {
    return Container(
      width: double.infinity, // Ensures full-width button
      constraints:
          const BoxConstraints(maxWidth: 400), // Max width for larger screens
      child: ElevatedButton.icon(
        onPressed: onPressed,
        icon: icon != null ? Icon(icon, color: Colors.white) : Container(),
        label: Text(
          label,
          style: const TextStyle(
              color: Colors.white), // Explicitly set white text color
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: backgroundColor,
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 32),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      ),
    );
  }
}
