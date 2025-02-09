import 'package:flutter/material.dart';
import 'package:pet_care_companion/main.dart';

class PetProfile extends StatefulWidget {
  const PetProfile({super.key});

  @override
  State<PetProfile> createState() => _PetProfileState();
}

class _PetProfileState extends State<PetProfile> {
  Map<String, dynamic>? petprofile;
  @override
  void initState() {
    super.initState();
    fetchpetprofile();
  }

  Future<void> fetchpetprofile() async {
    try {
      final userid = supabase.auth.currentUser?.id;

      if (userid != null) {
        final response =
            await supabase.from('User_tbl_pet').select().eq('user_id', userid);
      }
    } catch (e) {
      print('Error fetching Profile Details: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF1F5F9),
      appBar: AppBar(
        backgroundColor: Colors.deepOrange.shade900,
        title: const Text(
          'Pet Profile',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Profile Image Section
            Stack(
              alignment: Alignment.bottomRight,
              children: [
                Container(
                  height: 200,
                  decoration: const BoxDecoration(
                    color: Colors.blueGrey,
                    image: DecorationImage(
                      image:
                          AssetImage("assets/1.png"), // Replace with your image
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              ],
            ),
            // Pet Details Section - GridView
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 10,
                  mainAxisSpacing: 10,
                ),
                itemCount: 5,
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
              padding:
                  const EdgeInsets.symmetric(horizontal: 16.0, vertical: 24.0),
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.deepOrange.shade900,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => GalleryScreen()),
                  );
                },
                child: const Text(
                  'View Gallery',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Pet Details Methods
  String _getPetDetailTitle(int index) {
    switch (index) {
      case 0:
        return 'Pet Name';
      case 1:
        return 'Species';
      case 2:
        return 'Breed';
      case 3:
        return 'Weight';
      case 4:
        return 'Sex';
      default:
        return '';
    }
  }

  String _getPetDetailValue(int index) {
    switch (index) {
      case 0:
        return 'Fluffy';
      case 1:
        return 'Cat';
      case 2:
        return 'Persian';
      case 3:
        return '4.5 kg';
      case 4:
        return 'Female';
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
      default:
        return Icons.help;
    }
  }
}

class GalleryScreen extends StatelessWidget {
  const GalleryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Gallery'),
        backgroundColor: Colors.deepOrange.shade900,
      ),
      body: Center(
        child: Text(
          'Gallery Screen',
          style: TextStyle(fontSize: 24),
        ),
      ),
    );
  }
}
