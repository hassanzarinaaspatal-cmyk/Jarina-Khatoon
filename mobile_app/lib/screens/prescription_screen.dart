import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../config/api_config.dart';
import '../services/network_service.dart';

class PrescriptionScreen extends StatefulWidget {
  final Map<String, dynamic> visit;

  const PrescriptionScreen({super.key, required this.visit});

  @override
  State<PrescriptionScreen> createState() => _PrescriptionScreenState();
}

class _PrescriptionScreenState extends State<PrescriptionScreen> {
  final _diagnosisController = TextEditingController();
  final _prescriptionController = TextEditingController();
  bool _isSaving = false;
  String? _errorMessage;

  Future<void> _savePrescription() async {
    setState(() {
      _isSaving = true;
      _errorMessage = null;
    });

    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');
      final visitId = widget.visit['visit_id'];

      final response = await NetworkService.put(
        ApiConfig.opdPrescription(visitId),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          'diagnosis': _diagnosisController.text.trim(),
          'prescription': _prescriptionController.text.trim(),
        }),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200 && data['success'] == true) {
        if (!mounted) return;
        Navigator.pop(context, true);
      } else {
        setState(() => _errorMessage = data['message'] ?? 'Save nahi ho paya.');
      }
    } catch (e) {
      final errorMsg = NetworkService.getErrorMessage(e);
      setState(() => _errorMessage = errorMsg);
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final v = widget.visit;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Prescription"),
        backgroundColor: Colors.teal,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      v['full_name'] ?? '',
                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      "${v['hba_id'] ?? ''} • ${v['age'] ?? '-'} yrs, ${v['gender'] ?? '-'}",
                      style: const TextStyle(color: Colors.grey),
                    ),
                    if ((v['complaint'] ?? '').toString().isNotEmpty) ...[
                      const SizedBox(height: 8),
                      Text("Shikayat: ${v['complaint']}"),
                    ],
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
            const Text("Diagnosis", style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            TextField(
              controller: _diagnosisController,
              maxLines: 2,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                hintText: "Diagnosis likhein...",
              ),
            ),
            const SizedBox(height: 20),
            const Text("Prescription (Dawaiyan)", style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            TextField(
              controller: _prescriptionController,
              maxLines: 6,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                hintText: "Dawa ka naam, dose, din...",
              ),
            ),
            const SizedBox(height: 16),
            if (_errorMessage != null)
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.red.shade50,
                  border: Border.all(color: Colors.red.shade300),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  _errorMessage!,
                  style: TextStyle(color: Colors.red.shade700),
                ),
              ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                onPressed: _isSaving ? null : _savePrescription,
                style: ElevatedButton.styleFrom(backgroundColor: Colors.teal),
                child: _isSaving
                    ? const SizedBox(
                        height: 22,
                        width: 22,
                        child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                      )
                    : const Text("Save & Complete", style: TextStyle(color: Colors.white, fontSize: 16)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _diagnosisController.dispose();
    _prescriptionController.dispose();
    super.dispose();
  }
}