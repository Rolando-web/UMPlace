import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:google_sign_in/google_sign_in.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Admin Email Configuration
  static const String adminEmail = 'r.luayon.548817@umindanao.edu.ph';
  static const String requiredDomain = '@umindanao.edu.ph';

  // Check if current user is admin
  bool get isAdmin {
    return _auth.currentUser?.email == adminEmail;
  }

  // Get current user stream
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  // Sign In with Google
  Future<UserCredential?> signInWithGoogle() async {
    try {
      UserCredential userCredential;

      if (kIsWeb) {
        // Web: Use Firebase Auth signInWithPopup directly
        final googleProvider = GoogleAuthProvider();
        googleProvider.addScope('email');
        googleProvider.addScope('profile');
        googleProvider.setCustomParameters({'prompt': 'select_account'});
        userCredential = await _auth.signInWithPopup(googleProvider);
      } else {
        // Mobile: Use Google Sign-In package
        final googleUser =
            await GoogleSignIn.instance.authenticate();



        final googleAuth =
            googleUser.authentication;

        final OAuthCredential credential = GoogleAuthProvider.credential(
          idToken: googleAuth.idToken,
        );

        userCredential = await _auth.signInWithCredential(credential);
      }

      // Check the email domain
      final email = userCredential.user?.email ?? '';
      if (!email.endsWith(requiredDomain)) {
        // Sign out if the domain is incorrect
        await signOut();
        throw Exception(
            'Access Denied. You must use a $requiredDomain email address.');
      }

      return userCredential;
    } catch (e) {
      rethrow;
    }
  }

  // Sign Out - fully clears the session so a different account can be used
  Future<void> signOut() async {
    if (!kIsWeb) {
      await GoogleSignIn.instance.signOut();
    }
    await _auth.signOut();
  }

  // Sign In with Google (forces account picker every time)
  Future<UserCredential?> signInWithGoogleFresh() async {
    try {
      UserCredential userCredential;

      if (kIsWeb) {
        // Web: Use setCustomParameters to force account selection
        final googleProvider = GoogleAuthProvider();
        googleProvider.addScope('email');
        googleProvider.addScope('profile');
        googleProvider.setCustomParameters({'prompt': 'select_account'});
        userCredential = await _auth.signInWithPopup(googleProvider);
      } else {
        // Mobile: Use Google Sign-In package
        final googleUser =
            await GoogleSignIn.instance.authenticate();



        final googleAuth =
            googleUser.authentication;

        final OAuthCredential credential = GoogleAuthProvider.credential(
          idToken: googleAuth.idToken,
        );

        userCredential = await _auth.signInWithCredential(credential);
      }

      // Check the email domain
      final email = userCredential.user?.email ?? '';
      if (!email.endsWith(requiredDomain)) {
        await signOut();
        throw Exception(
            'Access Denied. You must use a $requiredDomain email address.');
      }

      return userCredential;
    } catch (e) {
      rethrow;
    }
  }
}
