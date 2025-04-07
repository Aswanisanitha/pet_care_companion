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
        print('Fetched slots: $_slotList');
      });
    } catch (e) {
      print('Error fetching slots: $e');
    }
  }

  // Generate token and insert appointment
  Future<void> appointment() async {
    try {
      final userId = supabase.auth.currentUser?.id;
      if (userId == null) {
        throw Exception('User not authenticated');
      }
      if (selectedDate == null ||
          selectedSlot == null ||
          selectedHospital == null) {
        throw Exception('Date, slot, or hospital not selected');
      }

      // Fetch existing appointments for the selected date and hospital
      final existingAppointments = await supabase
          .from('User_tbl_appoinment')
          .select(
              '*, slot_id!inner(*)') // Explicitly join with Vetinaryhospital_tbl_slot
          .eq('appoinment_Fordate', selectedDate!)
          .eq('slot_id.vetinaryhospital_id_id',
              selectedHospital!) // Filter on the nested field
          .order('appoinment_date', ascending: true); // Order by booking time
      // Generate token based on the number of existing appointments
      final token = existingAppointments.length + 1;

      final appointmentData = {
        'user_id_id': userId,
        'slot_id': selectedSlot, // Foreign key to Vetinaryhospital_tbl_slot
        'appoinment_date':
            DateTime.now().toIso8601String().split('T')[0], // Current date
        'appoinment_Fordate': selectedDate, // Selected date
        'appoinment_status': 0,
        'appoinment_token': token, // Generated token
      };

      print('Booking appointment with data: $appointmentData');

      final response =
          await supabase.from('User_tbl_appoinment').insert(appointmentData);

      print('Appointment booked successfully: $response');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Appointment booked! Token: $token')),
      );
    } catch (e) {
      print('Error booking appointment: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to book appointment: $e')),
      );
    }
  }

  // Show slot booking modal
  void showSlotBookingModal(
      BuildContext context, Map<String, dynamic> hospital) {
    setState(() {
      selectedHospital = hospital['vetinaryhospital_id'].toString();
      _slotList.clear();
      selectedDate = null;
      selectedSlot = null;
    });

    fetchSlots(selectedHospital!);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true, // Allow the modal to expand
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Padding(
              padding: EdgeInsets.only(
                left: 16.0,
                right: 16.0,
                top: 16.0,
                bottom: MediaQuery.of(context).viewInsets.bottom + 16.0,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Book Slot for ${hospital['vetinaryhospital_name']}",
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                      color: Colors.deepOrange,
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Select Date
                  TextFormField(
                    decoration: InputDecoration(
                      labelText: "Date",
                      hintText: selectedDate ?? "Select a date",
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      suffixIcon: const Icon(Icons.calendar_today),
                    ),
                    controller: TextEditingController(text: selectedDate),
                    readOnly: true,
                    onTap: () async {
                      DateTime? pickedDate = await showDatePicker(
                        context: context,
                        initialDate: DateTime.now(),
                        firstDate: DateTime.now(),
                        lastDate: DateTime(2100),
                      );
                      if (pickedDate != null) {
                        final formattedDate =
                            pickedDate.toIso8601String().split('T')[0];
                        setModalState(() {
                          selectedDate = formattedDate;
                        });
                        setState(() {
                          selectedDate = formattedDate;
                        });
                        print('Selected date: $selectedDate');
                      }
                    },
                  ),
                  const SizedBox(height: 16),

                  // Slot Dropdown - Fixed to prevent overflow
                  DropdownButtonFormField<String>(
                    decoration: InputDecoration(
                      labelText: "Available Slots",
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 12,
                      ),
                    ),
                    value: selectedSlot,
                    isExpanded: true, // This prevents overflow
                    icon: Icon(Icons.arrow_drop_down),
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 14,
                    ),
                    items: _slotList.map((slot) {
                      return DropdownMenuItem(
                        value: slot['id'].toString(),
                        child: Text(
                          "${slot['slot_fromtime']} - ${slot['slot_totime']} (Available: ${slot['slot_count']})",
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(fontSize: 14),
                        ),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setModalState(() {
                        selectedSlot = value;
                      });
                      setState(() {
                        selectedSlot = value;
                      });
                      print('Selected slot: $selectedSlot');
                    },
                  ),
                  const SizedBox(height: 16),

                  // Submit Button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: selectedDate == null || selectedSlot == null
                          ? null
                          : () async {
                              Navigator.pop(context);
                              await appointment();
                            },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.deepOrange,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        padding: EdgeInsets.symmetric(vertical: 12),
                      ),
                      child: const Text(
                        "Confirm Booking",
                        style: TextStyle(color: Colors.white),
                      ),
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
        title: const Text(
          'Hospital List',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.deepOrange.shade900,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: IntrinsicHeight(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Flexible(
                    flex: 1,
                    child: DropdownButtonFormField<String>(
                      decoration: const InputDecoration(
                        labelText: "Select District",
                        border: OutlineInputBorder(),
                        isDense: true,
                        contentPadding:
                            EdgeInsets.symmetric(vertical: 12, horizontal: 10),
                      ),
                      isExpanded: true, // Prevent overflow
                      value: selectedDistrict,
                      items: districtList.map((district) {
                        return DropdownMenuItem<String>(
                          value: district['id'].toString(),
                          child: Text(
                            district['district_name'] ?? 'Unknown',
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(fontSize: 14),
                          ),
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
                  const SizedBox(width: 8),
                  Flexible(
                    flex: 1,
                    child: DropdownButtonFormField<String>(
                      decoration: const InputDecoration(
                        labelText: "Select Place",
                        border: OutlineInputBorder(),
                        isDense: true,
                        contentPadding:
                            EdgeInsets.symmetric(vertical: 12, horizontal: 10),
                      ),
                      isExpanded: true, // Prevent overflow
                      value: selectedPlace,
                      items: placeList.map((place) {
                        return DropdownMenuItem<String>(
                          value: place['id'].toString(),
                          child: Text(
                            place['place_name'] ?? 'Unknown',
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(fontSize: 14),
                          ),
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
