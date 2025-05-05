import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../screen/auth_screen/verification_screen.dart';
import '../screen/home_screen.dart';
import 'userdata_notifier.dart';

final authNotifierProvider =
    NotifierProvider<AuthNotifier, User?>(AuthNotifier.new);

class AuthNotifier extends Notifier<User?> {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  @override
  User? build() {
    _auth.authStateChanges().listen((User? user) async {
      if (user != null) {
        // Reload the user to get the latest email verification status
        await user.reload();
        user = _auth.currentUser;

        // Check if the user’s email is verified
        if (user!.emailVerified) {
          state =
              user; // Set state to the authenticated user if email is verified.
        } else {
          state = null; // Set state to null if email is not verified.
          // Optionally, you can send them a verification email here if needed.
          // await user.sendEmailVerification();
        }
      } else {
        state = null; // User is not authenticated.
      }
    });

    return _auth.currentUser;
  }

  Future<void> signInAnon(BuildContext context) async {
    try {
      await _auth.signInAnonymously();
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const HomeScreen()),
      );
    } catch (e) {
      print('Error signing in anonymously: $e');
    }
  }

  Future<void> signUpWithEmail({
    required String firstName,
    required String lastName,
    required String email,
    required String password,
    required BuildContext context,
  }) async {
    try {
      // Attempt to create a new user
      await _auth
          .createUserWithEmailAndPassword(
        email: email,
        password: password,
      )
          .then((value) async {
        // Send verification email after signup only if user is created and email is not verified
        User? user = _auth.currentUser;

        if (user != null) {
          print(user.uid);
          // Save user data to Firestore
          await FirebaseFirestore.instance
              .collection('users_passengers')
              .doc(user.uid)
              .set({
            'userId': user.uid,
            'firstName': firstName,
            'lastName': lastName,
            'email': email,
            'notifyLocation': 'none',
            'createdAt': FieldValue.serverTimestamp(),
          });

          // Send email verification
          if (!user.emailVerified) {
            await user.sendEmailVerification();
            Fluttertoast.showToast(
              msg:
                  'Verification email has been sent. Please verify your email.',
              toastLength: Toast.LENGTH_LONG,
              gravity: ToastGravity.SNACKBAR,
              backgroundColor: Colors.black54,
              textColor: Colors.white,
              fontSize: 14.0,
            );
            // Navigate to the verification screen or inform the user to check their email
            // Example: Navigator.pushNamed(context, '/verificationScreen');
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(builder: (_) => const VerificationScreen()),
            );
          }
        }
      });
    } on FirebaseAuthException catch (e) {
      String errorMessage;
      switch (e.code) {
        case 'email-already-in-use':
          errorMessage = 'An account already exists with that email';
          Fluttertoast.showToast(
            msg: errorMessage,
            toastLength: Toast.LENGTH_LONG,
            gravity: ToastGravity.SNACKBAR,
            backgroundColor: Colors.black54,
            textColor: Colors.white,
            fontSize: 14.0,
          );
          // Prevent further actions (e.g., navigation to verification screen)
          return; // Exit the function so the app doesn't proceed to the verification screen
        case 'invalid-email':
          errorMessage = 'The email address is badly formatted';
          break;
        case 'weak-password':
          errorMessage = 'The password provided is too weak.';
          break;
        default:
          errorMessage = 'An unexpected error occurred. Please try again.';
      }

      // Show the appropriate error message
      Fluttertoast.showToast(
        msg: errorMessage,
        toastLength: Toast.LENGTH_LONG,
        gravity: ToastGravity.SNACKBAR,
        backgroundColor: Colors.black54,
        textColor: Colors.white,
        fontSize: 14.0,
      );
      print('FirebaseAuthException Error: $e');
    } catch (e) {
      // Handle any other exceptions
      print('Error: $e');
    }
  }

  Future<void> reloadUser() async {
    try {
      User? user = _auth.currentUser;
      if (user != null) {
        await user.reload();
        state = _auth.currentUser;
      }
    } catch (e) {
      print('Error reloading user: $e');
    }
  }

  Future<void> signInWithEmail({
    required String email,
    required String password,
    required BuildContext context,
  }) async {
    try {
      // Sign in the user with email and password
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: email.toString(),
        password: password.toString(),
      );

      // Get the current user after sign-in
      User? user = userCredential.user;

      if (user != null) {
        ref.read(userProvider.notifier).loadUserData();
        // Check if the email is verified
        if (user.emailVerified) {
          // If the email is verified, navigate to the HomeScreen
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (_) => const HomeScreen()),
          );
        } else {
          // If email is not verified, send the user to the VerificationScreen
          Navigator.of(context).push(
            MaterialPageRoute(builder: (_) => const VerificationScreen()),
          );

          // Optionally show a message prompting the user to verify their email
          Fluttertoast.showToast(
            msg:
                'Please verify your email. A verification email has been sent to ${user.email}.',
            toastLength: Toast.LENGTH_LONG,
            gravity: ToastGravity.SNACKBAR,
            backgroundColor: Colors.black54,
            textColor: Colors.white,
            fontSize: 14.0,
          );

          // Resend the verification email if needed
          await user.sendEmailVerification();
        }
      }
    } on FirebaseAuthException catch (e) {
      // Handle specific FirebaseAuthException errors
      String errorMessage;

      switch (e.code) {
        case 'invalid-email':
          errorMessage = 'The email address is not valid.';
          break;
        case 'invalid-credential':
          errorMessage = 'Incorrect Email or Password';
          break;
        case 'user-not-found':
          errorMessage = 'No user found with this email.';
          break;
        case 'wrong-password':
          errorMessage = 'The password is incorrect.';
          break;
        default:
          errorMessage = 'An unexpected error occurred. Please try again.';
      }

      Fluttertoast.showToast(
        msg: errorMessage,
        toastLength: Toast.LENGTH_LONG,
        gravity: ToastGravity.SNACKBAR,
        backgroundColor: Colors.black54,
        textColor: Colors.white,
        fontSize: 14.0,
      );
      print('FirebaseAuthException Error: $e');
    } catch (e) {
      // Handle any other exceptions
      print('Error: $e');
    }
  }

  Future<void> resetPassword({required String email}) async {
    try {
      await _auth.sendPasswordResetEmail(email: email).then((value) => {
            Fluttertoast.showToast(
              msg: 'Check your Email to reset Password',
              toastLength: Toast.LENGTH_LONG,
              gravity: ToastGravity.SNACKBAR,
              backgroundColor: Colors.black54,
              textColor: Colors.white,
              fontSize: 14.0,
            ),
          });
    } on FirebaseAuthException catch (e) {
      print('FirebaseAuthException Error: $e');
    } catch (e) {
      // Handle any other exceptions
      Fluttertoast.showToast(
        msg: e.toString(),
        toastLength: Toast.LENGTH_LONG,
        gravity: ToastGravity.SNACKBAR,
        backgroundColor: Colors.black54,
        textColor: Colors.white,
        fontSize: 14.0,
      );
      print('Error: $e');
    }
  }

  Future<void> signOut() async {
    await _auth.signOut();
  }
}
