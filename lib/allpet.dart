import 'package:flutter/material.dart';
import 'package:pet_care_companion/main.dart';
import 'package:pet_care_companion/petprofile.dart';

class allpet extends StatefulWidget {
  const allpet({super.key});

  @override
  State<allpet> createState() => _allpetState();
}

class _allpetState extends State<allpet> {
  List<Map<String, dynamic>> petlist = [];

  Future<void> fetchpet() async {
    try {
      final userId = supabase.auth.currentUser?.id;
      if (userId == null) {
        throw Exception('User not authenticated');
      }

      // Fetch all pets excluding the logged-in user's pets
      final response = await supabase
          .from('User_tbl_pet')
          .select('*, breed_id!inner(breed_name)') // Include breed name
          .neq('user_id_id', userId); // Exclude current user's pets

      setState(() {
        petlist = List<Map<String, dynamic>>.from(response);
      });
    } catch (e) {
      print('Error fetching pets: $e');
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
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                        PetDetailScreen(petId: pet['id'].toString()), // ✅ FIXED
                  ),
                );
              },
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8.0),
                child: GridTile(
                  footer: GridTileBar(
                    backgroundColor: Colors.black54,
                    title: Text(
                      pet['pet_name'] ?? 'Unnamed Pet',
                      style: const TextStyle(fontSize: 14),
                    ),
                  ),
                  child: Image.network(
                    pet['pet_photo'] ??
                        'https://via.placeholder.com/150', // Fallback image
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return const Icon(Icons.error,
                          size: 50); // Show error icon if image fails
                    },
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
