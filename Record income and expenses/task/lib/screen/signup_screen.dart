import 'package:flutter/material.dart';
import 'package:task/service/auth_service.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();
  String? _errorMessage;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Sign Up"),
      ),
      body: Center(
        child: Container(
          height: 450,
          width: 300,
          padding: const EdgeInsets.all(18),
          decoration: const BoxDecoration(
              boxShadow: [
                BoxShadow(
                    offset: Offset(0.1, 1),
                    blurRadius: 0.1,
                    spreadRadius: 0.1,
                    color: Colors.black)
              ],
              color: Colors.white,
              borderRadius: BorderRadius.all(Radius.circular(20))),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                "Sign Up",
                style: TextStyle(fontSize: 30),
              ),
              TextField(
                controller: _emailController,
                decoration: const InputDecoration(
                    labelText: "Email", border: OutlineInputBorder()),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: _passwordController,
                obscureText: true,
                decoration: const InputDecoration(
                    labelText: "Password", border: OutlineInputBorder()),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: _confirmPasswordController,
                obscureText: true,
                decoration: const InputDecoration(
                    labelText: "Confirm Password",
                    border: OutlineInputBorder()),
              ),
              const SizedBox(height: 10),
              if (_errorMessage != null)
                Text(
                  _errorMessage!,
                  style: const TextStyle(color: Colors.red),
                ),
              const SizedBox(height: 10),
              ElevatedButton(
                onPressed: () async {
                  String email = _emailController.text;
                  String password = _passwordController.text;
                  String confirmPassword = _confirmPasswordController.text;

                  // Reset error message
                  setState(() {
                    _errorMessage = null;
                  });

                  // Validate password and confirmation
                  if (password.length < 8) {
                    setState(() {
                      _errorMessage = "Password must be at least 8 characters.";
                    });
                    return;
                  }

                  if (password != confirmPassword) {
                    setState(() {
                      _errorMessage = "Passwords do not match.";
                    });
                    return;
                  }

                  // Call the registration service
                  var res = await AuthService().reqistration(
                    email: email,
                    password: password,
                    confirm: confirmPassword,
                  );

                  if (res == 'success') {
                    // Navigate back to Signin screen
                    Navigator.pop(context);
                  } else {
                    setState(() {
                      _errorMessage =
                          res; // Show error message from registration
                    });
                  }
                },
                child: const Text("Sign Up"),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }
}
