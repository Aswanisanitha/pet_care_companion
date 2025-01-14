import 'package:flutter/material.dart';

class ComplaintView extends StatelessWidget {
  const ComplaintView({super.key});

  @override
  Widget build(BuildContext context) {
    final List<Map<String, String>> complaints = [
      {
        'name': 'John Doe',
        'email': 'john.doe@example.com',
        'title': 'Service Delay',
        'content': 'The service was delayed by 2 hours.',
        'reply': 'We apologize for the inconvenience.',
        'date': '2024-12-29'
      },
      {
        'name': 'Jane Smith',
        'email': 'jane.smith@example.com',
        'title': 'Unclean Premises',
        'content': 'The premises were not clean during my visit.',
        'reply': 'Thank you for the feedback. We will address this issue.',
        'date': '2024-12-28'
      },
    ];

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.deepOrange.shade900,
        title: const Text('Complaint History',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView.builder(
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
                      "Name: ${complaint['name']}",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.deepOrange.shade900,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text("Email: ${complaint['email']}",
                        style: TextStyle(color: Colors.grey.shade600)),
                    SizedBox(height: 4),
                    Text("Title: ${complaint['title']}",
                        style: TextStyle(fontWeight: FontWeight.bold)),
                    SizedBox(height: 8),
                    Text("Content: ${complaint['content']}",
                        style: TextStyle(fontSize: 16)),
                    SizedBox(height: 8),
                    Text(
                      "Reply: ${complaint['reply']}",
                      style: TextStyle(fontSize: 16, color: Colors.green),
                    ),
                    SizedBox(height: 8),
                    Text(
                      "Date: ${complaint['date']}",
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
