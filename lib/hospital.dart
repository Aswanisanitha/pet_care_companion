import 'package:flutter/material.dart';
import 'package:pet_care_companion/main.dart';

class hospital extends StatefulWidget {
  const hospital({super.key});

  @override
  State<hospital> createState() => _hospitalState();
}

class _hospitalState extends State<hospital> {
  List<Map<String, dynamic>> _hospitalList = [];

  Future<void> fetchHospital() async {
    try {
      final response =
          await supabase.from('Guest_tbl_vetinaryhospital').select();

      setState(() {
        _hospitalList = response;
      });
    } catch (e) {
      print('Exception during fetch: $e');
    }
  }

  String? selectedDistrict;
  String? selectedPlace;

  List<Map<String, dynamic>> districtList = [];
  Future<void> fetchDistrict() async {
    try {
      final response = await supabase.from('Admin_tbl_district').select();

      setState(() {
        districtList = response;
      });
    } catch (e) {
      print('Exception during fetch: $e');
    }
  }

  List<Map<String, dynamic>> placeList = [];
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
      print('Exception during fetch: $e');
    }
  }

  @override
  void initState() {
    super.initState();
    fetchDistrict();
    fetchHospital();
  }

  void showSlotBookingModal(
      BuildContext context, Map<String, dynamic> hospital) {
    showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (BuildContext context) {
        String? selectedDate;
        String? selectedSlot;
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
                    setState(() {
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
                items: [
                  "9:00 AM - 10:00 AM",
                  "10:00 AM - 11:00 AM",
                  "11:00 AM - 12:00 PM",
                  "2:00 PM - 3:00 PM",
                ].map((slot) {
                  return DropdownMenuItem(
                    value: slot,
                    child: Text(slot),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    selectedSlot = value;
                  });
                },
              ),
              SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context); // Close the modal
                  // Submit booking logic here
                  print(
                      "Booked ${hospital['vetinaryhospital_name']} for $selectedDate at $selectedSlot");
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.deepOrange,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: Text("Submit", style: TextStyle(color: Colors.white)),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Hospital List',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.deepOrange.shade900,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: Colors.deepOrange, width: 1),
                    ),
                    padding: EdgeInsets.symmetric(horizontal: 8),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        hint: Text('Select District'),
                        value: selectedDistrict,
                        onChanged: (newValue) {
                          setState(() {
                            selectedDistrict = newValue;
                            fetchPlace(newValue!);
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
                ),
                SizedBox(width: 8),
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: Colors.deepOrange, width: 1),
                    ),
                    padding: EdgeInsets.symmetric(horizontal: 8),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        hint: Text('Select Place'),
                        value: selectedPlace,
                        onChanged: (newValue) {
                          setState(() {
                            selectedPlace = newValue;
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
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: _hospitalList.length,
              itemBuilder: (context, index) {
                final hospital = _hospitalList[index];
                return Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 8.0, vertical: 4.0),
                  child: Card(
                    elevation: 4,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: ListTile(
                      title: Text(
                        hospital['vetinaryhospital_name']!,
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      leading: Icon(
                        Icons.local_hospital,
                        color: Colors.deepOrange,
                      ),
                      trailing: ElevatedButton(
                        onPressed: () =>
                            showSlotBookingModal(context, hospital),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.deepOrange,
                        ),
                        child: Text("Book Slot",
                            style: TextStyle(color: Colors.white)),
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
