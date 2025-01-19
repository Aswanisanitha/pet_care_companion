import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:pet_care_companion/addphoto.dart';
import 'package:pet_care_companion/main.dart';
import 'package:pet_care_companion/vaccination.dart';

class addpet extends StatefulWidget {
  const addpet({super.key});

  @override
  State<addpet> createState() => _addpetState();
}

class _addpetState extends State<addpet> {
  final TextEditingController name = TextEditingController();
  final TextEditingController age = TextEditingController();
  final TextEditingController weight = TextEditingController();

  String selectedGender = '';
  String? selectedType;
  String? selectedBreed;

  List<Map<String, dynamic>> typeList = [];
  List<Map<String, dynamic>> breedList = [];
  List<Map<String, dynamic>> pets = []; //view pets

  File? _image;
  final ImagePicker _picker = ImagePicker();

  Future<void> _pickImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);
      });
    }
  }

  Future<void> fetchPetTypes() async {
    try {
      final response = await supabase.from('Admin_tbl_pettype').select();
      setState(() {
        typeList = List<Map<String, dynamic>>.from(response);
      });
    } catch (e) {
      print('Error fetching pet types: $e');
    }
  }

  // Fetch Breeds
  Future<void> fetchBreeds(String typeId) async {
    try {
      final response = await supabase
          .from('Admin_tbl_breed')
          .select()
          .eq('pettype_id', typeId);
      print(response);
      setState(() {
        breedList = List<Map<String, dynamic>>.from(response);
      });
    } catch (e) {
      print('Error fetching breeds: $e');
    }
  }

  Future<void> _addpet() async {
    try {
      final userid = supabase.auth.currentUser!.id;
      String? photoUrl;
      if (_image != null) {
        photoUrl = await _uploadImage(_image!);
      }
      await supabase.from('User_tbl_pet').insert({
        'user_id_id': userid,
        'pet_name': name.text,
        'pet_age': age.text,
        'pet_weight': weight.text,
        'pet_gender': selectedGender,
        'breed_id': selectedBreed,
        'pet_photo': photoUrl,
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Successfully Added ")),
      );
    } catch (e) {
      print(' Adding pet failed: $e');
    }
  }

  Future<String?> _uploadImage(File _image) async {
    try {
      final folderName = "PetDocs"; // Folder name
      final fileName = "$folderName/${_image.path.split('/').last}";
      // Adding a unique filename by combining timestamp and original file name

      await supabase.storage.from('petcare').upload(fileName, _image);

      final imageUrl = supabase.storage.from('petcare').getPublicUrl(fileName);
      return imageUrl;
    } catch (e) {
      print('Image upload failed: $e');
      return null;
    }
  }

  Future<void> fetchpets() async {
    try {
      final userid = supabase.auth.currentUser!.id;
      if (userid != null) {
        final response = await supabase
            .from('User_tbl_pet')
            .select(
                '*, Admin_tbl_breed(breed_name, Admin_tbl_pettype(type_name))')
            .eq('user_id_id', userid);

        print(response);

        setState(() {
          pets = List<Map<String, dynamic>>.from(response);
        });
      }
    } catch (e) {
      print('Error fetching pets: $e');
    }
  }

  @override
  void initState() {
    super.initState();
    fetchPetTypes();
    fetchpets();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.deepOrange.shade900,
        title: const Text(
          'Add Pet',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        elevation: 1,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: GestureDetector(
                  onTap: _pickImage,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      CircleAvatar(
                        radius: 60,
                        backgroundColor: Colors.grey.shade300,
                        backgroundImage: _image != null
                            ? FileImage(_image!)
                            : AssetImage('assets/petmain1.png')
                                as ImageProvider,
                      ),
                      if (_image == null)
                        const Icon(
                          Icons.camera_alt,
                          color: Colors.white,
                          size: 30,
                        ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                elevation: 4,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      _buildTextField(name, "Pet Name", Icons.pets),
                      const SizedBox(height: 15),
                      _buildDropdown(
                        label: "Species",
                        value: selectedType,
                        hint: "Select Species",
                        items: typeList.map((type) {
                          return DropdownMenuItem<String>(
                            value: type['id'].toString(),
                            child: Text(type['type_name']),
                          );
                        }).toList(),
                        onChanged: (value) {
                          setState(() {
                            selectedType = value;
                            fetchBreeds(value!);
                          });
                        },
                      ),
                      const SizedBox(height: 15),
                      _buildDropdown(
                        label: "Breed",
                        value: selectedBreed,
                        hint: "Select Breed",
                        items: breedList.map((breed) {
                          return DropdownMenuItem<String>(
                            value: breed['id'].toString(),
                            child: Text(breed['breed_name']),
                          );
                        }).toList(),
                        onChanged: (value) {
                          setState(() {
                            selectedBreed = value;
                          });
                        },
                      ),
                      const SizedBox(height: 15),
                      _buildTextField(age, "Age", Icons.cake),
                      const SizedBox(height: 15),
                      Text("Gender:", style: TextStyle(fontSize: 16)),
                      Row(
                        children: [
                          _buildRadioButton("Male"),
                          _buildRadioButton("Female"),
                        ],
                      ),
                      const SizedBox(height: 15),
                      _buildTextField(weight, "Weight", Icons.line_weight),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Center(
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.deepOrange.shade900,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                    fixedSize: const Size(200, 40),
                  ),
                  onPressed: _addpet,
                  child: const Text(
                    "Add",
                    style: TextStyle(color: Colors.white, fontSize: 16),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Text(
                "Pets:",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: pets.length,
                itemBuilder: (context, index) {
                  final pet = pets[index];
                  return Card(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 4,
                    child: Column(
                      children: [
                        ListTile(
                          leading: CircleAvatar(
                            backgroundImage: pet['pet_photo'] != null
                                ? NetworkImage(pet['pet_photo'])
                                : AssetImage('assets/petmain1.png')
                                    as ImageProvider,
                          ),
                          title: Text(pet['pet_name']),
                          subtitle: Text(
                              "Age: ${pet['pet_age']}, Weight: ${pet['pet_weight']}kg, Gender: ${pet['pet_gender']},Breed:${pet['Admin_tbl_breed']['breed_name']},PetType:${pet['Admin_tbl_breed']['Admin_tbl_pettype']['type_name']}"),
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            TextButton(
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => petphoto()),
                                );
                              },
                              child: const Text("Add Photo"),
                            ),
                            TextButton(
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) =>
                                          Vaccine(petid: pet['id'].toString())),
                                );
                              },
                              child: const Text("Add Vaccine Details "),
                            ),
                          ],
                        ),
                      ],
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(
      TextEditingController controller, String label, IconData icon) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: Colors.deepOrange.shade900),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.deepOrange.shade900),
        ),
      ),
    );
  }

  Widget _buildDropdown({
    required String label,
    required String? value,
    required String hint,
    required List<DropdownMenuItem<String>> items,
    required ValueChanged<String?> onChanged,
  }) {
    return DropdownButtonFormField<String>(
      value: value,
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.deepOrange.shade900),
        ),
      ),
      hint: Text(hint),
      items: items,
      onChanged: onChanged,
    );
  }

  Widget _buildRadioButton(String gender) {
    return Expanded(
      child: RadioListTile<String>(
        value: gender,
        groupValue: selectedGender,
        title: Text(
          gender,
          style: const TextStyle(fontSize: 14),
        ),
        activeColor: Colors.deepOrange.shade900,
        onChanged: (value) {
          setState(() {
            selectedGender = value!;
          });
        },
      ),
    );
  }
}
