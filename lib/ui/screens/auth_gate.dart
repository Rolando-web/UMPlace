import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../services/auth_service.dart';
import '../users/screens/main_layout.dart';
import '../admin/screens/admin_main_screen.dart';
import 'login_screen.dart';
import 'onboarding_screen.dart';

class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: AuthService().authStateChanges,
      builder: (context, snapshot) {
        // Show loading indicator while checking auth state
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator(color: Color(0xFFB11A23))),
          );
        }

        // If the user is logged in
        if (snapshot.hasData && snapshot.data != null) {
          // Check if they are the admin
          if (snapshot.data!.email == AuthService.adminEmail) {
            return const AdminMainScreen();
          } else {
            // Standard User: Check onboarding status
            return FutureBuilder(
              future: AuthService().getUserData(),
              builder: (context, userSnapshot) {
                if (userSnapshot.connectionState == ConnectionState.waiting) {
                  return const Scaffold(
                    body: Center(child: CircularProgressIndicator(color: Color(0xFFB11A23))),
                  );
                }

                if (userSnapshot.hasData && userSnapshot.data != null) {
                  final userData = userSnapshot.data!;
                  if (!userData.hasCompletedOnboarding) {
                    return const OnboardingScreen();
                  }
                  return const MainLayout();
                }

                // Fallback to MainLayout if data fetch fails
                return const MainLayout();
              },
            );
          }
        }

        // User is not logged in, show Login Screen
        return const LoginScreen();
      },
    );
  }
}
