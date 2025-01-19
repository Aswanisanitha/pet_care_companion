import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class Activity extends StatefulWidget {
  const Activity({Key? key}) : super(key: key);

  @override
  State<Activity> createState() => _ActivityState();
}

class _ActivityState extends State<Activity> {
  List<Map<String, dynamic>> activityList = [];
  String? selectedType;
  String? selectedBreed;

  List<Map<String, dynamic>> typeList = [];
  List<Map<String, dynamic>> breedList = [];
  final supabase = Supabase.instance.client;

  // Fetch Activities
  Future<void> fetchActivity() async {
    try {
      final response = await supabase.from('Admin_tbl_activity').select();
      setState(() {
        activityList = List<Map<String, dynamic>>.from(response);
      });
    } catch (e) {
      print('Error fetching activity: $e');
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
    fetchActivity();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.deepOrange.shade900,
        title: const Text(
          'Activity Details',
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
                  children: activityList
                      .where((activity) =>
                          (selectedType == null ||
                              activity['pettype_id'].toString() ==
                                  selectedType) &&
                          (selectedBreed == null ||
                              activity['breed_id'].toString() == selectedBreed))
                      .map((activity) {
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
                              Icon(Icons.local_activity,
                                  color: Colors.deepOrange),
                              SizedBox(height: 8),
                              Text(
                                activity['activity_name'],
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                              SizedBox(height: 4),
                              Text(
                                activity['activity_time'],
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                              SizedBox(height: 4),
                              Text(
                                activity['activity_details'],
                                style: TextStyle(fontWeight: FontWeight.bold),
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
