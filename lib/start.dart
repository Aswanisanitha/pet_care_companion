import 'package:flutter/material.dart';
import 'package:pet_care_companion/login.dart';
import 'package:pet_care_companion/registration.dart';

class FirstPage extends StatelessWidget {
  const FirstPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: const [
                Text(
                  "Welcome To",
                  style: TextStyle(
                    fontSize: 30,
                    color: Colors.black, // Adjust for better contrast
                  ),
                ),
              ],
            ),
          ),
          const Text(
            "Pet Care Companion",
            style: TextStyle(fontSize: 40, color: Colors.black),
          ),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.0),
            child: Text(
              "Love, Care and Companionship for your furry friends",
              style: TextStyle(
                color: Colors.black,
                fontSize: 16,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          Image.asset(
            "assets/pic.webp",
            fit: BoxFit.cover,
          ),
          const Spacer(),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              fixedSize: const Size(200, 40),
              backgroundColor: Colors.black,
            ),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const Login(),
                ),
              );
            },
            child: const Text(
              "Log In",
              style: TextStyle(color: Colors.white, fontSize: 18),
            ),
          ),
          const SizedBox(height: 10),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              fixedSize: const Size(200, 40),
              backgroundColor: Colors.deepOrange,
            ),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const Registration(),
                ),
              );
            },
            child: const Text(
              "Sign Up",
              style: TextStyle(color: Colors.black, fontSize: 18),
            ),
          ),
          const SizedBox(height: 40),
        ],
      ),
    );
  }
}
