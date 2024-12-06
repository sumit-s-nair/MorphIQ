import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:google_fonts/google_fonts.dart';

class SignUpScreen extends StatefulWidget {
  final VoidCallback onSignInPressed;

  const SignUpScreen({super.key, required this.onSignInPressed});

  @override
  SignUpScreenState createState() => SignUpScreenState();
}

class SignUpScreenState extends State<SignUpScreen>
    with SingleTickerProviderStateMixin {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();
  bool _isLoading = false;
  String? _errorMessage;
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

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

  Future<void> _signUp() async {
    setState(() => _isLoading = true);
    try {
      if (_passwordController.text.trim() !=
          _confirmPasswordController.text.trim()) {
        setState(() => _errorMessage = 'Passwords do not match');
        return;
      }
      await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );

      if (mounted) {
        Navigator.pushReplacementNamed(context, '/home');
      }
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
            '95411355053-lekorcvtk023dfai7n5h90tec992miuu.apps.googleusercontent.com',
      );

      final GoogleSignInAccount? googleUser = await googleSignIn.signIn();
      if (googleUser == null) return;
      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      // Create Firebase credentials using Google token
      final AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      // Sign in with Firebase using the credentials
      await FirebaseAuth.instance.signInWithCredential(credential);

      if (mounted) {
        Navigator.pushReplacementNamed(context, '/home');
      }

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
                const SizedBox(height: 12),

                // Confirm Password Input
                _buildTextField(
                  controller: _confirmPasswordController,
                  hintText: 'Confirm Password',
                  icon: FontAwesomeIcons.lock,
                  isPassword: true,
                  obscurePassword: _obscureConfirmPassword,
                ),
                const SizedBox(height: 4),

                // Error message
                if (_errorMessage != null)
                  Text(
                    _errorMessage!,
                    style:
                        const TextStyle(color: Colors.redAccent, fontSize: 14),
                  ),

                const SizedBox(height: 16),

                // Sign Up Button
                _buildButton(
                  label: 'Sign Up',
                  onPressed: _isLoading ? null : _signUp,
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
                  backgroundColor: Colors.greenAccent,
                ),
                const SizedBox(height: 12),

                // Sign in Link
                TextButton(
                  onPressed: widget.onSignInPressed,
                  child: Text(
                    "Already have an account? Sign in",
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
    bool obscurePassword = true,
  }) {
    return Container(
      width: double.infinity,
      constraints:
          const BoxConstraints(maxWidth: 400),
      child: TextField(
        controller: controller,
        obscureText: isPassword ? obscurePassword : false,
        decoration: InputDecoration(
          prefixIcon: Icon(icon, color: Colors.white),
          suffixIcon: isPassword
              ? IconButton(
                  icon: Icon(
                    obscurePassword
                        ? FontAwesomeIcons.eyeSlash
                        : FontAwesomeIcons.eye,
                    color: Colors.white,
                  ),
                  onPressed: () {
                    setState(() {
                      // Toggle password visibility
                      if (obscurePassword == _obscurePassword) {
                        _obscurePassword = !_obscurePassword;
                      } else {
                        _obscureConfirmPassword = !_obscureConfirmPassword;
                      }
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

  // Widget to build buttons
  Widget _buildButton({
    required String label,
    required VoidCallback? onPressed,
    IconData? icon,
    Color backgroundColor = Colors.blueAccent,
  }) {
    return Container(
      width: double.infinity,
      constraints:
          const BoxConstraints(maxWidth: 400),
      child: ElevatedButton.icon(
        onPressed: onPressed,
        icon: icon != null ? Icon(icon, color: Colors.white) : Container(),
        label: Text(
          label,
          style: const TextStyle(
              color: Colors.white),
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
