import 'package:flutter/material.dart';
import 'package:pet_care_companion/start.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

Future<void> main() async {
  await Supabase.initialize(
    url: 'https://kbumqqlifjsshvemrwde.supabase.co',
    anonKey:
        'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImtidW1xcWxpZmpzc2h2ZW1yd2RlIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NDE1MDgxMTgsImV4cCI6MjA1NzA4NDExOH0.pADWZS_A_mnP98KI9Yc_KQw_uazj79vpiIlFqq-w8Z8',
  );
  runApp(MainApp());
}

final supabase = Supabase.instance.client;

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(debugShowCheckedModeBanner: false, home: FirstPage());
  }
}
