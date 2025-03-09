import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:pet_care_companion/addphoto.dart';
import 'package:pet_care_companion/main.dart';
import 'package:pet_care_companion/vaccination.dart';

class addpet extends StatefulWidget {
  // Renamed for Dart conventions
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
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to fetch pet types: $e')),
        );
      }
    }
  }

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
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to fetch breeds: $e')),
        );
      }
    }
  }

  Future<void> _addPet() async {
    // Renamed for consistency
    try {
      // Validation
      if (name.text.isEmpty ||
          selectedGender.isEmpty ||
          selectedBreed == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please fill all required fields')),
        );
        return;
      }

      final userId = supabase.auth.currentUser?.id;
      if (userId == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('No user logged in')),
        );
        return;
      }

      String? photoUrl;
      if (_image != null) {
        photoUrl = await _uploadImage(_image!);
        if (photoUrl == null) {
          throw Exception('Image upload failed');
        }
      }

      await supabase.from('User_tbl_pet').insert({
        'user_id_id': userId,
        'pet_name': name.text,
        'pet_age': int.tryParse(age.text) ?? 0, // Convert to int
        'pet_weight': double.tryParse(weight.text) ?? 0.0, // Convert to double
        'pet_gender': selectedGender,
        'breed_id': selectedBreed,
        'pet_photo': photoUrl,
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Pet successfully added')),
      );

      // Clear form after successful addition
      name.clear();
      age.clear();
      weight.clear();
      setState(() {
        selectedGender = '';
        selectedType = null;
        selectedBreed = null;
        _image = null;
      });

      // Refresh pet list
      await fetchPets();
    } catch (e) {
      print('Adding pet failed: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to add pet: $e')),
        );
      }
    }
  }

  Future<String?> _uploadImage(File image) async {
    try {
      final folderName = "PetDocs";
      final fileName =
          "$folderName/${DateTime.now().millisecondsSinceEpoch}_${image.path.split('/').last}";

      await supabase.storage.from('petcare').upload(fileName, image);
      final imageUrl = supabase.storage.from('petcare').getPublicUrl(fileName);
      return imageUrl;
    } catch (e) {
      print('Image upload failed: $e');
      return null;
    }
  }

  Future<void> fetchPets() async {
    // Renamed for consistency
    try {
      final userId = supabase.auth.currentUser?.id;
      if (userId != null) {
        final response = await supabase
            .from('User_tbl_pet')
            .select(
                '*, Admin_tbl_breed(breed_name, Admin_tbl_pettype(type_name))')
            .eq('user_id_id', userId);

        setState(() {
          pets = List<Map<String, dynamic>>.from(response);
        });
      }
    } catch (e) {
      print('Error fetching pets: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to fetch pets: $e')),
        );
      }
    }
  }

  @override
  void initState() {
    super.initState();
    fetchPetTypes();
    fetchPets();
  }

  @override
  void dispose() {
    name.dispose();
    age.dispose();
    weight.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.deepOrange.shade900,
        title: const Text(
          'Add Pet',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        elevation: 1,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
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
                        const Icon(Icons.camera_alt,
                            color: Colors.white, size: 30),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Card(
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16)),
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
                            child: Text(type['type_name'] ?? 'Unknown'),
                          );
                        }).toList(),
                        onChanged: (value) {
                          setState(() {
                            selectedType = value;
                            selectedBreed =
                                null; // Reset breed when type changes
                            breedList.clear();
                            if (value != null) fetchBreeds(value);
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
                            child: Text(breed['breed_name'] ?? 'Unknown'),
                          );
                        }).toList(),
                        onChanged: (value) {
                          setState(() => selectedBreed = value);
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
                        borderRadius: BorderRadius.circular(30)),
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
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              pets.isEmpty
                  ? const Center(
                      child: Text(
                        'No pets found',
                        style: TextStyle(fontSize: 16, color: Colors.grey),
                      ),
                    )
                  : ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: pets.length,
                      itemBuilder: (context, index) {
                        final pet = pets[index];
                        return Card(
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12)),
                          elevation: 4,
                          child: Column(
                            children: [
                              ListTile(
                                leading: CircleAvatar(
                                  backgroundImage: pet['pet_photo'] != null
                                      ? NetworkImage(pet['pet_photo'])
                                      : const AssetImage('assets/petmain1.png')
                                          as ImageProvider,
                                ),
                                title: Text(pet['pet_name'] ?? 'Unnamed'),
                                subtitle: Text(
                                  'Age: ${pet['pet_age'] ?? 'N/A'}, Weight: ${pet['pet_weight'] ?? 'N/A'}kg, Gender: ${pet['pet_gender'] ?? 'N/A'}, Breed: ${pet['Admin_tbl_breed']?['breed_name'] ?? 'N/A'}, Type: ${pet['Admin_tbl_breed']?['Admin_tbl_pettype']?['type_name'] ?? 'N/A'}',
                                ),
                              ),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceEvenly,
                                children: [
                                  TextButton(
                                    onPressed: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) => petphoto(
                                              petid: pet['id'].toString()),
                                        ),
                                      );
                                    },
                                    child: const Text("Add Photo"),
                                  ),
                                  TextButton(
                                    onPressed: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) => Vaccine(
                                              petid: pet['id'].toString()),
                                        ),
                                      );
                                    },
                                    child: const Text("Add Vaccine Details"),
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
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
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
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
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
        title: Text(gender, style: const TextStyle(fontSize: 14)),
        activeColor: Colors.deepOrange.shade900,
        onChanged: (value) {
          setState(() => selectedGender = value!);
        },
      ),
    );
  }
}
