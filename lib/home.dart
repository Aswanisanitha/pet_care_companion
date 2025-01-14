import 'package:flutter/material.dart';
import 'package:pet_care_companion/account.dart';
import 'package:pet_care_companion/activity.dart';
import 'package:pet_care_companion/allpet.dart';
import 'package:pet_care_companion/food.dart';
import 'package:pet_care_companion/hospital.dart';
import 'package:pet_care_companion/traning.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: HomeScreen(),
    );
  }
}

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;

  // List of pages for navigation
  final List<Widget> _pages = [
    HomePage(),
    allpet(),
    account(),
  ];

  // Method to handle tab changes
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
        selectedItemColor:
            Colors.deepOrange.shade900, // Deep Orange selected color
        unselectedItemColor: Colors.grey, // Grey for unselected items
        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: "Home",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.pets),
            label: "Pets",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: "Account",
          ),
        ],
      ),
    );
  }
}

/// HomePage
class HomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: SingleChildScrollView(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Welcome Section
            Text(
              "Welcome, name,",
              style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
            ),
            Text("What are you looking for?", style: TextStyle(fontSize: 18)),
            SizedBox(height: 30),
            // Service Grid
            GridView.count(
              crossAxisCount: 2,
              crossAxisSpacing: 20,
              mainAxisSpacing: 20,
              shrinkWrap: true,
              physics: NeverScrollableScrollPhysics(),
              children: [
                ServiceContainer(
                  icon: Icons.local_hospital,
                  label: "Veterinary",
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => hospital()),
                    );
                  },
                ),
                ServiceContainer(
                  icon: Icons.local_activity,
                  label: "Activity",
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => Activity()),
                    );
                  },
                ),
                ServiceContainer(
                  icon: Icons.food_bank,
                  label: "Pet Food",
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => food()),
                    );
                  },
                ),
                ServiceContainer(
                  icon: Icons.fitness_center,
                  label: "Training",
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => traning()),
                    );
                  },
                ),
              ],
            ),
            SizedBox(height: 30),
            // Upcoming Vaccine Section
            Text(
              "Upcoming Vaccine",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 20),
            TaskCard(
              title: "Vet Checkup",
              time: "Scheduled at 10:00 AM",
              status: "On Time",
            ),
          ],
        ),
      ),
    );
  }
}

/// ServiceContainer Widget
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
              child: Icon(
                icon,
                size: 30,
                color: Colors.white,
              ),
            ),
            SizedBox(height: 10),
            Text(
              label,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// TaskCard Widget
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
    return Container(
      margin: EdgeInsets.only(bottom: 10),
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.3),
            spreadRadius: 2,
            blurRadius: 5,
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 5),
              Text(
                time,
                style: TextStyle(fontSize: 14, color: Colors.grey),
              ),
            ],
          ),
          Text(
            status,
            style: TextStyle(
              fontSize: 14,
              color: status == "Delayed" ? Colors.red : Colors.green,
            ),
          ),
        ],
      ),
    );
  }
}
