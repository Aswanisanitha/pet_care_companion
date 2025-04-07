import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class Food extends StatefulWidget {
  const Food({Key? key}) : super(key: key);

  @override
  State<Food> createState() => _FoodState();
}

class _FoodState extends State<Food> {
  List<Map<String, dynamic>> foodList = [];
  List<Map<String, dynamic>> filteredFoodList = [];
  String? selectedType;
  String? selectedBreed;
  List<Map<String, dynamic>> typeList = [];
  List<Map<String, dynamic>> breedList = [];
  final supabase = Supabase.instance.client;
  bool isLoading = true;

  Future<void> fetchFood() async {
    try {
      final response = await supabase.from('Admin_tbl_foodplan').select('''
            *,
            Admin_tbl_food(food_name, food_calories, food_type),
            Admin_tbl_breed!inner(
              id,
              breed_name,
              pettype_id,
              Admin_tbl_pettype!inner(type_name)
            )
          ''');

      if (response != null) {
        print('Food data: $response');
        setState(() {
          foodList = List<Map<String, dynamic>>.from(response);
          filterFoodPlans();
          isLoading = false;
        });
      } else {
        print('No data returned from fetchFood');
        setState(() => isLoading = false);
      }
    } catch (e) {
      print('Error fetching food details: $e');
      setState(() => isLoading = false);
    }
  }

  Future<void> fetchPetTypes() async {
    try {
      final response = await supabase.from('Admin_tbl_pettype').select();
      if (response != null) {
        setState(() {
          typeList = List<Map<String, dynamic>>.from(response);
        });
      }
    } catch (e) {
      print('Error fetching pet types: $e');
    }
  }

  Future<void> fetchBreeds(String typeId) async {
    try {
      final response = await supabase
          .from('Admin_tbl_breed')
          .select()
          .eq('pettype_id', typeId);
      if (response != null) {
        print('Breed data for type $typeId: $response');
        setState(() {
          breedList = List<Map<String, dynamic>>.from(response);
        });
      }
    } catch (e) {
      print('Error fetching breeds: $e');
    }
  }

  Future<void> filterFoodPlans() async {
    setState(() {
      filteredFoodList = foodList.where((food) {
        final breedData = food['Admin_tbl_breed'] as Map<String, dynamic>?;

        // Debugging output
        print(
            'Filtering - Selected Type: $selectedType, Selected Breed: $selectedBreed');
        print('Current food item breed data: $breedData');

        final matchesType = selectedType == null ||
            (breedData != null &&
                breedData['pettype_id'].toString() == selectedType);
        final matchesBreed = selectedBreed == null ||
            (breedData != null && breedData['id'].toString() == selectedBreed);

        return matchesType && matchesBreed;
      }).toList();

      print('Filtered food plans: $filteredFoodList');
    });
  }

  @override
  void initState() {
    super.initState();
    fetchPetTypes();
    fetchFood();
    filterFoodPlans();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.deepOrange.shade900,
        title: const Text(
          'Food Details',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: isLoading
            ? const Center(child: CircularProgressIndicator())
            : Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  DropdownButtonFormField<String>(
                    decoration: InputDecoration(
                      labelText: 'Species',
                      filled: true,
                      fillColor: Colors.grey[200],
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderSide:
                            BorderSide(color: Colors.deepOrange.shade900),
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
                      filterFoodPlans();
                    },
                    items: typeList.map((type) {
                      return DropdownMenuItem<String>(
                        value: type['id']?.toString(),
                        child: Text(type['type_name'] ?? 'Unknown'),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<String>(
                    decoration: InputDecoration(
                      labelText: 'Breed',
                      filled: true,
                      fillColor: Colors.grey[200],
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderSide:
                            BorderSide(color: Colors.deepOrange.shade900),
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    value: selectedBreed,
                    hint: const Text("Select Breed"),
                    onChanged: (newValue) {
                      setState(() {
                        selectedBreed = newValue;
                      });
                      filterFoodPlans();
                    },
                    items: breedList.map((breed) {
                      return DropdownMenuItem<String>(
                        value: breed['id']?.toString(),
                        child: Text(breed['breed_name'] ?? 'Unknown'),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 20),
                  Expanded(
                    child: SingleChildScrollView(
                      child: Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: filteredFoodList.map((foodplan) {
                          final foodData = foodplan['Admin_tbl_food']
                              as Map<String, dynamic>?;
                          return SizedBox(
                            width: MediaQuery.of(context).size.width / 2 - 24,
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
                                    const Icon(Icons.fastfood,
                                        color: Colors.deepOrange),
                                    const SizedBox(height: 8),
                                    Text(
                                      foodData?['food_name'] ?? 'N/A',
                                      style: const TextStyle(
                                          fontWeight: FontWeight.bold),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      foodplan['food_quantity']?.toString() ??
                                          'N/A',
                                      style: const TextStyle(
                                          fontWeight: FontWeight.bold),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      foodData?['food_calories']?.toString() ??
                                          'N/A',
                                      style: const TextStyle(
                                          fontWeight: FontWeight.bold),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      foodData?['food_type'] ?? 'N/A',
                                      style: const TextStyle(
                                          fontWeight: FontWeight.bold),
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
