import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../notifier/auth_notifier.dart';
import '../home_screen.dart';

class VerificationScreen extends HookConsumerWidget {
  const VerificationScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authNotifier = ref.watch(authNotifierProvider.notifier);

    ButtonStyle customOutlinedButtonStyle() {
      return OutlinedButton.styleFrom(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 32),
        foregroundColor: Colors.white,
        side: const BorderSide(color: Colors.white),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(5),
        ),
      );
    }

    OutlineInputBorder customBorder(
        {Color color = const Color.fromARGB(255, 223, 223, 223),
        double width = 3.0}) {
      return OutlineInputBorder(
        borderRadius: BorderRadius.circular(10.0),
        borderSide: BorderSide(color: color, width: width),
      );
    }

    return Scaffold(
        body: Container(
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage('images/backgroundLogins.jpg'),
                fit: BoxFit.cover,
              ),
            ),
            child: Stack(children: [
              Positioned.fill(
                child: BackdropFilter(
                  filter: ImageFilter.blur(
                      sigmaX: 5.0, sigmaY: 5.0), // Apply blur effect
                  child: Container(
                    color: Colors.purple
                        .withOpacity(0.4), // Pink overlay with opacity
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const SizedBox(height: 40),
                    Text('Verify Email',
                        textAlign: TextAlign.center,
                        style: GoogleFonts.acme(
                            fontSize: 24, color: Colors.white)),
                    const SizedBox(height: 40),
                    Text(
                        'A verification email has been sent to your email address. Please verify your email to continue.',
                        textAlign: TextAlign.center,
                        style: GoogleFonts.acme(
                            fontSize: 18, color: Colors.white)),
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton(
                        onPressed: () async {
                          await authNotifier.reloadUser();
                          final updatedUser = ref.read(authNotifierProvider);

                          if (updatedUser?.emailVerified == true) {
                            // Navigate to HomeScreen if email is verified
                            // Navigator.of(context).popUntil(ModalRoute.withName('/'));
                            Navigator.of(context).pushReplacement(
                              MaterialPageRoute(
                                  builder: (_) => const HomeScreen()),
                            );
                          } else {
                            // Show a message if email is not verified yet
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                    'Email is not verified. Please try again.',
                                    style: GoogleFonts.lato(
                                        fontSize: 16, color: Colors.red)),
                              ),
                            );
                          }
                        },
                        style: customOutlinedButtonStyle(),
                        child: Text('CHECK VERIFICATION',
                            style: GoogleFonts.lato(
                                fontSize: 16,
                                color: Colors.white,
                                fontWeight: FontWeight.bold)),
                      ),
                    ),
                  ],
                ),
              ),
            ])));
  }
}
