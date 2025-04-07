import 'package:flutter/material.dart';
import 'package:pet_care_companion/addpet.dart';
import 'package:pet_care_companion/changepswd.dart';
import 'package:pet_care_companion/complaint.dart';
import 'package:pet_care_companion/editprofile.dart';
import 'package:pet_care_companion/feedback.dart';
import 'package:pet_care_companion/login.dart';
import 'package:pet_care_companion/main.dart';
import 'package:pet_care_companion/myappointments.dart';
import 'package:pet_care_companion/mycomplaints.dart';
import 'package:pet_care_companion/myprofile.dart';

class account extends StatefulWidget {
  const account({super.key});

  @override
  State<account> createState() => _accountState();
}

class _accountState extends State<account> {
  Map<String, dynamic>? profile;
  bool isLoading = true; // Add loading state

  @override
  void initState() {
    super.initState();
    fetchprofile();
  }

  Future<void> fetchprofile() async {
    try {
      final userid = supabase.auth.currentUser?.id;

      if (userid != null) {
        final response = await supabase
            .from('Guest_tbl_userreg')
            .select()
            .eq('user_id', userid)
            .single();

        setState(() {
          profile = response; // Update profile data
          isLoading = false; // Set loading to false when data is fetched
        });
      } else {
        setState(() {
          isLoading = false; // Set loading to false if no user ID
        });
      }
    } catch (e) {
      print('Error fetching Profile Details: $e');
      setState(() {
        isLoading = false; // Set loading to false on error
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.deepOrange.shade900,
        title: const Text('Account',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: isLoading
          ? const Center(
              child: CircularProgressIndicator(
                color: Colors.deepOrange,
              ),
            ) // Show loading indicator while fetching
          : Column(
              children: [
                // Profile Header
                Container(
                  color: Colors.deepOrange.shade900,
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: 40,
                        backgroundImage:
                            profile != null && profile!['user_photo'] != null
                                ? NetworkImage(profile!['user_photo'])
                                : const AssetImage('assets/default_avatar.png')
                                    as ImageProvider, // Fallback image
                      ),
                      const SizedBox(width: 16),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            profile?['user_name'] ?? "User",
                            style: const TextStyle(
                                color: Colors.white,
                                fontSize: 20,
                                fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            profile?['user_email'] ?? "No email",
                            style: const TextStyle(
                                color: Colors.white70, fontSize: 14),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                Expanded(
                  child: ListView(
                    padding: const EdgeInsets.all(16),
                    children: [
                      _buildListTile(
                        context,
                        icon: Icons.person,
                        title: "View Profile",
                        subtitle: "User profile",
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => Myprofile()),
                        ),
                      ),
                      _buildListTile(
                        context,
                        icon: Icons.pets,
                        title: "Pet Profile",
                        subtitle: "Add your pet profile",
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => addpet()),
                        ),
                      ),
                      _buildListTile(
                        context,
                        icon: Icons.book_sharp,
                        title: "Bookings",
                        subtitle: "View appointments",
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => Appointment()),
                        ),
                      ),
                      _buildListTile(
                        context,
                        icon: Icons.settings,
                        title: "Settings",
                        subtitle: "Edit profile, change password",
                        onTap: () => _showBottomSheet(context, 'Settings', [
                          {'name': 'Edit Profile', 'page': EditProfile()},
                          {'name': 'Change Password', 'page': changepassword()},
                        ]),
                      ),
                      _buildListTile(
                        context,
                        icon: Icons.contact_support_outlined,
                        title: "Support Center",
                        subtitle: "Add your complaints and feedback",
                        onTap: () =>
                            _showBottomSheet(context, 'Support Center', [
                          {'name': 'Report Issue', 'page': Complaint()},
                          {'name': 'Feedback ', 'page': feedback()},
                          {'name': 'Complaints', 'page': ComplaintView()},
                        ]),
                      ),
                      _buildListTile(
                        context,
                        icon: Icons.logout,
                        title: "Logout",
                        subtitle: "Logout from user account",
                        onTap: () async {
                          await supabase.auth.signOut();
                          Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => const Login()));
                        },
                      ),
                    ],
                  ),
                ),
              ],
            ),
    );
  }

  // Helper method to build list tiles
  Widget _buildListTile(BuildContext context,
      {required IconData icon,
      required String title,
      required String subtitle,
      required VoidCallback onTap}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.shade200,
            blurRadius: 5,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        children: [
          Icon(icon, size: 28, color: Colors.deepOrange.shade900),
          const SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style:
                    const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 4),
              Text(
                subtitle,
                style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
              ),
            ],
          ),
          const Spacer(),
          IconButton(
            icon: const Icon(Icons.arrow_forward_ios,
                size: 16, color: Colors.grey),
            onPressed: onTap,
          ),
        ],
      ),
    );
  }

  // Method to show bottom sheet with a list of options
  void _showBottomSheet(
      BuildContext context, String title, List<Map<String, dynamic>> options) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (BuildContext context) {
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                title,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            ...options.map((option) {
              return ListTile(
                title: Text(option['name']),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => option['page'],
                    ),
                  );
                },
              );
            }).toList(),
          ],
        );
      },
    );
  }
}
