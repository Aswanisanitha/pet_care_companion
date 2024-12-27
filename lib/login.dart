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
    final Session? session = res.session;
    final User? user = res.user;
    if (user?.id != "") {
      Navigator.pushReplacement(
          context, MaterialPageRoute(builder: (context) => const HomeScreen()));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color.fromARGB(255, 247, 247, 247),
      appBar: AppBar(
        title: Text("Login"),
        backgroundColor: Color.fromARGB(255, 247, 247, 247),
      ),
      body: Padding(
        padding: const EdgeInsets.all(10.0),
        child: Form(
            child: Column(
          children: [
            Image.asset(
              "assets/login1.png",
            ),
            TextFormField(
              controller: email,
              decoration: InputDecoration(
                labelStyle: TextStyle(color: Colors.black),
                labelText: "Email",
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(
              height: 10,
            ),
            TextFormField(
              controller: password,
              obscureText: true,
              decoration: InputDecoration(
                  labelText: "Password",
                  labelStyle: TextStyle(color: Colors.black),
                  border: OutlineInputBorder()),
            ),
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                  onPressed: () {},
                  child: Text(
                    "Forgot Password ?",
                    style: TextStyle(
                      color: Colors.black,
                      fontWeight: FontWeight.w600,
                      fontSize: 16,
                    ),
                  )),
            ),
            SizedBox(
              height: 5,
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                fixedSize: const Size(200, 40),
                backgroundColor: Colors.black,
              ),
              onPressed: () {
                signIn();
              },
              child: Text(
                "Sign In",
                style: TextStyle(color: Colors.white, fontSize: 18),
              ),
            ),
            SizedBox(
              height: 6,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  "Don't have an account?",
                  style: TextStyle(color: Colors.black),
                ),
                TextButton(
                    onPressed: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => Registration(),
                          ));
                    },
                    child: Text(
                      " Sign Up",
                      style: TextStyle(
                        color: Colors.black,
                        fontWeight: FontWeight.w700,
                        fontSize: 20,
                      ),
                    )),
              ],
            ),
          ],
        )),
      ),
    );
  }
}
