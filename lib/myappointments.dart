import 'package:flutter/material.dart';
import 'package:pet_care_companion/main.dart';

class appointment extends StatefulWidget {
  const appointment({super.key});

  @override
  State<appointment> createState() => _appointmentState();
}

class _appointmentState extends State<appointment> {
  List<Map<String, dynamic>> appointments = [];
  Future<void> fetchappointments() async {
    try {
      final response = await supabase.from('User_tbl_appointment').select();
      setState(() {
        appointments = List<Map<String, dynamic>>.from(response);
      });
    } catch (e) {
      print('Error fetching appointment: $e');
    }
  }

  @override
  void initState() {
    super.initState();
    fetchappointments();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.deepOrange.shade900,
        title: const Text('Appointments',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
      ),
      body: ListView.builder(
        itemCount: appointments.length,
        itemBuilder: (context, index) {
          final appointment = appointments[index];
          return Padding(
            padding: const EdgeInsets.all(8.0),
            child: Card(
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      appointment['hospitalName']!,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: Colors.deepOrange.shade900,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text("Contact: ${appointment['contact']}"),
                    Text("Address: ${appointment['address']}"),
                    Text("Date: ${appointment['appointment_Fordate']}"),
                    Text("Time: ${appointment['time']}"),
                    SizedBox(height: 8),
                    Text(
                      "Status: ${appointment['status']}",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: appointment['status'] == 'Confirmed'
                            ? Colors.green
                            : Colors.orange,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
