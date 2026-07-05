import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'config/api_config.dart';
import 'patient_registration.dart';
import 'login_screen.dart';

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

  Future<void> _loadUser() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _fullName = prefs.getString('full_name') ?? '';
      _role = prefs.getString('role') ?? '';
    });
  }

  Future<void> _fetchQueue() async {
    setState(() => _isLoading = true);
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token') ?? '';

      final response = await http.get(
        Uri.parse(ApiConfig.todayQueue),
        headers: {'Authorization': 'Bearer $token'},
      );

      final data = jsonDecode(response.body);
      if (response.statusCode == 200 && data['success'] == true) {
        setState(() => _queue = data['queue']);
      }
    } catch (e) {
      // Silently ignore for now; could show error banner
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    if (!mounted) return;
    Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const LoginScreen()));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("रिसेप्शन डैशबोर्ड"),
        backgroundColor: Colors.teal,
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
                  Text("Role: $_role", style: const TextStyle(fontSize: 13, color: Colors.grey)),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(12),
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
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
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
                            return Card(
                              margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                              child: ListTile(
                                leading: CircleAvatar(
                                  backgroundColor: Colors.teal,
                                  child: Text('${item['token_number']}', style: const TextStyle(color: Colors.white)),
                                ),
                                title: Text(item['full_name'] ?? ''),
                                subtitle: Text("${item['hba_id']} | ${item['age'] ?? '-'} yrs | ${item['gender'] ?? '-'}"),
                                trailing: Text(item['status'] ?? ''),
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
