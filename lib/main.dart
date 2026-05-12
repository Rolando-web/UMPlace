import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:firebase_core/firebase_core.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'services/auth_service.dart';
import 'firebase_options.dart';
import 'ui/screens/splash_screen.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: ".env");
  // Initialize Firebase
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  // Initialize Google Sign-In for Mobile only. Web uses Firebase Auth directly.
  if (!kIsWeb) {
    const String webClientId = '1023766623042-8ubo7d538s6k60o6f65p4i9cg0j5en6f.apps.googleusercontent.com';
    await GoogleSignIn.instance.initialize(
      clientId: webClientId,
      serverClientId: webClientId,
    );
  }
  
  runApp(const UMPlaceApp());
}

class UMPlaceApp extends StatelessWidget {
  const UMPlaceApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'UMPlace',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFFB11A23)),
        useMaterial3: true,
        fontFamily: 'Inter',
      ),
      builder: (context, child) {
        if (child == null) return const SizedBox.shrink();
        return StreamBuilder<User?>(
          stream: FirebaseAuth.instance.authStateChanges(),
          builder: (context, snapshot) {
            final user = snapshot.data;
            final isAdmin = user?.email == AuthService.adminEmail;

            if (isAdmin) {
              return child;
            }

            return Container(
              color: Colors.grey.shade100,
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 500),
                  child: child,
                ),
              ),
            );
          },
        );
      },
      home: const SplashScreen(),
    );
  }
}
