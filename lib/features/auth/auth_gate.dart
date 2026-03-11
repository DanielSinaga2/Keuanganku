import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../dashboard/dashboard_page.dart';
import 'login/login_page.dart';
import '../../services/biometric_service.dart';

class AuthGate extends StatefulWidget {
  const AuthGate({super.key});

  @override
  State<AuthGate> createState() => _AuthGateState();
}

class _AuthGateState extends State<AuthGate> {

  final biometricService = BiometricService();

  @override
  void initState() {
    super.initState();
    checkLogin();
  }

  void checkLogin() async {

    final user = FirebaseAuth.instance.currentUser;

    if (user != null) {

      bool success = await biometricService.authenticate();

      if (success) {

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => const DashboardPage(),
          ),
        );

      }

    }

  }

  @override
  Widget build(BuildContext context) {

    final user = FirebaseAuth.instance.currentUser;

    if (user != null) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    return const LoginPage();
  }
}