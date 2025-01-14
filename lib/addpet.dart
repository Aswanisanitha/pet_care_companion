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
  List<Map<String, dynamic>> pets = [];

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
      setState(() {
        breedList = List<Map<String, dynamic>>.from(response);
      });
    } catch (e) {
      print('Error fetching breeds: $e');
    }
  }

  void _addPet() {
    if (name.text.isEmpty ||
        age.text.isEmpty ||
        weight.text.isEmpty ||
        selectedGender.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please fill all the required fields")),
      );
      return;
    }

    setState(() {
      pets.add({
        'name': name.text,
        'age': age.text,
        'weight': weight.text,
        'gender': selectedGender,
        'type': selectedType,
        'breed': selectedBreed,
        'image': _image,
      });

      _resetForm();
    });
  }

  void _resetForm() {
    name.clear();
    age.clear();
    weight.clear();
    selectedGender = '';
    selectedType = null;
    selectedBreed = null;
    _image = null;
  }

  @override
  void initState() {
    super.initState();
    fetchPetTypes();
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
                            : const AssetImage('assets/petmain1.png')
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
                      const Text("Gender:", style: TextStyle(fontSize: 16)),
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
                  onPressed: _addPet,
                  child: const Text(
                    "Add",
                    style: TextStyle(color: Colors.white, fontSize: 16),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                "Pets:",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
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
                            backgroundImage: pet['image'] != null
                                ? FileImage(pet['image'])
                                : const AssetImage('assets/petmain1.png')
                                    as ImageProvider,
                          ),
                          title: Text(pet['name']),
                          subtitle: Text(
                              "Age: ${pet['age']}, Weight: ${pet['weight']}kg, Gender: ${pet['gender']}"),
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
                                      builder: (context) => vaccine()),
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
