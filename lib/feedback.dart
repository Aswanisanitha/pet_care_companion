import 'package:flutter/material.dart';
import 'package:pet_care_companion/main.dart';

class feedback extends StatefulWidget {
  const feedback({super.key});

  @override
  State<feedback> createState() => _feedbackState();
}

class _feedbackState extends State<feedback> {
  final TextEditingController _feedbackController = TextEditingController();
  List<Map<String, dynamic>> feedbackList = [];

  Future<void> _addFeedback() async {
    try {
      final userId = supabase.auth.currentUser?.id;
      if (userId == null) return;

      await supabase.from('User_tbl_feedback').insert({
        'feedback_content': _feedbackController.text,
        'feedback_date': DateTime.now().toIso8601String(),
        'user_id_id': userId,
      });

      _feedbackController.clear();
      fetchFeedback(); // Refresh the list after adding
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Successfully Added")),
      );
    } catch (e) {
      print('Feedback not added: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error adding feedback: $e")),
      );
    }
  }

  Future<void> fetchFeedback() async {
    try {
      final userId = supabase.auth.currentUser?.id;

      if (userId != null) {
        final response = await supabase
            .from('User_tbl_feedback')
            .select()
            .eq('user_id_id', userId)
            .order('feedback_date', ascending: false);

        setState(() {
          feedbackList = List<Map<String, dynamic>>.from(response);
        });
      }
    } catch (e) {
      print('Error fetching feedback: $e');
    }
  }

  @override
  void initState() {
    super.initState();
    fetchFeedback();
  }

  @override
  void dispose() {
    _feedbackController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.deepOrange.shade900,
        title: const Text(
          'Feedback',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Form(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextFormField(
                    controller: _feedbackController,
                    maxLines: 5,
                    decoration: InputDecoration(
                      labelText: "Feedback",
                      labelStyle: TextStyle(color: Colors.deepOrange.shade900),
                      hintText: "Provide Your Feedback",
                      hintStyle: const TextStyle(color: Colors.grey),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide:
                            BorderSide(color: Colors.deepOrange.shade900),
                      ),
                      prefixIcon: Icon(Icons.description,
                          color: Colors.deepOrange.shade900),
                    ),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: _addFeedback,
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
                ],
              ),
            ),
            const SizedBox(height: 24),
            Text(
              "Feedback History",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.deepOrange.shade900,
              ),
            ),
            const SizedBox(height: 8),
            Expanded(
              child: feedbackList.isEmpty
                  ? const Center(child: Text('No feedback yet'))
                  : ListView.builder(
                      itemCount: feedbackList.length,
                      itemBuilder: (context, index) {
                        final feedback = feedbackList[index];
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
                                  feedback['feedback_date']?.toString() ??
                                      'N/A',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.grey.shade600,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  feedback['feedback_content']?.toString() ??
                                      'N/A',
                                  style: const TextStyle(fontSize: 16),
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
      ),
    );
  }
}
