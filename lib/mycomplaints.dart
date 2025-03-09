import 'package:flutter/material.dart';
import 'package:pet_care_companion/main.dart';

class ComplaintView extends StatefulWidget {
  const ComplaintView({super.key});

  @override
  State<ComplaintView> createState() => _ComplaintViewState();
}

class _ComplaintViewState extends State<ComplaintView> {
  List<Map<String, dynamic>> complaints =
      []; // Changed to dynamic to handle various types

  Future<void> fetchComplaints() async {
    try {
      final userId = supabase.auth.currentUser?.id;

      if (userId == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('No user logged in')),
        );
        return;
      }

      final response = await supabase.from('User_tbl_complaint').select('''
            *,
            Guest_tbl_userreg:user_id_id (user_name, user_email)
          ''').eq('user_id_id', userId);

      setState(() {
        complaints = List<Map<String, dynamic>>.from(response);
      });
    } catch (e) {
      print('Error fetching complaint details: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error fetching complaints: $e')),
        );
      }
    }
  }

  @override
  void initState() {
    super.initState();
    fetchComplaints();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.deepOrange.shade900,
        title: const Text(
          'Complaint History',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: complaints.isEmpty
            ? const Center(
                child: Text(
                  'No complaints found',
                  style: TextStyle(fontSize: 16, color: Colors.grey),
                ),
              )
            : ListView.builder(
                itemCount: complaints.length,
                itemBuilder: (context, index) {
                  final complaint = complaints[index];
                  return Card(
                    elevation: 4,
                    margin: const EdgeInsets.symmetric(vertical: 8),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Name: ${complaint['Guest_tbl_userreg']?['user_name'] ?? 'N/A'}",
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.deepOrange.shade900,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            "Email: ${complaint['Guest_tbl_userreg']?['user_email'] ?? 'N/A'}",
                            style: TextStyle(color: Colors.grey.shade600),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            "Title: ${complaint['complaint_title'] ?? 'No title'}",
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            "Content: ${complaint['complaint_content'] ?? 'No content'}",
                            style: const TextStyle(fontSize: 16),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            "Reply: ${complaint['complaint_reply'] ?? 'No reply yet'}",
                            style: const TextStyle(
                                fontSize: 16, color: Colors.green),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            "Date: ${complaint['complaint_date']?.toString() ?? 'N/A'}",
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.grey.shade600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
      ),
    );
  }
}
