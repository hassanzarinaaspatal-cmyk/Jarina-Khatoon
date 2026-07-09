import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../config/api_config.dart';
import '../services/network_service.dart';

class CheckinScreen extends StatefulWidget {
  const CheckinScreen({super.key});

  @override
  State<CheckinScreen> createState() => _CheckinScreenState();
}

class _CheckinScreenState extends State<CheckinScreen> {
  List<dynamic> _patients = [];
  List<dynamic> _filtered = [];
  bool _isLoading = true;
  String? _errorMessage;
  final _searchController = TextEditingController();
  int? _checkingInId;

  @override
  void initState() {
    super.initState();
    _loadPatients();
    _searchController.addListener(_filterPatients);
  }

  void _filterPatients() {
    final q = _searchController.text.trim().toLowerCase();
    setState(() {
      _filtered = q.isEmpty
          ? _patients
          : _patients.where((p) {
              final name = (p['full_name'] ?? '').toString().toLowerCase();
              final hba = (p['hba_id'] ?? '').toString().toLowerCase();
              final phone = (p['phone'] ?? '').toString().toLowerCase();
              return name.contains(q) || hba.contains(q) || phone.contains(q);
            }).toList();
    });
  }

  Future<void> _loadPatients() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token') ?? '';

      final response = await NetworkService.get(
        ApiConfig.patients,
        headers: {'Authorization': 'Bearer $token'},
      );

      final data = jsonDecode(response.body);
      if (response.statusCode == 200 && data['success'] == true) {
        setState(() {
          _patients = data['patients'] ?? [];
          _filtered = _patients;
        });
      } else {
        setState(() => _errorMessage = data['message'] ?? 'Patients load nahi hue.');
      }
    } catch (e) {
      setState(() => _errorMessage = NetworkService.getErrorMessage(e));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _checkin(Map patient) async {
    setState(() => _checkingInId = patient['id']);
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token') ?? '';

      final response = await NetworkService.post(
        ApiConfig.opdCheckin,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({'patient_id': patient['id']}),
      );

      final data = jsonDecode(response.body);
      if (!mounted) return;

      if (response.statusCode == 201 && data['success'] == true) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('${patient['full_name']} OPD line mein jud gaye. Token: ${data['token_number']}')),
        );
        Navigator.pop(context, true);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(data['message'] ?? 'Check-in fail ho gaya.')),
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(NetworkService.getErrorMessage(e))),
      );
    } finally {
      if (mounted) setState(() => _checkingInId = null);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("OPD लाइन में जोड़ें"),
        backgroundColor: Colors.teal,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12),
            child: TextField(
              controller: _searchController,
              decoration: const InputDecoration(
                hintText: "नाम, HBA ID या फ़ोन से खोजें...",
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(),
              ),
            ),
          ),
          Expanded(child: _buildBody()),
        ],
      ),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_errorMessage != null) {
      return Center(child: Text(_errorMessage!, style: TextStyle(color: Colors.red.shade700)));
    }
    if (_filtered.isEmpty) {
      return const Center(child: Text("कोई मरीज़ नहीं मिला।"));
    }
    return ListView.builder(
      itemCount: _filtered.length,
      itemBuilder: (context, index) {
        final p = _filtered[index];
        final isBusy = _checkingInId == p['id'];
        return Card(
          margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          child: ListTile(
            title: Text(p['full_name'] ?? ''),
            subtitle: Text("${p['hba_id'] ?? ''} • ${p['age'] ?? '-'} yrs, ${p['gender'] ?? '-'}"),
            trailing: isBusy
                ? const SizedBox(
                    width: 20, height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : ElevatedButton(
                    onPressed: () => _checkin(p),
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.teal),
                    child: const Text("जोड़ें", style: TextStyle(color: Colors.white)),
                  ),
          ),
        );
      },
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
}