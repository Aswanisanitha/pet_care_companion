import 'package:flutter/material.dart';

class breedfind extends StatelessWidget {
  const breedfind({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.deepOrange.shade900,
        title: const Text('Breed Find', style: TextStyle(color: Colors.white)),
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            // Back button action
          },
        ),
      ),
    );
  }
}
