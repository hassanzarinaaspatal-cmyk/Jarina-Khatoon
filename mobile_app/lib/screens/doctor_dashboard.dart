import 'package:flutter/material.dart';

class DoctorDashboard extends StatelessWidget {
  const DoctorDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Doctor Dashboard"),
        backgroundColor: Colors.teal,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [

            Card(
              child: ListTile(
                leading: const Icon(Icons.people, color: Colors.blue),
                title: const Text("Today's Patients"),
                subtitle: const Text("View OPD Queue"),
                onTap: () {},
              ),
            ),

            Card(
              child: ListTile(
                leading: const Icon(Icons.medical_services,
                    color: Colors.green),
                title: const Text("New Prescription"),
                subtitle: const Text("Create Prescription"),
                onTap: () {},
              ),
            ),

            Card(
              child: ListTile(
                leading: const Icon(Icons.science,
                    color: Colors.orange),
                title: const Text("Lab Reports"),
                subtitle: const Text("View Patient Reports"),
                onTap: () {},
              ),
            ),

            Card(
              child: ListTile(
                leading: const Icon(Icons.search,
                    color: Colors.purple),
                title: const Text("Search Patient"),
                subtitle: const Text("Find Patient Record"),
                onTap: () {},
              ),
            ),

            Card(
              child: ListTile(
                leading: const Icon(Icons.logout,
                    color: Colors.red),
                title: const Text("Logout"),
                onTap: () {
                  Navigator.pop(context);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}