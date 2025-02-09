import 'package:flutter/material.dart';
import 'package:pet_care_companion/main.dart';

class Hospital extends StatefulWidget {
  const Hospital({super.key});

  @override
  State<Hospital> createState() => _HospitalState();
}

class _HospitalState extends State<Hospital> {
  List<Map<String, dynamic>> _hospitalList = [];
  List<Map<String, dynamic>> _slotList = [];

  String? selectedDistrict;
  String? selectedPlace;
  String? selectedHospital;
  String? selectedSlot;
  String? selectedDate;

  List<Map<String, dynamic>> districtList = [];
  List<Map<String, dynamic>> placeList = [];

  @override
  void initState() {
    super.initState();
    fetchDistrict();
    fetchHospitals();
  }

  // Fetch all hospitals
  Future<void> fetchHospitals() async {
    try {
      final response =
          await supabase.from('Guest_tbl_vetinaryhospital').select();
      setState(() {
        _hospitalList = response;
      });
    } catch (e) {
      print('Error fetching hospitals: $e');
    }
  }

  // Fetch hospitals by place
  Future<void> fetchHospitalByPlace(String selectedPlace) async {
    try {
      final response = await supabase
          .from('Guest_tbl_vetinaryhospital')
          .select()
          .eq('place_id_id', selectedPlace);
      setState(() {
        _hospitalList = response;
      });
    } catch (e) {
      print('Error fetching hospitals by place: $e');
    }
  }

  // Fetch districts
  Future<void> fetchDistrict() async {
    try {
      final response = await supabase.from('Admin_tbl_district').select();
      setState(() {
        districtList = response;
      });
    } catch (e) {
      print('Error fetching districts: $e');
    }
  }

  // Fetch places based on district
  Future<void> fetchPlace(String selectedDistrict) async {
    try {
      final response = await supabase
          .from('Admin_tbl_place')
          .select()
          .eq('district_id', selectedDistrict);
      setState(() {
        placeList = response;
      });
    } catch (e) {
      print('Error fetching places: $e');
    }
  }

  // Fetch available slots for a hospital
  Future<void> fetchSlots(String selectedHospital) async {
    try {
      final response = await supabase
          .from('Vetinaryhospital_tbl_slot')
          .select()
          .eq('vetinaryhospital_id_id', selectedHospital);

      setState(() {
        _slotList = response;
      });
    } catch (e) {
      print('Error fetching slots: $e');
    }
  }

  Future<void> appointment() async {
    try {
      await supabase.from("User_tbl_appoinment").insert({''});
    } catch (e) {}
  }

  // Show slot booking modal
  void showSlotBookingModal(
      BuildContext context, Map<String, dynamic> hospital) {
    setState(() {
      selectedHospital = hospital['vetinaryhospital_id'].toString();
      _slotList.clear();
    });

    fetchSlots(selectedHospital!);

    showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Book Slot for ${hospital['vetinaryhospital_name']}",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                      color: Colors.deepOrange,
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Select Date
                  TextField(
                    decoration: InputDecoration(
                      labelText: "Date",
                      hintText: "Select a date",
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      suffixIcon: Icon(Icons.calendar_today),
                    ),
                    readOnly: true,
                    onTap: () async {
                      DateTime? pickedDate = await showDatePicker(
                        context: context,
                        initialDate: DateTime.now(),
                        firstDate: DateTime.now(),
                        lastDate: DateTime(2100),
                      );
                      if (pickedDate != null) {
                        setModalState(() {
                          selectedDate = pickedDate.toString().split(' ')[0];
                        });
                      }
                    },
                  ),
                  const SizedBox(height: 16),

                  // Slot Dropdown
                  DropdownButtonFormField<String>(
                    decoration: InputDecoration(
                      labelText: "Available Slots",
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    value: selectedSlot,
                    items: _slotList.map((slot) {
                      return DropdownMenuItem(
                        value: slot['id'].toString(),
                        child: Text(
                          "${slot['slot_fromtime']} - ${slot['slot_totime']} (Available: ${slot['slot_count']})",
                        ),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setModalState(() {
                        selectedSlot = value;
                      });
                    },
                  ),
                  const SizedBox(height: 16),

                  // Submit Button
                  ElevatedButton(
                    onPressed: selectedDate == null || selectedSlot == null
                        ? null
                        : () {
                            Navigator.pop(context);
                            print(
                                "Booked ${hospital['vetinaryhospital_name']} for $selectedDate at slot $selectedSlot");
                          },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.deepOrange,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: Text(
                      "Confirm Booking",
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Hospital List',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.deepOrange.shade900,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // District Dropdown

                Expanded(
                  child: DropdownButtonFormField<String>(
                    decoration: InputDecoration(
                      labelText: "Select District",
                      border: OutlineInputBorder(),
                    ),
                    value: selectedDistrict,
                    items: districtList.isEmpty
                        ? []
                        : districtList.map((district) {
                            return DropdownMenuItem<String>(
                              value: district['id'].toString(),
                              child:
                                  Text(district['district_name'] ?? 'Unknown'),
                            );
                          }).toList(),
                    onChanged: (newValue) {
                      setState(() {
                        selectedDistrict = newValue;
                        selectedPlace = null;
                        if (selectedDistrict != null) {
                          fetchPlace(selectedDistrict!);
                        }
                      });
                    },
                  ),
                ),
                SizedBox(
                  width: 10,
                ),
// Place Dropdown
                Expanded(
                  child: DropdownButtonFormField<String>(
                    decoration: InputDecoration(
                      labelText: "Select Place",
                      border: OutlineInputBorder(),
                    ),
                    value: selectedPlace,
                    items: placeList.isEmpty
                        ? []
                        : placeList.map((place) {
                            return DropdownMenuItem<String>(
                              value: place['id'].toString(),
                              child: Text(place['place_name'] ?? 'Unknown'),
                            );
                          }).toList(),
                    onChanged: (newValue) {
                      setState(() {
                        selectedPlace = newValue;
                        if (selectedPlace != null) {
                          fetchHospitalByPlace(selectedPlace!);
                        }
                      });
                    },
                  ),
                ),
              ],
            ),
          ),

          // Hospital List
          Expanded(
            child: ListView.builder(
              itemCount: _hospitalList.length,
              itemBuilder: (context, index) {
                final hospital = _hospitalList[index];
                return Card(
                  margin:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Hospital Name
                        Text(
                          hospital['vetinaryhospital_name'] ?? 'Unknown Name',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),

                        // Email
                        Row(
                          children: [
                            const Icon(Icons.email,
                                size: 18, color: Colors.grey),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                hospital['vetinaryhospital_email'] ??
                                    'No Email Provided',
                                style: const TextStyle(fontSize: 14),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),

                        // Contact
                        Row(
                          children: [
                            const Icon(Icons.phone,
                                size: 18, color: Colors.grey),
                            const SizedBox(width: 8),
                            Text(
                              hospital['vetinaryhospital_contact'] ??
                                  'No Contact Info Available',
                              style: const TextStyle(fontSize: 14),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),

                        // Address
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Icon(Icons.location_on,
                                size: 18, color: Colors.grey),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                hospital['vetinaryhospital_address'] ??
                                    'No Address Provided',
                                style: const TextStyle(fontSize: 14),
                              ),
                            ),
                          ],
                        ),
                        // const SizedBox(height: 5),

                        // Book Slot Button
                        Align(
                          alignment: Alignment.centerRight,
                          child: ElevatedButton(
                            onPressed: () =>
                                showSlotBookingModal(context, hospital),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.deepOrange,
                            ),
                            child: const Text(
                              "Book Slot",
                              style: TextStyle(color: Colors.white),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
