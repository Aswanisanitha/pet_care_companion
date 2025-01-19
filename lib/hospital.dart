import 'package:flutter/material.dart';
import 'package:pet_care_companion/main.dart';

class Hospital extends StatefulWidget {
  const Hospital({super.key});

  @override
  State<Hospital> createState() => _HospitalState();
}

class _HospitalState extends State<Hospital> {
  List<Map<String, dynamic>> _hospitalList = [];
  List<Map<String, dynamic>> districtList = [];
  List<Map<String, dynamic>> placeList = [];

  String? selectedDistrict;
  String? selectedPlace;

  Future<void> fetchHospitals(String selectedPlace) async {
    try {
      final response = await supabase
          .from('Guest_tbl_vetinaryhospital')
          .select()
          .eq('place_id_id', selectedPlace);
      setState(() {
        _hospitalList = List<Map<String, dynamic>>.from(response);
      });
    } catch (e) {
      print('Error fetching hospitals: $e');
    }
  }

  Future<void> fetchDistricts() async {
    try {
      final response = await supabase.from('Admin_tbl_district').select();
      setState(() {
        districtList = List<Map<String, dynamic>>.from(response);
      });
    } catch (e) {
      print('Error fetching districts: $e');
    }
  }

  Future<void> fetchPlaces(String districtId) async {
    try {
      final response = await supabase
          .from('Admin_tbl_place')
          .select()
          .eq('district_id', districtId);
      setState(() {
        placeList = List<Map<String, dynamic>>.from(response);
      });
    } catch (e) {
      print('Error fetching places: $e');
    }
  }

  @override
  void initState() {
    super.initState();
    fetchDistricts();
  }

  void showSlotBookingModal(
      BuildContext context, Map<String, dynamic> hospital) {
    String? selectedDate;
    String? selectedSlot;
    List<Map<String, dynamic>> slotList = [];

    Future<void> fetchSlots(String hospitalId) async {
      try {
        final response = await supabase
            .from('Vetinaryhospital_tbl_slot')
            .select()
            .eq('vetinaryhospital_id_id', hospitalId);
        print(response);
        setState(() {
          slotList = List<Map<String, dynamic>>.from(response);
        });
      } catch (e) {
        print('Error fetching slots: $e');
      }
    }

    fetchSlots(hospital['id'].toString()); // Fetch slots for the hospital
    print(hospital);
    showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, modalSetState) {
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
                  SizedBox(height: 16),
                  TextField(
                    decoration: InputDecoration(
                      labelText: "Date",
                      hintText: "Select a date",
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      suffixIcon: Icon(Icons.calendar_today),
                    ),
                    onTap: () async {
                      DateTime? pickedDate = await showDatePicker(
                        context: context,
                        initialDate: DateTime.now(),
                        firstDate: DateTime.now(),
                        lastDate: DateTime(2100),
                      );
                      if (pickedDate != null) {
                        modalSetState(() {
                          selectedDate = pickedDate.toString().split(' ')[0];
                        });
                      }
                    },
                  ),
                  SizedBox(height: 16),
                  DropdownButtonFormField<String>(
                    decoration: InputDecoration(
                      labelText: "Slot Time",
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    value: selectedSlot,
                    items: slotList.map((slot) {
                      return DropdownMenuItem(
                        value: slot['id'].toString(),
                        child: Text(slot['slot_fromtime']),
                      );
                    }).toList(),
                    onChanged: (value) {
                      modalSetState(() {
                        selectedSlot = value;
                      });
                    },
                  ),
                  SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context); // Close the modal
                      print(
                          "Booked ${hospital['vetinaryhospital_name']} for $selectedDate at $selectedSlot");
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.deepOrange,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: Text(
                      "Submit",
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
              children: [
                Expanded(
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      hint: Text('Select District'),
                      value: selectedDistrict,
                      onChanged: (newValue) {
                        setState(() {
                          selectedDistrict = newValue;
                          fetchPlaces(newValue!);
                          selectedPlace = null;
                        });
                      },
                      items: districtList.map((district) {
                        return DropdownMenuItem<String>(
                          value: district['id'].toString(),
                          child: Text(district['district_name']),
                        );
                      }).toList(),
                    ),
                  ),
                ),
                SizedBox(width: 8),
                Expanded(
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      hint: Text('Select Place'),
                      value: selectedPlace,
                      onChanged: (newValue) {
                        setState(() {
                          selectedPlace = newValue;
                          fetchHospitals(selectedPlace!);
                        });
                      },
                      items: placeList.map((place) {
                        return DropdownMenuItem<String>(
                          value: place['id'].toString(),
                          child: Text(place['place_name']),
                        );
                      }).toList(),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: _hospitalList.length,
              itemBuilder: (context, index) {
                final hospital = _hospitalList[index];
                return Card(
                  margin: const EdgeInsets.all(8.0),
                  elevation: 4,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: ListTile(
                    title: Text(
                      hospital['vetinaryhospital_name']!,
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(hospital['vetinaryhospital_contact']),
                        Text(hospital['vetinaryhospital_email']),
                        Text(hospital['vetinaryhospital_address']),
                      ],
                    ),
                    leading: Icon(
                      Icons.local_hospital,
                      color: Colors.deepOrange,
                    ),
                    trailing: ElevatedButton(
                      onPressed: () => showSlotBookingModal(context, hospital),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.deepOrange,
                      ),
                      child: Text(
                        "Book Slot",
                        style: TextStyle(color: Colors.white),
                      ),
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
