import 'package:flutter/material.dart';
import 'package:task/main.dart';
import 'package:task/service/auth_service.dart';
import 'signup_screen.dart'; // Import SignupScreen
import 'package:task/main.dart'; // Import MainAppScreen if needed

class SigninScreen extends StatefulWidget {
  const SigninScreen({super.key});

  @override
  State<SigninScreen> createState() => _SigninScreenState();
}

class _SigninScreenState extends State<SigninScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  bool _isLoading = false;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Record income and expenses"),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: Center(
        child: _isLoading
            ? const CircularProgressIndicator()
            : Container(
                height: 280,
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
                      "Record income and expenses",
                      style: TextStyle(fontSize: 18),
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
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        TextButton(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => const SignupScreen()),
                              );
                            },
                            child: const Text("Sign up")),
                        TextButton(
                            onPressed: () async {
                              setState(() {
                                _isLoading = true;
                              });
                              var res = await AuthService().signin(
                                  email: _emailController.text,
                                  password: _passwordController.text);
                              setState(() {
                                _isLoading = false;
                              });
                              if (res == 'success') {
                                Navigator.pushReplacement(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) =>
                                            const ExpenseTrackerApp()));
                              } else {
                                ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(content: Text(res!)));
                              }
                            },
                            child: const Text("Sign in")),
                      ],
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
    super.dispose();
  }
}
