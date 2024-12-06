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
        final uri = Uri.parse(settings.name ?? '');
        if (uri.pathSegments.length == 2 && uri.pathSegments.first == 'forms') {
          final formId = uri.pathSegments[1];
          return MaterialPageRoute(
            builder: (context) => SubmitFormPage(formId: formId),
          );
        }
        // Default route handling
        return null;
      },
      initialRoute: '/',
      routes: {
        '/': (context) => const AuthScreen(),
        '/forgot-password': (context) => const PasswordRecoveryScreen(),
        '/home': (context) => const HomePage(),
        '/create-form': (context) => const CreateFormPage(),
        '/form-details': (context) => const FormDetailsPage(),
      },
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
          )
        : SignUpScreen(
            onSignInPressed: _toggleAuthScreen,
          );
  }
}
