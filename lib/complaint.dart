import 'package:flutter/material.dart';
import 'package:pet_care_companion/main.dart';

class Complaint extends StatefulWidget {
  const Complaint({super.key});

  @override
  State<Complaint> createState() => _ComplaintState();
}

class _ComplaintState extends State<Complaint> {
  final TextEditingController _complainttitle = TextEditingController();
  final TextEditingController _complaintcontent = TextEditingController();

  Future<void> _addcomplaint() async {
    try {
      final userId = supabase.auth.currentUser?.id;
      if (userId == null) return;

      await supabase.from('User_tbl_complaint').insert({
        'complaint_title': _complainttitle.text,
        'complaint_content': _complaintcontent.text,
        'complaint_date': DateTime.now().toIso8601String(),
        'user_id_id': userId,
      });

      // Refresh the list after adding
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Successfully Added")),
      );
    } catch (e) {
      print('Complaint not added: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error adding complaint: $e")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.deepOrange.shade900,
        title: const Text('Complaint',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextFormField(
                controller: _complainttitle,
                decoration: InputDecoration(
                  labelText: "Title",
                  labelStyle: TextStyle(color: Colors.deepOrange.shade900),
                  hintText: "Enter the complaint title",
                  hintStyle: TextStyle(color: Colors.grey),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide(color: Colors.deepOrange.shade900),
                  ),
                  prefixIcon:
                      Icon(Icons.title, color: Colors.deepOrange.shade900),
                ),
              ),
              SizedBox(height: 16),
              TextFormField(
                controller: _complaintcontent,
                maxLines: 5,
                decoration: InputDecoration(
                  labelText: "Content",
                  labelStyle: TextStyle(color: Colors.deepOrange.shade900),
                  hintText: "Enter the complaint details",
                  hintStyle: TextStyle(color: Colors.grey),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide(color: Colors.deepOrange.shade900),
                  ),
                  prefixIcon: Icon(Icons.description,
                      color: Colors.deepOrange.shade900),
                ),
              ),
              SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
                  _addcomplaint();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.deepOrange.shade900,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: Text("Submit", style: TextStyle(color: Colors.white)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
