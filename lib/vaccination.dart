import 'package:flutter/material.dart';

class vaccine extends StatefulWidget {
  const vaccine({super.key});

  @override
  State<vaccine> createState() => _vaccineState();
}

class _vaccineState extends State<vaccine> {
  final _vaccineNameFocus = FocusNode();
  final _vaccineDetailsFocus = FocusNode();
  final _vaccinatedDateFocus = FocusNode();
  final _nextVaccineDateFocus = FocusNode();

  // Example list for vaccine history
  final List<Map<String, String>> vaccineHistory = [
    {
      "name": "Rabies",
      "details": "Protects against rabies virus",
      "date": "01-01-2024",
      "nextDate": "01-01-2025"
    },
    {
      "name": "Parvo",
      "details": "Prevents canine parvovirus",
      "date": "15-02-2024",
      "nextDate": "15-02-2025"
    },
  ];

  int? _selectedCardIndex;

  @override
  void dispose() {
    _vaccineNameFocus.dispose();
    _vaccineDetailsFocus.dispose();
    _vaccinatedDateFocus.dispose();
    _nextVaccineDateFocus.dispose();
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
                focusNode: _vaccineNameFocus,
              ),
              const SizedBox(height: 16),
              _buildTextField(
                label: "Vaccine Details",
                focusNode: _vaccineDetailsFocus,
                maxLines: 5,
              ),
              const SizedBox(height: 16),
              _buildTextField(
                label: "Vaccinated Date",
                focusNode: _vaccinatedDateFocus,
              ),
              const SizedBox(height: 16),
              _buildTextField(
                label: "Next Vaccine Date",
                focusNode: _nextVaccineDateFocus,
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
                  // Submit action
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
                                vaccine["name"] ?? "",
                                style: const TextStyle(
                                    fontSize: 16, fontWeight: FontWeight.bold),
                              ),
                              const SizedBox(height: 5),
                              Text("Details: ${vaccine["details"] ?? ""}"),
                              Text("Vaccinated Date: ${vaccine["date"] ?? ""}"),
                              Text(
                                  "Next Vaccine Date: ${vaccine["nextDate"] ?? ""}"),
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
    required FocusNode focusNode,
    int maxLines = 1,
  }) {
    return TextFormField(
      focusNode: focusNode,
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
