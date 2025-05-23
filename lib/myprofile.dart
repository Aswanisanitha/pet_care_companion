import 'package:flutter/material.dart';
import 'package:pet_care_companion/main.dart';

class Myprofile extends StatefulWidget {
  const Myprofile({super.key});

  @override
  State<Myprofile> createState() => _MyprofileState();
}

class _MyprofileState extends State<Myprofile> {
  Map<String, dynamic>? profile;
  bool isLoading = true;
  String? errorMessage;

  @override
  void initState() {
    super.initState();
    fetchProfile();
  }

  Future<void> fetchProfile() async {
    try {
      setState(() {
        isLoading = true;
        errorMessage = null;
      });

      final userId = supabase.auth.currentUser?.id;

      if (userId != null) {
        final response = await supabase
            .from('Guest_tbl_userreg')
            .select()
            .eq('user_id', userId)
            .single();

        setState(() {
          profile = response;
          isLoading = false;
        });
      } else {
        setState(() {
          isLoading = false;
          errorMessage = 'User not logged in';
        });
      }
    } catch (e) {
      setState(() {
        isLoading = false;
        errorMessage = 'Error fetching profile: $e';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'My Profile',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        backgroundColor: Colors.deepOrange.shade900,
        elevation: 1,
      ),
      body: Stack(
        children: [
          // Gradient Background
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.deepOrange.shade900,
                  Colors.deepOrange.shade200,
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: isLoading
                ? const Center(child: CircularProgressIndicator())
                : errorMessage != null
                    ? Center(child: Text(errorMessage!))
                    : Column(
                        children: [
                          // Profile Picture
                          Center(
                            child: Stack(
                              children: [
                                Container(
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                        color: Colors.white, width: 4),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withOpacity(0.1),
                                        spreadRadius: 5,
                                        blurRadius: 10,
                                        offset: const Offset(0, 5),
                                      ),
                                    ],
                                  ),
                                  child: CircleAvatar(
                                    radius: 60,
                                    backgroundImage: profile?['user_photo'] !=
                                                null &&
                                            profile!['user_photo'].isNotEmpty
                                        ? NetworkImage(profile!['user_photo'])
                                        : null,
                                    backgroundColor: Colors.orange.shade200,
                                    child: profile?['user_photo'] == null ||
                                            profile!['user_photo'].isEmpty
                                        ? const Icon(
                                            Icons.person,
                                            size: 60,
                                            color: Colors.white,
                                          )
                                        : null,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 30),
                          // User Details Section
                          _buildInfoTile(
                              Icons.person, profile?['user_name'] ?? 'Unknown'),
                          const SizedBox(height: 20),
                          _buildInfoTile(
                              Icons.email, profile?['user_email'] ?? 'Unknown'),
                          const SizedBox(height: 20),
                          _buildInfoTile(Icons.phone,
                              profile?['user_contact'] ?? 'Unknown'),
                          const SizedBox(height: 20),
                          _buildInfoTile(Icons.house,
                              profile?['user_address'] ?? 'Unknown'),
                        ],
                      ),
          ),
        ],
      ),
    );
  }

  // Helper Widget for Info Tiles
  Widget _buildInfoTile(IconData icon, String text) {
    return Container(
      width: double.infinity,
      height: 50,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            spreadRadius: 2,
            blurRadius: 6,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        children: [
          Icon(icon, color: Colors.deepOrange.shade900),
          const SizedBox(width: 12),
          Text(
            text,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
        ],
      ),
    );
  }
}
