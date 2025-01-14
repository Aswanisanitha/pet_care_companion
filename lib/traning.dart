import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class traning extends StatefulWidget {
  const traning({Key? key}) : super(key: key);

  @override
  State<traning> createState() => _traningState();
}

class _traningState extends State<traning> {
  List<Map<String, dynamic>> traningList = [];
  String? selectedType;
  String? selectedBreed;

  List<Map<String, dynamic>> typeList = [];
  List<Map<String, dynamic>> breedList = [];
  final supabase = Supabase.instance.client;

  // Fetch Activities
  Future<void> fetchtraning() async {
    try {
      final response = await supabase.from('Admin_tbl_traning').select();
      setState(() {
        traningList = List<Map<String, dynamic>>.from(response);
      });
    } catch (e) {
      print('Error fetching traning: $e');
    }
  }

  // Fetch Pet Types
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

  @override
  void initState() {
    super.initState();
    fetchPetTypes();
    fetchtraning();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.deepOrange.shade900,
        title: const Text(
          'Traning Details',
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
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Species Dropdown
            DropdownButtonFormField<String>(
              decoration: InputDecoration(
                labelText: 'Species',
                filled: true,
                fillColor: Colors.grey[200],
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.deepOrange.shade900),
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              value: selectedType,
              hint: const Text("Select Species"),
              onChanged: (newValue) {
                setState(() {
                  selectedType = newValue;
                  selectedBreed = null;
                  breedList.clear();
                });
                if (newValue != null) {
                  fetchBreeds(newValue);
                }
              },
              items: typeList.map((type) {
                return DropdownMenuItem<String>(
                  value: type['id'].toString(),
                  child: Text(type['type_name']),
                );
              }).toList(),
            ),
            const SizedBox(height: 16),
            // Breed Dropdown
            DropdownButtonFormField<String>(
              decoration: InputDecoration(
                labelText: 'Breed',
                filled: true,
                fillColor: Colors.grey[200],
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.deepOrange.shade900),
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              value: selectedBreed,
              hint: const Text("Select Breed"),
              onChanged: (newValue) {
                setState(() {
                  selectedBreed = newValue;
                });
              },
              items: breedList.map((breed) {
                return DropdownMenuItem<String>(
                  value: breed['id'].toString(),
                  child: Text(breed['breed_name']),
                );
              }).toList(),
            ),
            const SizedBox(height: 20),
            // Activity List
            Expanded(
              child: SingleChildScrollView(
                child: Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: traningList
                      .where((traning) =>
                          (selectedType == null ||
                              traning['pettype_id'].toString() ==
                                  selectedType) &&
                          (selectedBreed == null ||
                              traning['breed_id'].toString() == selectedBreed))
                      .map((traningplan) {
                    return SizedBox(
                      width: MediaQuery.of(context).size.width / 2 -
                          24, // Adjust width
                      child: Card(
                        elevation: 4,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Icon(Icons.model_training,
                                  color: Colors.deepOrange),
                              SizedBox(height: 8),
                              Text(
                                traningplan['traning_name'],
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                              SizedBox(height: 4),
                              Text(
                                traningplan['description'] ?? 'No details',
                                style: TextStyle(color: Colors.grey),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
