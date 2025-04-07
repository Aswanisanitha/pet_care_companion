import 'package:flutter/material.dart';
import 'package:pet_care_companion/petgallery.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class PetDetailScreen extends StatefulWidget {
  final String petId;

  const PetDetailScreen({super.key, required this.petId});

  @override
  State<PetDetailScreen> createState() => _PetDetailScreenState();
}

class _PetDetailScreenState extends State<PetDetailScreen> {
  final supabase = Supabase.instance.client;
  Map<String, dynamic>? petData;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchPetById(widget.petId);
  }

  Future<void> fetchPetById(String petId) async {
    try {
      final response = await supabase
          .from('User_tbl_pet')
          .select('*, breed_id(*, pettype_id(*))')
          .eq('id', petId)
          .single();

      print("Pet Details:");
      print("Name: ${response['pet_name']}");
      print("Breed: ${response['breed_id']?['breed_name']}");
      print("Pet Type: ${response['breed_id']?['pettype_id']?['type_name']}");
      print("Age: ${response['pet_age']}");
      print("Gender: ${response['pet_gender']}");
      print("Weight: ${response['pet_weight']}");
      print("Photo: ${response['pet_photo']}");

      setState(() {
        petData = response;
        isLoading = false;
      });
    } catch (e) {
      print('Error fetching pet by ID: $e');
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF1F5F9),
      appBar: AppBar(
        backgroundColor: Colors.deepOrange.shade900,
        title: const Text('Pet Profile',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : petData == null
              ? const Center(child: Text('No pet data found.'))
              : SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Profile Image Section
                      Container(
                        height: 200,
                        decoration: BoxDecoration(
                          color: Colors.blueGrey,
                          image: DecorationImage(
                            image: NetworkImage(petData!['pet_photo'] ??
                                'https://via.placeholder.com/150'),
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                      // Pet Details Grid
                      Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: GridView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          gridDelegate:
                              const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            crossAxisSpacing: 10,
                            mainAxisSpacing: 10,
                          ),
                          itemCount: 6,
                          itemBuilder: (context, index) {
                            return Card(
                              elevation: 4,
                              color: Colors.white,
                              child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      _getPetDetailIcon(index),
                                      size: 30,
                                      color: Colors.deepOrange.shade900,
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      _getPetDetailTitle(index),
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16,
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      _getPetDetailValue(index),
                                      style: const TextStyle(
                                        fontSize: 14,
                                        color: Colors.black54,
                                      ),
                                      textAlign: TextAlign.center,
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                      // View Gallery Button
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16.0),
                        child: ElevatedButton.icon(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    PetGalleryScreen(petId: widget.petId),
                              ),
                            );
                          },
                          icon: const Icon(Icons.photo_library),
                          label: const Text("View Gallery"),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.deepOrange.shade900,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            textStyle: const TextStyle(fontSize: 16),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                    ],
                  ),
                ),
    );
  }

  String _getPetDetailTitle(int index) {
    switch (index) {
      case 0:
        return 'Pet Name';
      case 1:
        return 'Pet Type';
      case 2:
        return 'Breed';
      case 3:
        return 'Weight';
      case 4:
        return 'Gender';
      case 5:
        return 'Age';
      default:
        return '';
    }
  }

  String _getPetDetailValue(int index) {
    switch (index) {
      case 0:
        return petData?['pet_name'] ?? 'Unnamed';
      case 1:
        return petData?['breed_id']?['pettype_id']?['type_name'] ?? 'Unknown';
      case 2:
        return petData?['breed_id']?['breed_name'] ?? 'Unknown';
      case 3:
        return petData?['pet_weight'] ?? 'N/A';
      case 4:
        return petData?['pet_gender'] ?? 'N/A';
      case 5:
        return petData?['pet_age'] ?? 'N/A';
      default:
        return '';
    }
  }

  IconData _getPetDetailIcon(int index) {
    switch (index) {
      case 0:
        return Icons.pets;
      case 1:
        return Icons.all_inclusive;
      case 2:
        return Icons.category;
      case 3:
        return Icons.monitor_weight;
      case 4:
        return Icons.accessibility;
      case 5:
        return Icons.cake;
      default:
        return Icons.help;
    }
  }
}
