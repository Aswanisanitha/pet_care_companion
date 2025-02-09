import 'package:flutter/material.dart';
import 'package:pet_care_companion/main.dart';

class Vaccine extends StatefulWidget {
  final String petid;

  const Vaccine({super.key, required this.petid});

  @override
  State<Vaccine> createState() => _VaccineState();
}

class _VaccineState extends State<Vaccine> {
  // Controllers for text fields
  final TextEditingController _vaccineName = TextEditingController();
  final TextEditingController _vaccineDetails = TextEditingController();
  final TextEditingController _vaccinatedDate = TextEditingController();
  final TextEditingController _nextVaccineDate = TextEditingController();
  List<Map<String, dynamic>> vaccineHistory = [];
  int? _selectedCardIndex;

  Future<void> _addvaccine() async {
    try {
      final userid = supabase.auth.currentUser!.id;

      await supabase.from('User_tbl_vaccinedetails').insert({
        'pet_id_id': widget.petid,
        'vaccine_name': _vaccineName.text,
        'vaccine_details': _vaccineDetails.text,
        'vaccine_date': _vaccinatedDate.text,
        'vaccine_fordate': _nextVaccineDate.text,
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Successfully Added ")),
      );
    } catch (e) {
      print(' Vaccine not added: $e');
    }
  }

  Future<void> fetchvaccine() async {
    try {
      final response = await supabase
          .from('User_tbl_vaccinedetails')
          .select()
          .eq('pet_id_id', widget.petid);
      setState(() {
        vaccineHistory = List<Map<String, dynamic>>.from(response);
      });
    } catch (e) {
      print('Error fetching vaccine: $e');
    }
  }

  @override
  void initState() {
    super.initState();
    fetchvaccine();
  }

  @override
  void dispose() {
    // Dispose controllers
    _vaccineName.dispose();
    _vaccineDetails.dispose();
    _vaccinatedDate.dispose();
    _nextVaccineDate.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.deepOrange.shade900,
        title: const Text(
          'Vaccination Reminder',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
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
        child: Form(
          child: Column(
            children: [
              _buildTextField(
                label: "Vaccine Name",
                controller: _vaccineName,
              ),
              const SizedBox(height: 16),
              _buildTextField(
                label: "Vaccine Details",
                controller: _vaccineDetails,
                maxLines: 5,
              ),
              const SizedBox(height: 16),
              _buildTextField(
                label: "Vaccinated Date",
                controller: _vaccinatedDate,
              ),
              const SizedBox(height: 16),
              _buildTextField(
                label: "Next Vaccine Date",
                controller: _nextVaccineDate,
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
                  print("Submit button clicked"); // Debugging
                  _addvaccine();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.deepOrange.shade900,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: const Text(
                  "Submit",
                  style: TextStyle(color: Colors.white),
                ),
              ),
              const SizedBox(height: 20),
              Expanded(
                child: ListView.builder(
                  itemCount: vaccineHistory.length,
                  itemBuilder: (context, index) {
                    final vaccine = vaccineHistory[index];
                    return GestureDetector(
                      onTap: () {
                        setState(() {
                          _selectedCardIndex = index;
                        });
                      },
                      child: Card(
                        margin: const EdgeInsets.symmetric(vertical: 8),
                        elevation: 3,
                        color: _selectedCardIndex == index
                            ? Colors.deepOrange.shade100
                            : Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                          side: BorderSide(
                            color: _selectedCardIndex == index
                                ? Colors.deepOrange.shade900
                                : Colors.transparent,
                          ),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(12.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                vaccine["vaccine_name"] ?? "",
                                style: const TextStyle(
                                    fontSize: 16, fontWeight: FontWeight.bold),
                              ),
                              const SizedBox(height: 5),
                              Text(
                                  "Details: ${vaccine["vaccine_details"] ?? ""}"),
                              Text(
                                  "Vaccinated Date: ${vaccine["vaccine_date"] ?? ""}"),
                              Text(
                                  "Next Vaccine Date: ${vaccine["vaccine_fordate"] ?? ""}"),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required String label,
    required TextEditingController controller,
    int maxLines = 1,
  }) {
    return TextFormField(
      controller: controller,
      maxLines: maxLines,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(color: Colors.deepOrange.shade900),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: Colors.deepOrange.shade900),
        ),
      ),
    );
  }
}
