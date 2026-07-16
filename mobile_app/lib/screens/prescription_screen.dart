import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'config_api.dart'; // सुनिश्चित करें कि यह फाइल सही है
import 'network_service.dart'; // सुनिश्चित करें कि यह फाइल सही है

class PrescriptionScreen extends StatefulWidget {
  const PrescriptionScreen({Key? key}) : super(key: key);

  @override
  _PrescriptionScreenState createState() => _PrescriptionScreenState();
}

class _PrescriptionScreenState extends State<PrescriptionScreen> {
  final TextEditingController _diagnosisController = TextEditingController();
  final TextEditingController _prescriptionController = TextEditingController();
  bool _isLoading = false;
  String? _errorMessage;

  Future<void> _submitPrescription() async {
    final diagnosis = _diagnosisController.text;
    final prescription = _prescriptionController.text;

    if (diagnosis.isEmpty || prescription.isEmpty) {
      setState(() {
        _errorMessage = "Diagnosis and Prescription are required";
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');

      // यहाँ हम .post का उपयोग कर रहे हैं
      final response = await NetworkService.post(
        ApiConfig.addPrescription,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          'diagnosis': diagnosis,
          'prescription': prescription,
        }),
      );

      if (response.statusCode == 200) {
        Navigator.pop(context); // सफल होने पर वापस जाएं
      } else {
        setState(() {
          _errorMessage = "Error: ${response.body}";
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Prescription')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _diagnosisController,
              decoration: const InputDecoration(labelText: 'Diagnosis'),
            ),
            TextField(
              controller: _prescriptionController,
              decoration: const InputDecoration(labelText: 'Prescription'),
            ),
            const SizedBox(height: 20),
            if (_errorMessage != null)
              Text(_errorMessage!, style: const TextStyle(color: Colors.red)),
            const SizedBox(height: 20),
            _isLoading
                ? const CircularProgressIndicator()
                : ElevatedButton(
                    onPressed: _submitPrescription,
                    child: const Text('Submit'),
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
