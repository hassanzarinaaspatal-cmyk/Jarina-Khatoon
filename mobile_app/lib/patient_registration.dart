import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:image_picker/image_picker.dart';
import 'package:file_picker/file_picker.dart';

import 'config/api_config.dart';
import 'services/network_service.dart';

class PatientRegistrationScreen extends StatefulWidget {
  const PatientRegistrationScreen({super.key});

  @override
  State<PatientRegistrationScreen> createState() => _PatientRegistrationScreenState();
}

class _PatientRegistrationScreenState extends State<PatientRegistrationScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _ageController = TextEditingController();
  final _phoneController = TextEditingController();
  final _addressController = TextEditingController();
  final _guardianController = TextEditingController();
  
  String _gender = 'Male';
  bool _isSaving = false;

  final ImagePicker _picker = ImagePicker();
  File? _patientPhoto;
  File? _document1;

  // रजिस्ट्रेशन का असली फंक्शन
  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    
    setState(() => _isSaving = true);
    
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token') ?? '';

      // API को डेटा भेज रहे हैं
      final response = await NetworkService.post(
        ApiConfig.register,
        headers: {'Authorization': 'Bearer $token'},
        body: {
          "full_name": _nameController.text,
          "age": _ageController.text,
          "gender": _gender,
          "phone": _phoneController.text,
          "guardian_name": _guardianController.text,
          "address": _addressController.text,
        },
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("मरीज़ सफलता से रजिस्टर हो गया!")));
        Navigator.pop(context); 
      } else {
        throw Exception("सर्वर एरर: ${response.statusCode}");
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("रजिस्ट्रेशन में दिक्कत: $e")));
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("नया मरीज़ रजिस्ट्रेशन"), backgroundColor: Colors.teal, foregroundColor: Colors.white),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _nameController, 
                decoration: const InputDecoration(labelText: "पूरा नाम *", border: OutlineInputBorder()),
                validator: (val) => val!.isEmpty ? "नाम लिखना ज़रूरी है" : null,
              ),
              const SizedBox(height: 12),
              
              Row(children: [
                Expanded(child: TextFormField(controller: _ageController, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: "उम्र", border: OutlineInputBorder()))),
                const SizedBox(width: 12),
                Expanded(child: DropdownButtonFormField<String>(
                  value: _gender, 
                  decoration: const InputDecoration(labelText: "लिंग", border: OutlineInputBorder()), 
                  items: const [DropdownMenuItem(value: 'Male', child: Text('पुरुष')), DropdownMenuItem(value: 'Female', child: Text('महिला'))], 
                  onChanged: (v) => setState(() => _gender = v!),
                )),
              ]),
              const SizedBox(height: 12),
              TextFormField(controller: _phoneController, keyboardType: TextInputType.phone, decoration: const InputDecoration(labelText: "मोबाइल नंबर", border: OutlineInputBorder())),
              const SizedBox(height: 12),
              TextFormField(controller: _guardianController, decoration: const InputDecoration(labelText: "पिता/पति का नाम", border: OutlineInputBorder())),
              const SizedBox(height: 12),
              TextFormField(controller: _addressController, maxLines: 2, decoration: const InputDecoration(labelText: "पता", border: OutlineInputBorder())),
              
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity, height: 50, 
                child: ElevatedButton(
                  onPressed: _isSaving ? null : _submit, 
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.teal), 
                  child: _isSaving ? const CircularProgressIndicator(color: Colors.white) : const Text("रजिस्टर करें", style: TextStyle(color: Colors.white, fontSize: 16)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _ageController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    _guardianController.dispose();
    super.dispose();
  }
}
