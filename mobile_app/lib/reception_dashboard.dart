import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart'; // 💡 यह ज़रूरी है
import 'config/api_config.dart';
import 'patient_registration.dart';
import 'login_screen.dart';
import 'checkin_screen.dart';
import 'doctor_dashboard.dart';
import 'services/network_service.dart';

class ReceptionDashboard extends StatefulWidget {
  const ReceptionDashboard({super.key});

  @override
  State<ReceptionDashboard> createState() => _ReceptionDashboardState();
}

class _ReceptionDashboardState extends State<ReceptionDashboard> {
  List<dynamic> _queue = [];
  bool _isLoading = true;
  String _fullName = '';
  String _role = '';

  @override
  void initState() {
    super.initState();
    _loadUser();
    _fetchQueue();
  }

  // 💡 कॉल करने का फंक्शन
  Future<void> _makePhoneCall(String phoneNumber) async {
    final Uri launchUri = Uri(scheme: 'tel', path: phoneNumber);
    if (await canLaunchUrl(launchUri)) {
      await launchUrl(launchUri);
    }
  }

  // 💡 व्हाट्सएप करने का फंक्शन
  Future<void> _openWhatsApp(String phoneNumber) async {
    final Uri url = Uri.parse("https://wa.me/$phoneNumber");
    if (await canLaunchUrl(url)) {
      await launchUrl(url);
    }
  }

  Future<void> _loadUser() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _fullName = prefs.getString('full_name') ?? '';
      _role = prefs.getString('role') ?? '';
    });
  }

  Future<void> _fetchQueue() async {
    if (!mounted) return;
    setState(() => _isLoading = true);
    
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token') ?? '';

      final response = await NetworkService.get(
        ApiConfig.todayQueue,
        headers: {'Authorization': 'Bearer $token'},
      );

      if (!mounted) return;

      final data = jsonDecode(response.body);
      if (response.statusCode == 200 && data != null && data['success'] == true) {
        setState(() {
          _queue = data['queue'] ?? [];
        });
      }
    } catch (e) {
      print("❌ Queue fetch error: $e");
      if (mounted) {
        setState(() => _queue = []);
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    if (!mounted) return;
    Navigator.pushReplacement(
      context, 
      MaterialPageRoute(builder: (_) => const LoginScreen())
    );
  }

  @override
  Widget build(BuildContext context) {
    final bool showDoctorAccess = _role.toLowerCase() == 'admin' || _role.toLowerCase() == 'doctor';

    return Scaffold(
      appBar: AppBar(
        title: const Text("रिसेप्शन डैशबोर्ड"),
        actions: [
          IconButton(icon: const Icon(Icons.logout), onPressed: _logout),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _fetchQueue,
        child: Column(
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              color: Colors.teal.shade50,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("नमस्ते, $_fullName", style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  Text("पद (Role): $_role", style: const TextStyle(fontSize: 13, color: Colors.grey)),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 12, 12, 0),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const PatientRegistrationScreen()),
                    ).then((_) => _fetchQueue());
                  },
                  icon: const Icon(Icons.person_add),
                  label: const Text("नया मरीज़ रजिस्टर करें"),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.teal,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 8, 12, 0),
              child: SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const CheckinScreen()),
                    ).then((_) => _fetchQueue());
                  },
                  icon: const Icon(Icons.playlist_add_check),
                  label: const Text("मरीज़ को OPD लाइन में जोड़ें"),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.teal,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                ),
              ),
            ),
            if (showDoctorAccess)
              Padding(
                padding: const EdgeInsets.fromLTRB(12, 8, 12, 0),
                child: SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const DoctorDashboard()),
                      ).then((_) => _fetchQueue());
                    },
                    icon: const Icon(Icons.medical_services),
                    label: const Text("Doctor Dashboard खोलें"),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.indigo,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                  ),
                ),
              ),
            const Padding(
              padding: EdgeInsets.fromLTRB(16, 16, 16, 0),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text("आज की OPD लाइन", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              ),
            ),
            const SizedBox(height: 8),
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : _queue.isEmpty
                      ? const Center(child: Text("आज कोई मरीज़ नहीं आया अभी तक।"))
                      : ListView.builder(
                          itemCount: _queue.length,
                          itemBuilder: (context, index) {
                            final item = _queue[index];
                            Color statusColor = Colors.orange;
                            if (item['status'] == 'Completed') statusColor = Colors.green;
                            if (item['status'] == 'Cancelled') statusColor = Colors.red;

                            return Card(
                              margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                              child: ListTile(
                                leading: CircleAvatar(
                                  backgroundColor: Colors.teal.shade700,
                                  child: Text('${item['token_number'] ?? index + 1}', style: const TextStyle(color: Colors.white)),
                                ),
                                title: Text(item['full_name'] ?? 'अज्ञात मरीज़'),
                                subtitle: Text("${item['hba_id'] ?? 'नो ID'} | ${item['age'] ?? '-'} साल | ${item['gender'] ?? '-'}"),
                                trailing: Row( // 💡 यहाँ बटन जोड़े हैं
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    IconButton(
                                      icon: const Icon(Icons.call, color: Colors.green, size: 20),
                                      onPressed: () => _makePhoneCall(item['phone'] ?? ''),
                                    ),
                                    IconButton(
                                      icon: const Icon(Icons.message, color: Colors.blue, size: 20),
                                      onPressed: () => _openWhatsApp(item['phone'] ?? ''),
                                    ),
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                      decoration: BoxDecoration(
                                        color: statusColor.withOpacity(0.1),
                                        borderRadius: BorderRadius.circular(4),
                                      ),
                                      child: Text(
                                        item['status'] ?? 'Waiting',
                                        style: TextStyle(color: statusColor, fontWeight: FontWeight.bold, fontSize: 10),
                                      ),
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
