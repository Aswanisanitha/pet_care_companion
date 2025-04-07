import 'package:flutter/material.dart';
import 'package:pet_care_companion/account.dart';
import 'package:pet_care_companion/activity.dart';
import 'package:pet_care_companion/allpet.dart';
import 'package:pet_care_companion/food.dart';
import 'package:pet_care_companion/hospital.dart';
import 'package:pet_care_companion/traning.dart';
import 'package:pet_care_companion/main.dart'; // Assuming this includes `supabase`

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String name = "Loading..";
  List<Map<String, dynamic>> appointments = [];
  List<Map<String, dynamic>> vaccineNotifications = [];
  int _selectedIndex = 0;

  final List<Widget> _pages = [
    HomePage(),
    allpet(),
    account(),
  ];

  @override
  void initState() {
    super.initState();
    fetchprofile();
    fetchAppointments();
    fetchVaccineNotifications();
  }

  // Future<void> fetchAllData() async {
  //   await Future.wait([
  //     fetchprofile(),
  //     fetchAppointments(),
  //     fetchVaccineNotifications(),
  //   ]);
  // }

  Future<void> fetchprofile() async {
    try {
      final userid = supabase.auth.currentUser?.id;
      if (userid != null) {
        final response = await supabase
            .from('Guest_tbl_userreg')
            .select("user_name")
            .eq('user_id', userid)
            .single();

        if (!mounted) return;
        setState(() {
          name = response['user_name'] ?? "User";
        });
      }
    } catch (e) {
      print('Error fetching Profile Details: $e');
      if (!mounted) return;
      setState(() {
        name = "User";
      });
    }
  }

  Future<void> fetchAppointments() async {
    try {
      final user = supabase.auth.currentUser;
      if (user == null) return;

      final response = await supabase
          .from('User_tbl_appoinment')
          .select(
              '*, Vetinaryhospital_tbl_slot(slot_fromtime, slot_totime, vetinaryhospital_id_id!inner(vetinaryhospital_name))')
          .eq('user_id_id', user.id)
          .order('appoinment_Fordate', ascending: true);

      if (!mounted) return;
      setState(() {
        appointments = List<Map<String, dynamic>>.from(response ?? []);
      });
    } catch (e) {
      print('Error fetching appointments: $e');
      if (!mounted) return;
      setState(() {
        appointments = [];
      });
    }
  }

  Future<void> fetchVaccineNotifications() async {
    try {
      final user = supabase.auth.currentUser;
      if (user == null) {
        print("User not logged in");
        return;
      }

      print("Fetching pets for user ID: ${user.id}");

      final petResponse = await supabase
          .from('User_tbl_pet')
          .select()
          .eq('user_id_id', user.id);

      print("Pet Response: $petResponse");

      if (petResponse.isEmpty) {
        print("No pets found");
        return;
      }

      final petIds =
          List<String>.from(petResponse.map((pet) => pet['id'].toString()));

      print("Pet IDs: $petIds");

      final response = await supabase
          .from('User_tbl_vaccinedetails')
          .select('*, pet_id_id!inner(pet_name)')
          .inFilter('pet_id_id', petIds)
          .order('vaccine_fordate', ascending: true);

      print("Vaccine Response: $response");

      if (!mounted) return;

      setState(() {
        final now = DateTime.now();
        vaccineNotifications =
            List<Map<String, dynamic>>.from(response ?? []).where((vaccine) {
          final forDate = DateTime.tryParse(vaccine['vaccine_fordate'] ?? '');
          if (forDate == null) return false;
          final diff = forDate.difference(now).inDays;
          return diff >= 0 && diff <= 7;
        }).toList();
      });
    } catch (e) {
      print('Error fetching vaccine notifications: $e');
      if (!mounted) return;
      setState(() {
        vaccineNotifications = [];
      });
    }
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        selectedItemColor: Colors.deepOrange.shade900,
        unselectedItemColor: Colors.grey,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: "Home"),
          BottomNavigationBarItem(icon: Icon(Icons.pets), label: "Pets"),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: "Account"),
        ],
      ),
    );
  }
}

class HomePage extends StatelessWidget {
  String _getStatus(String date) {
    final appointmentDate = DateTime.tryParse(date);
    if (appointmentDate == null) return "Unknown";
    final now = DateTime.now();
    if (appointmentDate.isBefore(now)) return "Missed";
    if (appointmentDate.difference(now).inDays <= 1) return "Soon";
    return "On Time";
  }

  String _getVaccineStatus(String date) {
    final vaccineDate = DateTime.tryParse(date);
    if (vaccineDate == null) return "Unknown";
    final now = DateTime.now();
    final diff = vaccineDate.difference(now).inDays;
    if (diff == 0) return "Today";
    if (diff > 0 && diff <= 7) return "Upcoming";
    return "Unknown";
  }

  @override
  Widget build(BuildContext context) {
    final state = context.findAncestorStateOfType<_HomeScreenState>();
    if (state == null) return Center(child: Text('Error loading home page.'));

    final String userName = state.name;
    final appointments = state.appointments;
    final vaccineNotifications = state.vaccineNotifications;

    return SafeArea(
      child: SingleChildScrollView(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Welcome, $userName!",
                style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
            SizedBox(height: 10),
            Text("What are you looking for?", style: TextStyle(fontSize: 18)),
            SizedBox(height: 30),
            GridView.count(
              crossAxisCount: 2,
              shrinkWrap: true,
              physics: NeverScrollableScrollPhysics(),
              crossAxisSpacing: 20,
              mainAxisSpacing: 20,
              children: [
                ServiceContainer(
                  icon: Icons.local_hospital,
                  label: "Veterinary",
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => Hospital()),
                  ),
                ),
                ServiceContainer(
                  icon: Icons.local_activity,
                  label: "Activity",
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => Activity()),
                  ),
                ),
                ServiceContainer(
                  icon: Icons.food_bank,
                  label: "Pet Food",
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => Food()),
                  ),
                ),
                ServiceContainer(
                  icon: Icons.fitness_center,
                  label: "Training",
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => Training()),
                  ),
                ),
              ],
            ),
            SizedBox(height: 30),
            Text("Reminders",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            SizedBox(height: 20),
            if (appointments.isEmpty)
              TaskCard(
                title: "No Upcoming Appointments",
                time: "Schedule one now!",
                status: "N/A",
              )
            else
              ...appointments.map((appointment) {
                final slot = appointment['Vetinaryhospital_tbl_slot'] ?? {};
                final hospital = slot['vetinaryhospital_id_id'] ?? {};
                final date = appointment['appoinment_Fordate'] ?? '';
                return TaskCard(
                  title: "Vet Visit - ${hospital['vetinaryhospital_name']}",
                  time:
                      "Scheduled on $date, ${slot['slot_fromtime']} - ${slot['slot_totime']}",
                  status: _getStatus(date),
                );
              }).toList(),
            SizedBox(height: 30),
            Text("Vaccination Notifications",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            SizedBox(height: 20),
            if (vaccineNotifications.isEmpty)
              TaskCard(
                title: "No Upcoming Vaccinations",
                time: "All up to date!",
                status: "N/A",
              )
            else
              ...vaccineNotifications.map((vaccine) {
                final pet = vaccine['pet_id_id'] ?? {};
                return TaskCard(
                  title: "${vaccine['vaccine_name']} for ${pet['pet_name']}",
                  time: "Due on ${vaccine['vaccine_fordate']}",
                  status: _getVaccineStatus(vaccine['vaccine_fordate']),
                );
              }).toList(),
          ],
        ),
      ),
    );
  }
}

class TaskCard extends StatelessWidget {
  final String title;
  final String time;
  final String status;

  const TaskCard({
    required this.title,
    required this.time,
    required this.status,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 3,
      margin: EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: ListTile(
        title: Text(title, style: TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(time),
        trailing: Text(
          status,
          style: TextStyle(
            color: status == "Today"
                ? Colors.green
                : status == "Missed"
                    ? Colors.red
                    : Colors.orange,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}

class ServiceContainer extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const ServiceContainer({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(15),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.2),
              spreadRadius: 2,
              blurRadius: 5,
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircleAvatar(
              radius: 30,
              backgroundColor: Colors.deepOrange.shade900,
              child: Icon(icon, size: 30, color: Colors.white),
            ),
            SizedBox(height: 10),
            Text(label,
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }
}
