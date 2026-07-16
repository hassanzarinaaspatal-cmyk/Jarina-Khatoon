import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../config/api_config.dart';
import '../models/patient_model.dart'; // 💡 हमारे नए पेशेंट मॉडल को इम्पोर्ट किया
import '../services/network_service.dart';

class CheckinScreen extends StatefulWidget {
  const CheckinScreen({super.key});

  @override
  State<CheckinScreen> createState() => _CheckinScreenState();
}

class _CheckinScreenState extends State<CheckinScreen> {
  List<Patient> _patients = []; // 💡 dynamic से बदलकर Patient मॉडल की लिस्ट की
  List<Patient> _filtered = [];
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
              // 💡 मॉडल के वेरिएबल्स इस्तेमाल करने से स्पेलिंग मिस्टेक का खतरा खत्म
              final name = p.fullName.toLowerCase();
              final hba = p.hbaId.toLowerCase();
              final phone = (p.phone ?? '').toLowerCase();
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
          final List<dynamic> patientList = data['patients'] ?? [];
          // 💡 कच्चे JSON डेटा को सीधे Patient ऑब्जेक्ट्स में मैप किया
          _patients = patientList.map((json) => Patient.fromJson(json)).toList();
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

  Future<void> _checkin(Patient patient) async {
    setState(() => _checkingInId = patient.id);
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token') ?? '';

      final response = await NetworkService.post(
        ApiConfig.opdCheckin,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({'patient_id': patient.id}),
      );

      final data = jsonDecode(response.body);
      if (!mounted) return;

      // 💡 200 या 201 दोनों को स्वीकार किया ताकि बैकएंड के छोटे बदलावों से ऐप न टूटे
      if ((response.statusCode == 200 || response.statusCode == 201) && data['success'] == true) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('${patient.fullName} OPD line mein jud gaye. Token: ${data['token_number']}')),
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
        final isBusy = _checkingInId == p.id;
        return Card(
          margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          child: ListTile(
            title: Text(p.fullName), // 💡 क्लीनर डेटा एक्सेस
            subtitle: Text("${p.hbaId} • ${p.age ?? '-'} yrs, ${p.gender ?? '-'}"),
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
    // 💡 मेमोरी लीक से बचने के लिए पहले लिसनर को हटाया, फिर डिस्पोज़ किया
    _searchController.removeListener(_filterPatients);
    _searchController.dispose();
    super.dispose();
  }
}
