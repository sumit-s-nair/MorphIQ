import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:morph_iq/screens/auth/forgot_password.dart';
import 'package:morph_iq/screens/auth/login_screen.dart';
import 'package:morph_iq/screens/auth/signup_screen.dart';
import 'package:morph_iq/screens/create_form_screen.dart';
import 'package:morph_iq/screens/form/form_details_screen.dart';
import 'package:morph_iq/screens/form_response_screen.dart';
import 'package:morph_iq/screens/home_screen.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: Colors.black,
      ),
      // Define routes
      onGenerateRoute: (settings) {
        // Handle the authentication check and redirect logic here
        final uri = Uri.parse(settings.name ?? '');

        // Define routes that require authentication
        if (uri.pathSegments.length == 2 && uri.pathSegments.first == 'forms') {
          final formId = uri.pathSegments[1];
          // Check if user is logged in before navigating to the form
          return _authGuard(
            context,
            MaterialPageRoute(
              builder: (context) => SubmitFormPage(formId: formId),
            ),
          );
        }

        // Home, create form, and other protected routes
        if (uri.pathSegments.first == 'home' ||
            uri.pathSegments.first == 'create-form' ||
            uri.pathSegments.first == 'form-details') {
          return _authGuard(
            context,
            MaterialPageRoute(
              builder: (context) => const HomePage(),
            ),
          );
        }

        // Default route handling
        return null;
      },
      initialRoute: '/splash', // Splash screen is the first route
      routes: {
        '/splash': (context) => const SplashScreen(),
        '/': (context) => const AuthScreen(),
        '/forgot-password': (context) => const PasswordRecoveryScreen(),
        '/home': (context) => const HomePage(),
        '/create-form': (context) => const CreateFormPage(),
        '/form-details': (context) => const FormDetailsPage(),
      },
    );
  }

  // Checks if the user is logged in before navigating to a route
  Route? _authGuard(
    BuildContext context,
    MaterialPageRoute route,
  ) {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      // User is not logged in, navigate to AuthScreen
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Navigator.pushReplacementNamed(context, '/');
      });
      return null;
    }
    // User is logged in, proceed to the requested route
    return route;
  }
}

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  SplashScreenState createState() => SplashScreenState();
}

class SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _checkUserLoginStatus();
  }

  // Method to check if the user is logged in during the splash screen display
  void _checkUserLoginStatus() async {
    final user = FirebaseAuth.instance.currentUser;

    await Future.delayed(const Duration(seconds: 3));

    // Navigate to screen based on login status
    if (user != null) {
      if (mounted) {
        Navigator.pushReplacementNamed(
            context, '/home'); // User is logged in, go to Home page
      }
    } else {
      if (mounted) {
        Navigator.pushReplacementNamed(
            context, '/'); // User is not logged in, go to Auth screen
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromRGBO(38, 38, 38, 1),
      body: Center(
        child: Image.asset(
          'assets/images/logo.png',
          width: 300,
          height: 300,
        ),
      ),
    );
  }
}

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  AuthScreenState createState() => AuthScreenState();
}

class AuthScreenState extends State<AuthScreen> {
  bool _isLogin = true;

  void _toggleAuthScreen() {
    setState(() {
      _isLogin = !_isLogin;
    });
  }

  @override
  Widget build(BuildContext context) {
    return _isLogin
        ? LoginScreen(
            onSignUpPressed: _toggleAuthScreen,
            onLoginSuccess: () {
              // Redirect to home on successful login
              Navigator.pushReplacementNamed(context, '/home');
            },
          )
        : SignUpScreen(
            onSignInPressed: _toggleAuthScreen,
            onSignUpSuccess: () {
              // Redirect to home after sign up
              Navigator.pushReplacementNamed(context, '/home');
            },
          );
  }
}
