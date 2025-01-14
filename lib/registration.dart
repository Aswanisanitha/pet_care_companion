import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:pet_care_companion/login.dart';
import 'package:pet_care_companion/main.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class Registration extends StatefulWidget {
  const Registration({super.key});

  @override
  State<Registration> createState() => _RegistrationState();
}

class _RegistrationState extends State<Registration> {
  final TextEditingController name = TextEditingController();
  final TextEditingController email = TextEditingController();
  final TextEditingController contact = TextEditingController();
  final TextEditingController address = TextEditingController();
  final TextEditingController password = TextEditingController();
  final TextEditingController dob = TextEditingController();

  String selectedGender = '';
  String? selectedDistrict;
  String? selectedPlace;
  File? _image;
  final ImagePicker _picker = ImagePicker();
  List<Map<String, dynamic>> Districtlist = [];

  Future<void> fetchdistrict() async {
    try {
      final response = await supabase.from('Admin_tbl_district').select();

      setState(() {
        Districtlist = response;
      });
    } catch (e) {
      print('Exception during fetch: $e');
    }
  }

  List<Map<String, dynamic>> Placelist = [];
  Future<void> fetchplace(String selectedDistrict) async {
    try {
      final response = await supabase
          .from('Admin_tbl_place')
          .select()
          .eq('district_id', selectedDistrict);

      setState(() {
        Placelist = response;
      });
    } catch (e) {
      print('Exception during fetch: $e');
    }
  }

  Future<void> _reg() async {
    try {
      final AuthResponse response = await supabase.auth.signUp(
        email: email.text,
        password: password.text,
      );

      if (response.user != null) {
        String fullName = name.text;
        String firstName = fullName.split(' ').first;
        await supabase.auth.updateUser(UserAttributes(
          data: {'display_name': firstName},
        ));
      }

      final User? user = response.user;

      if (user == null) {
        print('Sign up error: $user');
      } else {
        final String userId = user.id;

        String? photoUrl;
        if (_image != null) {
          photoUrl = await _uploadImage(_image!, userId);
        }

        await supabase.from('Guest_tbl_userreg').insert({
          'user_id': userId,
          'user_photo': photoUrl,
          'user_name': name.text,
          'user_email': email.text,
          'user_password': password.text,
          'user_contact': contact.text,
          'user_gender': selectedGender,
          'user_address': address.text,
          'user_dob': dob.text,
          'user_place_id': selectedPlace,
        });
        print('User created successfully');
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Account Created successfully')),
        );
        Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => Login(),
            ));
      }
    } catch (e) {
      print('Sign up failed: $e');
    }
  }

  Future<void> _pickImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);
      });
    }
  }

  Future<String?> _uploadImage(File image, String userId) async {
    try {
      final Foldername = "UserDocs";
      final fileName = '$Foldername/user_$userId';

      await supabase.storage.from('petcare').upload(fileName, image);

      final imageUrl = supabase.storage.from('petcare').getPublicUrl(fileName);
      return imageUrl;
    } catch (e) {
      print('Image upload failed: $e');
      return null;
    }
  }

  @override
  void initState() {
    super.initState();
    fetchdistrict();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.deepOrange.shade900,
        title: const Text('Registration',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
      ),
      body: Padding(
        padding: const EdgeInsets.all(10.0),
        child: Form(
          child: SingleChildScrollView(
            child: Column(
              children: [
                Center(
                  child: GestureDetector(
                    onTap: _pickImage,
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        CircleAvatar(
                          radius: 50,
                          backgroundColor:
                              const Color.fromARGB(95, 193, 169, 169),
                          backgroundImage: _image != null
                              ? FileImage(_image!)
                              : const AssetImage('assets/user.png')
                                  as ImageProvider,
                        ),
                        if (_image == null)
                          const Icon(
                            Icons.camera_alt,
                            color: Color.fromARGB(255, 255, 255, 255),
                            size: 30,
                          ),
                      ],
                    ),
                  ),
                ),
                SizedBox(height: 10),
                TextFormField(
                  controller: name,
                  decoration: InputDecoration(
                    labelText: "Name",
                    prefixIcon: Icon(Icons.person, color: Colors.deepOrange),
                    labelStyle: TextStyle(color: Colors.black),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.deepOrange),
                    ),
                  ),
                ),
                SizedBox(height: 30),
                TextFormField(
                  controller: address,
                  decoration: InputDecoration(
                    prefixIcon: Icon(Icons.home, color: Colors.deepOrange),
                    labelText: "Address",
                    labelStyle: TextStyle(color: Colors.black),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.deepOrange),
                    ),
                  ),
                ),
                SizedBox(height: 30),
                TextFormField(
                  controller: contact,
                  decoration: InputDecoration(
                    prefixIcon: Icon(Icons.phone, color: Colors.deepOrange),
                    labelText: "Contact",
                    labelStyle: TextStyle(color: Colors.black),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.deepOrange),
                    ),
                  ),
                  keyboardType: TextInputType.phone,
                ),
                SizedBox(height: 30),
                TextFormField(
                  controller: email,
                  decoration: InputDecoration(
                    prefixIcon: Icon(Icons.email, color: Colors.deepOrange),
                    labelText: "Email",
                    labelStyle: TextStyle(color: Colors.black),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.deepOrange),
                    ),
                  ),
                  keyboardType: TextInputType.emailAddress,
                ),
                SizedBox(height: 30),
                TextFormField(
                  controller: password,
                  decoration: InputDecoration(
                    prefixIcon: Icon(Icons.lock, color: Colors.deepOrange),
                    labelText: "Password",
                    labelStyle: TextStyle(color: Colors.black),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.deepOrange),
                    ),
                  ),
                  obscureText: true,
                ),
                SizedBox(height: 40),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    fixedSize: const Size(200, 40),
                    backgroundColor: Colors.black,
                  ),
                  onPressed: _reg,
                  child: Text(
                    "Sign Up",
                    style: TextStyle(color: Colors.white, fontSize: 18),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
