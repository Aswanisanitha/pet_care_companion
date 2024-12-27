import 'package:flutter/material.dart';
import 'package:pet_care_companion/login.dart';
import 'package:pet_care_companion/registration.dart';
import 'package:pet_care_companion/start.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    url: 'https://ggqrkktpfymtlxifalgt.supabase.co',
    anonKey:
        'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImdncXJra3RwZnltdGx4aWZhbGd0Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3MzMyOTQ1NTAsImV4cCI6MjA0ODg3MDU1MH0.eIqIJIuxCx_BQltYmCBJYy93R0pTBQ0BBNafhP7QBVU',
  );

  runApp(const MainApp());
}

final supabase = Supabase.instance.client;

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(home: FirstPage());
  }
}
