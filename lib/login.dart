import 'package:flutter/material.dart';
import 'package:pet_care_companion/home.dart';
import 'package:pet_care_companion/main.dart';
import 'package:pet_care_companion/registration.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class Login extends StatefulWidget {
  const Login({super.key});

  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> {
  final TextEditingController email = TextEditingController();
  final TextEditingController password = TextEditingController();

  Future<void> signIn() async {
    final AuthResponse res = await supabase.auth.signInWithPassword(
      email: email.text,
      password: password.text,
    );
    final User? user = res.user;
    print(user);
    if (user?.id != "") {
      Navigator.pushReplacement(
          context, MaterialPageRoute(builder: (context) => HomeScreen()));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.deepOrange.shade900,
        title: const Text(
          'Login',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(10.0),
        child: SingleChildScrollView(
          child: Form(
            child: Column(
              children: [
                Image.asset(
                  "assets/login1.png",
                ),
                // Email TextField with Icon and Focused Border
                TextFormField(
                  controller: email,
                  decoration: InputDecoration(
                    prefixIcon: Icon(Icons.email, color: Colors.deepOrange),
                    labelStyle: TextStyle(color: Colors.black),
                    labelText: "Email",
                    border: OutlineInputBorder(),
                    focusedBorder: OutlineInputBorder(
                      borderSide:
                          BorderSide(color: Colors.deepOrange, width: 2.0),
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                // Password TextField with Icon and Focused Border
                TextFormField(
                  controller: password,
                  obscureText: true,
                  decoration: InputDecoration(
                    prefixIcon: Icon(Icons.lock, color: Colors.deepOrange),
                    labelText: "Password",
                    labelStyle: TextStyle(color: Colors.black),
                    border: OutlineInputBorder(),
                    focusedBorder: OutlineInputBorder(
                      borderSide:
                          BorderSide(color: Colors.deepOrange, width: 2.0),
                    ),
                  ),
                ),
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: () {},
                    child: Text(
                      "Forgot Password?",
                      style: TextStyle(
                        color: Colors.deepOrange.shade900,
                        fontWeight: FontWeight.w600,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 5),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    fixedSize: const Size(200, 40),
                    backgroundColor: Colors.black,
                  ),
                  onPressed: () {
                    signIn();
                  },
                  child: const Text(
                    "Sign In",
                    style: TextStyle(color: Colors.white, fontSize: 18),
                  ),
                ),
                const SizedBox(height: 6),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      "Don't have an account?",
                      style: TextStyle(color: Colors.black),
                    ),
                    TextButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => Registration(),
                          ),
                        );
                      },
                      child: Text(
                        " Sign Up",
                        style: TextStyle(
                          color: Colors.deepOrange,
                          fontWeight: FontWeight.w700,
                          fontSize: 20,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
