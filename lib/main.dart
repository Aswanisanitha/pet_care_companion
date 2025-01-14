import 'package:flutter/material.dart';
import 'package:pet_care_companion/account.dart';
import 'package:pet_care_companion/activity.dart';
import 'package:pet_care_companion/addpet.dart';
import 'package:pet_care_companion/addphoto.dart';
import 'package:pet_care_companion/allpet.dart';
import 'package:pet_care_companion/changepswd.dart';

import 'package:pet_care_companion/complaint.dart';
import 'package:pet_care_companion/editprofile.dart';
import 'package:pet_care_companion/feedback.dart';
import 'package:pet_care_companion/food.dart';
import 'package:pet_care_companion/home.dart';
import 'package:pet_care_companion/hospital.dart';
import 'package:pet_care_companion/login.dart';
import 'package:pet_care_companion/myappointments.dart';
import 'package:pet_care_companion/mycomplaints.dart';
import 'package:pet_care_companion/myprofile.dart';
import 'package:pet_care_companion/petgallery.dart';
import 'package:pet_care_companion/petprofile.dart';
import 'package:pet_care_companion/registration.dart';
import 'package:pet_care_companion/start.dart';
import 'package:pet_care_companion/traning.dart';
import 'package:pet_care_companion/vaccination.dart';
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
    return MaterialApp(home: HomeScreen());
  }
}
