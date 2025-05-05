import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../notifier/auth_notifier.dart';
import 'login_screen.dart';

class SignUpScreen extends HookConsumerWidget {
  const SignUpScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final emailController = useTextEditingController();
    final passwordController = useTextEditingController();
    final firstNameController = useTextEditingController();
    final lastNameController = useTextEditingController();

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

    OutlineInputBorder customBorder({
      Color color = const Color.fromARGB(255, 223, 223, 223),
      double width = 3.0,
    }) {
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
        child: Stack(
          children: [
            Positioned.fill(
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 5.0, sigmaY: 5.0),
                child: Container(
                  color: Colors.purple.withOpacity(0.4),
                ),
              ),
            ),
            SafeArea(
              child: LayoutBuilder(
                builder: (context, constraints) {
                  return SingleChildScrollView(
                    padding: EdgeInsets.only(
                      left: 16,
                      right: 16,
                      bottom: MediaQuery.of(context).viewInsets.bottom + 20,
                    ),
                    child: ConstrainedBox(
                      constraints:
                          BoxConstraints(minHeight: constraints.maxHeight),
                      child: IntrinsicHeight(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const SizedBox(height: 40),
                            Text(
                              "SIGN UP",
                              style: GoogleFonts.acme(
                                color: Colors.white,
                                fontSize: 26,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 40),
                            Row(
                              children: [
                                Expanded(
                                  child: TextField(
                                    style: const TextStyle(color: Colors.white),
                                    controller: firstNameController,
                                    decoration: InputDecoration(
                                      labelText: 'First Name',
                                      hintText: 'First Name',
                                      labelStyle:
                                          const TextStyle(color: Colors.white),
                                      hintStyle: const TextStyle(
                                          color: Colors.white70),
                                      border: customBorder(),
                                      enabledBorder: customBorder(),
                                      focusedBorder:
                                          customBorder(color: Colors.white),
                                    ),
                                    keyboardType: TextInputType.name,
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: TextField(
                                    style: const TextStyle(color: Colors.white),
                                    controller: lastNameController,
                                    decoration: InputDecoration(
                                      labelText: 'Last Name',
                                      hintText: 'Last Name',
                                      labelStyle:
                                          const TextStyle(color: Colors.white),
                                      hintStyle: const TextStyle(
                                          color: Colors.white70),
                                      border: customBorder(),
                                      enabledBorder: customBorder(),
                                      focusedBorder:
                                          customBorder(color: Colors.white),
                                    ),
                                    keyboardType: TextInputType.name,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 10),
                            TextField(
                              style: const TextStyle(color: Colors.white),
                              controller: emailController,
                              decoration: InputDecoration(
                                labelText: 'Email',
                                hintText: 'Enter Email',
                                labelStyle:
                                    const TextStyle(color: Colors.white),
                                hintStyle:
                                    const TextStyle(color: Colors.white70),
                                border: customBorder(),
                                enabledBorder: customBorder(),
                                focusedBorder:
                                    customBorder(color: Colors.white),
                              ),
                              keyboardType: TextInputType.emailAddress,
                            ),
                            const SizedBox(height: 16),
                            TextField(
                              controller: passwordController,
                              style: const TextStyle(color: Colors.white),
                              decoration: InputDecoration(
                                labelText: 'Password',
                                hintText: 'Enter Password',
                                labelStyle:
                                    const TextStyle(color: Colors.white),
                                hintStyle:
                                    const TextStyle(color: Colors.white70),
                                border: customBorder(),
                                enabledBorder: customBorder(),
                                focusedBorder:
                                    customBorder(color: Colors.white),
                              ),
                              obscureText: true,
                            ),
                            const SizedBox(height: 24),
                            SizedBox(
                              width: double.infinity,
                              child: OutlinedButton(
                                onPressed: () async {
                                  if (firstNameController.text.trim().isEmpty ||
                                      lastNameController.text.trim().isEmpty ||
                                      emailController.text.trim().isEmpty ||
                                      passwordController.text.trim().isEmpty) {
                                    Fluttertoast.showToast(
                                      msg: 'Please fill all the fields',
                                      toastLength: Toast.LENGTH_LONG,
                                      gravity: ToastGravity.BOTTOM,
                                      backgroundColor: Colors.red,
                                      textColor: Colors.white,
                                      fontSize: 14.0,
                                    );
                                    return;
                                  }
                                  await ref
                                      .read(authNotifierProvider.notifier)
                                      .signUpWithEmail(
                                        firstName:
                                            firstNameController.text.trim(),
                                        lastName:
                                            lastNameController.text.trim(),
                                        email: emailController.text.trim(),
                                        password:
                                            passwordController.text.trim(),
                                        context: context,
                                      );
                                },
                                style: customOutlinedButtonStyle(),
                                child: const Text(
                                  'Sign Up',
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 16),
                            SizedBox(
                              width: double.infinity,
                              child: OutlinedButton(
                                onPressed: () {
                                  Navigator.of(context).pushReplacement(
                                    MaterialPageRoute(
                                      builder: (_) => const LoginScreen(),
                                    ),
                                  );
                                },
                                style: customOutlinedButtonStyle(),
                                child: const Text(
                                  'HAVE AN ACCOUNT?',
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 20),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
