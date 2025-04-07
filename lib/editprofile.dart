import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart'; // For image selection
import 'dart:io';

import 'package:pet_care_companion/main.dart'; // For file handling

class EditProfile extends StatefulWidget {
  @override
  State<EditProfile> createState() => _EditProfileState();
}

class _EditProfileState extends State<EditProfile> {
  final TextEditingController name = TextEditingController();
  final TextEditingController address = TextEditingController();
  final TextEditingController contact = TextEditingController();

  Map<String, dynamic>? profile;
  File? _image;
  final ImagePicker _picker = ImagePicker();
  bool _isLoading = false; // Loading state

  @override
  void initState() {
    super.initState();
    fetchProfile();
  }

  Future<void> fetchProfile() async {
    setState(() {
      _isLoading = true; // Show loading indicator
    });
    try {
      final userid = supabase.auth.currentUser?.id;

      if (userid != null) {
        final response = await supabase
            .from('Guest_tbl_userreg')
            .select()
            .eq('user_id', userid)
            .single();

        setState(() {
          profile = response;
          name.text = profile?['user_name'] ?? '';
          address.text = profile?['user_address'] ?? '';
          contact.text = profile?['user_contact'] ?? '';
        });
      }
    } catch (e) {
      print('Error fetching Profile Details: $e');
    } finally {
      setState(() {
        _isLoading = false; // Hide loading indicator
      });
    }
  }

  Future<void> _edit() async {
    try {
      final userid = supabase.auth.currentUser?.id;

      if (userid != null) {
        String? photoUrl;

        if (_image != null) {
          photoUrl = await _uploadImage(_image!, userid);
        } else {
          photoUrl = profile?['user_photo'];
        }

        final updates = {
          'user_name': name.text,
          'user_address': address.text,
          'user_contact': contact.text,
          'user_photo': photoUrl,
        };

        await supabase
            .from('Guest_tbl_userreg')
            .update(updates)
            .eq('user_id', userid);

        await fetchProfile();

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Profile updated successfully')),
        );
      }
    } catch (e) {
      print('Error updating Profile Details: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to update profile: $e')),
      );
    }
  }

  Future<String?> _uploadImage(File image, String userid) async {
    try {
      final folderName = "UserDocs";
      final fileName =
          '$folderName/$userid-${DateTime.now().millisecondsSinceEpoch}.jpg';

      await supabase.storage.from('petcare').upload(fileName, image);

      final imageUrl = supabase.storage.from('petcare').getPublicUrl(fileName);
      print("Uploaded Image URL: $imageUrl");
      return imageUrl;
    } catch (e) {
      print('Image upload failed: $e');
      return null;
    }
  }

  Future<void> _pickImage() async {
    final pickedImage = await _picker.pickImage(source: ImageSource.gallery);

    if (pickedImage != null) {
      setState(() {
        _image = File(pickedImage.path);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.deepOrange.shade900,
        title: const Text('Edit Profile',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        actions: [
          TextButton(
            onPressed: _edit,
            child: const Text('Save', style: TextStyle(color: Colors.white)),
          ),
          // Add a button to navigate to Account page (example)
        ],
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator()) // Show loading indicator
          : SingleChildScrollView(
              child: Column(
                children: [
                  // Profile Picture
                  Container(
                    height: 150,
                    color: Colors.deepOrange.shade900,
                    child: Center(
                      child: Stack(
                        children: [
                          CircleAvatar(
                            radius: 50,
                            backgroundImage: _image != null
                                ? FileImage(_image!) as ImageProvider
                                : (profile?['user_photo'] != null
                                    ? NetworkImage(profile!['user_photo'])
                                    : const AssetImage(
                                            'assets/default_profile.png')
                                        as ImageProvider),
                          ),
                          Positioned(
                            bottom: 0,
                            right: 0,
                            child: GestureDetector(
                              onTap: _pickImage,
                              child: CircleAvatar(
                                radius: 16,
                                backgroundColor: Colors.white,
                                child: Icon(Icons.camera_alt,
                                    size: 16, color: Colors.black),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Form Fields
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildTextFormField('Name', name),
                        const SizedBox(height: 20),
                        _buildTextFormField('Address', address),
                        const SizedBox(height: 20),
                        _buildTextFormField('Phone Number', contact,
                            keyboardType: TextInputType.phone),
                        const SizedBox(height: 20),
                      ],
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildTextFormField(String label, TextEditingController controller,
      {TextInputType keyboardType = TextInputType.text}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
              fontSize: 16, fontWeight: FontWeight.bold, color: Colors.grey),
        ),
        const SizedBox(height: 2),
        Container(
          width: double.infinity,
          height: 45,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            color: Colors.white,
            border: Border.all(color: Colors.grey.shade300),
            borderRadius: BorderRadius.circular(8),
          ),
          child: TextFormField(
            controller: controller,
            keyboardType: keyboardType,
            decoration: const InputDecoration(
              border: InputBorder.none,
            ),
          ),
        ),
      ],
    );
  }
}
