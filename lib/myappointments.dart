import 'package:flutter/material.dart';
import 'package:pet_care_companion/main.dart';

class Appointment extends StatefulWidget {
  const Appointment({super.key});

  @override
  State<Appointment> createState() => _AppointmentState();
}

class _AppointmentState extends State<Appointment> {
  List<Map<String, dynamic>> appointments = [];

  Future<void> fetchAppointments() async {
    try {
      final userId = supabase.auth.currentUser?.id;

      if (userId != null) {
        final response = await supabase
            .from('User_tbl_appoinment')
            .select(
                '*, Vetinaryhospital_tbl_slot(*, Guest_tbl_vetinaryhospital(*))')
            .eq('user_id_id', userId);

        setState(() {
          appointments = List<Map<String, dynamic>>.from(response);
        });
      }
    } catch (e) {
      print('Error fetching appointment Details: $e');
    }
  }

  @override
  void initState() {
    super.initState();
    fetchAppointments();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.deepOrange.shade900,
        title: const Text(
          'Appointments',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: appointments.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
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
                            appointment['Vetinaryhospital_tbl_slot']
                                            ?['Guest_tbl_vetinaryhospital']
                                        ?['vetinaryhospital_name']
                                    ?.toString() ??
                                'N/A',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                              color: Colors.deepOrange.shade900,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            "Contact: ${appointment['Vetinaryhospital_tbl_slot']?['Guest_tbl_vetinaryhospital']?['vetinaryhospital_contact']?.toString() ?? 'N/A'}",
                          ),
                          Text(
                            "Address: ${appointment['Vetinaryhospital_tbl_slot']?['Guest_tbl_vetinaryhospital']?['vetinaryhospital_address']?.toString() ?? 'N/A'}",
                          ),
                          Text(
                            "Date: ${appointment['appoinment_Fordate']?.toString() ?? 'N/A'}",
                          ),
                          Text(
                            "From Time: ${appointment['Vetinaryhospital_tbl_slot']['slot_fromtime']?.toString() ?? 'N/A'}",
                          ),
                          Text(
                            "To Time: ${appointment['Vetinaryhospital_tbl_slot']['slot_totime']?.toString() ?? 'N/A'}",
                          ),
                          Text(
                            "Token Number: ${appointment['appoinment_token']?.toString() ?? 'N/A'}",
                          ),
                          const SizedBox(height: 8),
                          // Text(
                          //   "Status: ${appointment['appoinment_status']?.toString() ?? 'N/A'}",
                          //   style: TextStyle(
                          //     fontWeight: FontWeight.bold,
                          //     color: appointment['appoinment_status'] ==
                          //             'Confirmed'
                          //         ? Colors.green
                          //         : Colors.orange,
                          //   ),
                          // ),
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
