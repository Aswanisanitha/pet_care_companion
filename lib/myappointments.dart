import 'package:flutter/material.dart';

class appointment extends StatelessWidget {
  const appointment({super.key});

  @override
  Widget build(BuildContext context) {
    // Sample appointment data
    final appointments = [
      {
        'hospitalName': 'City Hospital',
        'contact': '+1 123 456 7890',
        'address': '123 Main Street, NY',
        'date': '2024-12-31',
        'time': '10:00 AM',
        'status': 'Confirmed'
      },
      {
        'hospitalName': 'Metro Care',
        'contact': '+1 987 654 3210',
        'address': '456 Elm Street, LA',
        'date': '2024-12-30',
        'time': '2:00 PM',
        'status': 'Pending'
      },
    ];

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
                    Text("Date: ${appointment['date']}"),
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
