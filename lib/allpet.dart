import 'package:flutter/material.dart';
import 'package:pet_care_companion/main.dart';

class allpet extends StatefulWidget {
  const allpet({super.key});

  @override
  State<allpet> createState() => _allpetState();
}

class _allpetState extends State<allpet> {
  List<Map<String, dynamic>> petlist = [];

  Future<void> fetchpet() async {
    try {
      final response = await supabase.from('User_tbl_pet').select();
      setState(() {
        petlist = List<Map<String, dynamic>>.from(response);
      });
    } catch (e) {
      print('Error fetching traning: $e');
    }
  }

  @override
  void initState() {
    super.initState();

    fetchpet();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.deepOrange.shade900,
        title: const Text('Pets',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: GridView.builder(
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 8.0,
            mainAxisSpacing: 8.0,
          ),
          itemCount: petlist.length,
          itemBuilder: (context, index) {
            final pet = petlist[index];
            return GestureDetector(
              onTap: () {
                // Add functionality here, e.g., open the image in fullscreen
              },
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8.0),
                child: GridTile(
                  footer: GridTileBar(
                    backgroundColor: Colors.black54,
                    title: Text(
                      pet['pet_name'],
                      style: TextStyle(fontSize: 14),
                    ),
                  ),
                  child: Image.network(
                    pet['pet_photo'],
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
