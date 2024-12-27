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
      // Step 1: Sign up with Supabase Authentication
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
      // print(user);

      if (user == null) {
        print('Sign up error: $user');
      } else {
        final String userId = user.id;

        // Step 2: Upload profile photo (if selected)
        String? photoUrl;
        if (_image != null) {
          photoUrl = await _uploadImage(_image!, userId);
        }

        // Step 3: Insert user details into `tbl_user`
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

      // Get public URL of the uploaded image
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
        title: Text("Registration"),
        backgroundColor: Color.fromARGB(255, 247, 247, 247),
      ),
      body: Stack(
        children: [
          // Background image
          Container(
            decoration: BoxDecoration(
              image: DecorationImage(
                image: AssetImage("assets/sign.png"),
                fit: BoxFit
                    .cover, // Ensure the image covers the entire background
              ),
            ),
          ),
          // Semi-transparent overlay
          Container(
            color: Colors.black
                .withOpacity(0.3), // Adjust the opacity for desired effect
          ),

          Padding(
            padding: const EdgeInsets.all(10.0),
            child: Form(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    Center(
                      child: GestureDetector(
                        onTap: _pickImage,
                        child: Stack(
                          alignment: Alignment
                              .center, // Aligns the camera icon at the center
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
                            if (_image ==
                                null) // Show the camera icon only if no image is uploaded
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
                          labelStyle: TextStyle(
                            color: Colors.black,
                          ),
                          border: OutlineInputBorder()),
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    TextFormField(
                      controller: address,
                      minLines: 4,
                      maxLines: null,
                      decoration: InputDecoration(
                        labelText: "Address",
                        labelStyle: TextStyle(
                          color: Colors.black,
                        ),
                        border: OutlineInputBorder(),
                      ),
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    TextFormField(
                      controller: contact,
                      decoration: InputDecoration(
                          labelText: "Contact",
                          labelStyle: TextStyle(
                            color: Colors.black,
                          ),
                          border: OutlineInputBorder()),
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    TextFormField(
                      controller: email,
                      decoration: InputDecoration(
                          labelText: "Email",
                          labelStyle: TextStyle(
                            color: Colors.black,
                          ),
                          border: OutlineInputBorder()),
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    Container(
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: const Color.fromARGB(255, 7, 1, 1),
                          width: 1.0,
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(left: 10.0),
                            child: Text(
                              "Gender:",
                              style:
                                  TextStyle(fontSize: 16, color: Colors.black),
                            ),
                          ),
                          Radio(
                            value: "Male",
                            groupValue: selectedGender,
                            onChanged: (e) {
                              setState(() {
                                selectedGender = e!;
                              });
                            },
                          ),
                          Text(
                            "Male",
                            style: TextStyle(color: Colors.black),
                          ),
                          Radio(
                            value: "Female",
                            groupValue: selectedGender,
                            onChanged: (e) {
                              setState(() {
                                selectedGender = e!;
                              });
                            },
                          ),
                          Text(
                            "Female",
                            style: TextStyle(color: Colors.black),
                          ),
                          Radio(
                            value: "Others",
                            groupValue: selectedGender,
                            onChanged: (e) {
                              setState(() {
                                selectedGender = e!;
                              });
                            },
                          ),
                          Text("Others", style: TextStyle(color: Colors.black)),
                        ],
                      ),
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    TextFormField(
                      controller: dob,
                      readOnly:
                          true, // Make the field read-only to prevent manual input
                      decoration: InputDecoration(
                        labelText: "Date of Birth",
                        labelStyle: TextStyle(
                          color: Colors
                              .black, // Change the color to your desired value
                        ),
                        hintText: ("Select Date of Birth"),
                        hintStyle: TextStyle(color: Colors.black),
                        border: OutlineInputBorder(),
                        suffixIcon: Icon(Icons.calendar_today),
                      ),
                      onTap: () async {
                        DateTime? pickedDate = await showDatePicker(
                          context: context,
                          initialDate: DateTime.now(), // Set the initial date
                          firstDate: DateTime(1900), // Earliest date selectable
                          lastDate: DateTime.now(), // Latest date selectable
                        );

                        if (pickedDate != null) {
                          setState(() {
                            // Format the date as desired, e.g., YYYY-MM-DD
                            dob.text =
                                "${pickedDate.year}-${pickedDate.month.toString().padLeft(2, '0')}-${pickedDate.day.toString().padLeft(2, '0')}";
                          });
                        }
                      },
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    TextFormField(
                      controller: password,
                      decoration: InputDecoration(
                          labelText: "Password",
                          labelStyle: TextStyle(
                            color: Colors.black,
                          ),
                          border: OutlineInputBorder()),
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    DropdownButtonFormField<String>(
                      decoration: InputDecoration(
                        labelText: 'District',
                        labelStyle: TextStyle(
                          color: Colors.black,
                        ),
                        border: OutlineInputBorder(),
                      ),
                      value: selectedDistrict,
                      hint: Text("Select a District"),
                      onChanged: (newvalue) {
                        setState(() {
                          selectedDistrict = newvalue;

                          fetchplace(newvalue!);
                        });
                      },
                      items: Districtlist.map((district) {
                        return DropdownMenuItem<String>(
                          value: district['id'].toString(),
                          child: Text(district['district_name']),
                        );
                      }).toList(),
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    DropdownButtonFormField<String>(
                      decoration: InputDecoration(
                        labelText: 'Place',
                        labelStyle: TextStyle(
                          color: Colors.black,
                        ),
                        border: OutlineInputBorder(),
                      ),
                      value: selectedPlace,
                      hint: Text("Select a Place"),
                      onChanged: (newvalue) {
                        setState(() {
                          selectedPlace = newvalue;
                        });
                      },
                      items: Placelist.map((place) {
                        // print("Place:$place['id'].toString()");
                        return DropdownMenuItem<String>(
                          value: place['id'].toString(),
                          child: Text(place['place_name']),
                        );
                      }).toList(),
                    ),
                    SizedBox(
                      height: 15,
                    ),
                    SizedBox(height: 15),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        fixedSize: const Size(200, 40),
                        backgroundColor: Colors.black,
                      ),
                      onPressed: () {
                        _reg();
                      },
                      child: Text(
                        "Sign Up",
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
