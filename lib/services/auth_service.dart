import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:google_sign_in/google_sign_in.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_model.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  String? get currentUserId => _auth.currentUser?.uid;

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
        // Mobile: Use Google Sign-In package (using the available instance/authenticate API)
        final googleUser = await _googleSignIn.authenticate();
        if (googleUser == null) return null;

        final googleAuth = await googleUser.authentication;
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
      await _googleSignIn.signOut();
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
        // Mobile: Use Google Sign-In package (using the available instance/authenticate API)
        final googleUser = await _googleSignIn.authenticate();
        if (googleUser == null) return null;

        final googleAuth = await googleUser.authentication;
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
  // User Data Management
  Future<UserModel?> getUserData() async {
    final user = _auth.currentUser;
    if (user == null) return null;

    final doc = await _firestore.collection('users').doc(user.uid).get();
    if (!doc.exists) {
      // Initialize user data if not exists
      final newUser = UserModel(
        uid: user.uid,
        email: user.email ?? '',
        displayName: user.displayName ?? user.email?.split('@')[0] ?? 'User',
      );
      await _firestore.collection('users').doc(user.uid).set(newUser.toFirestore());
      return newUser;
    }
    return UserModel.fromFirestore(doc);
  }

  Future<void> completeOnboarding() async {
    final user = _auth.currentUser;
    if (user == null) return;
    await _firestore.collection('users').doc(user.uid).update({
      'hasCompletedOnboarding': true,
    });
  }

  Future<void> verifyId(String idUrl) async {
    final user = _auth.currentUser;
    if (user == null) return;
    
    await _firestore.collection('users').doc(user.uid).update({
      'verificationStatus': 'pending',
      'studentIdUrl': idUrl,
    });
  }

  Future<void> approveVerification(String uid) async {
    final doc = await _firestore.collection('users').doc(uid).get();
    if (!doc.exists) return;
    
    final userData = UserModel.fromFirestore(doc);
    int newScore = userData.trustScore + 20;
    if (newScore > 100) newScore = 100;

    await _firestore.collection('users').doc(uid).update({
      'verificationStatus': 'verified',
      'trustScore': newScore,
    });
  }

  Future<void> rejectVerification(String uid) async {
    await _firestore.collection('users').doc(uid).update({
      'verificationStatus': 'rejected',
    });
  }

  Stream<UserModel?> get userModelStream async* {
    await for (final user in _auth.authStateChanges()) {
      if (user == null) {
        yield null;
      } else {
        yield* _firestore
            .collection('users')
            .doc(user.uid)
            .snapshots()
            .map((doc) => doc.exists ? UserModel.fromFirestore(doc) : null);
      }
    }
  }
}
